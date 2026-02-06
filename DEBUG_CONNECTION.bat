@echo off
title Debug RecoverAI Connection
echo.
echo ========================================================
echo   REPARACION DE CONEXION WHATSAPP
echo ========================================================
echo.
echo 1. Deteniendo procesos trabados...
taskkill /F /IM node.exe /T >nul 2>&1

echo.
echo 2. Eliminando sesion basura anterior...
cd /d "%~dp0backend"
if exist .wwebjs_auth (
    echo    - Borrando cache de autenticacion...
    rmdir /s /q .wwebjs_auth
)
if exist .wwebjs_cache (
    echo    - Borrando cache temporal...
    rmdir /s /q .wwebjs_cache
)

echo.
echo 3. INICIANDO SISTEMA EN MODO VISIBLE
echo --------------------------------------------------------
echo    POR FAVOR ESPERA A QUE SALGA EL CODIGO QR ABAJO
echo    (Puede tardar unos 10-20 segundos)
echo --------------------------------------------------------
echo.

node server.js

echo.
echo El servidor se ha detenido.
pause
