using BancoSangreApi.Data;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
builder.Services.AddProblemDetails();

// La cadena se configura fuera del código; el ejemplo local usa Windows Authentication.
var connection = builder.Configuration.GetConnectionString("BancoSangre")
    ?? throw new InvalidOperationException("Configura ConnectionStrings:BancoSangre.");
builder.Services.AddDbContext<BancoSangreDbContext>(options => options.UseSqlServer(connection));

var project = builder.Configuration["Firebase:ProjectId"]
    ?? throw new InvalidOperationException("Configura Firebase:ProjectId.");
var issuer = $"https://securetoken.google.com/{project}";

// JwtBearer descarga las claves públicas de Google y valida el ID token de Firebase.
// No genera contraseñas ni necesita una clave privada de administrador.
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = issuer;
        options.Audience = project;
        options.MapInboundClaims = false;
        options.IncludeErrorDetails = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = issuer,
            ValidateAudience = true,
            ValidAudience = project,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidAlgorithms = [SecurityAlgorithms.RsaSha256],
            ClockSkew = TimeSpan.FromSeconds(30),
            NameClaimType = "sub"
        };
        options.Events = new JwtBearerEvents
        {
            OnTokenValidated = context =>
            {
                // Después de validar el token, exige un UID válido en la identidad recibida.
                var uid = context.Principal?.FindFirst("sub")?.Value;
                if (string.IsNullOrWhiteSpace(uid) || uid.Length > 128)
                    context.Fail("El token no identifica un usuario válido.");
                return Task.CompletedTask;
            }
        };
    });
builder.Services.AddAuthorization();
builder.Services.AddEndpointsApiExplorer();
// Documenta los endpoints y permite enviar el token desde Authorize en Swagger.
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "Banco de Sangre — API académica", Version = "v1" });
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http, Scheme = "bearer", BearerFormat = "JWT",
        Description = "ID token del usuario de Firebase."
    });
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        [new OpenApiSecurityScheme { Reference = new OpenApiReference
            { Type = ReferenceType.SecurityScheme, Id = "Bearer" } }] = Array.Empty<string>()
    });
});

var app = builder.Build();
// Devuelve errores básicos sin exponer consultas ni datos privados.
app.UseExceptionHandler();
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
// Primero valida la identidad; después comprueba el acceso a los endpoints protegidos.
app.UseAuthentication();
app.UseAuthorization();
// Publica las rutas declaradas con Route y HttpGet/HttpPost/HttpPut/HttpDelete.
app.MapControllers();
app.Run();


