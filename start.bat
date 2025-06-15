@echo off
echo ===================================
echo Base de Datos Distribuida - Docker
echo ===================================
echo.

REM Verificar si Docker está instalado
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Docker no está instalado
    echo Por favor, instala Docker Desktop desde https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Verificar si Docker Compose está instalado
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Docker Compose no está instalado
    pause
    exit /b 1
)

REM Verificar si Docker está corriendo
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Docker no está corriendo
    echo Por favor, inicia Docker Desktop
    pause
    exit /b 1
)

echo ✅ Docker está instalado y corriendo
echo.

REM Detener contenedores existentes si los hay
echo 🔄 Deteniendo contenedores existentes...
docker-compose down

REM Iniciar los servicios
echo 🚀 Iniciando servicios...
docker-compose up -d

REM Esperar a que los servicios estén listos
echo ⏳ Esperando a que los servicios estén listos...
timeout /t 10 /nobreak >nul

REM Verificar el estado
echo.
echo 📊 Estado de los servicios:
docker-compose ps

echo.
echo ✅ ¡Base de datos distribuida iniciada!
echo.
echo 📌 Accesos:
echo    - pgAdmin: http://localhost:5050
echo      Usuario: admin@admin.com
echo      Contraseña: admin
echo.
echo    - PostgreSQL Caracas: localhost:5432
echo    - PostgreSQL Valencia: localhost:5433
echo.
echo 📝 Para verificar el funcionamiento:
echo    docker exec -it bd-valencia psql -U postgres -d clientes_valencia -c "SELECT * FROM clientes_unificados ORDER BY id;"
echo.
echo 🛑 Para detener los servicios:
echo    docker-compose down
echo.
pause 