@echo off
echo.
echo ========================================================
echo   PUBLICACION PROFESIONAL (Web Real)
echo ========================================================
echo.
echo FASE 1: Subiendo tu Pagina Web a Internet (Surge)...
echo Si te pide E-mail y Password, pon los tuyos para crear tu cuenta gratis.
echo.
cd d:\RecoverAI\backend\public
call npx surge . --domain recoverai-pro-shop.surge.sh
echo.
echo.
echo FASE 2: Conectando el Cerebro (Backend)...
echo Ya no necesitas copiar contrasenas. Dejalo corriendo.
echo.
call lt --port 3000 --subdomain recoverai-backend-pro
pause
