@echo off
rem Maven execution helper for FitTrack project
set "MAVEN_EXE=C:\Program Files\JetBrains\IntelliJ IDEA 2026.2.3\plugins\maven-plugin\lib\maven3\bin\mvn.cmd"
if exist "%MAVEN_EXE%" (
    "%MAVEN_EXE%" %*
) else (
    mvn %*
)
