# Guía Detallada de Implementación

## 1. Requisitos Previos

### Software Necesario
- PostgreSQL 15 o superior
- pgAdmin 4
- Sistema operativo: Windows/Linux/MacOS

### Puertos Necesarios
- Puerto 5432 (Nodo Caracas)
- Puerto 5433 (Nodo Valencia)

## 2. Instalación de PostgreSQL

### Windows
1. Descargar PostgreSQL desde [postgresql.org](https://www.postgresql.org/download/windows/)
2. Ejecutar el instalador
3. Seleccionar los componentes:
   - PostgreSQL Server
   - pgAdmin 4
   - Command Line Tools
4. Establecer contraseña para el usuario postgres
5. Mantener el puerto por defecto (5432)

### Linux (Ubuntu/Debian)
```bash
# Actualizar repositorios
sudo apt update

# Instalar PostgreSQL
sudo apt install postgresql postgresql-contrib

# Iniciar servicio
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

## 3. Configuración de los Nodos

### Nodo Caracas (Puerto 5432)

1. Abrir pgAdmin 4
2. Crear nuevo servidor:
   - Nombre: Caracas
   - Host: localhost
   - Puerto: 5432
   - Usuario: postgres
   - Contraseña: [la establecida durante la instalación]

3. Ejecutar script de inicialización:
   ```bash
   # En Windows
   psql -U postgres -f scripts/caracas/init.sql

   # En Linux
   sudo -u postgres psql -f scripts/caracas/init.sql
   ```

### Nodo Valencia (Puerto 5433)

1. Modificar el puerto de PostgreSQL:
   ```bash
   # En Windows
   # Editar postgresql.conf en la carpeta de instalación
   # Cambiar port = 5432 a port = 5433

   # En Linux
   sudo nano /etc/postgresql/[version]/main/postgresql.conf
   # Cambiar port = 5432 a port = 5433
   ```

2. Reiniciar el servicio PostgreSQL
   ```bash
   # En Windows
   # Usar el Administrador de Servicios

   # En Linux
   sudo systemctl restart postgresql
   ```

3. Abrir pgAdmin 4
4. Crear nuevo servidor:
   - Nombre: Valencia
   - Host: localhost
   - Puerto: 5433
   - Usuario: postgres
   - Contraseña: [la establecida durante la instalación]

5. Ejecutar script de inicialización:
   ```bash
   # En Windows
   psql -U postgres -p 5433 -f scripts/valencia/init.sql

   # En Linux
   sudo -u postgres psql -p 5433 -f scripts/valencia/init.sql
   ```

## 4. Verificación de la Instalación

### Verificar Nodo Caracas
```sql
-- Conectarse a la base de datos
\c clientes_caracas

-- Verificar tabla y datos
SELECT * FROM clientes;
```

### Verificar Nodo Valencia
```sql
-- Conectarse a la base de datos
\c clientes_valencia

-- Verificar tabla y datos
SELECT * FROM clientes;

-- Verificar Foreign Data Wrapper
SELECT * FROM clientes_caracas;
```

## 5. Prueba de Consultas Distribuidas

1. Abrir pgAdmin 4
2. Conectarse al servidor Valencia
3. Abrir Query Tool
4. Ejecutar las consultas de ejemplo:
   ```sql
   -- Consulta que accede a ambos nodos
   SELECT * FROM clientes_unificados
   WHERE ciudad IN ('Caracas', 'Valencia')
   ORDER BY ciudad, id;
   ```

## 6. Solución de Problemas Comunes

### Error de Conexión
- Verificar que ambos servicios PostgreSQL estén corriendo
- Confirmar que los puertos estén correctamente configurados
- Verificar credenciales de acceso

### Error en Foreign Data Wrapper
```sql
-- Verificar extensión
SELECT * FROM pg_extension WHERE extname = 'postgres_fdw';

-- Si no existe, crear
CREATE EXTENSION postgres_fdw;
```

### Error en Mapeo de Usuario
```sql
-- Verificar mapeo
SELECT * FROM pg_user_mappings;

-- Si es necesario, recrear
DROP USER MAPPING IF EXISTS FOR postgres SERVER caracas_server;
CREATE USER MAPPING FOR postgres
    SERVER caracas_server
    OPTIONS (user 'postgres', password 'postgres');
```

## 7. Monitoreo y Mantenimiento

### Verificar Conexiones Activas
```sql
SELECT * FROM pg_stat_activity;
```

### Verificar Tamaño de las Tablas
```sql
SELECT pg_size_pretty(pg_total_relation_size('clientes'));
SELECT pg_size_pretty(pg_total_relation_size('clientes_caracas'));
```

### Limpiar Conexiones Inactivas
```sql
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = 'clientes_valencia' 
AND pid <> pg_backend_pid();
```

## 8. Consideraciones de Seguridad

1. Cambiar las contraseñas por defecto
2. Configurar pg_hba.conf para limitar accesos
3. Usar SSL para conexiones entre nodos
4. Mantener PostgreSQL actualizado
5. Realizar backups regulares

## 9. Scripts de Mantenimiento

### Backup
```bash
# Backup nodo Caracas
pg_dump -U postgres -p 5432 clientes_caracas > backup_caracas.sql

# Backup nodo Valencia
pg_dump -U postgres -p 5433 clientes_valencia > backup_valencia.sql
```

### Restore
```bash
# Restore nodo Caracas
psql -U postgres -p 5432 clientes_caracas < backup_caracas.sql

# Restore nodo Valencia
psql -U postgres -p 5433 clientes_valencia < backup_valencia.sql
``` 