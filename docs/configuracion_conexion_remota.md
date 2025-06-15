# Configuración de Conexiones Remotas en PostgreSQL

## 1. Configuración del Servidor (Nodo Caracas)

### 1.1 Modificar postgresql.conf
1. Localizar el archivo `postgresql.conf`:
   ```bash
   # Windows
   C:\Program Files\PostgreSQL\[version]\data\postgresql.conf

   # Linux
   /etc/postgresql/[version]/main/postgresql.conf
   ```

2. Editar el archivo y modificar:
   ```conf
   # Escuchar en todas las interfaces
   listen_addresses = '*'

   # Puerto para Caracas
   port = 5432
   ```

### 1.2 Modificar pg_hba.conf
1. Localizar el archivo `pg_hba.conf` en el mismo directorio
2. Agregar las siguientes líneas:
   ```conf
   # IPv4 local connections:
   host    all             all             0.0.0.0/0               md5
   # IPv6 local connections:
   host    all             all             ::/0                    md5
   ```

### 1.3 Reiniciar PostgreSQL
```bash
# Windows
net stop postgresql
net start postgresql

# Linux
sudo systemctl restart postgresql
```

## 2. Configuración del Cliente (Nodo Valencia)

### 2.1 Modificar postgresql.conf
1. Localizar el archivo `postgresql.conf`
2. Editar el archivo y modificar:
   ```conf
   # Escuchar en todas las interfaces
   listen_addresses = '*'

   # Puerto para Valencia
   port = 5433
   ```

### 2.2 Modificar pg_hba.conf
1. Agregar las mismas líneas que en Caracas
2. Asegurarse de que los puertos no estén bloqueados

## 3. Configuración de Firewall

### Windows
1. Abrir Firewall de Windows
2. Agregar reglas de entrada:
   ```bash
   # Para Caracas
   netsh advfirewall firewall add rule name="PostgreSQL Caracas" dir=in action=allow protocol=TCP localport=5432

   # Para Valencia
   netsh advfirewall firewall add rule name="PostgreSQL Valencia" dir=in action=allow protocol=TCP localport=5433
   ```

### Linux
```bash
# Para Caracas
sudo ufw allow 5432/tcp

# Para Valencia
sudo ufw allow 5433/tcp
```

## 4. Configuración en pgAdmin

### 4.1 Nodo Caracas
1. Click derecho en "Servers" → "Create" → "Server"
2. En la pestaña "Connection":
   - Host name/address: [IP del servidor Caracas]
   - Port: 5432
   - Maintenance database: postgres
   - Username: postgres
   - Password: [tu contraseña]

### 4.2 Nodo Valencia
1. Click derecho en "Servers" → "Create" → "Server"
2. En la pestaña "Connection":
   - Host name/address: [IP del servidor Valencia]
   - Port: 5433
   - Maintenance database: postgres
   - Username: postgres
   - Password: [tu contraseña]

## 5. Verificación de la Conexión

### 5.1 Desde la línea de comandos
```bash
# Conectar a Caracas
psql -h [IP_Caracas] -p 5432 -U postgres

# Conectar a Valencia
psql -h [IP_Valencia] -p 5433 -U postgres
```

### 5.2 Desde pgAdmin
1. Expandir el servidor
2. Verificar que se pueden ver las bases de datos
3. Probar una consulta simple:
   ```sql
   SELECT version();
   ```

## 6. Solución de Problemas

### 6.1 Error de Conexión Rechazada
1. Verificar que PostgreSQL está escuchando:
   ```bash
   # Windows
   netstat -ano | findstr "5432"
   netstat -ano | findstr "5433"

   # Linux
   sudo netstat -tulpn | grep postgres
   ```

2. Verificar firewall:
   ```bash
   # Windows
   netsh advfirewall firewall show rule name="PostgreSQL Caracas"
   netsh advfirewall firewall show rule name="PostgreSQL Valencia"

   # Linux
   sudo ufw status
   ```

### 6.2 Error de Autenticación
1. Verificar pg_hba.conf
2. Verificar credenciales
3. Verificar que el usuario tiene permisos

### 6.3 Error de Timeout
1. Verificar conectividad de red:
   ```bash
   # Windows
   ping [IP_destino]

   # Linux
   ping [IP_destino]
   ```

2. Verificar que los puertos están abiertos:
   ```bash
   # Windows
   telnet [IP_destino] 5432
   telnet [IP_destino] 5433

   # Linux
   nc -zv [IP_destino] 5432
   nc -zv [IP_destino] 5433
   ```

## 7. Consideraciones de Seguridad

1. **Restringir Acceso**
   - Modificar pg_hba.conf para limitar IPs
   - Usar contraseñas fuertes
   - Configurar SSL

2. **Monitoreo**
   - Revisar logs de conexión
   - Monitorear intentos de acceso
   - Configurar alertas

3. **Backup**
   - Realizar backups regulares
   - Probar restauración
   - Documentar procedimientos

## 8. Ejemplo de Configuración

### 8.1 pg_hba.conf (Ejemplo Seguro)
```conf
# Solo permitir conexiones desde IPs específicas
host    all             all             192.168.1.0/24           md5
host    all             all             10.0.0.0/8               md5
```

### 8.2 postgresql.conf (Ejemplo Optimizado)
```conf
# Conexiones
max_connections = 100
superuser_reserved_connections = 3

# Memoria
shared_buffers = 128MB
work_mem = 4MB

# Logging
log_destination = 'stderr'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
```

## 9. Mantenimiento

### 9.1 Verificar Conexiones Activas
```sql
SELECT * FROM pg_stat_activity;
```

### 9.2 Limpiar Conexiones Inactivas
```sql
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = 'clientes_caracas' 
AND pid <> pg_backend_pid();
```

### 9.3 Monitorear Uso de Recursos
```sql
SELECT * FROM pg_stat_database;
``` 