# Base de Datos Distribuida con Docker

Esta guía te permitirá ejecutar la base de datos distribuida usando Docker en una sola máquina.

## Arquitectura

- **Nodo Caracas**: PostgreSQL en puerto 5432 (IP: 172.20.0.10)
- **Nodo Valencia**: PostgreSQL en puerto 5433 (IP: 172.20.0.11)
- **pgAdmin**: Interfaz web en puerto 5050

## Requisitos Previos

- Docker Desktop instalado
- Docker Compose instalado
- Puertos 5432, 5433 y 5050 disponibles

## Instrucciones de Instalación

### 1. Clonar o descargar el proyecto

```bash
git clone [URL_DEL_REPOSITORIO]
cd TEGD_Practica4
```

### 2. Iniciar los contenedores

```bash
# Iniciar todos los servicios
docker-compose up -d

# Verificar que los contenedores estén corriendo
docker-compose ps
```

### 3. Verificar los logs

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs específicos
docker-compose logs -f postgres-caracas
docker-compose logs -f postgres-valencia
```

### 4. Acceder a pgAdmin

1. Abrir navegador web
2. Ir a: http://localhost:5050
3. Credenciales:
   - Email: `admin@admin.com`
   - Password: `admin`

### 5. Configurar servidores en pgAdmin

#### Servidor Caracas:
- Click derecho en "Servers" → "Register" → "Server"
- General:
  - Name: `Caracas`
- Connection:
  - Host: `bd-caracas` (o `172.20.0.10`)
  - Port: `5432`
  - Database: `postgres`
  - Username: `postgres`
  - Password: `postgres`

#### Servidor Valencia:
- Click derecho en "Servers" → "Register" → "Server"
- General:
  - Name: `Valencia`
- Connection:
  - Host: `bd-valencia` (o `172.20.0.11`)
  - Port: `5432`
  - Database: `postgres`
  - Username: `postgres`
  - Password: `postgres`

## Verificación de la Instalación

### Opción 1: Desde la línea de comandos

```bash
# Conectar al nodo Valencia
docker exec -it bd-valencia psql -U postgres -d clientes_valencia

# Ejecutar consulta distribuida
SELECT * FROM clientes_unificados ORDER BY id;

# Salir
\q
```

### Opción 2: Usando el script de verificación

```bash
# Ejecutar script de verificación
docker exec -it bd-valencia psql -U postgres -f /docker-entrypoint-initdb.d/init.sql
```

### Opción 3: Desde pgAdmin

1. Conectarse al servidor Valencia
2. Navegar a: Databases → clientes_valencia
3. Click derecho → Query Tool
4. Ejecutar:
```sql
-- Ver todos los clientes (local + remoto)
SELECT * FROM clientes_unificados 
ORDER BY id;

-- Verificar que accede a ambos nodos
EXPLAIN ANALYZE
SELECT * FROM clientes_unificados
WHERE ciudad IN ('Caracas', 'Valencia');
```

## Comandos Útiles

### Gestión de contenedores

```bash
# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes (BORRA TODOS LOS DATOS)
docker-compose down -v

# Reiniciar un servicio específico
docker-compose restart postgres-valencia

# Ver logs en tiempo real
docker-compose logs -f
```

### Acceso directo a PostgreSQL

```bash
# Conectar a Caracas
docker exec -it bd-caracas psql -U postgres

# Conectar a Valencia
docker exec -it bd-valencia psql -U postgres

# Ejecutar consulta directa en Valencia
docker exec -it bd-valencia psql -U postgres -d clientes_valencia -c "SELECT * FROM clientes_unificados;"
```

### Verificar conectividad entre contenedores

```bash
# Desde Valencia, hacer ping a Caracas
docker exec -it bd-valencia ping -c 3 172.20.0.10

# Verificar que Valencia puede conectarse a Caracas
docker exec -it bd-valencia psql -h 172.20.0.10 -U postgres -d clientes_caracas -c "SELECT COUNT(*) FROM clientes;"
```

## Solución de Problemas

### Error: Los contenedores no inician

```bash
# Ver logs detallados
docker-compose logs postgres-caracas
docker-compose logs postgres-valencia

# Verificar que los puertos no estén en uso
netstat -ano | findstr "5432"
netstat -ano | findstr "5433"
```

### Error: No se puede conectar entre nodos

```bash
# Verificar la red Docker
docker network inspect tegd_practica4_bd-network

# Reiniciar los servicios
docker-compose restart
```

### Error: Foreign Data Wrapper no funciona

```bash
# Conectar a Valencia y verificar
docker exec -it bd-valencia psql -U postgres -d clientes_valencia

# Verificar extensión
SELECT * FROM pg_extension WHERE extname = 'postgres_fdw';

# Verificar servidor remoto
SELECT * FROM pg_foreign_server;
```

## Demostración de Consulta Distribuida

Para demostrar que la consulta accede a ambos nodos a través de la red:

1. Ejecutar en pgAdmin (conectado a Valencia):
```sql
-- Esta consulta accede a datos locales (Valencia) y remotos (Caracas)
EXPLAIN (ANALYZE, VERBOSE, BUFFERS) 
SELECT * FROM clientes_unificados 
WHERE ciudad IN ('Caracas', 'Valencia')
ORDER BY id;
```

2. El plan de ejecución mostrará:
   - `Append` (combina resultados)
   - `Seq Scan on clientes` (datos locales de Valencia)
   - `Foreign Scan on clientes_caracas` (datos remotos de Caracas via FDW)

## Capturas de Pantalla Recomendadas para el Informe

1. Docker Desktop mostrando los contenedores corriendo
2. pgAdmin con ambos servidores conectados
3. Resultado de la consulta `SELECT * FROM clientes_unificados`
4. Plan de ejecución mostrando el Foreign Scan
5. Logs de Docker mostrando la comunicación entre nodos

## Limpieza

Para eliminar todo y empezar de nuevo:

```bash
# Detener y eliminar contenedores, redes y volúmenes
docker-compose down -v

# Verificar que todo se eliminó
docker ps -a
docker volume ls
docker network ls
``` 