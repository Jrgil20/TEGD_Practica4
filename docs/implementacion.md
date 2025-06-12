# Implementación de Base de Datos Distribuida

## 1. Configuración de Nodos

### Nodo Caracas
- Host: localhost
- Puerto: 5432
- Base de datos: clientes_caracas
- Usuario: postgres
- Contraseña: postgres

### Nodo Valencia
- Host: localhost
- Puerto: 5433
- Base de datos: clientes_valencia
- Usuario: postgres
- Contraseña: postgres

## 2. Estructura de la Base de Datos

### Tabla Clientes
```sql
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(50),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 3. Fragmentación Horizontal

### Criterios de Fragmentación
- Nodo Caracas: Clientes con ID <= 5
- Nodo Valencia: Clientes con ID > 5

## 4. Configuración de Conexiones

### Foreign Data Wrapper
```sql
-- En nodo Valencia
CREATE EXTENSION postgres_fdw;

CREATE SERVER caracas_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'localhost', port '5432', dbname 'clientes_caracas');

CREATE USER MAPPING FOR postgres
    SERVER caracas_server
    OPTIONS (user 'postgres', password 'postgres');

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
```

## 5. Consultas Distribuidas

### Vista Unificada
```sql
CREATE VIEW clientes_unificados AS
SELECT * FROM clientes
UNION ALL
SELECT * FROM clientes_caracas;
```

### Ejemplo de Consulta
```sql
SELECT * FROM clientes_unificados
WHERE ciudad IN ('Caracas', 'Valencia')
ORDER BY id;
```

## 6. Verificación de la Distribución

Para verificar que la consulta se está realizando correctamente a través de la red:

1. Ejecutar la consulta desde pgAdmin conectado al nodo Valencia
2. Verificar en los logs de PostgreSQL que se realizan las conexiones
3. Comprobar que los resultados incluyen datos de ambos nodos

## 7. Consideraciones de Seguridad

1. Usar contraseñas fuertes
2. Limitar el acceso a los puertos de PostgreSQL
3. Configurar SSL para las conexiones entre nodos
4. Mantener actualizado PostgreSQL 