namespace BancoSangreApi.Models;

public class Cita
{
    public int Id { get; set; }
    public int DonanteId { get; set; }
    public Donante Donante { get; set; } = null!;
    public int BancoSangreId { get; set; }
    public BancoSangre BancoSangre { get; set; } = null!;
    public DateTimeOffset FechaHora { get; set; }
}


