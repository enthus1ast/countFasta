import ../../fastalib

doAssert cnt("tests/default/testfile.fasta") == 3
doAssert cntReport("tests/default/testfile.fasta") == 3