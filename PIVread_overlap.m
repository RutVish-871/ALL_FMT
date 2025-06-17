clear
% Load images
cal_image = imread("cal\B00001.tif");
alpha15 = imread("alpha_15\B00001.tif");

% Crop calibration image
cal_main = cal_image(1237:2472, 1:1616);
xpx = size(cal_main, 2);
ypx = size(cal_main,1);

% image( cal_main);

% Pixel length calibration
px_len = mean([10/93, 10/94]) * 1e-3;

% Split image into two frames
im1 = alpha15(1:1236, :);
im2 = alpha15(1237:end, :);

% Define interrogation window and overlap
win = 32;
overlap = 0.5;
step = floor(win*(1-overlap));  % 50% overlap


% Determine number of windows
winSizex = floor((size(im1,2) - win) / step) + 1;
winSizey = floor((size(im1,1) - win) / step) + 1;

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
U = px_len * dim2 / 0.00007;
V = px_len * dim1 / 0.00007;

mag = sqrt(U.^2 + V.^2);
for i = 1:size(U,1)
    for j = 1:size(U,2)
        if (mag(i,j)) == 0
            U(i,j) = NaN;

            V(i,j) = NaN;
            mag(i,j) = NaN;
        end
    end
end

% Generate grid for quiver plot
X = linspace(0, px_len*(size(im1,2) - win), winSizex);
Y = linspace(px_len*(size(im1,1) - win), 0, winSizey);
[X, Y] = meshgrid(X, Y);

% Plot velocity vectors
hold on
grid on


% contourf(X, Y, mag, '--')
clim([0, 13])
quiver(X,Y,U,-V);
% colorbar
