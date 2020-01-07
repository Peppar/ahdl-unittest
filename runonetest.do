echo "*" $testname "started at" [gettime] >> $logpath

# Initialize simulation
asim -lib fifo $testtop

# Run simulation
run
if $errors = 0
  # Test successful
  echo " " $testname "successful at" [gettime] >> $logpath
else
  # Test failed
  echo " " $testname "failed at" [gettime] >> $logpath
endif

