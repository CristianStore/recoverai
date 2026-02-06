@echo off
echo ---------------------------------------------------
echo  🚀 INITIALIZING RECOVERAI TUNNEL (SERVEO)
echo ---------------------------------------------------
echo.
echo  Trying to connect to Serveo...
echo  If it asks for "yes/no" regarding fingerprint, type yes.
echo.
echo  [IMPORTANT]
echo  LOOK FOR THE URL BELOW that looks like:
echo  https://xxxx.serveo.net
echo.
ssh -R 80:localhost:3000 serveo.net
pause
