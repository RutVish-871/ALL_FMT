%% To be compared only with aoa 15 deg 10 ensemble DaVIS file
% clear
% close all
% Load images
cal_image = int16(imread("cal\B00001.tif"));
alpha15 = int16(imread("alpha_15\B00001.tif"));

% Crop calibration image
cal_main = cal_image(1237:2472, 1:1616);


% image( cal_main);
xpx = 10/93; %length per pixel in x direction in mm
ypx = 10/94; %length per pixel in y direction in mm

% Pixel length calibration

px_len_av = mean([xpx, ypx]); %Obtained from the calibration image, average in 2 directions

dt = 70 * 1e-6; %delta time in microseconds

% Split image into two frames
im1 = (alpha15(1:1236, :)) - mean(alpha15(1:1236, :), "all");
im2 = (alpha15(1237:end, :)) - mean(alpha15(1237:end, :), "all");



% Define interrogation window and overlap
win =32;
overlap =0.5;
step = floor(win*(1-overlap));  % advance by overlap


% Determine number of windows
winSizex = floor((size(im1,2) -win) / step);
winSizey = ceil((size(im1,1) -win) / step);

% Initialize matrices
corr = zeros(winSizey, winSizex);
dim1 = zeros(winSizey, winSizex);
dim2 = zeros(winSizey, winSizex);

% Loop over interrogation windows
for i = 1:winSizex
    for j = 1:winSizey

        x_start = (i-1)*step + 1;
        y_start = (j-1)*step + 1;
        if x_start+win-1 <= size(im1, 2) && y_start+win-1 <= size(im1, 1)
        % Extract interrogation windows
            sub1 = im1(y_start:y_start+win-1, x_start:x_start+win-1);
            sub2 = im2(y_start:y_start+win-1, x_start:x_start+win-1); 
    
            % Cross-correlation
            crr = xcorr2(sub2, sub1);
            [corr(j,i), I] = max(crr, [], "all", "linear"); %Peak cross corr
            sz = size(crr);
            [dim1(j,i), dim2(j,i)] = ind2sub(sz, I); %Peak Localization
        end
    end
end

% Subtract window center to get displacements
dim1 = dim1 - win;
dim2 = dim2 - win;

% Compute velocities
U_self = px_len_av * 1e-3 * dim2 / dt; %x-velocity in m/s
V_self = -px_len_av * 1e-3* dim1 / dt; %y-velocity in m/s

mag_self = sqrt(U_self.^2 + V_self.^2);
for i = 1:size(U_self,1)
    for j = 1:size(U_self,2)
        if (mag_self(i,j)) == 0 || (mag_self(i,j)) >= 15
            U_self(i,j) = NaN;

            V_self(i,j) = NaN;
            mag_self(i,j) = NaN;
        end
    end
end

% Generate grid for quiver plot
X = linspace(-46.1454928517000, 122.911565721000, winSizex); % limits taken from the 10 ensemble file
Y = linspace(105.229393303400, -24.1510086656000, winSizey); % limits taken from the 10 ensemble file
[X_self, Y_self] = meshgrid(X, Y);

% Plot velocity vectors
figure(1)

% set(gca, 'Units','Normalized' , "Position", [0.1, 0.2, a*0.1616, a*0.1236]);

hold on
grid on


contourf(X_self, Y_self, mag_self, 50, 'LineColor','none')
ax = gca;
ax.Xaxis.Fontsize = 1;
colormap("jet")

quiver(X_self,Y_self,U_self,V_self, 'Color', 'k', 'LineWidth',0.75);

a=6;
set(gcf, 'Units','Normalized' , "Position", [0.2, 0.2, a*0.1, a*0.1]);
xlabel('$x $ (mm)', Interpreter='latex', FontSize=15);
ylabel('$y $ (mm)', Interpreter='latex', FontSize=15);
title('Velocity Contour and Vectors', Interpreter='latex', FontSize=15)
c = colorbar;
c.Label.String = 'Velocity magnitude (m/s)';
c.Label.FontSize = 12;
c.Label.Interpreter = "latex";
clim([0, 13])
