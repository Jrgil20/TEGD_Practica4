# Guía de Implementación - Base de Datos Distribuida PostgreSQL

## 🎯 Objetivo
Implementar una base de datos distribuida con PostgreSQL usando fragmentación horizontal entre dos nodos (Caracas y Valencia) con IPs reales (no localhost).

## 📋 Requisitos Previos
- Docker y Docker Compose instalados
- Al menos 4GB de RAM disponible
- Puertos 5432, 5433 y 8080 libres

## 🚀 Implementación Paso a Paso

### Paso 1: Preparar el Entorno
```bash
# Crear directorio del proyecto
mkdir bd-distribuida-postgres
cd bd-distribuida-postgres

# Crear estructura de carpetas
mkdir -p scripts/caracas scripts/valencia config docs
```

### Paso 2: Crear los Archivos de Configuración
1. Copiar el archivo `docker-compose.yml` en la raíz del proyecto
2. Copiar los archivos de configuración PostgreSQL en la carpeta `config/`
3. Copiar los scripts SQL en sus respectivas carpetas

### Paso 3: Configurar PostgreSQL para Caracas
```bash
# Crear archivo de configuración específico para Valencia
cp config/postgresql-caracas.conf config/postgresql-valencia.conf
```

### Paso 4: Levantar los Servicios
```bash
# Levantar todos los servicios
docker-compose up -d

# Verificar que los contenedores estén corriendo
docker-compose ps
```

### Paso 5: Verificar la Conectividad
```bash
# Conectar al nodo Valencia
docker exec -it db-valencia psql -U postgres -d clientes_valencia

# Ejecutar consulta de prueba
SELECT * FROM probar_conexion_caracas();
```

## 🔧 Configuración Manual (si es necesario)

### Configurar pg_hba.conf
```bash
# Acceder al contenedor de Caracas
docker exec -it db-caracas bash

# Editar pg_hba.conf
echo "host all all 172.20.0.0/16 md5" >> /var/lib/postgresql/data/pg_hba.conf

# Reiniciar PostgreSQL
docker restart db-caracas
```

## 🧪 Pruebas de Funcionamiento

### Conectar a Valencia y Ejecutar Pruebas
```sql
-- Conectar a Valencia
\c clientes_valencia

-- Ejecutar consultas distribuidas
\i /scripts/consultas-distribuidas.sql
```

### Verificar Fragmentación Horizontal
```sql
-- Desde Valencia, verificar que se accede a ambos nodos
SELECT 
    nodo_origen,
    COUNT(*) as total,
    MIN(id) as id_min,
    MAX(id) as id_max
FROM clientes_unificados
GROUP BY nodo_origen;
```

## 📊 Acceso a pgAdmin
1. Abrir navegador en `http://localhost:8080`
2. Login: `admin@distribuido.com` / `admin123`
3. Agregar servidores:
   - **Caracas**: Host `172.20.0.10`, Puerto `5432`
   - **Valencia**: Host `172.20.0.11`, Puerto `5432`

## 🔍 Monitoreo y Diagnóstico

### Verificar Logs
```bash
# Logs de Valencia
docker logs db-valencia

# Logs de Caracas
docker logs db-caracas
```

### Verificar Conectividad de Red
```bash
# Ping entre contenedores
docker exec db-valencia ping 172.20.0.10
docker exec db-caracas ping 172.20.0.11
```

## 📈 Consultas Clave para el Informe

### 1. Demostrar Conexión Distribuida
```sql
-- Ejecutar desde Valencia
SELECT 
    'Conectado desde Valencia' as nodo_actual,
    COUNT(*) as registros_caracas_remotos
FROM clientes_caracas;
```

### 2. Mostrar Fragmentación Horizontal
```sql
-- Mostrar distribución de datos
SELECT 
    nodo_origen,
    ciudad,
    COUNT(*) as cantidad_registros
FROM clientes_unificados
GROUP BY nodo_origen, ciudad
ORDER BY nodo_origen;
```

### 3. Consulta Unificada
```sql
-- Consulta que accede a ambos nodos simultáneamente
SELECT 
    id,
    nombre || ' ' || apellido as nombre_completo,
    ciudad,
    nodo_origen
FROM clientes_unificados
ORDER BY id;
```

## 🛠️ Troubleshooting

### Problema: No se puede conectar entre nodos
**Solución:**
```bash
# Verificar red Docker
docker network ls
docker network inspect bd-distribuida_bd_distribuida

# Verificar pg_hba.conf
docker exec db-caracas cat /var/lib/postgresql/data/pg_hba.conf | grep 172.20
```

### Problema: Foreign table no funciona
**Solución:**
```sql
-- Verificar extensión
SELECT * FROM pg_extension WHERE extname = 'postgres_fdw';

-- Verificar servidor remoto
SELECT * FROM pg_foreign_server;

-- Verificar mapeo de usuario
SELECT * FROM pg_user_mappings;
```

## 📋 Checklist de Verificación

- [ ] Ambos contenedores están corriendo
- [ ] Se puede conectar a Valencia desde host
- [ ] Se puede conectar a Caracas desde host
- [ ] Valencia puede consultar tabla remota de Caracas
- [ ] Foreign Data Wrapper configurado correctamente
- [ ] Vista unificada muestra datos de ambos nodos
- [ ] Consultas distribuidas funcionan correctamente
- [ ] pgAdmin puede acceder a ambos servidores
- [ ] Fragmentación horizontal implementada (Caracas: ID ≤ 5, Valencia: ID > 5)

## 🎓 Evidencias para el Informe

### Captura 1: Arquitectura de Red
```bash
# Mostrar la configuración de red Docker
docker network inspect bd-distribuida_bd_distribuida --format '{{json .}}' | jq '.IPAM.Config'
```

### Captura 2: Conexión Distribuida
```sql
-- Ejecutar desde Valencia para mostrar conexión a Caracas
SELECT 
    'EVIDENCIA: Consulta ejecutada desde Valencia' as descripcion,
    current_database() as bd_actual,
    inet_server_addr() as ip_valencia,
    now() as timestamp_consulta;

-- Mostrar datos remotos de Caracas
SELECT 
    'Datos obtenidos del nodo remoto Caracas:' as origen,
    COUNT(*) as total_registros_caracas
FROM clientes_caracas;
```

### Captura 3: Fragmentación Horizontal
```sql
-- Demostrar fragmentación por ID
SELECT 
    'FRAGMENTACIÓN HORIZONTAL ACTIVA' as titulo,
    nodo_origen,
    MIN(id) as id_minimo,
    MAX(id) as id_maximo,
    COUNT(*) as total_registros
FROM clientes_unificados
GROUP BY nodo_origen
ORDER BY nodo_origen;
```

## 🔧 Comandos de Mantenimiento

### Backup Distribuido
```bash
# Backup de Caracas
docker exec db-caracas pg_dump -U postgres clientes_caracas > backup_caracas_$(date +%Y%m%d).sql

# Backup de Valencia
docker exec db-valencia pg_dump -U postgres clientes_valencia > backup_valencia_$(date +%Y%m%d).sql
```

### Monitoreo de Rendimiento
```sql
-- Estadísticas de consultas distribuidas
SELECT 
    schemaname,
    tablename,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    seq_scan,
    seq_tup_read
FROM pg_stat_user_tables
WHERE tablename IN ('clientes', 'clientes_caracas');
```

## 🚨 Consideraciones de Seguridad

### Producción
- Cambiar contraseñas por defecto
- Configurar SSL/TLS entre nodos
- Implementar firewall a nivel de red
- Usar certificados para autenticación

### Red
```bash
# Ejemplo de configuración de firewall (Ubuntu/CentOS)
# Permitir solo tráfico PostgreSQL entre nodos específicos
iptables -A INPUT -p tcp --dport 5432 -s 172.20.0.10 -j ACCEPT
iptables -A INPUT -p tcp --dport 5432 -s 172.20.0.11 -j ACCEPT
```

## 📊 Métricas de Rendimiento

### Latencia de Red
```sql
-- Medir tiempo de respuesta entre nodos
\timing on
SELECT COUNT(*) FROM clientes_caracas;
\timing off
```

### Throughput Distribuido
```sql
-- Consulta intensiva para medir rendimiento
EXPLAIN ANALYZE
SELECT 
    c1.nombre,
    c2.nombre
FROM clientes c1
CROSS JOIN clientes_caracas c2
LIMIT 100;
```

## 📝 Documentación para el Informe

### Sección 1: Arquitectura Implementada
- Diagrama de red Docker con IPs específicas
- Esquema de fragmentación horizontal
- Configuración de Foreign Data Wrapper

### Sección 2: Evidencias de Funcionamiento
- Screenshots de consultas ejecutadas desde Valencia
- Resultados mostrando datos de ambos nodos
- Logs de conexión entre servidores

### Sección 3: Pruebas de Integridad
- Verificación de que no hay duplicados entre nodos
- Pruebas de consistencia de datos
- Métricas de rendimiento

### Sección 4: Consultas Distribuidas
```sql
-- CONSULTA PRINCIPAL PARA DEMOSTRACIÓN
SELECT 
    '========================================' as separador
UNION ALL
SELECT 'CONSULTA DISTRIBUIDA - NODOS CARACAS Y VALENCIA'
UNION ALL
SELECT '========================================'
UNION ALL
SELECT 
    CONCAT(
        'ID: ', LPAD(id::text, 3, '0'),
        ' | Cliente: ', RPAD(nombre || ' ' || apellido, 20, ' '),
        ' | Ciudad: ', RPAD(ciudad, 8, ' '),
        ' | Nodo: ', nodo_origen
    ) as resultado
FROM clientes_unificados
ORDER BY 
    CASE WHEN separador IS NULL THEN id ELSE -1 END,
    separador NULLS FIRST;
```

## 🔄 Scripts de Automatización

### Script de Inicio Completo
```bash
#!/bin/bash
# inicio-distribuido.sh

echo "🚀 Iniciando Base de Datos Distribuida..."

# Limpiar contenedores existentes
docker-compose down -v

# Levantar servicios
docker-compose up -d

# Esperar que los servicios estén listos
echo "⏳ Esperando que los servicios estén listos..."
sleep 30

# Verificar conectividad
echo "🔍 Verificando conectividad..."
docker exec db-valencia psql -U postgres -d clientes_valencia -c "SELECT * FROM probar_conexion_caracas();"

echo "✅ Base de datos distribuida lista!"
echo "🌐 pgAdmin: http://localhost:8080"
echo "🗄️ Valencia: localhost:5433"
echo "🗄️ Caracas: localhost:5432"
```

### Script de Pruebas Automatizadas
```bash
#!/bin/bash
# test-distribuido.sh

echo "🧪 Ejecutando pruebas de distribución..."

# Test 1: Conectividad
echo "Test 1: Verificando conectividad entre nodos..."
RESULT=$(docker exec db-valencia psql -U postgres -d clientes_valencia -t -c "SELECT COUNT(*) FROM clientes_caracas;")
if [[ $RESULT -gt 0 ]]; then
    echo "✅ Conectividad OK: $RESULT registros remotos encontrados"
else
    echo "❌ Error de conectividad"
    exit 1
fi

# Test 2: Fragmentación
echo "Test 2: Verificando fragmentación horizontal..."
CARACAS_IDS=$(docker exec db-valencia psql -U postgres -d clientes_valencia -t -c "SELECT MAX(id) FROM clientes_caracas;")
VALENCIA_IDS=$(docker exec db-valencia psql -U postgres -d clientes_valencia -t -c "SELECT MIN(id) FROM clientes;")

echo "✅ Caracas MAX ID: $CARACAS_IDS"
echo "✅ Valencia MIN ID: $VALENCIA_IDS"

# Test 3: Vista unificada
echo "Test 3: Verificando vista unificada..."
TOTAL_UNIFICADO=$(docker exec db-valencia psql -U postgres -d clientes_valencia -t -c "SELECT COUNT(*) FROM clientes_unificados;")
echo "✅ Total registros unificados: $TOTAL_UNIFICADO"

echo "🎉 Todas las pruebas completadas exitosamente!"
```

## 📞 Soporte y Recursos Adicionales

### Logs Detallados
```bash
# Ver logs en tiempo real
docker-compose logs -f

# Logs específicos de un servicio
docker-compose logs db-valencia
docker-compose logs db-caracas
```

### Limpieza del Entorno
```bash
# Parar y limpiar todo
docker-compose down -v --remove-orphans

# Limpiar volúmenes
docker volume prune -f

# Limpiar redes
docker network prune -f
```

¡Con esta configuración tendrás una base de datos distribuida completamente funcional usando IPs reales en lugar de localhost!

## 🎯 Resultado Final

Tu base de datos distribuida:
- ✅ **Nodo Caracas**: IP 172.20.0.10 (Puerto 5432)
- ✅ **Nodo Valencia**: IP 172.20.0.11 (Puerto 5433)
- ✅ **Fragmentación Horizontal**: Caracas (ID ≤ 5), Valencia (ID > 5)
- ✅ **Consultas Distribuidas**: Desde Valencia accede a ambos nodos
- ✅ **Foreign Data Wrapper**: Conexión remota configurada
- ✅ **pgAdmin**: Interfaz gráfica en puerto 8080