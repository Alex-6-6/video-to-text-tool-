@echo off
setlocal
set "DIR=%~dp0"
if "%DIR:~-1%"=="\" set "DIR=%DIR:~0,-1%"

echo ============================================
echo  Downloading Whisper models + ffmpeg
echo  (about 3.4 GB total; interrupted downloads will resume)
echo  You can re-run this script anytime to continue.
echo ============================================

:: --- tiny model ---
echo [1/5] tiny model (fast, ~41 MB)...
curl -L -C - -o "%DIR%\m_fast.bin" "https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main/ggml-tiny-q8_0.bin"
if %ERRORLEVEL% NEQ 0 echo WARNING: tiny download may be incomplete.

:: --- small model ---
echo [2/5] small model (standard, ~252 MB)...
curl -L -C - -o "%DIR%\m_mid.bin" "https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main/ggml-small-q8_0.bin"
if %ERRORLEVEL% NEQ 0 echo WARNING: small download may be incomplete.

:: --- large model ---
echo [3/5] large model (precise, ~2.9 GB, this one takes a while)...
curl -L -C - --retry 3 --retry-delay 5 -o "%DIR%\m_large.bin" "https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin"
if %ERRORLEVEL% NEQ 0 echo WARNING: large download may be incomplete. Re-run script to resume.

:: --- ffmpeg ---
echo [4/5] ffmpeg (audio extractor, ~80 MB)...
:: Try primary source first
curl -L -C - --retry 3 --retry-delay 3 --max-time 300 -o "%DIR%\ffmpeg.zip" "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
if %ERRORLEVEL% NEQ 0 (
    echo   Primary source failed, trying mirror...
    curl -L -C - --retry 3 --retry-delay 3 --max-time 300 -o "%DIR%\ffmpeg.zip" "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
)

:: Check if ffmpeg.zip exists and is not empty
if exist "%DIR%\ffmpeg.zip" (
    for %%A in ("%DIR%\ffmpeg.zip") do set "FSIZE=%%~zA"
    if %FSIZE% GTR 100000 (
        echo   extracting...
        tar -xf "%DIR%\ffmpeg.zip" -C "%DIR%"
        :: Copy ffmpeg.exe from the extracted folder (path varies by source)
        if exist "%DIR%\ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe" (
            copy /Y "%DIR%\ffmpeg-master-latest-win64-gpl\bin\*" "%DIR%\" >nul 2>&1
            ren "%DIR%\ffmpeg.exe" "1.exe"
            rd /s /q "%DIR%\ffmpeg-master-latest-win64-gpl"
        ) else if exist "%DIR%\ffmpeg-*-essentials\bin\ffmpeg.exe" (
            for /d %%D in ("%DIR%\ffmpeg-*") do copy /Y "%%D\bin\*" "%DIR%\" >nul 2>&1
            ren "%DIR%\ffmpeg.exe" "1.exe"
            for /d %%D in ("%DIR%\ffmpeg-*") do rd /s /q "%%D"
        )
        del /q "%DIR%\ffmpeg.zip"
        echo   ffmpeg OK.
    ) else (
        echo   ERROR: ffmpeg.zip download incomplete or corrupted.
        echo   Delete ffmpeg.zip and re-run this script.
    )
) else (
    echo   ERROR: ffmpeg failed to download.
    echo   Re-run this script to retry.
)

:: --- summary ---
echo.
echo ============================================
echo  Summary:
for %%M in (m_fast.bin m_mid.bin m_large.bin 1.exe) do (
    if exist "%DIR%\%%M" (
        for %%A in ("%DIR%\%%M") do echo   [OK]   %%M   (%%~zA bytes)
    ) else (
        echo   [MISSING] %%M
    )
)
echo ============================================
echo.
echo If anything is missing or incomplete, just re-run this script.
echo It will skip what you already have and continue the rest.
echo.
pause
