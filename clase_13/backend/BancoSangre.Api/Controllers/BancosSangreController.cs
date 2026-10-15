using BancoSangreApi.Data;
using BancoSangreApi.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BancoSangreApi.Controllers;

[ApiController]
[Route("api/bancos-sangre")]
public class BancosSangreController(BancoSangreDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<BancoSangreDto>>> Listar(CancellationToken ct)
    {
        // EF transforma esta consulta en SQL y devuelve solamente los campos del catálogo.
        return await db.BancosSangre.AsNoTracking().OrderBy(b => b.Id)
            .Select(b => new BancoSangreDto(b.Id, b.Nombre, b.Direccion, b.Telefono)).ToListAsync(ct);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<BancoSangreDto>> Obtener(int id, CancellationToken ct)
    {
        // Consulta el banco solicitado y responde 404 si no existe.
        var banco = await db.BancosSangre.AsNoTracking().Where(b => b.Id == id)
            .Select(b => new BancoSangreDto(b.Id, b.Nombre, b.Direccion, b.Telefono))
            .SingleOrDefaultAsync(ct);
        return banco is null ? NotFound() : Ok(banco);
    }
}


