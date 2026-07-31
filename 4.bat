@echo off
setlocal
set "DIR=%~dp0"
if "%DIR:~-1%"=="\" set "DIR=%DIR:~0,-1%"

if "%~1"=="" (
  echo Usage: drag a video file onto this bat.
  pause
  exit /b
)

echo ============================================
echo  Select model tier:
echo    1 = Fast     (tiny,   quick, less accurate)
echo    2 = Standard (small,  balanced)   [default]
echo    3 = Precise  (large,  slow, most accurate)
echo ============================================
set "TIER=2"
set /p "TIER=Enter 1 / 2 / 3 (default 2): "

if "%TIER%"=="1" (
  set "MODEL=m_fast.bin"
  echo Tier: Fast (tiny)
) else if "%TIER%"=="3" (
  set "MODEL=m_large.bin"
  echo Tier: Precise (large)
) else (
  set "TIER=2"
  set "MODEL=m_mid.bin"
  echo Tier: Standard (small)
)

if not exist "%DIR%\%MODEL%" (
  echo ERROR: model file "%MODEL%" not found in toolkit folder.
  pause
  exit /b
)

set "TMPDIR=%TEMP%\whisper_run"
if not exist "%TMPDIR%" mkdir "%TMPDIR%"

echo [1/2] Extracting audio...
"%DIR%\1.exe" -y -i "%~1" -ar 16000 -ac 1 "%DIR%\audio.wav"
if not exist "%DIR%\audio.wav" (
  echo Error: audio extraction failed.
  pause
  exit /b
)

echo [2/2] Recognizing (tier %TIER%)...
copy /Y "%DIR%\%MODEL%" "%TMPDIR%\model.bin" >nul 2>&1
copy /Y "%DIR%\audio.wav" "%TMPDIR%\audio.wav" >nul 2>&1
copy /Y "%DIR%\2.exe" "%TMPDIR%\whisper.exe" >nul 2>&1
copy /Y "%DIR%\whisper.dll" "%TMPDIR%\whisper.dll" >nul 2>&1
copy /Y "%DIR%\ggml.dll" "%TMPDIR%\ggml.dll" >nul 2>&1
copy /Y "%DIR%\ggml-base.dll" "%TMPDIR%\ggml-base.dll" >nul 2>&1
copy /Y "%DIR%\ggml-cpu-haswell.dll" "%TMPDIR%\ggml-cpu-haswell.dll" >nul 2>&1

cd /d "%TMPDIR%"
whisper.exe -m model.bin -f audio.wav -l zh -t 8 -osrt -oj -of transcript

if exist "%TMPDIR%\transcript.srt" (
  copy /Y "%TMPDIR%\transcript.srt" "%DIR%\transcript.srt" >nul 2>&1
  copy /Y "%TMPDIR%\transcript.json" "%DIR%\transcript.json" >nul 2>&1
  echo Done. transcript.srt is in the toolkit folder.
) else (
  echo ERROR: transcript.srt was NOT produced.
  echo Check the error message above.
)

cd /d "%DIR%"
pause
