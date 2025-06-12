-- Crear base de datos
CREATE DATABASE clientes_valencia;

\c clientes_valencia

-- Crear tabla de clientes
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

-- Insertar datos de ejemplo (ID > 5)
INSERT INTO clientes (nombre, apellido, email, telefono, direccion, ciudad) VALUES
('Laura', 'Sánchez', 'laura@email.com', '0241-1234567', 'Av. Bolívar Norte #123', 'Valencia'),
('Roberto', 'Hernández', 'roberto@email.com', '0241-2345678', 'Calle Principal #456', 'Valencia'),
('Carmen', 'Díaz', 'carmen@email.com', '0241-3456789', 'Av. Universidad #789', 'Valencia'),
('José', 'Torres', 'jose@email.com', '0241-4567890', 'Calle Comercio #321', 'Valencia'),
('Isabel', 'Ramírez', 'isabel@email.com', '0241-5678901', 'Av. Bolívar Sur #654', 'Valencia');

-- Configurar Foreign Data Wrapper
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

-- Crear vista unificada
CREATE VIEW clientes_unificados AS
SELECT * FROM clientes
UNION ALL
SELECT * FROM clientes_caracas; 