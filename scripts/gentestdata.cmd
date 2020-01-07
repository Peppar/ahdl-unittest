@echo off
python gentestdata.py 4096 || goto :error
move /Y test_fifo_testdata.sv ..\unittests\src || goto :error
goto :EOF

:error
echo Failed
exit /b %errorlevel%

