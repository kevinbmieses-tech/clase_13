USE BancoSangreAcademico;
GO

-- Comprueba las tres tablas del negocio y la tabla técnica de migraciones.
SELECT name AS Tabla FROM sys.tables ORDER BY name;

SELECT Id, Nombre, Direccion, Telefono FROM dbo.BancosSangre ORDER BY Id;

-- Ejecuta de nuevo después de crear, editar y eliminar una cita desde Flutter.
SELECT c.Id AS CitaId, c.DonanteId, c.BancoSangreId,
       b.Nombre AS Banco, c.FechaHora
FROM dbo.Citas AS c
JOIN dbo.Donantes AS d ON d.Id = c.DonanteId
JOIN dbo.BancosSangre AS b ON b.Id = c.BancoSangreId
ORDER BY c.Id DESC;

-- Las relaciones impiden citas sin un banco o donante existente.
SELECT name AS Relacion FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID('dbo.Citas');
