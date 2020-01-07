@echo off
setlocal
set AHDL_BIN=C:\lscc\diamond\3.10_x64\active-hdl\BIN
set PATH=%AHDL_BIN%;%PATH%

rem The test log is recreated by test.do
del test.log 2>NUL

rem -do is like -execute but it does not quit the GUI when the script stops
avhdl -quiet -nosplash -execute "runtests.do"

echo AVHDL process exited with code %ERRORLEVEL%
echo Test log:
echo ========
echo.
type test.log

