# Guía de Verificación y Pruebas

## 1. Verificación de la Instalación

### Verificar Servicios PostgreSQL
```bash
# Windows
sc query postgresql

# Linux
sudo systemctl status postgresql
```

### Verificar Puertos
```bash
# Windows
netstat -ano | findstr "5432"
netstat -ano | findstr "5433"

# Linux
sudo netstat -tulpn | grep postgres
```

## 2. Pruebas de Conexión

### Prueba Nodo Caracas
```bash
# Conectar a PostgreSQL
psql -U postgres -p 5432

# Verificar base de datos
\l

# Conectar a la base de datos
\c clientes_caracas

# Verificar tabla
\dt

# Verificar datos
SELECT * FROM clientes;
```

### Prueba Nodo Valencia
```bash
# Conectar a PostgreSQL
psql -U postgres -p 5433

# Verificar base de datos
\l

# Conectar a la base de datos
\c clientes_valencia

# Verificar tabla
\dt

# Verificar datos
SELECT * FROM clientes;
```

## 3. Pruebas de Fragmentación

### Verificar Datos en Caracas
```sql
-- Deben ser solo registros con ID <= 5
SELECT * FROM clientes
WHERE id <= 5;
```

### Verificar Datos en Valencia
```sql
-- Deben ser solo registros con ID > 5
SELECT * FROM clientes
WHERE id > 5;
```

## 4. Pruebas de Consultas Distribuidas

### Prueba 1: Consulta Básica
```sql
-- Debe mostrar todos los registros
SELECT * FROM clientes_unificados
ORDER BY id;
```

### Prueba 2: Filtrado por Ciudad
```sql
-- Debe mostrar registros de ambas ciudades
SELECT * FROM clientes_unificados
WHERE ciudad IN ('Caracas', 'Valencia')
ORDER BY ciudad, id;
```

### Prueba 3: Agrupación
```sql
-- Debe contar registros de ambas ciudades
SELECT ciudad, COUNT(*) as total
FROM clientes_unificados
GROUP BY ciudad
ORDER BY total DESC;
```

## 5. Verificación de Rendimiento

### Plan de Ejecución
```sql
-- Verificar que accede a ambos nodos
EXPLAIN ANALYZE
SELECT * FROM clientes_unificados
WHERE ciudad IN ('Caracas', 'Valencia');
```

### Estadísticas de Consultas
```sql
-- Verificar estadísticas de tablas
SELECT schemaname, relname, seq_scan, idx_scan
FROM pg_stat_user_tables
WHERE relname IN ('clientes', 'clientes_caracas');
```

## 6. Pruebas de Integridad

### Verificar Foreign Data Wrapper
```sql
-- Verificar extensión
SELECT * FROM pg_extension WHERE extname = 'postgres_fdw';

-- Verificar servidor
SELECT * FROM pg_foreign_server;

-- Verificar mapeo de usuario
SELECT * FROM pg_user_mappings;
```

### Verificar Vista
```sql
-- Verificar definición de la vista
SELECT pg_get_viewdef('clientes_unificados'::regclass);
```

## 7. Pruebas de Carga

### Insertar Datos Adicionales
```sql
-- En Caracas
INSERT INTO clientes (nombre, apellido, email, telefono, direccion, ciudad)
VALUES ('Nuevo', 'Cliente', 'nuevo@email.com', '0212-9999999', 'Nueva Dirección', 'Caracas');

-- En Valencia
INSERT INTO clientes (nombre, apellido, email, telefono, direccion, ciudad)
VALUES ('Otro', 'Cliente', 'otro@email.com', '0241-9999999', 'Otra Dirección', 'Valencia');
```

### Verificar Sincronización
```sql
-- Debe mostrar los nuevos registros
SELECT * FROM clientes_unificados
ORDER BY id DESC
LIMIT 2;
```

## 8. Pruebas de Recuperación

### Simular Fallo en Caracas
1. Detener servicio PostgreSQL en puerto 5432
2. Intentar consulta:
   ```sql
   SELECT * FROM clientes_unificados;
   ```
3. Verificar mensaje de error
4. Reiniciar servicio
5. Verificar recuperación

### Simular Fallo en Valencia
1. Detener servicio PostgreSQL en puerto 5433
2. Intentar consulta:
   ```sql
   SELECT * FROM clientes_unificados;
   ```
3. Verificar mensaje de error
4. Reiniciar servicio
5. Verificar recuperación

## 9. Documentación de Pruebas

### Plantilla de Registro
```
Fecha: [Fecha]
Prueba: [Nombre de la prueba]
Resultado: [Éxito/Fallo]
Observaciones: [Detalles]
```

### Ejemplo de Registro
```
Fecha: 2024-03-14
Prueba: Consulta distribuida básica
Resultado: Éxito
Observaciones: La consulta accede correctamente a ambos nodos y muestra todos los registros
```

## 10. Recomendaciones

1. Realizar pruebas periódicamente
2. Mantener registro de resultados
3. Documentar cualquier problema encontrado
4. Verificar rendimiento después de cambios
5. Realizar backups antes de pruebas importantes 