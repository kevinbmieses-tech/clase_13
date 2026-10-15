using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace BancoSangreApi.Migrations
{
    /// <inheritdoc />
    public partial class Inicial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BancosSangre",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Nombre = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    Direccion = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: false),
                    Telefono = table.Column<string>(type: "nvarchar(25)", maxLength: 25, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BancosSangre", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Donantes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirebaseUid = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false, collation: "Latin1_General_100_BIN2")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Donantes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Citas",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DonanteId = table.Column<int>(type: "int", nullable: false),
                    BancoSangreId = table.Column<int>(type: "int", nullable: false),
                    FechaHora = table.Column<DateTimeOffset>(type: "datetimeoffset", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Citas", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Citas_BancosSangre_BancoSangreId",
                        column: x => x.BancoSangreId,
                        principalTable: "BancosSangre",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Citas_Donantes_DonanteId",
                        column: x => x.DonanteId,
                        principalTable: "Donantes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.InsertData(
                table: "BancosSangre",
                columns: new[] { "Id", "Direccion", "Nombre", "Telefono" },
                values: new object[,]
                {
                    { 1, "Sede de demostración, Santo Domingo", "Banco de práctica — Santo Domingo", "809-555-0101" },
                    { 2, "Sede de demostración, Santiago", "Banco de práctica — Santiago", "809-555-0102" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Citas_BancoSangreId",
                table: "Citas",
                column: "BancoSangreId");

            migrationBuilder.CreateIndex(
                name: "IX_Citas_DonanteId_FechaHora",
                table: "Citas",
                columns: new[] { "DonanteId", "FechaHora" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Donantes_FirebaseUid",
                table: "Donantes",
                column: "FirebaseUid",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Citas");

            migrationBuilder.DropTable(
                name: "BancosSangre");

            migrationBuilder.DropTable(
                name: "Donantes");
        }
    }
}
