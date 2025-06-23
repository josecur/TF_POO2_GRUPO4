CREATE DATABASE DENUNCIAS;

CREATE TABLE denuncia (
	idDenuncia varchar(20) PRIMARY KEY,
	tipoDenuncia varchar(20) NOT NULL CHECK (
		tipoDenuncia IN ('Abuso Sexual', 'Acoso', 'Acoso Sexual', 'Domestica', 'Psicologica', 'Violencia')), 
	estado varchar(20) NOT NULL CHECK (
		estado IN ('Nueva','En Revision', 'Aprobada', 'Rechazada', 'En Proceso', 'Resuelta', 'Cerrada', 'Eliminada')),
	riesgo varchar(20) NOT NULL CHECK (riesgo IN ('ALTO', 'CRITICO', 'EXTREMO')),
	fecha_creacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE datos_personales(
	idDenuncia varchar(20) PRIMARY KEY,
	nombre varchar(50) NOT NULL,
	apellidoPaterno varchar(50) NOT NULL,
	apellidoMaterno varchar(50) NOT NULL,
	tipoDocumento varchar(4) NOT NULL CHECK (tipoDocumento IN ('DNI','CE')),
	idDocumento INT NOT NULL,
	email varchar(100) NOT NULL,
	celular INT NOT NULL,
	edad INT NOT NULL
	FOREIGN KEY (idDenuncia) REFERENCES denuncia(idDenuncia) ON DELETE CASCADE
);

CREATE TABLE ubicacion(
	idDenuncia varchar(20) PRIMARY KEY,
	departamento varchar(50) NOT NULL,
	provincia varchar(50) NOT NULL,
	distrito varchar(50) NOT NULL,
	direccion varchar(200),
	detallesAdicionales varchar(500)
	FOREIGN KEY (idDenuncia) REFERENCES denuncia(idDenuncia) ON DELETE CASCADE
);

CREATE TABLE detalles_denuncia(
	idDenuncia varchar(20) PRIMARY KEY, 
	fechaSuceso DATE NOT NULL,
	horaSuceso TIME ,
	victima varchar(100),
	agresor varchar(100),
	relacionAgresor varchar(20) CHECK (relacionAgresor IN ('Ninguna', 'Conocido/a', 'Amistad', 'Pareja')),
	medio varchar(20) CHECK (medio IN ('Virtual', 'Presencial')),
	testigos bit, --Si hubo testigos en lo momento del hecho
	frecuencia varchar(20) CHECK (frecuencia IN ('Primera Vez', 'Ocasionalmente', 'Frecuentemente', 'Repetitivo')),
	menoresInvolucrados bit, --Si hubo menores involucrados
	sintomas varchar(50), --Declara sintomas como Depresion, Ansiedad, Panico, Paranoia etc 
	heridas varchar(200), --Declara las heridas inflijidas a la victima 
	gravedadHeridas varchar(20) CHECK (gravedadHeridas IN ('Leve', 'Moderada', 'Grave')), 
	hospitalizacion bit, --Si hubo hospitalizacion
	usoDeObjetos bit, --Si hubo uso de objetos
	agresores bit, --Si hubo mas de un agresor
	objetos varchar(50), --Se declara los objetos usados
	descripcion varchar(1000) --Es un espacion donde se puede declarar cuanto se quiera sobre el hecho y proporcionar detalles adicionales
	FOREIGN KEY (idDenuncia) REFERENCES denuncia(idDenuncia) ON DELETE CASCADE
);


GO
CREATE FUNCTION fn_getDenunciaAcoso(@idDenuncia VARCHAR(20))
RETURNS TABLE
AS
RETURN 
SELECT
    '------------------ DATOS PERSONALES ------------------' + CHAR(13) + CHAR(10) +
    'Nombre: ' + ISNULL(dp.nombre, 'No especificado') + CHAR(13) + CHAR(10) +
    'Apellido Paterno: ' + ISNULL(dp.apellidoPaterno, 'No especificado') + CHAR(13) + CHAR(10) +
    'Apellido Materno: ' + ISNULL(dp.apellidoMaterno, 'No especificado') + CHAR(13) + CHAR(10) +
    'Documento: ' + ISNULL(dp.tipoDocumento, 'Desconocido') + ' / ' + ISNULL(CAST(dp.idDocumento AS VARCHAR), 'No especificado') + CHAR(13) + CHAR(10) +
    'Email: ' + ISNULL(dp.email, 'No especificado') + CHAR(13) + CHAR(10) +
    'Celular: ' + ISNULL(dp.celular, 'No especificado') + CHAR(13) + CHAR(10) +
    'Edad: ' + ISNULL(CAST(dp.edad AS VARCHAR), 'No especificada') + CHAR(13) + CHAR(10) +

    CHAR(13) + CHAR(10) + '--------------------- UBICACIÓN ---------------------' + CHAR(13) + CHAR(10) +
    'Departamento: ' + ISNULL(uu.departamento, 'No especificado') + CHAR(13) + CHAR(10) +
    'Provincia: ' + ISNULL(uu.provincia, 'No especificado') + CHAR(13) + CHAR(10) +
    'Distrito: ' + ISNULL(uu.distrito, 'No especificado') + CHAR(13) + CHAR(10) +
    'Dirección: ' + ISNULL(uu.direccion, 'No especificada') + CHAR(13) + CHAR(10) +
    'Detalles: ' + ISNULL(uu.detallesAdicionales, 'Ninguno') + CHAR(13) + CHAR(10) +

    CHAR(13) + CHAR(10) + '----------------- DETALLES DEL HECHO ----------------' + CHAR(13) + CHAR(10) +
    'Fecha: ' + ISNULL(CONVERT(VARCHAR, dd.fechaSuceso, 103), 'No especificada') +
    ' - Hora: ' + ISNULL(CONVERT(VARCHAR, dd.horaSuceso, 108), 'No especificada') + CHAR(13) + CHAR(10) +
    'Tipo: ' + ISNULL(d.tipoDenuncia, 'No especificado') + CHAR(13) + CHAR(10) +
    'Riesgo: ' + ISNULL(d.riesgo, 'No especificado') + CHAR(13) + CHAR(13) + CHAR(10) +

    'Victima: ' + ISNULL(dd.victima, 'No especificada') + CHAR(13) + CHAR(10) +
    'Agresor: ' + ISNULL(dd.agresor, 'No especificado o Desconocido') + CHAR(13) + CHAR(10) +
    'Relación con agresor: ' + ISNULL(dd.relacionAgresor, 'Desconocida') + CHAR(13) + CHAR(13) + CHAR(10) +
    'Testigos: ' + CASE WHEN dd.testigos = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(10) +
    'Frecuencia: ' + ISNULL(dd.frecuencia, 'No especificada') + CHAR(13) + CHAR(10) +
    'Medio: ' + ISNULL(dd.medio, 'No especificado') + CHAR(13) + CHAR(13) + CHAR(10) +

    'Descripción:' + CHAR(13) + CHAR(10) +
    ISNULL(dd.descripcion, 'No disponible')
    AS mensaje
FROM denuncia d
LEFT JOIN datos_personales dp ON d.idDenuncia = dp.idDenuncia
LEFT JOIN detalles_denuncia dd ON d.idDenuncia = dd.idDenuncia
LEFT JOIN ubicacion uu ON d.idDenuncia = uu.idDenuncia
WHERE d.idDenuncia = @idDenuncia AND d.tipoDenuncia = 'Acoso';




GO
CREATE FUNCTION fn_getDenunciaAcosoSexual(@idDenuncia VARCHAR(20))
RETURNS TABLE
AS
RETURN 
SELECT
    '------------------ DATOS PERSONALES ------------------' + CHAR(13) + CHAR(10) +
    'Nombre: ' + ISNULL(dp.nombre, 'No especificado') + CHAR(13) + CHAR(10) +
    'Apellido Paterno: ' + ISNULL(dp.apellidoPaterno, 'No especificado') + CHAR(13) + CHAR(10) +
    'Apellido Materno: ' + ISNULL(dp.apellidoMaterno, 'No especificado') + CHAR(13) + CHAR(10) +
    'Documento: ' + ISNULL(dp.tipoDocumento, 'Desconocido') + ' / ' + ISNULL(CAST(dp.idDocumento AS VARCHAR), 'No especificado') + CHAR(13) + CHAR(10) +
    'Email: ' + ISNULL(dp.email, 'No especificado') + CHAR(13) + CHAR(10) +
    'Celular: ' + ISNULL(dp.celular, 'No especificado') + CHAR(13) + CHAR(10) +
    'Edad: ' + ISNULL(CAST(dp.edad AS VARCHAR), 'No especificada') + CHAR(13) + CHAR(10) +

    CHAR(13) + CHAR(10) + '--------------------- UBICACIÓN ---------------------' + CHAR(13) + CHAR(10) +
    'Departamento: ' + ISNULL(uu.departamento, 'No especificado') + CHAR(13) + CHAR(10) +
    'Provincia: ' + ISNULL(uu.provincia, 'No especificado') + CHAR(13) + CHAR(10) +
    'Distrito: ' + ISNULL(uu.distrito, 'No especificado') + CHAR(13) + CHAR(10) +
    'Dirección: ' + ISNULL(uu.direccion, 'No especificada') + CHAR(13) + CHAR(10) +
    'Detalles: ' + ISNULL(uu.detallesAdicionales, 'Ninguno') + CHAR(13) + CHAR(10) +

    CHAR(13) + CHAR(10) + '----------------- DETALLES DEL HECHO ----------------' + CHAR(13) + CHAR(10) +
    'Fecha: ' + ISNULL(CONVERT(VARCHAR, dd.fechaSuceso, 103), 'No especificada') + 
    ' - Hora: ' + ISNULL(CONVERT(VARCHAR, dd.horaSuceso, 108), 'No especificada') + CHAR(13) + CHAR(10) +
    'Tipo: ' + ISNULL(d.tipoDenuncia, 'No especificado') + CHAR(13) + CHAR(10) +
    'Riesgo: ' + ISNULL(d.riesgo, 'No especificado') + CHAR(13) + CHAR(13) + CHAR(10) +

    'Victima: ' + ISNULL(dd.victima, 'No especificada') + CHAR(13) + CHAR(10) +
    'Agresor: ' + ISNULL(dd.agresor, 'No especificado o Desconocido') + CHAR(13) + CHAR(10) +
    'Relación con agresor: ' + ISNULL(dd.relacionAgresor, 'Desconocida') + CHAR(13) + CHAR(13) + CHAR(10) +
    'Testigos: ' + CASE WHEN dd.testigos = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(10) +
    'Frecuencia: ' + ISNULL(dd.frecuencia, 'No especificada') + CHAR(13) + CHAR(13) + CHAR(10) +

    'Descripción:' + CHAR(13) + CHAR(10) +
    ISNULL(dd.descripcion, 'No disponible')
    AS mensaje
FROM denuncia d
LEFT JOIN datos_personales dp ON d.idDenuncia = dp.idDenuncia
LEFT JOIN detalles_denuncia dd ON d.idDenuncia = dd.idDenuncia
LEFT JOIN ubicacion uu ON d.idDenuncia = uu.idDenuncia
WHERE d.idDenuncia = @idDenuncia AND d.tipoDenuncia = 'Acoso Sexual';


GO
CREATE FUNCTION fn_getDenunciaAbusoSexual(@idDenuncia VARCHAR(20))
RETURNS TABLE
AS
RETURN 
SELECT
	'------------------ DATOS PERSONALES ------------------' + CHAR(13) + CHAR(10) +
    'Nombre: ' + ISNULL(dp.nombre, 'No especificado') + CHAR(13) + CHAR(10) +
	'Apellido Paterno: ' + ISNULL(dp.apellidoPaterno, 'No especificado') + CHAR(13) + CHAR(10) +
	'Apellido Materno: ' + ISNULL(dp.apellidoMaterno, 'No especificado') + CHAR(13) + CHAR(10) +
    'Documento: ' + dp.tipoDocumento + ' / ' + CAST(dp.idDocumento AS VARCHAR) + CHAR(13) +  CHAR(10) +
    'Email: ' + ISNULL(dp.email, 'No especificado') + CHAR(13) + CHAR(10) +
    'Celular: ' + ISNULL(CAST(dp.celular AS VARCHAR), 'No especificado') + CHAR(13) + CHAR(10) +
    'Edad: ' + ISNULL(CAST(dp.edad AS VARCHAR), 'No especificada') + CHAR(13) + CHAR(10) +

	CHAR(13) +  CHAR(10) +'--------------------- UBICACIÓN ---------------------' + CHAR(13) + CHAR(10) +
    'Departamento: ' + ISNULL(uu.departamento, 'No especificado') + CHAR(13) + CHAR(10) +
    'Provincia: ' + ISNULL(uu.provincia, 'No especificado') + CHAR(13) + CHAR(10) +
    'Distrito: ' + ISNULL(uu.distrito, 'No especificado') + CHAR(13) + CHAR(10) +
    'Dirección: ' + ISNULL(uu.direccion, 'No especificada') + CHAR(13) + CHAR(10) +
    'Detalles: ' + ISNULL(uu.detallesAdicionales, 'Ninguno') + CHAR(13) + CHAR(10) +

	CHAR(13) +  CHAR(10) +'----------------- DETALLES DEL HECHO ----------------' + CHAR(13) + CHAR(10) +
	'Fecha: ' + ISNULL(CONVERT(VARCHAR, dd.fechaSuceso, 103), 'No especificada') +
	' - Hora: ' + ISNULL(CONVERT(VARCHAR, dd.horaSuceso, 108), 'No especificada') + CHAR(13) + CHAR(10) +
	'Tipo: ' + ISNULL(d.tipoDenuncia, 'No especificado') + CHAR(13) + CHAR(10) +
	'Riesgo: ' + ISNULL(d.riesgo, 'No especificado') + CHAR(13) + CHAR(13) + CHAR(10) +
	'Victima: ' + ISNULL(dd.victima, 'No especificada') + CHAR(13) + CHAR(10) +
    'Más de un agresor: ' + CASE WHEN dd.agresores = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(10) +
	'Agresor: ' + ISNULL(dd.agresor, 'No especificado o Desconocido') + CHAR(13) + CHAR(10) +
	'Relación con agresor: ' + ISNULL(dd.relacionAgresor, 'Desconocida') + CHAR(13) + CHAR(13) + CHAR(10) +
	'Testigos: ' + CASE WHEN dd.testigos = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(10) +
	'Síntomas: ' + ISNULL(dd.sintomas, 'No especificados') + CHAR(13) + CHAR(10) +
	'Hospitalización: ' + CASE WHEN dd.hospitalizacion = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(13) + CHAR(10) +
	'Descripción:' + CHAR(13) + CHAR(10) +
	ISNULL(dd.descripcion, 'No disponible')
	AS mensaje
FROM denuncia d
LEFT JOIN datos_personales dp ON d.idDenuncia = dp.idDenuncia
LEFT JOIN detalles_denuncia dd ON d.idDenuncia = dd.idDenuncia
LEFT JOIN ubicacion uu ON d.idDenuncia = uu.idDenuncia
WHERE d.idDenuncia = @idDenuncia AND d.tipoDenuncia = 'Abuso Sexual';




GO
CREATE FUNCTION fn_getDenunciaDomestica(@idDenuncia VARCHAR(20))
RETURNS TABLE
AS
RETURN 
SELECT
    '------------------ DATOS PERSONALES ------------------' + CHAR(13) + CHAR(10) +
    'Nombre: ' + ISNULL(dp.nombre, 'No especificado') + CHAR(13) + CHAR(10) +
    'Apellido Paterno: ' + ISNULL(dp.apellidoPaterno, 'No especificado') + CHAR(13) + CHAR(10) +
    'Apellido Materno: ' + ISNULL(dp.apellidoMaterno, 'No especificado') + CHAR(13) + CHAR(10) +
    'Documento: ' + ISNULL(dp.tipoDocumento, 'Desconocido') + ' / ' + ISNULL(CAST(dp.idDocumento AS VARCHAR), 'No especificado') + CHAR(13) + CHAR(10) +
    'Email: ' + ISNULL(dp.email, 'No especificado') + CHAR(13) + CHAR(10) +
    'Celular: ' + ISNULL(dp.celular, 'No especificado') + CHAR(13) + CHAR(10) +
    'Edad: ' + ISNULL(CAST(dp.edad AS VARCHAR), 'No especificada') + CHAR(13) + CHAR(10) +

    CHAR(13) + CHAR(10) + '--------------------- UBICACIÓN ---------------------' + CHAR(13) + CHAR(10) +
    'Departamento: ' + ISNULL(uu.departamento, 'No especificado') + CHAR(13) + CHAR(10) +
    'Provincia: ' + ISNULL(uu.provincia, 'No especificado') + CHAR(13) + CHAR(10) +
    'Distrito: ' + ISNULL(uu.distrito, 'No especificado') + CHAR(13) + CHAR(10) +
    'Dirección: ' + ISNULL(uu.direccion, 'No especificada') + CHAR(13) + CHAR(10) +
    'Detalles: ' + ISNULL(uu.detallesAdicionales, 'Ninguno') + CHAR(13) + CHAR(10) +

    CHAR(13) + CHAR(10) + '----------------- DETALLES DEL HECHO ----------------' + CHAR(13) + CHAR(10) +
    'Fecha: ' + ISNULL(CONVERT(VARCHAR, dd.fechaSuceso, 103), 'No especificada') + 
    ' - Hora: ' + ISNULL(CONVERT(VARCHAR, dd.horaSuceso, 108), 'No especificada') + CHAR(13) + CHAR(10) +
    'Tipo: ' + ISNULL(d.tipoDenuncia, 'No especificado') + CHAR(13) + CHAR(10) +
    'Riesgo: ' + ISNULL(d.riesgo, 'No especificado') + CHAR(13) + CHAR(13) + CHAR(10) +

    'Victima: ' + ISNULL(dd.victima, 'No especificada') + CHAR(13) + CHAR(10) +
    'Agresor: ' + ISNULL(dd.agresor, 'No especificado o Desconocido') + CHAR(13) + CHAR(10) +
    'Relación con agresor: ' + ISNULL(dd.relacionAgresor, 'Desconocida') + CHAR(13) + CHAR(13) + CHAR(10) +
    'Testigos: ' + CASE WHEN dd.testigos = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(10) +
    'Frecuencia: ' + ISNULL(dd.frecuencia, 'No especificada') + CHAR(13) + CHAR(10) +
    'Heridas: ' + ISNULL(dd.heridas, 'No especificadas') + CHAR(13) + CHAR(10) +
    'Gravedad de las heridas: ' + ISNULL(dd.gravedadHeridas, 'No especificada') + CHAR(13) + CHAR(10) +
    'Hospitalización: ' + CASE WHEN dd.hospitalizacion = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(10) +
    'Menores involucrados: ' + CASE WHEN dd.menoresInvolucrados = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(13) + CHAR(10) +

    'Descripción:' + CHAR(13) + CHAR(10) +
    ISNULL(dd.descripcion, 'No disponible')
    AS mensaje
FROM denuncia d
LEFT JOIN datos_personales dp ON d.idDenuncia = dp.idDenuncia
LEFT JOIN detalles_denuncia dd ON d.idDenuncia = dd.idDenuncia
LEFT JOIN ubicacion uu ON d.idDenuncia = uu.idDenuncia
WHERE d.idDenuncia = @idDenuncia AND d.tipoDenuncia = 'Domestica';


GO
CREATE FUNCTION fn_getDenunciaPsicologica(@idDenuncia VARCHAR(20))
RETURNS TABLE
AS
RETURN 
SELECT
    '------------------ DATOS PERSONALES ------------------' + CHAR(13) + CHAR(10) +
    'Nombre: ' + ISNULL(dp.nombre, 'No especificado') + CHAR(13) + CHAR(10) +
    'Apellido Paterno: ' + ISNULL(dp.apellidoPaterno, 'No especificado') + CHAR(13) + CHAR(10) +
    'Apellido Materno: ' + ISNULL(dp.apellidoMaterno, 'No especificado') + CHAR(13) + CHAR(10) +
    'Documento: ' + ISNULL(dp.tipoDocumento, 'Desconocido') + ' / ' + ISNULL(CAST(dp.idDocumento AS VARCHAR), 'No especificado') + CHAR(13) + CHAR(10) +
    'Email: ' + ISNULL(dp.email, 'No especificado') + CHAR(13) + CHAR(10) +
    'Celular: ' + ISNULL(dp.celular, 'No especificado') + CHAR(13) + CHAR(10) +
    'Edad: ' + ISNULL(CAST(dp.edad AS VARCHAR), 'No especificada') + CHAR(13) + CHAR(10) +

    CHAR(13) + CHAR(10) + '--------------------- UBICACIÓN ---------------------' + CHAR(13) + CHAR(10) +
    'Departamento: ' + ISNULL(uu.departamento, 'No especificado') + CHAR(13) + CHAR(10) +
    'Provincia: ' + ISNULL(uu.provincia, 'No especificado') + CHAR(13) + CHAR(10) +
    'Distrito: ' + ISNULL(uu.distrito, 'No especificado') + CHAR(13) + CHAR(10) +
    'Dirección: ' + ISNULL(uu.direccion, 'No especificada') + CHAR(13) + CHAR(10) +
    'Detalles: ' + ISNULL(uu.detallesAdicionales, 'Ninguno') + CHAR(13) + CHAR(10) +

    CHAR(13) + CHAR(10) + '----------------- DETALLES DEL HECHO ----------------' + CHAR(13) + CHAR(10) +
    'Fecha: ' + ISNULL(CONVERT(VARCHAR, dd.fechaSuceso, 103), 'No especificada') + 
    ' - Hora: ' + ISNULL(CONVERT(VARCHAR, dd.horaSuceso, 108), 'No especificada') + CHAR(13) + CHAR(10) +
    'Tipo: ' + ISNULL(d.tipoDenuncia, 'No especificado') + CHAR(13) + CHAR(10) +
    'Riesgo: ' + ISNULL(d.riesgo, 'No especificado') + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +

    'Victima: ' + ISNULL(dd.victima, 'No especificada') + CHAR(13) + CHAR(10) +
    'Agresor: ' + ISNULL(dd.agresor, 'No especificado o Desconocido') + CHAR(13) + CHAR(10) +
    'Relación con agresor: ' + ISNULL(dd.relacionAgresor, 'Desconocida') + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +

    'Frecuencia: ' + ISNULL(dd.frecuencia, 'No especificada') + CHAR(13) + CHAR(10) +
    'Síntomas: ' + ISNULL(dd.sintomas, 'No especificados') + CHAR(13) + CHAR(10) +
    'Hospitalización: ' + CASE WHEN dd.hospitalizacion = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +

    'Descripción:' + CHAR(13) + CHAR(10) +
    ISNULL(dd.descripcion, 'No disponible')
    AS mensaje
FROM denuncia d
LEFT JOIN datos_personales dp ON d.idDenuncia = dp.idDenuncia
LEFT JOIN detalles_denuncia dd ON d.idDenuncia = dd.idDenuncia
LEFT JOIN ubicacion uu ON d.idDenuncia = uu.idDenuncia
WHERE d.idDenuncia = @idDenuncia AND d.tipoDenuncia = 'Psicologica';


GO
CREATE FUNCTION fn_getDenunciaViolencia(@idDenuncia VARCHAR(20))
RETURNS TABLE
AS
RETURN 
SELECT
    '------------------ DATOS PERSONALES ------------------' + CHAR(13) + CHAR(10) +
    'Nombre: ' + ISNULL(dp.nombre, 'No especificado') + CHAR(13) + CHAR(10) +
    'Apellido Paterno: ' + ISNULL(dp.apellidoPaterno, 'No especificado') + CHAR(13) + CHAR(10) +
    'Apellido Materno: ' + ISNULL(dp.apellidoMaterno, 'No especificado') + CHAR(13) + CHAR(10) +
    'Documento: ' + ISNULL(dp.tipoDocumento, 'Desconocido') + ' / ' + ISNULL(CAST(dp.idDocumento AS VARCHAR), 'No especificado') + CHAR(13) + CHAR(10) +
    'Email: ' + ISNULL(dp.email, 'No especificado') + CHAR(13) + CHAR(10) +
    'Celular: ' + ISNULL(dp.celular, 'No especificado') + CHAR(13) + CHAR(10) +
    'Edad: ' + ISNULL(CAST(dp.edad AS VARCHAR), 'No especificada') + CHAR(13) + CHAR(10) +

    CHAR(13) + CHAR(10) + '--------------------- UBICACIÓN ---------------------' + CHAR(13) + CHAR(10) +
    'Departamento: ' + ISNULL(uu.departamento, 'No especificado') + CHAR(13) + CHAR(10) +
    'Provincia: ' + ISNULL(uu.provincia, 'No especificado') + CHAR(13) + CHAR(10) +
    'Distrito: ' + ISNULL(uu.distrito, 'No especificado') + CHAR(13) + CHAR(10) +
    'Dirección: ' + ISNULL(uu.direccion, 'No especificada') + CHAR(13) + CHAR(10) +
    'Detalles: ' + ISNULL(uu.detallesAdicionales, 'Ninguno') + CHAR(13) + CHAR(10) +

    CHAR(13) + CHAR(10) + '----------------- DETALLES DEL HECHO ----------------' + CHAR(13) + CHAR(10) +
    'Fecha: ' + ISNULL(CONVERT(VARCHAR, dd.fechaSuceso, 103), 'No especificada') + 
    ' - Hora: ' + ISNULL(CONVERT(VARCHAR, dd.horaSuceso, 108), 'No especificada') + CHAR(13) + CHAR(10) +
    'Tipo: ' + ISNULL(d.tipoDenuncia, 'No especificado') + CHAR(13) + CHAR(10) +
    'Riesgo: ' + ISNULL(d.riesgo, 'No especificado') + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +

    'Victima: ' + ISNULL(dd.victima, 'No especificada') + CHAR(13) + CHAR(10) +
    'Más de un agresor: ' + CASE WHEN dd.agresores = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(10) +
    'Agresor: ' + ISNULL(dd.agresor, 'No especificado o Desconocido') + CHAR(13) + CHAR(10) +
    'Relación con agresor: ' + ISNULL(dd.relacionAgresor, 'Desconocida') + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +

    'Testigos: ' + CASE WHEN dd.testigos = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(10) +
    'Uso de objetos: ' + CASE WHEN dd.usoDeObjetos = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(10) +
    'Objetos: ' + ISNULL(dd.objetos, 'No especificados') + CHAR(13) + CHAR(10) +
    'Heridas: ' + ISNULL(dd.heridas, 'No especificadas') + CHAR(13) + CHAR(10) +
    'Gravedad de las heridas: ' + ISNULL(dd.gravedadHeridas, 'No especificada') + CHAR(13) + CHAR(10) +
    'Hospitalización: ' + CASE WHEN dd.hospitalizacion = 1 THEN 'Sí' ELSE 'No' END + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +

    'Descripción:' + CHAR(13) + CHAR(10) +
    ISNULL(dd.descripcion, 'No disponible')
    AS mensaje
FROM denuncia d
LEFT JOIN datos_personales dp ON d.idDenuncia = dp.idDenuncia
LEFT JOIN detalles_denuncia dd ON d.idDenuncia = dd.idDenuncia
LEFT JOIN ubicacion uu ON d.idDenuncia = uu.idDenuncia
WHERE d.idDenuncia = @idDenuncia AND d.tipoDenuncia = 'Violencia';




GO
CREATE PROCEDURE sp_getMensajeDenuncia
    @idDenuncia VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tipo VARCHAR(20);
    DECLARE @mensaje NVARCHAR(MAX);

    SELECT @tipo = tipoDenuncia FROM denuncia WHERE idDenuncia = @idDenuncia;

    IF @tipo IS NULL
    BEGIN
        RAISERROR('Denuncia no encontrada', 16, 1);
        RETURN;
    END

    IF @tipo = 'Acoso'
    BEGIN
        SELECT @mensaje = mensaje FROM fn_getDenunciaAcoso(@idDenuncia);
    END

    ELSE IF @tipo = 'Psicologica'
    BEGIN
        SELECT @mensaje = mensaje FROM fn_getDenunciaPsicologica(@idDenuncia);
    END

    ELSE IF @tipo = 'Abuso Sexual'
    BEGIN
        SELECT @mensaje = mensaje FROM fn_getDenunciaAbusoSexual(@idDenuncia);
    END

	ELSE IF @tipo = 'Acoso Sexual'
	BEGIN
		SELECT @mensaje = mensaje FROM fn_getDenunciaAcosoSexual(@idDenuncia);
	END
    
	ELSE IF @tipo = 'Domestica'
	BEGIN
		SELECT @mensaje = mensaje FROM fn_getDenunciaDomestica(@idDenuncia);
	END

	ELSE IF @tipo = 'Violencia'
	BEGIN
		SELECT  @mensaje = mensaje FROM fn_getDenunciaViolencia(@idDenuncia);
	END

    ELSE
    BEGIN
        SELECT @mensaje = 'Tipo de denuncia no soportado o función no definida.';
    END

    SELECT @mensaje AS mensaje;
END


CREATE SEQUENCE SiguienteNumeroDenuncia
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO CYCLE;


GO
CREATE PROCEDURE SiguienteId
    @abreviacionDepto VARCHAR(20),
    @nuevoId VARCHAR(20) OUTPUT
AS
BEGIN
    DECLARE @nuevoNumero VARCHAR(6);
    DECLARE @siguiente INT;

    -- Obtener siguiente número de la secuencia
    SET @siguiente = NEXT VALUE FOR SiguienteNumeroDenuncia;

    -- Formatear número
    SET @nuevoNumero = FORMAT(@siguiente, '000000');

    -- Generar ID final
    SET @nuevoId = CONCAT('D-', @abreviacionDepto, '-', @nuevoNumero);
END;


SELECT * FROM denuncia;
SELECT * FROM datos_personales;
SELECT * from ubicacion;
SELECT * FROM detalles_denuncia;

SELECT * FROM denuncia WHERE idDenuncia = 'D-AP-000001' AND tipoDenuncia = 'Abuso Sexual';

SELECT * FROM fn_getDenunciaAbusoSexual('D-AN-000004');