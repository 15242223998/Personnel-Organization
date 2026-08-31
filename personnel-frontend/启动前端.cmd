@echo off
title Frontend Dev Server
cd /d "%~dp0"
echo Starting frontend dev server...
echo URL: http://localhost:5173
echo Press Ctrl+C to stop.
npm run dev
pause
