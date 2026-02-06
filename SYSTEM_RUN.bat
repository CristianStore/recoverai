@echo off
:: SYSTEM_RUN.bat - Nucleo del sistema (Ejecutado por VBS de forma oculta)

:: 1. Limpieza
taskkill /F /IM node.exe /T >nul 2>&1

:: 2. Despliegue Frontend (Surge) - Rapido y silencioso
cd /d d:\RecoverAI\backend\public
call npx surge . --domain recoverai-pro-shop.surge.sh >nul 2>&1

:: 3. Inicio de Servicios en Background (Misma consola)
:: Backend
start /B cmd /c "cd /d d:\RecoverAI\backend && node server.js"
:: Frontend
start /B cmd /c "cd /d d:\RecoverAI\frontend && npm run dev"
:: Tunel (Backend API) - Usando Serveo por estabilidad CORS
start /B cmd /c "ssh -o StrictHostKeyChecking=no -R recoverai-api-cristian:80:localhost:3000 serveo.net"

:: 4. Espera de calentamiento
timeout /t 5 /nobreak >nul

:: 5. Abrir Dashboard (Visible para el usuario)
start chrome "http://localhost:5173"

:: 6. MANTENER VIVO (Critico para que no se cierren los procesos background)
:: Este bucle mantiene el script corriendo indefinidamente en modo oculto
:loop
timeout /t 60 /nobreak >nul
goto loop
