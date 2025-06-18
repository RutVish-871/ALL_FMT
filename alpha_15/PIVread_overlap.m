%% To be used only with aoa 15 deg 10 ensemble DaVIS file
% clear
% close all
% Load images
cal_image = imread("cal\B00001.tif");
alpha15 = imread("alpha_15\B00001.tif");

% Crop calibration image
cal_main = cal_image(1237:2472, 1:1616);
xpx = size(cal_main, 2);
ypx = size(cal_main,1);

% image( cal_main);

% Pixel length calibration
px_len = mean([10/93, 10/94]);

% Split image into two frames
im1 = alpha15(1:1236, :);
im2 = alpha15(1237:end, :);

% Define interrogation window and overlap
win =32;
overlap = 0.5;
step = floor(win*(1-overlap));  % advance by overlap


% Determine number of windows
winSizex = floor(size(im1,2)   / step)-2;
winSizey = ceil(size(im1,1) / step)-2;

% Initialize matrices
corr = zeros(winSizey, winSizex);
dim1 = zeros(winSizey, winSizex);
dim2 = zeros(winSizey, winSizex);

% Loop over interrogation windows
for i = 1:winSizex
    for j = 1:winSizey
        x_start = (i-1)*step + 1;
        y_start = (j-1)*step + 1;

        % Extract interrogation windows
        sub1 = im1(y_start:y_start+win-1, x_start:x_start+win-1);
        sub2 = im2(y_start:y_start+win-1, x_start:x_start+win-1);

        % Cross-correlation
        crr = xcorr2(sub2, sub1);
        [corr(j,i), I] = max(crr(:));
        [dim1(j,i), dim2(j,i)] = ind2sub(size(crr), I);
    end
end

% Subtract window center to get displacements
dim1 = dim1 - win;
dim2 = dim2 - win;

% Compute velocities
U_self = px_len*1e-3 * dim2 / 0.00007;
V_self = px_len *1e-3* dim1 / 0.00007;

mag_self = sqrt(U_self.^2 + V_self.^2);
for i = 1:size(U_self,1)
    for j = 1:size(U_self,2)
        if (mag_self(i,j)) == 0
            U_self(i,j) = NaN;

            V_self(i,j) = NaN;
            mag_self(i,j) = NaN;
        end
    end
end

% Generate grid for quiver plot
X = linspace(-46.1454928517000, 122.911565721000, winSizex);
Y = linspace(105.229393303400, -24.1510086656000, winSizey);
[X, Y] = meshgrid(X, Y);

% Plot velocity vectors
figure(1)
hold on
grid on


% contourf(X, Y, mag, 50, 'LineColor','none')
% colormap("jet")
% colorbar
% clim([0, 13])
quiver(X,Y,U_self,-V_self, 'Color', 'b');
xlabel('$x $ (mm)', Interpreter='latex');
ylabel('$y $ (mm)', Interpreter='latex');
title('Vector Plot', Interpreter='latex')