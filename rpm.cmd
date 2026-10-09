@echo off
rem Smart alias forwarding rpm commands to npm
if /i "%~1"=="dev" (
    if /i "%~2"=="run" (
        npm run dev
        goto :eof
    )
    npm run dev
    goto :eof
)
if /i "%~1"=="run" (
    npm run %2 %3 %4 %5 %6 %7 %8 %9
    goto :eof
)
npm %*
