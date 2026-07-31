@echo off
setlocal
set "DIR=%~dp0"
if "%DIR:~-1%"=="\" set "DIR=%DIR:~0,-1%"

echo ============================================
echo  Downloading Whisper models + ffmpeg
echo  (this may take a while, about 3.4 GB)
echo ============================================

echo [1/4] tiny model (fast)...
curl -L -o "%DIR%\m_fast.bin" "https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main/ggml-tiny-q8_0.bin"

echo [2/4] small model (standard)...
curl -L -o "%DIR%\m_mid.bin" "https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main/ggml-small-q8_0.bin"

echo [3/4] large model (precise)...
curl -L -o "%DIR%\m_large.bin" "https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin"

echo [4/4] ffmpeg (audio extractor)...
curl -L -o "%DIR%\ffmpeg.zip" "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
echo   extracting...
tar -xf "%DIR%\ffmpeg.zip" -C "%DIR%"
copy /Y "%DIR%\ffmpeg-master-latest-win64-gpl\bin\*" "%DIR%\" >nul 2>&1
ren "%DIR%\ffmpeg.exe" "1.exe"
rd /s /q "%DIR%\ffmpeg-master-latest-win64-gpl"
del /q "%DIR%\ffmpeg.zip"

echo ============================================
echo  Done. Everything is ready.
echo  Drag a video file onto 4.bat to start.
echo ============================================
pause
