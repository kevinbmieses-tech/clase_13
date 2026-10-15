using BancoSangreApi.Models;
using Microsoft.EntityFrameworkCore;

namespace BancoSangreApi.Data;

public class BancoSangreDbContext(DbContextOptions<BancoSangreDbContext> options) : DbContext(options)
{
    // Cada DbSet permite consultar y guardar entidades de una tabla del negocio.
    public DbSet<BancoSangre> BancosSangre => Set<BancoSangre>();
    public DbSet<Donante> Donantes => Set<Donante>();
    public DbSet<Cita> Citas => Set<Cita>();

    protected override void OnModelCreating(ModelBuilder model)
    {
        // Define las reglas que EF Core representa en las migraciones de SQL Server.
        model.Entity<BancoSangre>(b =>
        {
            b.ToTable("BancosSangre");
            b.Property(x => x.Nombre).HasMaxLength(120).IsRequired();
            b.Property(x => x.Direccion).HasMaxLength(250).IsRequired();
            b.Property(x => x.Telefono).HasMaxLength(25).IsRequired();
            // Catálogo ficticio para la práctica; no representa bancos registrados oficialmente.
            b.HasData(
                new BancoSangre { Id = 1, Nombre = "Banco de práctica - Santo Domingo",
                    Direccion = "Sede de demostración, Santo Domingo", Telefono = "809-555-0101" },
                new BancoSangre { Id = 2, Nombre = "Banco de práctica - Santiago",
                    Direccion = "Sede de demostración, Santiago", Telefono = "809-555-0102" });
        });
        model.Entity<Donante>(d =>
        {
            d.ToTable("Donantes");
            // Firebase distingue mayúsculas: SQL debe comparar el UID exactamente igual.
            d.Property(x => x.FirebaseUid).HasMaxLength(128)
                .UseCollation("Latin1_General_100_BIN2").IsRequired();
            d.HasIndex(x => x.FirebaseUid).IsUnique();
        });
        model.Entity<Cita>(c =>
        {
            c.ToTable("Citas");
            c.Property(x => x.FechaHora).HasColumnType("datetimeoffset").IsRequired();
            // Cada cita pertenece a un donante y a un banco; no hay borrado en cascada.
            c.HasOne(x => x.Donante).WithMany().HasForeignKey(x => x.DonanteId)
                .OnDelete(DeleteBehavior.Restrict);
            c.HasOne(x => x.BancoSangre).WithMany().HasForeignKey(x => x.BancoSangreId)
                .OnDelete(DeleteBehavior.Restrict);
            // Evita que la misma persona reserve dos citas a la misma fecha y hora.
            c.HasIndex(x => new { x.DonanteId, x.FechaHora }).IsUnique();
        });
    }
}


