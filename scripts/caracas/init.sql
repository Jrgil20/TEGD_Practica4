-- Crear base de datos
CREATE DATABASE clientes_caracas;

\c clientes_caracas

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

-- Insertar datos de ejemplo (ID <= 5)
INSERT INTO clientes (nombre, apellido, email, telefono, direccion, ciudad) VALUES
('Juan', 'Pérez', 'juan@email.com', '0212-1234567', 'Av. Principal #123', 'Caracas'),
('María', 'González', 'maria@email.com', '0212-2345678', 'Calle Secundaria #456', 'Caracas'),
('Carlos', 'Rodríguez', 'carlos@email.com', '0212-3456789', 'Av. Libertador #789', 'Caracas'),
('Ana', 'Martínez', 'ana@email.com', '0212-4567890', 'Calle Principal #321', 'Caracas'),
('Pedro', 'López', 'pedro@email.com', '0212-5678901', 'Av. Bolívar #654', 'Caracas'); 