namespace BancoSangreApi.Models;

public class Donante
{
    public int Id { get; set; }
    // El perfil completo está en Firestore; Firebase Authentication gestiona las contraseñas.
    public string FirebaseUid { get; set; } = "";
}


