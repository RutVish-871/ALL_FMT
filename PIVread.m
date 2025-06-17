% close all
clear

cal_image = imread("cal\B00001.tif");
alpha15 = imread("alpha_15\B00001.tif");

cal_main = cal_image(1237:end, :);

px_len = mean([30/280, 90/835])*10^-3;

im1 = alpha15(1:1236, :);
im2 = alpha15(1237:end, :);

win = 32;
overlap = 0;
winNumx = floor(1616/win);
winNumy = floor(1236/win);
corr = zeros(winNumy-1,winNumx-1);
dim1 = zeros(winNumy-1,winNumx-1);
dim2 = zeros(winNumy-1,winNumx-1);
for i = 1:winNumx - 1
    for j = 1:winNumy -1
        crr = xcorr2(im2(1+win*(j-1):win*(j), 1+win*(i-1):win*i), im1(1+win*(j-1):win*j, 1+win*(i-1):win*i));
        [corr(j,i), I] = max(crr(:));
        [dim1(j,i), dim2(j,i)] = ind2sub(size(crr), I);
    end
end
dim1 = dim1 - win;
dim2 = dim2 - win;

U = px_len*dim2/0.00007;
V = px_len*dim1/0.00007;
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


X = linspace(0,px_len*1616, winNumx-1);
Y = linspace(px_len*1236,0, winNumy-1);
[X,Y] = meshgrid(X, Y);
figure(2)
% quiver(X, Y, U, -V)
contourf(X,Y,mag);


