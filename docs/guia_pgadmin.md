# Guía de Configuración de pgAdmin 4

## 1. Instalación de pgAdmin 4

### Windows
1. pgAdmin 4 se instala automáticamente con PostgreSQL
2. Si necesitas instalarlo por separado:
   - Descargar desde [pgadmin.org](https://www.pgadmin.org/download/)
   - Ejecutar el instalador
   - Seguir las instrucciones del asistente

### Linux
```bash
# Instalar pgAdmin 4
sudo apt install pgadmin4
```

## 2. Configuración de Servidores

### Nodo Caracas
1. Abrir pgAdmin 4
2. Click derecho en "Servers" → "Register" → "Server"
3. En la pestaña "General":
   - Name: Caracas
4. En la pestaña "Connection":
   - Host name/address: localhost
   - Port: 5432
   - Maintenance database: postgres
   - Username: postgres
   - Password: [tu contraseña]
5. Click en "Save"

### Nodo Valencia
1. Click derecho en "Servers" → "Register" → "Server"
2. En la pestaña "General":
   - Name: Valencia
3. En la pestaña "Connection":
   - Host name/address: localhost
   - Port: 5433
   - Maintenance database: postgres
   - Username: postgres
   - Password: [tu contraseña]
4. Click en "Save"

## 3. Ejecución de Scripts

### Nodo Caracas
1. Expandir el servidor "Caracas"
2. Click derecho en "Databases" → "Create" → "Database"
   - Database: clientes_caracas
   - Owner: postgres
3. Click derecho en la base de datos "clientes_caracas"
4. Seleccionar "Query Tool"
5. Copiar y pegar el contenido de `scripts/caracas/init.sql`
6. Click en "Execute" (F5)

### Nodo Valencia
1. Expandir el servidor "Valencia"
2. Click derecho en "Databases" → "Create" → "Database"
   - Database: clientes_valencia
   - Owner: postgres
3. Click derecho en la base de datos "clientes_valencia"
4. Seleccionar "Query Tool"
5. Copiar y pegar el contenido de `scripts/valencia/init.sql`
6. Click en "Execute" (F5)

## 4. Verificación de la Configuración

### Verificar Nodo Caracas
1. Expandir "Caracas" → "Databases" → "clientes_caracas" → "Schemas" → "public" → "Tables"
2. Click derecho en la tabla "clientes" → "View/Edit Data" → "All Rows"
3. Verificar que se muestren los 5 registros de Caracas

### Verificar Nodo Valencia
1. Expandir "Valencia" → "Databases" → "clientes_valencia" → "Schemas" → "public" → "Tables"
2. Click derecho en la tabla "clientes" → "View/Edit Data" → "All Rows"
3. Verificar que se muestren los 5 registros de Valencia
4. Expandir "Foreign Tables"
5. Click derecho en "clientes_caracas" → "View/Edit Data" → "All Rows"
6. Verificar que se muestren los registros de Caracas

## 5. Ejecución de Consultas Distribuidas

1. Conectarse al servidor "Valencia"
2. Abrir Query Tool
3. Ejecutar las consultas de ejemplo:
   ```sql
   -- Consulta que accede a ambos nodos
   SELECT * FROM clientes_unificados
   WHERE ciudad IN ('Caracas', 'Valencia')
   ORDER BY ciudad, id;
   ```

## 6. Monitoreo de Consultas

### Ver Plan de Ejecución
1. En Query Tool, escribir la consulta
2. Click en "Explain" (F7)
3. Analizar el plan de ejecución para verificar que accede a ambos nodos

### Ver Estadísticas
1. Click derecho en el servidor
2. Seleccionar "Statistics"
3. Revisar:
   - Database Statistics
   - Table Statistics
   - Index Statistics

## 7. Solución de Problemas en pgAdmin

### Error de Conexión
1. Verificar que el servicio PostgreSQL esté corriendo
2. Confirmar credenciales
3. Verificar puertos
4. Revisar firewall

### Error en Foreign Data Wrapper
1. Verificar extensión en pgAdmin:
   - Expandir "clientes_valencia" → "Extensions"
   - Confirmar que "postgres_fdw" está instalada
2. Si no está instalada:
   - Abrir Query Tool
   - Ejecutar: `CREATE EXTENSION postgres_fdw;`

### Error en Vista
1. Verificar que la vista existe:
   - Expandir "clientes_valencia" → "Views"
   - Confirmar que "clientes_unificados" está presente
2. Si no existe:
   - Abrir Query Tool
   - Ejecutar el script de creación de la vista

## 8. Tips y Trucos

### Atajos de Teclado
- F5: Ejecutar consulta
- F7: Mostrar plan de ejecución
- Ctrl+Space: Autocompletar
- Ctrl+/: Comentar/descomentar

### Características Útiles
1. Auto-completado de SQL
2. Resaltado de sintaxis
3. Formateo de código
4. Exportación de resultados
5. Historial de consultas

### Exportación de Datos
1. Click derecho en la tabla
2. Seleccionar "Import/Export"
3. Elegir formato (CSV, SQL, etc.)
4. Configurar opciones
5. Click en "OK" 