# Configuración Base de Datos Distribuida con VMs

## 🖥️ Configuración de Máquinas Virtuales

### Requisitos de Hardware
- **VM Caracas**: 2GB RAM, 20GB disco, Ubuntu Server 22.04
- **VM Valencia**: 2GB RAM, 20GB disco, Ubuntu Server 22.04
- Red configurada en modo Bridge o NAT con IPs estáticas

### Configuración de Red

#### VM Caracas (ejemplo)
```bash
# /etc/netplan/00-installer-config.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

#### VM Valencia (ejemplo)
```bash
# /etc/netplan/00-installer-config.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 192.168.1.101/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

### Instalación PostgreSQL

#### En ambas VMs:
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar PostgreSQL
sudo apt install postgresql postgresql-contrib -y

# Iniciar servicio
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Configurar contraseña de postgres
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres123';"
```

### Configuración de Acceso Remoto

#### En VM Caracas:
```bash
# Editar postgresql.conf
sudo nano /etc/postgresql/15/main/postgresql.conf

# Cambiar:
listen_addresses = '*'
port = 5432

# Editar pg_hba.conf
sudo nano /etc/postgresql/15/main/pg_hba.conf

# Agregar al final:
host    all             all             192.168.1.0/24          md5

# Reiniciar PostgreSQL
sudo systemctl restart postgresql
```

#### En VM Valencia:
```bash
# Misma configuración que Caracas
sudo nano /etc/postgresql/15/main/postgresql.conf
# listen_addresses = '*'

sudo nano /etc/postgresql/15/main/pg_hba.conf
# host    all             all             192.168.1.0/24          md5

sudo systemctl restart postgresql
```

### Script de Inicialización Caracas (VM)
```sql
-- caracas-vm-init.sql
CREATE DATABASE clientes_caracas;
\c clientes_caracas

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(50) NOT NULL DEFAULT 'Caracas',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO clientes (nombre, apellido, email, telefono, direccion, ciudad) VALUES
('Juan', 'Pérez', 'juan.perez@email.com', '0212-1234567', 'Av. Principal #123', 'Caracas'),
('María', 'González', 'maria.gonzalez@email.com', '0212-2345678', 'Calle Secundaria #456', 'Caracas'),
('Carlos', 'Rodríguez', 'carlos.rodriguez@email.com', '0212-3456789', 'Av. Libertador #789', 'Caracas'),
('Ana', 'Martínez', 'ana.martinez@email.com', '0212-4567890', 'Calle Principal #321', 'Caracas'),
('Pedro', 'López', 'pedro.lopez@email.com', '0212-5678901', 'Av. Bolívar #654', 'Caracas');

-- Ejecutar en Caracas:
-- sudo -u postgres psql -f caracas-vm-init.sql
```

### Script de Inicialización Valencia (VM)
```sql
-- valencia-vm-init.sql
CREATE DATABASE clientes_valencia;
\c clientes_valencia

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(50) NOT NULL DEFAULT 'Valencia',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO clientes (nombre, apellido, email, telefono, direccion, ciudad) VALUES
('Laura', 'Sánchez', 'laura.sanchez@email.com', '0241-1234567', 'Av. Bolívar Norte #123', 'Valencia'),
('Roberto', 'Hernández', 'roberto.hernandez@email.com', '0241-2345678', 'Calle Principal #456', 'Valencia'),
('Carmen', 'Díaz', 'carmen.diaz@email.com', '0241-3456789', 'Av. Universidad #789', 'Valencia'),
('José', 'Torres', 'jose.torres@email.com', '0241-4567890', 'Calle Comercio #321', 'Valencia'),
('Isabel', 'Ramírez', 'isabel.ramirez@email.com', '0241-5678901', 'Av. Bolívar Sur #654', 'Valencia');

-- Configurar Foreign Data Wrapper
CREATE EXTENSION postgres_fdw;

-- IMPORTANTE: Usar la IP real de la VM Caracas
CREATE SERVER caracas_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host '192.168.1.100', port '5432', dbname 'clientes_caracas');

CREATE USER MAPPING FOR postgres
    SERVER caracas_server
    OPTIONS (user 'postgres', password 'postgres123');

CREATE FOREIGN TABLE clientes_caracas (
    id INTEGER,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(50),
    fecha_registro TIMESTAMP
)
SERVER caracas_server
OPTIONS (schema_name 'public', table_name 'clientes');

-- Vista unificada
CREATE VIEW clientes_unificados AS
SELECT *, 'Valencia' as nodo_origen FROM clientes
UNION ALL
SELECT *, 'Caracas' as nodo_origen FROM clientes_caracas;

-- Ejecutar en Valencia:
-- sudo -u postgres psql -f valencia-vm-init.sql
```

### Pruebas de Conectividad entre VMs

#### Desde VM Valencia:
```bash
# Probar conectividad de red
ping 192.168.1.100

# Probar conexión PostgreSQL
psql -h 192.168.1.100 -U postgres -d clientes_caracas -c "SELECT COUNT(*) FROM clientes;"

# Conectar a BD local y probar foreign table
sudo -u postgres psql -d clientes_valencia -c "SELECT COUNT(*) FROM clientes_caracas;"
```

### Firewall y Seguridad

#### En ambas VMs:
```bash
# Configurar UFW
sudo ufw enable
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 5432/tcp  # PostgreSQL

# Permitir solo desde la otra VM
sudo ufw allow from 192.168.1.100 to any port 5432  # En Valencia
sudo ufw allow from 192.168.1.101 to any port 5432  # En Caracas
```

### Monitoreo y Diagnóstico

#### Verificar servicios:
```bash
# Estado de PostgreSQL
sudo systemctl status postgresql

# Puertos escuchando
sudo netstat -tlnp | grep 5432

# Logs de PostgreSQL
sudo tail -f /var/log/postgresql/postgresql-15-main.log
```

#### Pruebas de rendimiento:
```bash
# Desde Valencia, medir latencia hacia Caracas
sudo -u postgres psql -d clientes_valencia -c "\timing on" -c "SELECT COUNT(*) FROM clientes_caracas;" -c "\timing off"
```

### Script de Automatización para VMs

```bash
#!/bin/bash
# setup-vm-distribuida.sh

echo "🔧 Configurando Base de Datos Distribuida en VMs..."

# Variables
CARACAS_IP="192.168.1.100"
VALENCIA_IP="192.168.1.101"

# Función para configurar VM
configure_vm() {
    local vm_name=$1
    local vm_ip=$2
    
    echo "Configurando VM: $vm_name ($vm_ip)"
    
    # Actualizar sistema
    sudo apt update && sudo apt upgrade -y
    
    # Instalar PostgreSQL
    sudo apt install postgresql postgresql-contrib -y
    
    # Configurar PostgreSQL
    sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/15/main/postgresql.conf
    echo "host all all 192.168.1.0/24 md5" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf
    
    # Configurar contraseña
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres123';"
    
    # Reiniciar servicio
    sudo systemctl restart postgresql
    
    echo "✅ VM $vm_name configurada"
}

# Detectar IP de la máquina actual
CURRENT_IP=$(hostname -I | awk '{print $1}')

if [[ "$CURRENT_IP" == "$CARACAS_IP" ]]; then
    configure_vm "Caracas" "$CARACAS_IP"
    sudo -u postgres psql -f caracas-vm-init.sql
elif [[ "$CURRENT_IP" == "$VALENCIA_IP" ]]; then
    configure_vm "Valencia" "$VALENCIA_IP"
    sudo -u postgres psql -f valencia-vm-init.sql
else
    echo "❌ IP no reconocida. Configurar manualmente."
fi

echo "🎉 Configuración completada!"
```

## 🔗 Integración con pgAdmin

### Instalar pgAdmin en una tercera VM o máquina host:
```bash
# Instalar pgAdmin4
sudo apt install curl
curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list
sudo apt update
sudo apt install pgadmin4
```

### Configurar conexiones en pgAdmin:
- **Servidor Caracas**: Host `192.168.1.100`, Puerto `5432`
- **Servidor Valencia**: Host `192.168.1.101`, Puerto `5432`

¡Con esta configuración tendrás una base distribuida real con VMs separadas usando sus propias IPs!