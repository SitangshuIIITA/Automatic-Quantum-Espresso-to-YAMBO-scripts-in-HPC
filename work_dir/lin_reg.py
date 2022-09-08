import numpy as np


with open('GW_negativeE.txt') as f:
         data = np.loadtxt(f, delimiter=None, dtype='float', skiprows=0, comments="#", usecols=None)
x =  np.array(data[:,0])
y =  np.array(data[:,1])

x_mean=np.mean(x)
y_mean=np.mean(y)
print("Mean for x value is",x_mean,"and mean for y values is",y_mean)

num=0
den=0
for i in range(len(x)):
    num+=(x[i]-x_mean)*(y[i]-y_mean)
    den+=(x[i]-x_mean)**2
b1 =num/den
print (b1)
b0=y_mean-(b1*x_mean)
print("Intercept is ", float(b0),"Coefficeint is ",float(b1))
with open('slope_v.txt', 'w') as f:
         f.write("%f" % float(b1))

y_pred=b0+b1*x


############### conduction plot ##########################

with open('GW_positiveE.txt') as f:
         data = np.loadtxt(f, delimiter=None, dtype='float', skiprows=0, comments="#", usecols=None)
x =  np.array(data[:,0])
y =  np.array(data[:,1])

x_mean=np.mean(x)
y_mean=np.mean(y)
print("Mean for x value is",x_mean,"and mean for y values is",y_mean)

num=0
den=0
for i in range(len(x)):
    num+=(x[i]-x_mean)*(y[i]-y_mean)
    den+=(x[i]-x_mean)**2
b1 =num/den
print (b1)
b0=y_mean-(b1*x_mean)
print("Intercept is ", float(b0),"Coefficeint is ",float(b1))
with open('slope_c.txt', 'w') as f:
         f.write("%f" % float(b1))

y_pred=b0+b1*x

