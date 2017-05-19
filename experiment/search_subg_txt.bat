@echo off
for /r %%i in (*subg*) do echo %%~nxi | findstr /v /i "mat" | findstr /v /i "txt"
pause