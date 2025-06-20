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

## Plot the original data and the fitted polynomial
plt.figure("Voltage Velocity Correlation Curve")
plt.scatter(x, y, color='red', label='Data', s = 16)        # Plot original data points
plt.plot(x_fit, y_fit, label=f'{degree} degree polynomial') # Plot fitted curve
plt.xlabel('Velocity [m/s]')
plt.ylabel('Voltage [V]')
plt.legend()
plt.title('Polynomial Fit to Velocity vs Voltage')
plt.grid(True)
plt.close()

## Get velocity profiles for each ALFA case
for j in [0, 5, 15]:
    heights = []
    means_A0 = []
    stds_A0 = []
    means_A0_mapped = []
    stds_A0_mapped = []
    for i in range(9, 90, 4):  # Start at 9, end at 89, with a step of 4
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

plt.close('all')

## Power Spectral Density Graphs
for j in [0, 5, 15]:
    for i in range(9, 90, 4):
        file_name = f'A{j}/A{j}_p{i}.txt'
        data = pd.read_csv(file_name, header=None, names = ['time', 'vel'], sep='\s+')
        t = data['time'][:]
        vel = data['vel'][:]
        dt = t[1]-t[0]
        freq = 1/dt

        nperseg = 2048
        freq_fft, PSD = welch(vel, fs=freq, nperseg=nperseg, window='hann', scaling='density')

        peak_index = np.argmax(PSD)
        peak_freq = freq_fft[peak_index]
        peak_val = PSD[peak_index]
        
        plt.figure(f"Power Spectral Density at h = {i} mm for A{j}", figsize=(8,3.5))
        plt.loglog(freq_fft, PSD, label=f'{nperseg}-point window')
        plt.plot(peak_freq, peak_val, 'ro', label=f'Peak: {peak_freq:.2f} Hz')

        plt.xlabel('Frequency [Hz]')
        plt.ylabel('Power Spectral Density, $\phi_{uu}$ [W/Hz]')    
        plt.title("$\phi_{uu}$ at " + f"h = {i} mm " + f"for $\\alpha={j}$" + "$^{\\circ}$")
        plt.grid(True)
        plt.tight_layout()
        plt.legend()

        path_name = f'plots/A{j}/PSD_at_p{i}_for_A{j}.png'
        plt.savefig(path_name)
        plt.close()
        # print(f"plot A{j}, {((i-9)/4)+1} done")

## Variance with window size
for j in [0]:
    for i in range(41, 42, 4):
        nperseg_list = [512, 1024, 2048, 4096]

        file_name = f'A{j}/A{j}_p{i}.txt'
        data = pd.read_csv(file_name, header=None, names=['time', 'vel'], sep='\s+')
        t = data['time'][:]
        vel = data['vel'][:]
        dt = t[1] - t[0]
        freq = 1 / dt

        fig, axes = plt.subplots(len(nperseg_list), 1, figsize=(8, 2 * len(nperseg_list)), sharex=True)

        for ax, nperseg in zip(axes, nperseg_list):
            freq_fft, PSD = welch(vel, fs=freq, nperseg=nperseg, window='hann', scaling='density')

            ax.loglog(freq_fft, PSD, label=f'{nperseg}-point window')
            ax.set_ylabel('$\\phi_{uu}$ [W/Hz]')
            ax.grid(True)
            ax.legend(loc='upper right')

        axes[-1].set_xlabel('Frequency [Hz]')
        fig.suptitle("$\\phi_{uu}$ at " + f"h = {i} mm " + f"for $\\alpha={j}$" + "$^{\\circ}$", fontsize=14)
        fig.tight_layout(rect=[0, 0, 1, 1])

        path_name = f'plots/Window Size/PSD_STACKED_at_p{i}_for_A{j}_var_winsize.png'
        plt.savefig(path_name)
        plt.close()