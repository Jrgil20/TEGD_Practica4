-- ========================================
-- PRUEBAS DE CONECTIVIDAD DISTRIBUIDA
-- ========================================

-- Conectarse al nodo de Valencia para ejecutar estas consultas
\c clientes_valencia

-- 1. Verificar conexión entre nodos
SELECT * FROM probar_conexion_caracas();

-- 2. Mostrar la tabla de configuración de acceso
SELECT * FROM configuracion_acceso;

-- ========================================
-- CONSULTAS BÁSICAS DISTRIBUIDAS
-- ========================================

-- 3. Consulta principal: Obtener TODOS los clientes desde Valencia
-- Esta consulta demuestra la fragmentación horizontal funcionando
SELECT 
    id,
    nombre,
    apellido,
    email,
    ciudad,
    nodo_origen,
    fecha_registro
FROM clientes_unificados
ORDER BY id;

-- 4. Verificar que los datos vienen de ambos nodos
SELECT 
    nodo_origen,
    COUNT(*) as total_clientes,
    MIN(id) as id_minimo,
    MAX(id) as id_maximo
FROM clientes_unificados
GROUP BY nodo_origen
ORDER BY nodo_origen;

-- ========================================
-- CONSULTAS AVANZADAS DISTRIBUIDAS
-- ========================================

-- 5. Buscar clientes por ciudad (fragmentación geográfica)
SELECT 
    'Consulta desde Valencia accediendo a ambos nodos' as descripcion,
    COUNT(*) as total_caracas
FROM clientes_unificados 
WHERE ciudad = 'Caracas';

SELECT 
    'Clientes locales en Valencia' as descripcion,
    COUNT(*) as total_valencia
FROM clientes_unificados 
WHERE ciudad = 'Valencia';

-- 6. Consulta con JOIN distribuido (simulado)
SELECT 
    cu.nodo_origen,
    cu.ciudad,
    COUNT(*) as cantidad,
    ROUND(AVG(LENGTH(cu.email)), 2) as promedio_longitud_email
FROM clientes_unificados cu
GROUP BY cu.nodo_origen, cu.ciudad
ORDER BY cu.nodo_origen, cu.ciudad;

-- 7. Consulta de análisis temporal distribuido
SELECT 
    DATE(fecha_registro) as fecha,
    nodo_origen,
    COUNT(*) as registros_por_dia
FROM clientes_unificados
GROUP BY DATE(fecha_registro), nodo_origen
ORDER BY fecha, nodo_origen;

-- ========================================
-- CONSULTAS DE RENDIMIENTO Y MONITOREO
-- ========================================

-- 8. Estadísticas de distribución
SELECT * FROM estadisticas_distribucion;

-- 9. Análisis de fragmentación
WITH fragmentacion AS (
    SELECT 
        nodo_origen,
        COUNT(*) as registros,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as porcentaje
    FROM clientes_unificados
    GROUP BY nodo_origen
)
SELECT 
    nodo_origen,
    registros,
    porcentaje || '%' as distribucion
FROM fragmentacion;

-- 10. Consulta para verificar integridad de datos
SELECT 
    'Verificación de integridad' as prueba,
    COUNT(DISTINCT email) as emails_unicos,
    COUNT(*) as total_registros,
    CASE 
        WHEN COUNT(DISTINCT email) = COUNT(*) 
        THEN 'PASS: No hay emails duplicados entre nodos' 
        ELSE 'FAIL: Hay emails duplicados'
    END as resultado
FROM clientes_unificados;

-- ========================================
-- CONSULTAS DE DIAGNÓSTICO DE RED
-- ========================================

-- 11. Probar latencia de conexión remota
SELECT 
    'Conexión a nodo remoto Caracas' as test,
    COUNT(*) as registros_remotos,
    NOW() as timestamp_consulta
FROM clientes_caracas;

-- 12. Comparar datos locales vs remotos
SELECT 
    'LOCAL - Valencia' as fuente,
    COUNT(*) as total,
    MIN(fecha_registro) as primer_registro,
    MAX(fecha_registro) as ultimo_registro
FROM clientes
UNION ALL
SELECT 
    'REMOTO - Caracas' as fuente,
    COUNT(*) as total,
    MIN(fecha_registro) as primer_registro,
    MAX(fecha_registro) as ultimo_registro
FROM clientes_caracas;

-- ========================================
-- CONSULTA FINAL DE DEMOSTRACIÓN
-- ========================================

-- 13. CONSULTA PRINCIPAL PARA EL INFORME
-- Esta consulta demuestra que desde Valencia se accede a ambos nodos
SELECT 
    '=== CONSULTA DISTRIBUIDA DESDE NODO VALENCIA ===' as titulo
UNION ALL
SELECT 'ID | Nombre Completo | Ciudad | Nodo de Origen'
UNION ALL
SELECT '---|-----------------|--------|---------------'
UNION ALL
SELECT 
    CONCAT(
        LPAD(id::TEXT, 2, '0'), ' | ',
        RPAD(nombre || ' ' || apellido, 15, ' '), ' | ',
        RPAD(ciudad, 6, ' '), ' | ',
        nodo_origen
    ) as resultado
FROM clientes_unificados
ORDER BY id;

-- Mensaje final
SELECT 
    '*** DEMOSTRACIÓN EXITOSA ***' as resultado
UNION ALL
SELECT 'Conexión establecida desde Valencia hacia Caracas'
UNION ALL
SELECT 'Fragmentación horizontal funcionando correctamente'
UNION ALL 
SELECT CONCAT('Total de registros distribuidos: ', COUNT(*))
FROM clientes_unificados;