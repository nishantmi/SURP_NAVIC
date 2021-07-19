#Code to analyse the output from the simulation of carrError VHDL code

from fixedpoint import FixedPoint
import matplotlib.pyplot as plt

f = open("outputs.txt","r")
f1 = open("TRACEFILE.txt","r")


diff = []
diff1 = []
diff3 = []
for line in f:
    out_var, out = line.split()
    out_var = FixedPoint('0b'+out_var, signed = 1, m = 16, n =16, str_base = 2)
    out     = FixedPoint('0b'+out, signed = 1, m = 16, n =16, str_base = 2)

    diff.append(float(out_var) - float(out))                       #Stores the difference between expected and actual output
    diff3.append(float(out_var))                                   #Stores Actual output
    diff1.append((float(out_var) - float(out))/float(out_var)*100) #Stores Percentage error

f.close()
diff2 = []
for line in f1:
    if line[0] == "E":
        continue
    carError, oldNCO, carrErrorDiff, NCO = line.split()
    diff2.append(float(FixedPoint('0b'+carrErrorDiff, signed = True, m = 2, n = 30, str_base = 2)))  #Stores the carrErrorDiff

f1.close()
print(max(diff), min(diff))              #Prints the maximum and minimum error observed

#Plots
plt.figure(1)
plt.plot(diff)
plt.title('Error Plot')
plt.draw()
plt.figure(2)
plt.plot(diff1)
plt.title('Percentage Error Plot')
plt.draw()
plt.figure(3)
plt.plot(diff1)
plt.title('Percentage Error Plot (Limited Y Axis)')
plt.ylim(-100, 100)
plt.draw()
plt.figure(4)
plt.scatter(diff2, diff)
plt.title('Error vs carrErrorDiff Plot')
plt.draw()
plt.show()
plt.figure(5)
plt.scatter(diff3, diff1)
plt.title('Precentange Error vs NCOFreq Plot')
plt.draw()
plt.show()
plt.figure(6)
plt.scatter(diff3, diff1)
plt.title('Precentange Error vs NCOFreq Plot (Limited Y Axis)')
plt.ylim(-100, 100)
plt.draw()
plt.show()
