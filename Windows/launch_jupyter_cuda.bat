@echo off
setlocal

REM CUDA 13.0 torch, for machines with an NVIDIA GPU. Separate pixi env, same checkout.
set "PIXI_ENV=cuda"
set "TARGET_DIR=%USERPROFILE%\Desktop\jupyter-env"
set "GIT_SOURCE=https://github.com/cwood1967/jupyter-env.git"

REM Detached envs go in the user's home (C:\Users\<user>\pixi-envs), not the
REM Desktop checkout. The package cache still follows PIXI_CACHE_DIR if set.

set "PIXI_EXE=pixi"
where pixi >nul 2>nul
if errorlevel 1 (
    set "PIXI_EXE=%USERPROFILE%\.pixi\bin\pixi.exe"
)
if not "%PIXI_EXE%"=="pixi" if not exist "%PIXI_EXE%" (
    echo pixi not found - installing...
    powershell -ExecutionPolicy ByPass -c "irm -useb https://pixi.sh/install.ps1 | iex"
)
if not "%PIXI_EXE%"=="pixi" if not exist "%PIXI_EXE%" (
    echo Failed to install pixi. Install it manually from https://pixi.sh, then re-run this file.
    pause
    exit /b 1
)

if exist "%TARGET_DIR%\.git" (
    echo Updating existing jupyter-env checkout...
    git -C "%TARGET_DIR%" fetch origin && git -C "%TARGET_DIR%" reset --hard origin/main
) else (
    if exist "%TARGET_DIR%" (
        echo Removing incomplete previous checkout...
        rmdir /s /q "%TARGET_DIR%"
    )
    git clone "%GIT_SOURCE%" "%TARGET_DIR%"
)

set "NB_DIR=%~1"
if "%NB_DIR%"=="" (
    for /f "delims=" %%F in ('powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.OpenFileDialog; $f.ValidateNames = $false; $f.CheckFileExists = $false; $f.CheckPathExists = $true; $f.FileName = 'Select this folder'; $f.Title = 'Choose a folder to open in Jupyter'; if ($f.ShowDialog() -eq 'OK') { Split-Path $f.FileName }"') do set "NB_DIR=%%F"
)
if "%NB_DIR%"=="" (
    echo No folder selected.
    pause
    exit /b 1
)

cd /d "%TARGET_DIR%"
REM Stored in .pixi\config.toml, which git reset leaves alone.
"%PIXI_EXE%" config set --local detached-environments "%USERPROFILE%\pixi-envs"
echo Installing the %PIXI_ENV% environment - the CUDA torch download is large...
REM --frozen: install exactly what pixi.lock pins, without re-solving.
"%PIXI_EXE%" install --frozen -e %PIXI_ENV%
if errorlevel 1 (
    echo Environment install failed.
    pause
    exit /b 1
)
"%PIXI_EXE%" run --frozen -e %PIXI_ENV% jupyter lab --notebook-dir="%NB_DIR%"
