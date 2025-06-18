import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os

os.chdir(os.path.dirname(__file__))

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

# Step 1: Read data from file
data = pd.read_csv('Velocity_voltage.txt', header=None, names = ['vel', 'volt'], sep='\s+')

x = data['vel'][:]
y = data['volt'][:]

x, y = getAverage(x, y)

# Step 3: Choose the degree of the polynomial
degree = 4

# Step 4: Fit a polynomial to the data
coefficients = np.polyfit(y, x, degree)

print("Coefficients of the polynomial: ", coefficients)

# Step 5: Create a polynomial function from the coefficients
polynomial = np.poly1d(coefficients)

# Step 6: Generate x values for plotting the fitted curve
y_fit = np.linspace(min(y), max(y), 100)
x_fit = polynomial(y_fit)

heights = []
means_A0 = []
stds_A0 = []

means_A0_mapped = []
stds_A0_mapped = []
# Loop over the required values (9, 13, ..., 89)
for i in range(9, 90, 4):  # Start at 9, end at 89, with a step of 4
    # Generate the filename dynamically
    file_name = f'A0/A0_p{i}.txt'
    
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




# Step 7: Plot the original data and the fitted polynomial
plt.figure("Voltage Velocity Correlation Curve")
plt.scatter(x, y, color='red', label='Data')  # Plot original data points
plt.plot(x_fit, y_fit, label=f'{degree} degree polynomial')  # Plot fitted curve
plt.xlabel('Velocity')
plt.ylabel('Voltage')
plt.legend()
plt.title('Polynomial Fit to Velocity vs Voltage')
plt.grid(True)

plt.figure("Mean Velocity")
plt.plot(means_A0_mapped, heights, label='Mapped Mean', marker='o')
plt.xlabel('Height (cm)')
plt.ylabel('Mapped Mean of A0')
plt.title('Mapped Mean of A0 vs Height')
plt.grid(True)
plt.legend()
plt.show()