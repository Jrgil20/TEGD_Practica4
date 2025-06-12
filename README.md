# Práctica N° 04: Bases de Datos Distribuidas

Crear una base de datos que contenga una tabla de registro de clientes en dos 
nodos (Caracas y Valencia) con el objetivo de hacer una consulta (Select) que 
realice la conexión al nodo de valencia y en dicha consulta se obtengan los registros 
de los clientes registrados en el nodo de Caracas y Valencia (Fragmentación 
Horizontal). Para el desarrollo de esta práctica puede considerar los campos más 
relevantes que debe poseer un registro de clientes. 

Para finalizar, en la redacción del informe de la práctica evidenciar que la consulta 
se conecta al nodo de Valencia a través de la red de datos y se obtiene los diferentes 
registros a través de un único query

## Descripción

Este proyecto implementa una base de datos distribuida con PostgreSQL, utilizando fragmentación horizontal para distribuir los datos de clientes entre dos nodos (Caracas y Valencia).

## Objetivos

- Crear una base de datos distribuida con dos nodos
- Implementar fragmentación horizontal de la tabla de clientes
- Realizar consultas que accedan a ambos nodos simultáneamente
- Documentar el proceso de implementación

## Requisitos

- PostgreSQL 15 o superior
- pgAdmin 4
- Docker (opcional)

## Estructura del Proyecto

```bash
    ├── docs/                    # Documentación detallada
    ├── scripts/                 # Scripts SQL y de configuración
    │   ├── caracas/            # Scripts para nodo Caracas
    │   └── valencia/           # Scripts para nodo Valencia
    └── README.md               # Este archivo
```

## Configuración

1. Instalar PostgreSQL en ambos nodos
2. Configurar las conexiones según los scripts en `scripts/`
3. Ejecutar los scripts de inicialización

## Uso

1. Conectarse al nodo de Valencia
2. Ejecutar las consultas de ejemplo en `scripts/queries.sql`

## Documentación

La documentación detallada se encuentra en la carpeta `docs/`
