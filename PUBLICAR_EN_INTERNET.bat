@echo off
setlocal
echo.
echo ========================================================
echo   CONEXION ESTABLE (RecoverAI)
echo ========================================================
echo.
echo Obteniendo tu IP de seguridad (Necesaria para desbloquear el link)...
for /f "tokens=*" %%a in ('curl -s https://loca.lt/mytunnelpassword') do set TUNNEL_PASS=%%a
echo.
echo --------------------------------------------------------
echo   TU CLAVE DE ACCESO ES:  %TUNNEL_PASS%
echo --------------------------------------------------------
echo   (Copiala, la necesitaras en el celular la primera vez)
echo.
echo TU LINK DE TIENDA:
echo https://recoverai-demo-pro.loca.lt
echo.
echo Conectando...
echo.
call lt --port 3000 --subdomain recoverai-demo-pro
pause
