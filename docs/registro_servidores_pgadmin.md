# Guía de Registro de Servidores en pgAdmin 4

## 1. Acceso a pgAdmin 4

1. Abrir pgAdmin 4 desde el menú inicio o escritorio
2. Ingresar la contraseña maestra si es la primera vez
3. Se abrirá la interfaz principal en el navegador

## 2. Registro del Servidor Caracas

### Paso 1: Crear Server Group (Opcional)
1. Click derecho en "Servers" en el panel izquierdo
2. Seleccionar "Create" → "Server Group"
3. En el diálogo:
   - Name: `Venezuela`
   - Click en "Save"

### Paso 2: Registrar Servidor Caracas
1. Click derecho en el Server Group "Venezuela" (o en "Servers" si no creaste grupo)
2. Seleccionar "Create" → "Server"
3. En la ventana "Create - Server", completar:

#### Pestaña "General"
- Name: `Caracas`
- Comment: `Nodo principal en Caracas`

#### Pestaña "Connection"
- Host name/address: `localhost`
- Port: `5432`
- Maintenance database: `postgres`
- Username: `postgres`
- Password: [tu contraseña de PostgreSQL]
- Save password?: ✓ (marcar)

#### Pestaña "SSL"
- SSL mode: `Prefer`

4. Click en "Save"

## 3. Registro del Servidor Valencia

### Paso 1: Registrar Servidor Valencia
1. Click derecho en el Server Group "Venezuela" (o en "Servers")
2. Seleccionar "Create" → "Server"
3. En la ventana "Create - Server", completar:

#### Pestaña "General"
- Name: `Valencia`
- Comment: `Nodo secundario en Valencia`

#### Pestaña "Connection"
- Host name/address: `localhost`
- Port: `5433`
- Maintenance database: `postgres`
- Username: `postgres`
- Password: [tu contraseña de PostgreSQL]
- Save password?: ✓ (marcar)

#### Pestaña "SSL"
- SSL mode: `Prefer`

4. Click en "Save"

## 4. Verificación de la Conexión

### Verificar Servidor Caracas
1. Expandir el servidor "Caracas"
2. Deberías ver:
   - Databases
   - Login/Group Roles
   - Tablespaces
   - Catalogs
   - etc.

### Verificar Servidor Valencia
1. Expandir el servidor "Valencia"
2. Deberías ver la misma estructura que en Caracas

## 5. Solución de Problemas Comunes

### Error: No se puede conectar al servidor
1. Verificar que PostgreSQL esté corriendo:
   ```bash
   # Windows
   sc query postgresql

   # Linux
   sudo systemctl status postgresql
   ```

2. Verificar puertos:
   ```bash
   # Windows
   netstat -ano | findstr "5432"
   netstat -ano | findstr "5433"

   # Linux
   sudo netstat -tulpn | grep postgres
   ```

3. Verificar credenciales:
   - Usuario correcto
   - Contraseña correcta
   - Base de datos postgres existe

### Error: SSL no está habilitado
1. En la pestaña "SSL":
   - Cambiar SSL mode a `Disable` temporalmente
   - O configurar SSL en PostgreSQL

### Error: Timeout de conexión
1. En la pestaña "Connection":
   - Aumentar "Connection timeout"
   - Verificar firewall
   - Verificar que el servicio esté respondiendo

## 6. Configuración Adicional

### Cambiar Contraseña Guardada
1. Click derecho en el servidor
2. Seleccionar "Properties"
3. Ir a la pestaña "Connection"
4. Actualizar la contraseña
5. Click en "Save"

### Configurar Timeout
1. Click derecho en el servidor
2. Seleccionar "Properties"
3. Ir a la pestaña "Connection"
4. Ajustar "Connection timeout"
5. Click en "Save"

### Configurar Auto-connect
1. Click derecho en el servidor
2. Seleccionar "Properties"
3. Ir a la pestaña "Connection"
4. Marcar "Auto connect?"
5. Click en "Save"

## 7. Tips y Trucos

### Atajos de Teclado
- F5: Actualizar
- Ctrl+Alt+R: Registrar nuevo servidor
- Ctrl+Alt+D: Desconectar servidor

### Características Útiles
1. Auto-completado de nombres de servidor
2. Guardado de múltiples conexiones
3. Organización en grupos
4. Exportación/Importación de configuraciones

### Mejores Prácticas
1. Usar nombres descriptivos
2. Organizar servidores en grupos
3. Documentar configuraciones especiales
4. Mantener contraseñas seguras
5. Realizar backups de la configuración 