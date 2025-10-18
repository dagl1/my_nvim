@echo off
set REPO=%LOCALAPPDATA%\nvim
echo Updating Neovim config...
cd /d "%REPO%"
git pull
echo Launching Neovide...
start "" "neovide.exe"