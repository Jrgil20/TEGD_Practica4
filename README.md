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
- Docker y Docker Compose (para instalación con contenedores)

## Opciones de Instalación

### Opción 1: Docker (Recomendado)
Si no tienes dos computadoras disponibles, puedes usar Docker para simular ambos nodos en una sola máquina. Ver [DOCKER_README.md](DOCKER_README.md) para instrucciones detalladas.

### Opción 2: Instalación Manual
Para instalación en máquinas separadas o en una sola máquina con diferentes puertos, ver la documentación en la carpeta `docs/`.

## Estructura del Proyecto

```bash
├── docs/                    # Documentación detallada
├── scripts/                 # Scripts SQL y de configuración
│   ├── caracas/            # Scripts para nodo Caracas
│   └── valencia/           # Scripts para nodo Valencia
├── docker-compose.yml      # Configuración de Docker
├── DOCKER_README.md        # Guía de instalación con Docker
└── README.md               # Este archivo
```

## Inicio Rápido con Docker

```bash
# Clonar el repositorio
git clone [URL_DEL_REPOSITORIO]
cd TEGD_Practica4

# Iniciar los servicios
docker-compose up -d

# Verificar que todo esté funcionando
docker-compose ps

# Acceder a pgAdmin
# Abrir navegador: http://localhost:5050
# Usuario: admin@admin.com
# Contraseña: admin
```

## Configuración Manual

1. Instalar PostgreSQL en ambos nodos
2. Configurar las conexiones según los scripts en `scripts/`
3. Ejecutar los scripts de inicialización

## Uso

1. Conectarse al nodo de Valencia
2. Ejecutar las consultas de ejemplo en `scripts/queries.sql`

## Documentación

La documentación detallada se encuentra en la carpeta `docs/`
