alog -O2 -protect 0 -msg 5 -sve "$dsn/src/test_fifo.sv"
acom -2008 -O3 -e 100 -protect 0 -reorder "$dsn/src/fifo.vhd"
