@echo off
title Backend Spring Boot
cd /d "%~dp0"
echo Starting backend (Spring Boot)...
echo URL: http://localhost:8080
echo Press Ctrl+C to stop.
mvn spring-boot:run
pause
