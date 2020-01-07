set transcript off
set testroot [pwd]
set logpath $testroot\test.log

echo "Unit test run started at" [getdate] [gettime] >> $logpath
echo "Logging to" $logpath >> $logpath

workspace open sim
design activate unittest

# Compile all files
comp

set testname "FIFO"
set testtop test_fifo
do $testroot\runonetest.do


#set testname "Next module"
#set testtop test_next_module
#do $testroot\runonetest.do

echo "Unit test run finished at" [gettime] >> $logpath

set transcript on

