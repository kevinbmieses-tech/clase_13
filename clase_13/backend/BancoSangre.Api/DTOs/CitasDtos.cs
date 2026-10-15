using System.ComponentModel.DataAnnotations;

namespace BancoSangreApi.DTOs;

public record BancoSangreDto(int Id, string Nombre, string Direccion, string Telefono);

// Solo recibe banco y fecha; la identidad del donante se obtiene del token validado.
public class GuardarCitaDto
{
    [Range(1, int.MaxValue, ErrorMessage = "Selecciona un banco de sangre válido.")]
    public int BancoSangreId { get; set; }
    [Required(ErrorMessage = "Indica la fecha y hora de la cita.")]
    public DateTimeOffset? FechaHora { get; set; }
}

// No expone el UID ni información de otros donantes.
public record CitaDto(int Id, int BancoSangreId, string BancoNombre,
    string BancoDireccion, DateTimeOffset FechaHora);


