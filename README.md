Run cycle enumerating code on sample input and compare results
--------------------------------------------------------------

An ocaml script generates random directed graphs with loops.

Those loops are fed to a number of different cycle enumeration algorithms.

The outputs are compared with each other to ensure correct execution.

Setup
-----

	git submodule update --init

Usage
-----

	./test.sh 11

The argument to the shell script is an integer denoting the maximum number of
vertices for which graphs will be generated.
