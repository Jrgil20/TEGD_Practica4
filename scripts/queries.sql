-- Consulta 1: Obtener todos los clientes
SELECT * FROM clientes_unificados
ORDER BY id;

-- Consulta 2: Obtener clientes por ciudad
SELECT * FROM clientes_unificados
WHERE ciudad IN ('Caracas', 'Valencia')
ORDER BY ciudad, id;

-- Consulta 3: Contar clientes por ciudad
SELECT ciudad, COUNT(*) as total_clientes
FROM clientes_unificados
GROUP BY ciudad
ORDER BY total_clientes DESC;

-- Consulta 4: Buscar clientes por nombre o apellido
SELECT * FROM clientes_unificados
WHERE nombre ILIKE '%a%' OR apellido ILIKE '%a%'
ORDER BY id;

-- Consulta 5: Obtener clientes registrados en los últimos 30 días
SELECT * FROM clientes_unificados
WHERE fecha_registro >= CURRENT_TIMESTAMP - INTERVAL '30 days'
ORDER BY fecha_registro DESC; 