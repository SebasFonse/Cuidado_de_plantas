-- Consultas para verificar en el SQL Editor de Neon que las HU guardan la información.
-- Las tablas las crea Quarkus automáticamente al arrancar (strategy: update).

-- Tablas creadas
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- RQ1-HU01: usuarios registrados (la contraseña se guarda cifrada con BCrypt)
SELECT id, nombre, correo, LEFT(contrasena_hash, 20) || '...' AS contrasena_cifrada, fecha_registro
FROM usuarios
ORDER BY id;

-- RQ4-HU01: plantas registradas con su dueño
SELECT p.id, p.nombre, p.especie, p.ubicacion, p.descripcion, p.imagen_url,
       p.fecha_registro, u.nombre AS usuario, u.correo
FROM plantas p
JOIN usuarios u ON u.id = p.usuario_id
ORDER BY p.id;

-- Cantidad de plantas por usuario
SELECT u.nombre, COUNT(p.id) AS total_plantas
FROM usuarios u
LEFT JOIN plantas p ON p.usuario_id = u.id
GROUP BY u.nombre
ORDER BY total_plantas DESC;

-- HU08 + mejora del profesor: cuidados con su periodo (primer y último día)
SELECT c.id, p.nombre AS planta, c.tipo, c.frecuencia_dias, c.fecha_ultimo_cuidado,
       c.fecha_inicio AS primer_dia, c.fecha_fin AS ultimo_dia, c.notas
FROM cuidados c
JOIN plantas p ON p.id = c.planta_id
ORDER BY c.id;
