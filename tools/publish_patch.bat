@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish_patch.ps1" %*
pause
