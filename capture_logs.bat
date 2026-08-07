@echo off
REM Script untuk capture Flutter logs
REM Jalankan script ini, lalu lakukan screening di app

echo ========================================
echo Flutter Logs Capture Script
echo ========================================
echo.
echo Instruksi:
echo 1. Script ini akan mulai capture logs
echo 2. Lakukan screening 3x dengan audio berbeda
echo 3. Tekan Ctrl+C untuk stop
echo 4. Logs akan tersimpan di screening_logs.txt
echo.
echo Tekan Enter untuk mulai...
pause > nul

cd /d "%~dp0"
echo.
echo Capturing logs... (Tekan Ctrl+C untuk stop)
echo.

flutter logs > screening_logs.txt 2>&1

echo.
echo Logs tersimpan di: screening_logs.txt
echo Silakan buka file tersebut dan cari baris dengan [TfliteService]
echo.
pause
