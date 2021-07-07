Please run config.m before running the Simulink Model.

Use sv22.bin as input to the model (in the Binary File Reader). This file has signal data whose first entry corresponds to the start of the CACode for satellite number 22. To simulate the model for any other satellite, create a binary file such that the first entry corresponds to the start of the CA code for that satellite.

The tracking results generated after running the Matlab Code are contained in codeResults.jpg while the tracking results generated after simulating the Simulink Model are contained in simResults.jpg

trackingModelFixedPoint uses a fixed point represntation (word length = 32 bits with varying fraction length depending on the expected range of the variables).

Tracking results generated after simulating the fixed point Simulink model are contained in fixedPointSimResults.jpg