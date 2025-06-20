import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
from scipy.signal import welch
from scipy.interpolate import griddata

os.chdir(os.path.dirname(__file__))

plt.rc('text', usetex=True) 
plt.rc('font', family='serif')
plt.rc('legend',fontsize=12)
plt.rcParams['axes.labelsize'] = 12
plt.rcParams['axes.titlesize'] = 15

data = pd.read_csv('Pressure Probe/Pressure_probe_measurements.txt', header=0, names = ['x', 'y', 'u', 'v'], sep=',', na_values=' nan')

x = data['x'][:]    # x-coordinate [mm]
y = data['y'][:]    # y-coordinate [mm]
u_vel = data['u'][:]    # x-velocity component [m/s]
v_vel = data['v'][:]    # y-velocity component [m/s]

v_tot = np.sqrt(np.power(u_vel,2) + np.power(v_vel,2))

X, Y = np.meshgrid(x, y)
U_vel = griddata((x, y), u_vel, (X, Y), method='linear')
V_vel = griddata((x, y), v_vel, (X, Y), method='linear')
V_tot = griddata((x, y), v_tot, (X, Y), method='linear')

step = 1
plt.figure(figsize=(9,4))

contour = plt.contourf(X, Y, V_tot, levels=100, cmap='viridis')
cbar = plt.colorbar(contour)
cbar.set_label('u [m/s]')

plt.quiver(x[::step], y[::step], u_vel[::step], v_vel[::step], color='k', scale=150, width=0.001)
plt.xlabel('x [mm]')
plt.ylabel('y [mm]')
plt.title('Velocity Vector Field')
plt.axis('equal')
plt.grid(True)
plt.tight_layout()

path_name = f'plots/Pressure Probe/V_tot_contour_plot.png'
plt.savefig(path_name)

plt.show()