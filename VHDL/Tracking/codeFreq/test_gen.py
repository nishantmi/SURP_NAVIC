#Testbench generator for testing carrError VHDL code

from fixedpoint import FixedPoint
import random

f = open("TRACEFILE.txt","w")
randomList = random.sample(range(-70000000, 70000000), 100000)
randomList = [i/1e8 for i in randomList]             #1e5 random values for codeError between -0.7 to 0.7

tau2bytau1 = FixedPoint(0.148/0.011175510204082, signed = False, m = 4, n =28, str_base=2)
oldNCO = FixedPoint(0, signed = False, m = 8, n =24, str_base=2)
codeErrorPrev=FixedPoint(0, signed = True, m = 8, n =24, str_base=2)

for ind in range(len(randomList)):
	codeError = FixedPoint(randomList[ind], signed = True, m = 8, n =24, str_base=2)
	codeErrorDiff = FixedPoint(float(codeError - codeErrorPrev), signed = True, m = 8, n =24, str_base=2)
	codeErrorPrev = codeError
	NCO  = FixedPoint(float(oldNCO + (tau2bytau1) * (codeErrorDiff)), signed = True, m = 8, n =24, str_base=2)

	f.write(str(codeError) + " " + str(oldNCO)+ " " + str(codeErrorDiff)+ " " + str(NCO) + "\n")

	oldNCO = NCO

f.close()
