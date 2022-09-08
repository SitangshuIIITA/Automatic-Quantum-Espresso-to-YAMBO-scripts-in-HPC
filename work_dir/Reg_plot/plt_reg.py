import numpy as np
import matplotlib.pyplot as plt


fig = plt.figure(figsize=(25,18))

csfont = {'fontname':'Arial Narrow'}
plt.rcParams['axes.linewidth'] = 0.5 #set the value globally
plt.rcParams['xtick.major.size'] = 8
plt.rcParams['ytick.major.size'] = 8
plt.rcParams.update({'font.size': 50})
plt.tick_params(axis="both", direction='in', length=8)
plt.margins(0.1, 0.05)

ax = plt.subplot(1,1,1)

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

plt.scatter(x,y, c="orange",  marker = "o", s = 180)
plt.plot(x,y_pred, c="k", lw=2, label="Valence band slope = %0.2f" %b1)
plt.legend(loc='upper left', frameon=False, fontsize=50)

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

plt.scatter(x,y, c="green", marker = "o", s = 180)
plt.plot(x,y_pred, c="blue", lw=2, label="Conduction band slope = %0.2f" %b1)
plt.legend(loc='upper left', frameon=False, fontsize=50)

plt.plot(x,y_pred, color="blue")

plt.ylabel(r'GW gap (eV)')
plt.xlabel(r'DFT gap (eV)')
plt.title("Linear fit", loc='right', x=0.95, y=0.02)

#plt.show()
fig.savefig('DFT_GW_QP_gap_fitting.eps', bbox_inches='tight',format='eps', dpi=1500)
