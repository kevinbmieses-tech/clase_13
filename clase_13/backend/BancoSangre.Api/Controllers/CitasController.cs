using System.Security.Claims;
using BancoSangreApi.Data;
using BancoSangreApi.DTOs;
using BancoSangreApi.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace BancoSangreApi.Controllers;

[ApiController]
[Authorize]
[Route("api/citas")]
public class CitasController(BancoSangreDbContext db) : ControllerBase
{
    // Obtiene la identidad del token validado, nunca de un ID enviado por Flutter.
    private string Uid => User.FindFirstValue("sub")!;

    // Obtiene únicamente las citas del usuario autenticado, sin rastrear cambios para la lectura.
    private IQueryable<Cita> MisCitas() => db.Citas.AsNoTracking()
        .Where(c => c.Donante.FirebaseUid == Uid);

    // Filtra las entidades antes de proyectar la respuesta para que EF genere el SQL.
    private static IQueryable<CitaDto> Respuesta(IQueryable<Cita> citas) => citas
        .Select(c => new CitaDto(c.Id, c.BancoSangreId, c.BancoSangre.Nombre,
            c.BancoSangre.Direccion, c.FechaHora));

    private async Task<string?> Validar(GuardarCitaDto entrada, CancellationToken ct)
    {
        if (entrada.FechaHora is null || entrada.FechaHora <= DateTimeOffset.UtcNow)
            return "La fecha y hora deben ser futuras.";
        // Comprueba que el banco exista antes de guardar la cita.
        return await db.BancosSangre.AnyAsync(b => b.Id == entrada.BancoSangreId, ct)
            ? null : "El banco de sangre no existe.";
    }

    [HttpGet]
    public async Task<ActionResult<List<CitaDto>>> Listar(CancellationToken ct) =>
        await Respuesta(MisCitas().OrderBy(c => c.FechaHora)).ToListAsync(ct);

    [HttpGet("{id:int}")]
    public async Task<ActionResult<CitaDto>> Obtener(int id, CancellationToken ct)
    {
        var cita = await Respuesta(MisCitas().Where(c => c.Id == id)).SingleOrDefaultAsync(ct);
        // Una cita ajena tampoco se expone como existente.
        return cita is null ? NotFound() : Ok(cita);
    }

    [HttpPost]
    public async Task<ActionResult<CitaDto>> Crear(GuardarCitaDto entrada, CancellationToken ct)
    {
        var error = await Validar(entrada, ct);
        if (error is not null) return Problem(statusCode: 400, detail: error);
        // Crea el vínculo mínimo con Firebase solo si este usuario aún no tiene uno en SQL.
        var donante = await db.Donantes.SingleOrDefaultAsync(d => d.FirebaseUid == Uid, ct)
            ?? new Donante { FirebaseUid = Uid };
        var cita = new Cita { Donante = donante, BancoSangreId = entrada.BancoSangreId,
            FechaHora = entrada.FechaHora!.Value.ToUniversalTime() };
        db.Citas.Add(cita);
        try
        {
            // Guarda donante y cita juntos en una transacción de SQL Server.
            await db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException e) when (e.InnerException is SqlException { Number: 2601 or 2627 })
        {
            return Problem(statusCode: 409, detail: "La reserva coincide con otra operación. Revisa tus citas antes de reintentar.");
        }
        var resultado = await Respuesta(MisCitas().Where(c => c.Id == cita.Id)).SingleAsync(ct);
        return CreatedAtAction(nameof(Obtener), new { id = cita.Id }, resultado);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Modificar(int id, GuardarCitaDto entrada, CancellationToken ct)
    {
        var cita = await db.Citas.SingleOrDefaultAsync(c => c.Id == id && c.Donante.FirebaseUid == Uid, ct);
        if (cita is null) return NotFound();
        var error = await Validar(entrada, ct);
        if (error is not null) return Problem(statusCode: 400, detail: error);
        // Solo permite cambiar el banco y la fecha, manteniendo el dueño original.
        cita.BancoSangreId = entrada.BancoSangreId;
        cita.FechaHora = entrada.FechaHora!.Value.ToUniversalTime();
        // Guarda en SQL Server el cambio de banco y fecha de la cita propia.
        try { await db.SaveChangesAsync(ct); }
        catch (DbUpdateConcurrencyException) { return NotFound(); }
        catch (DbUpdateException e) when (e.InnerException is SqlException { Number: 2601 or 2627 })
        { return Problem(statusCode: 409, detail: "Ya tienes una cita en esa fecha y hora."); }
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Eliminar(int id, CancellationToken ct)
    {
        var cita = await db.Citas.SingleOrDefaultAsync(c => c.Id == id && c.Donante.FirebaseUid == Uid, ct);
        if (cita is null) return NotFound();
        // Elimina únicamente la cita propia; conserva el banco y el vínculo del donante.
        db.Citas.Remove(cita);
        // Remove marca la eliminación; SaveChangesAsync la ejecuta en SQL Server.
        try { await db.SaveChangesAsync(ct); }
        catch (DbUpdateConcurrencyException) { return NotFound(); }
        return NoContent();
    }
}


