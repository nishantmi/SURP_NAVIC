These folders contain the VHDL codes for carrFreq and codeFreq blocks of the tracking Simulink model.

Both folders have MATLAB_Function.vhd and VHDLGen.vhd which were generated from the blocks in the tracking model using HDL Coder.

Currently, PDIcode/PDIcarr are both 0 so we do not have codeError/carrError as input (although TRACEFILE.txt has them).

testbench.vhd takes inputs from TRACEFILE.txt (generated using test_gen.py) and applies them to the DUT.
The outputs (expected and actual) are stores in output.txt which can be used for analysis in simResults.py