-- Script de Verificación de Base de Datos Distribuida
-- Ejecutar desde el nodo Valencia

\c clientes_valencia

-- 1. Verificar datos locales de Valencia
ECHO '=== DATOS LOCALES DE VALENCIA ==='
SELECT * FROM clientes ORDER BY id;

-- 2. Verificar conexión con Caracas
ECHO '=== DATOS REMOTOS DE CARACAS ==='
SELECT * FROM clientes_caracas ORDER BY id;

-- 3. Verificar vista unificada
ECHO '=== VISTA UNIFICADA (TODOS LOS CLIENTES) ==='
SELECT * FROM clientes_unificados ORDER BY id;

-- 4. Estadísticas por ciudad
ECHO '=== ESTADÍSTICAS POR CIUDAD ==='
SELECT ciudad, COUNT(*) as total_clientes
FROM clientes_unificados
GROUP BY ciudad
ORDER BY ciudad;

-- 5. Verificar que la consulta accede a ambos nodos
ECHO '=== PLAN DE EJECUCIÓN (VERIFICAR ACCESO A AMBOS NODOS) ==='
EXPLAIN (ANALYZE, VERBOSE, BUFFERS)
SELECT * FROM clientes_unificados
WHERE ciudad IN ('Caracas', 'Valencia')
ORDER BY id;

-- 6. Información de la conexión FDW
ECHO '=== INFORMACIÓN DEL FOREIGN DATA WRAPPER ==='
SELECT srvname, srvoptions 
FROM pg_foreign_server;

-- 7. Test de rendimiento
ECHO '=== TEST DE RENDIMIENTO ==='
EXPLAIN ANALYZE
SELECT ciudad, COUNT(*) as total
FROM clientes_unificados
GROUP BY ciudad; 