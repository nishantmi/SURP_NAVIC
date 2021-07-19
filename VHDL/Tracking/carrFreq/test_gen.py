#Testbench generator for testing carrError VHDL code

from fixedpoint import FixedPoint
import random

f = open("TRACEFILE.txt","w")
randomList = random.sample(range(-25000000, 25000000), 100000)
randomList = [i/1e8 for i in randomList]             #1e5 random values for carrError between -0.25 to 0.25

tau2bytau1 = FixedPoint(0.0296/1.117551020408163e-04, signed = False, m = 9, n =23, str_base=2)
oldNCO = FixedPoint(0, signed = False, m = 16, n =16, str_base=2)
carrErrorPrev=FixedPoint(0, signed = True, m = 2, n =30, str_base=2)

for ind in range(len(randomList)):
	carrError = FixedPoint(randomList[ind], signed = True, m = 2, n = 30, str_base=2)
	carrErrorDiff = FixedPoint(float(carrError - carrErrorPrev), signed = True, m = 2, n = 30, str_base=2)
	carrErrorPrev = carrError
	NCO  = FixedPoint(float(oldNCO + (tau2bytau1) * (carrErrorDiff)), signed = True, m = 16, n = 16, str_base=2)

	f.write(str(carrError) + " " + str(oldNCO)+ " " + str(carrErrorDiff)+ " " + str(NCO) + "\n")

	oldNCO = NCO

f.close()
