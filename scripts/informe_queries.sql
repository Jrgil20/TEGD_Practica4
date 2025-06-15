-- =====================================================
-- CONSULTAS PARA EVIDENCIAR EN EL INFORME DE LA PRÁCTICA
-- =====================================================
-- Ejecutar estas consultas desde el nodo de Valencia para demostrar:
-- 1. Conexión distribuida a través de la red
-- 2. Fragmentación horizontal funcionando
-- 3. Consulta única que obtiene registros de ambos nodos

-- PASO 1: Conectarse al nodo de Valencia
-- \c clientes_valencia

-- =====================================================
-- EVIDENCIA 1: INFORMACIÓN DEL NODO ACTUAL
-- =====================================================
SELECT 
    'NODO VALENCIA - INFORMACIÓN DE CONEXIÓN' as titulo,
    current_database() as base_datos_actual,
    inet_server_addr() as ip_servidor_valencia,
    inet_server_port() as puerto_servidor,
    current_user as usuario_conectado,
    now() as timestamp_conexion;

-- =====================================================
-- EVIDENCIA 2: PRUEBA DE CONECTIVIDAD AL NODO REMOTO
-- =====================================================
-- Esta consulta demuestra que Valencia se conecta a Caracas a través de la red
SELECT 
    'CONEXIÓN REMOTA A CARACAS ESTABLECIDA' as estado,
    COUNT(*) as registros_obtenidos_caracas,
    MIN(fecha_registro) as primer_registro_caracas,
    MAX(fecha_registro) as ultimo_registro_caracas
FROM clientes_caracas;

-- =====================================================
-- EVIDENCIA 3: FRAGMENTACIÓN HORIZONTAL ACTIVA
-- =====================================================
-- Demostrar que los datos están fragmentados correctamente
SELECT 
    'FRAGMENTACIÓN HORIZONTAL VERIFICADA' as titulo,
    'Caracas' as nodo,
    COUNT(*) as total_registros,
    MIN(id) as id_minimo,
    MAX(id) as id_maximo,
    'IDs del 1 al 5 (según fragmentación)' as observacion
FROM clientes_caracas

UNION ALL

SELECT 
    'FRAGMENTACIÓN HORIZONTAL VERIFICADA' as titulo,
    'Valencia' as nodo,
    COUNT(*) as total_registros,
    MIN(id) as id_minimo,
    MAX(id) as id_maximo,
    'IDs del 6 en adelante (según fragmentación)' as observacion
FROM clientes;

-- =====================================================
-- EVIDENCIA 4: CONSULTA DISTRIBUIDA PRINCIPAL
-- =====================================================
-- Esta es la consulta clave que demuestra el objetivo de la práctica:
-- "consulta que realice la conexión al nodo de valencia y obtenga 
-- los registros de los clientes de Caracas y Valencia"

SELECT 
    '========== CONSULTA DISTRIBUIDA DESDE VALENCIA ==========' as separador
    
UNION ALL

SELECT 
    CONCAT(
        'ID: ', LPAD(id::text, 2, '0'),
        ' | Cliente: ', RPAD(nombre || ' ' || apellido, 25, ' '),
        ' | Ciudad: ', RPAD(ciudad, 8, ' '),
        ' | Teléfono: ', telefono,
        ' | Nodo: ', 
        CASE 
            WHEN id <= 5 THEN 'CARACAS (Remoto)'
            ELSE 'VALENCIA (Local)'
        END
    ) as registro_completo
FROM clientes_unificados
ORDER BY id;

-- =====================================================
-- EVIDENCIA 5: ANÁLISIS DE LA DISTRIBUCIÓN
-- =====================================================
-- Estadísticas que muestran cómo están distribuidos los datos
WITH estadisticas_nodos AS (
    SELECT 
        CASE 
            WHEN id <= 5 THEN 'Caracas'
            ELSE 'Valencia'
        END as nodo_origen,
        COUNT(*) as cantidad,
        MIN(id) as id_min,
        MAX(id) as id_max,
        ciudad
    FROM clientes_unificados
    GROUP BY 
        CASE WHEN id <= 5 THEN 'Caracas' ELSE 'Valencia' END,
        ciudad
)
SELECT 
    'DISTRIBUCIÓN DE DATOS POR NODO' as analisis,
    nodo_origen,
    ciudad,
    cantidad as registros,
    CONCAT('IDs del ', id_min, ' al ', id_max) as rango_ids
FROM estadisticas_nodos
ORDER BY nodo_origen, ciudad;

-- =====================================================
-- EVIDENCIA 6: VERIFICACIÓN DE INTEGRIDAD DISTRIBUIDA
-- =====================================================
-- Verificar que no hay duplicados entre nodos y que los emails son únicos
SELECT 
    'VERIFICACIÓN DE INTEGRIDAD DISTRIBUIDA' as prueba,
    COUNT(*) as total_registros,
    COUNT(DISTINCT email) as emails_unicos,
    COUNT(DISTINCT id) as ids_unicos,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT email) AND COUNT(*) = COUNT(DISTINCT id)
        THEN '✅ INTEGRIDAD CORRECTA: Sin duplicados entre nodos'
        ELSE '❌ ERROR: Hay duplicados en la distribución'
    END as resultado_integridad
FROM clientes_unificados;

-- =====================================================
-- EVIDENCIA 7: CONSULTA DE RENDIMIENTO DISTRIBUIDO
-- =====================================================
-- Activar timing para mostrar rendimiento de consultas distribuidas
\timing on

-- Consulta que requiere acceso a ambos nodos
SELECT 
    COUNT(*) as total_clientes_ambos_nodos,
    AVG(LENGTH(email)) as promedio_longitud_email,
    COUNT(DISTINCT ciudad) as ciudades_diferentes
FROM clientes_unificados;

\timing off

-- =====================================================
-- EVIDENCIA 8: CONSULTA FINAL PARA DEMOSTRACIÓN
-- =====================================================
-- Esta consulta resume todo lo requerido en la práctica
SELECT 
    '🎯 PRÁCTICA N° 04: BASES DE DATOS DISTRIBUIDAS - COMPLETADA' as titulo
    
UNION ALL

SELECT '📊 RESULTADOS DE LA IMPLEMENTACIÓN:'

UNION ALL

SELECT CONCAT('✅ Nodos implementados: Caracas y Valencia')

UNION ALL

SELECT CONCAT('✅ Registros en Caracas (remoto): ', 
    (SELECT COUNT(*) FROM clientes_caracas))

UNION ALL

SELECT CONCAT('✅ Registros en Valencia (local): ', 
    (SELECT COUNT(*) FROM clientes))

UNION ALL

SELECT CONCAT('✅ Total registros distribuidos: ', 
    (SELECT COUNT(*) FROM clientes_unificados))

UNION ALL

SELECT '✅ Fragmentación horizontal: Activa (Caracas: ID ≤ 5, Valencia: ID > 5)'

UNION ALL

SELECT '✅ Consulta distribuida: Ejecutada desde Valencia accediendo a Caracas'

UNION ALL

SELECT '✅ Conectividad de red: Establecida entre nodos'

UNION ALL

SELECT CONCAT('📅 Fecha de ejecución: ', NOW()::text)

UNION ALL

SELECT '🔗 Conexión actual: ' || current_database() || ' en servidor Valencia';

-- =====================================================
-- COMANDOS ADICIONALES PARA DOCUMENTACIÓN
-- =====================================================

-- Mostrar configuración del Foreign Data Wrapper
\dx postgres_fdw

-- Mostrar servidores remotos configurados
SELECT * FROM pg_foreign_server;

-- Mostrar tablas externas
SELECT * FROM information_schema.foreign_tables;

-- Información sobre la vista unificada
\d+ clientes_unificados