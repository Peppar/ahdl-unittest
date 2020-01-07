import sys
import random

if len(sys.argv) < 2:
    print("usage: {0} TEST_DATA_LENGTH".format(sys.argv[0]))
    sys.exit(1)

testDataLength = 4096
with open("test_fifo_testdata.sv", "w") as f:
    f.write("`define TEST_DATA_LENGTH {0}\n".format(testDataLength))
    f.write("`define TEST_DATA '{")
    for i in range(testDataLength):
        if i != 0:
            f.write(",")
        if i % 8 == 0:
            f.write(" \\\n  ")
        f.write("8'h{0:02x}".format(random.randint(0, 255)))
    f.write(" \\\n  }\n")

