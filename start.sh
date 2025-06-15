#!/bin/bash

echo "==================================="
echo "Base de Datos Distribuida - Docker"
echo "==================================="
echo ""

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado"
    echo "Por favor, instala Docker Desktop desde https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: Docker Compose no está instalado"
    exit 1
fi

# Verificar si Docker está corriendo
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker no está corriendo"
    echo "Por favor, inicia Docker Desktop"
    exit 1
fi

echo "✅ Docker está instalado y corriendo"
echo ""

# Detener contenedores existentes si los hay
echo "🔄 Deteniendo contenedores existentes..."
docker-compose down

# Iniciar los servicios
echo "🚀 Iniciando servicios..."
docker-compose up -d

# Esperar a que los servicios estén listos
echo "⏳ Esperando a que los servicios estén listos..."
sleep 10

# Verificar el estado
echo ""
echo "📊 Estado de los servicios:"
docker-compose ps

echo ""
echo "✅ ¡Base de datos distribuida iniciada!"
echo ""
echo "📌 Accesos:"
echo "   - pgAdmin: http://localhost:5050"
echo "     Usuario: admin@admin.com"
echo "     Contraseña: admin"
echo ""
echo "   - PostgreSQL Caracas: localhost:5432"
echo "   - PostgreSQL Valencia: localhost:5433"
echo ""
echo "📝 Para verificar el funcionamiento:"
echo "   docker exec -it bd-valencia psql -U postgres -d clientes_valencia -c 'SELECT * FROM clientes_unificados ORDER BY id;'"
echo ""
echo "🛑 Para detener los servicios:"
echo "   docker-compose down"
echo "" 