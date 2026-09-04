@echo off
chcp 65001 >nul
setlocal
title 组织人事系统 - 后端 (Spring Boot :8080)
cd /d "%~dp0"

rem ---------- 定位 JDK 17 ----------
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

rem ---------- 定位 Maven ----------
set "MVN_CMD="
if exist "%~dp0..\.tools-maven\apache-maven-3.9.6\bin\mvn.cmd" set "MVN_CMD=%~dp0..\.tools-maven\apache-maven-3.9.6\bin\mvn.cmd"
if not defined MVN_CMD (
    where mvn >nul 2>nul
    if not errorlevel 1 set "MVN_CMD=mvn"
)
if not defined MVN_CMD (
    echo [错误] 未找到 Maven，请安装 Maven 并加入 PATH 后重试。
    pause
    exit /b 1
)

echo 后端启动中，URL: http://localhost:8080  API文档: http://localhost:8080/doc.html
echo 按 Ctrl+C 停止。
"%MVN_CMD%" spring-boot:run
endlocal
