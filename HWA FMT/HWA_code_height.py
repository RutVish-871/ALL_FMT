import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
from scipy.signal import welch

os.chdir(os.path.dirname(__file__))

plt.rc('text', usetex=True) 
plt.rc('font', family='serif')
plt.rc('legend',fontsize=12)
plt.rcParams['axes.labelsize'] = 12
plt.rcParams['axes.titlesize'] = 15

def getAverage(x, y):
    x_new = []
    y_new = []
    for i in range(len(x)):
        for j in range(i+1,len(x)):
            if(np.abs(x[i]-x[j])<0.1):
                temp = np.sqrt(np.mean([x[i]**2, x[j]**2]))     # RMS value of Velocity
                x_new.append(temp)

                temp = np.mean([y[i], y[j]])                    # Mean value of Voltage
                y_new.append(temp)

    return x_new, y_new

# Read data from file
data = pd.read_csv('Velocity_voltage.txt', header=None, names = ['vel', 'volt'], sep='\s+')

x = data['vel'][:]
y = data['volt'][:]

x, y = getAverage(x, y)

# Fit a polynomial to the data
degree = 4
coefficients = np.polyfit(y, x, degree)

print("Coefficients of the polynomial: ", coefficients)

polynomial = np.poly1d(coefficients)

# Generate x values for plotting the fitted curve
y_fit = np.linspace(min(y), max(y), 100)
x_fit = polynomial(y_fit)

# Plot the original data and the fitted polynomial
plt.figure("Voltage Velocity Correlation Curve")
plt.scatter(x, y, color='red', label='Data', s = 16)        # Plot original data points
plt.plot(x_fit, y_fit, label=f'{degree} degree polynomial') # Plot fitted curve
plt.xlabel('Velocity [m/s]')
plt.ylabel('Voltage [V]')
plt.legend()
plt.title('Polynomial Fit to Velocity vs Voltage')
plt.grid(True)
plt.show()

# Get velocity profiles for each ALFA case
heights = []
means_A0 = []
stds_A0 = []
means_A0_mapped = []
stds_A0_mapped = []

for j in [0, 5, 15]:
    for i in range(9, 90, 4):  # Start at 9, end at 89, with a step of 4
        # Generate the filename dynamically
        file_name = f'A{j}/A{j}_p{i}.txt'
        
        try:
            second_col = pd.read_csv(file_name, header=None, sep='\s+').iloc[:, 1]
            second_col_mapped = polynomial(second_col)

            mean_val_original = second_col.mean()
            std_val_original = second_col.std()

            mean_val_mapped = second_col_mapped.mean()
            std_val_mapped = second_col_mapped.std()

            heights.append(i)
            means_A0.append(mean_val_original)
            stds_A0.append(std_val_original)
            means_A0_mapped.append(mean_val_mapped)
            stds_A0_mapped.append(std_val_mapped)

            print(f'Statistics for {file_name} - Mapped Mean: {mean_val_mapped:.4f}, Std: {std_val_mapped:.4f}')

        except FileNotFoundError:
            print(f"Warning: File not found: {file_name}. Skipping.")
        except Exception as e:
            print(f"An error occurred processing {file_name}: {e}. Skipping.")
    
    plt.figure("Mean Velocity at Different Heights")
    plt.plot(means_A0_mapped, heights, label='$\\alpha=$'+str(j)+'$^{\\circ}$', marker='o', markersize=3)
    plt.ylabel('Height [mm]')
    plt.xlabel('Mean Velocity [m/s]')
    plt.title('Mean Velocity at Different Heights')
    plt.grid(True)
    plt.legend()

    plt.figure("Standard Deviation in Velocity at Different Heights")
    plt.plot(stds_A0_mapped, heights, label='$\\alpha=$'+str(j)+'$^{\\circ}$', marker='o', markersize=3)
    plt.ylabel('Height [mm]')
    plt.xlabel('Standard Deviation in Velocity [m/s]')
    plt.title('Standard Deviation in Velocity at Different Heights')
    plt.grid(True)
    plt.legend()

    heights = []
    means_A0 = []
    stds_A0 = []
    means_A0_mapped = []
    stds_A0_mapped = []

plt.show()

## Power Spectral Density Graphs

# for i in range(9, 90, 4):  # Start at 9, end at 89, with a step of 4
#     # Generate the filename dynamically
#     file_name = f'A0/A0_p{i}.txt'
#     data = pd.read_csv(file_name, header=None, names = ['time', 'vel'], sep='\s+')
#     t = data['time'][:]
#     vel = data['vel'][:]
#     dt = t[1]-t[0]
#     freq = 1/dt

#     nperseg = 2048
#     freq_fft, PSD = welch(vel, fs=freq, nperseg=nperseg, window='hann', scaling='density')

#     plt.figure("Power Spectral Density")
#     plt.loglog(freq_fft, PSD, label=f'{nperseg}-point window')
#     plt.grid(True)
#     plt.show()