using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BancoSangreApi.Migrations
{
    /// <inheritdoc />
    public partial class CambiarGuionesBancos : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "BancosSangre",
                keyColumn: "Id",
                keyValue: 1,
                column: "Nombre",
                value: "Banco de práctica - Santo Domingo");

            migrationBuilder.UpdateData(
                table: "BancosSangre",
                keyColumn: "Id",
                keyValue: 2,
                column: "Nombre",
                value: "Banco de práctica - Santiago");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "BancosSangre",
                keyColumn: "Id",
                keyValue: 1,
                column: "Nombre",
                value: "Banco de práctica — Santo Domingo");

            migrationBuilder.UpdateData(
                table: "BancosSangre",
                keyColumn: "Id",
                keyValue: 2,
                column: "Nombre",
                value: "Banco de práctica — Santiago");
        }
    }
}
