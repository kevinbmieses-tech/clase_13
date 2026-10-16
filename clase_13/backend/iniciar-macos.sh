#!/usr/bin/env bash
set -euo pipefail

# Ejecutar desde cualquier carpeta: bash clase_13/backend/iniciar-macos.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DIR="$SCRIPT_DIR/BancoSangre.Api"

if ! command -v docker >/dev/null 2>&1; then
  echo "No se encontró Docker. Instala y abre Docker Desktop para macOS." >&2
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "Docker Desktop no está iniciado; ábrelo antes de continuar." >&2
  exit 1
fi
if ! command -v dotnet >/dev/null 2>&1; then
  echo "Instala el SDK .NET 10 antes de continuar." >&2
  exit 1
fi
if ! dotnet --list-sdks | grep -Eq '^10[.]'; then
  echo "Este backend usa net10.0. Instala .NET SDK 10: https://dotnet.microsoft.com/download/dotnet/10.0" >&2
  exit 1
fi
if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
  echo "Crea backend/.env a partir de backend/.env.example y establece MSSQL_SA_PASSWORD." >&2
  exit 1
fi
set -a
# El fichero .env es local. Se recomienda contraseña alfanumérica larga.
source "$SCRIPT_DIR/.env"
set +a
if [[ -z "${MSSQL_SA_PASSWORD:-}" || "$MSSQL_SA_PASSWORD" == "REEMPLAZAR_CON_CONTRASENA_FUERTE" ]]; then
  echo "Configura una contraseña real en backend/.env." >&2
  exit 1
fi

docker compose --project-directory "$SCRIPT_DIR" -f "$SCRIPT_DIR/docker-compose.yml" up -d

# SQL Server del contenedor se expone solo en localhost:1433. Nunca subir contraseña.
export ConnectionStrings__BancoSangre="Server=127.0.0.1,1433;Database=BancoSangreAcademico;User Id=sa;Password=${MSSQL_SA_PASSWORD};Encrypt=True;TrustServerCertificate=True"
export Firebase__ProjectId="donar-sangre-intec"
export ASPNETCORE_ENVIRONMENT=Development

cd "$API_DIR"
echo "Esperando 20 segundos para que SQL Server inicie (puede tardar más con emulación)..."
sleep 20
echo "Restaurando herramientas EF Core y aplicando migraciones existentes..."
dotnet tool restore
dotnet ef database update
echo "Migraciones aplicadas. Swagger: http://127.0.0.1:5080/swagger"
dotnet run --launch-profile http
