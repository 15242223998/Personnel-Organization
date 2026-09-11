@echo off
chcp 65001 >nul
setlocal
title 组织人事系统 - 一键启动
cd /d "%~dp0"

echo ============================================================
echo            高校干部人事组织管理系统 - 一键启动
echo ============================================================
echo.

rem ---------- 1. 定位 JDK 17 ----------
set "JDK_DIR=C:\Program Files\Java\jdk-17"
if exist "%JDK_DIR%\bin\java.exe" (
    set "JAVA_HOME=%JDK_DIR%"
    set "PATH=%JDK_DIR%\bin;%PATH%"
) else (
    where java >nul 2>nul
    if errorlevel 1 (
        echo [错误] 未找到 Java 17，请安装 JDK 17 或配置 JAVA_HOME 后重试。
        pause
        exit /b 1
    )
)

rem ---------- 2. 定位 Maven ----------
set "MVN_CMD="
if exist "%~dp0.tools-maven\apache-maven-3.9.6\bin\mvn.cmd" set "MVN_CMD=%~dp0.tools-maven\apache-maven-3.9.6\bin\mvn.cmd"
if not defined MVN_CMD (
    where mvn >nul 2>nul
    if not errorlevel 1 set "MVN_CMD=mvn"
)
if not defined MVN_CMD (
    echo [错误] 未找到 Maven，请安装 Maven 并加入 PATH 后重试。
    pause
    exit /b 1
)
echo [OK] JDK 与 Maven 就绪：%MVN_CMD%

rem ---------- 3. 启动后端 (8080) ----------
echo [1/3] 正在启动后端 Spring Boot (http://localhost:8080) ...
cd /d "%~dp0personnel-backend"
start "Personnel-Backend-8080" cmd /k ""%MVN_CMD%" spring-boot:run"

rem ---------- 4. 启动前端 (5173，开放局域网供平板访问) ----------
echo [2/3] 正在启动前端 Vite (http://localhost:5173) ...
cd /d "%~dp0personnel-frontend"
start "Personnel-Frontend-5173" cmd /k "npm run dev -- --host"

rem ---------- 5. 等待并打开浏览器 ----------
echo [3/3] 等待服务启动...
timeout /t 10 /nobreak >nul
start "" "http://localhost:5173/login?logout=1"

echo.
echo ============================================================
echo  后端接口: http://localhost:8080   API文档: http://localhost:8080/doc.html
echo  前端页面: http://localhost:5173   默认账号: admin / 123456
rem 取本机局域网 IP，便于平板访问投票端
set "LANIP="
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 ^| Where-Object { $_.IPAddress -notlike ''127.*'' -and $_.IPAddress -notlike ''169.254.*'' } ^| Select-Object -First 1).IPAddress" 2^>nul') do set "LANIP=%%i"
if not defined LANIP set "LANIP=<本机局域网IP>"
echo  平板签字端: http://%LANIP%:5173/tablet
echo.
echo  提示：关闭对应黑色窗口即可停止服务。此窗口可按任意键关闭。
echo ============================================================
pause
endlocal
