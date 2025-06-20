table1 = readmatrix("B00001.dat");
table2 = readmatrix("B00002.dat");

% table_filt = table(table(:,5)==1,:);

x = table1(:,1);
y = table1(:,2);
mean_x = table1(:,3);
mean_y = table1(:,4);
nan = table1(:,5);

std_x = table2(:,3);
std_y = table2(:,4);

% figure(1);
% quiver(x,y,Vx,Vy);

X= reshape(x, 26, 20)';
Y= reshape(y, 26, 20)';
mean_x= reshape(mean_x, 26, 20)';
mean_y= reshape(mean_y, 26, 20)';
std_x= reshape(std_x, 26, 20)';
std_y= reshape(std_y, 26, 20)';
nan_val = reshape(nan, 26, 20)';

V_mean_mag = sqrt(mean_x.^2 + mean_y.^2);
std_mag = sqrt(std_x.^2 + std_y.^2);

SNR = V_mean_mag./std_mag;

for i=1:26
    for j=1:20
        if nan_val(j,i)==0
            SNR(j,i) = NaN;
            V_mean_mag(j,i) = NaN;
            std_mag(j,i) = NaN;
        end
    end
end

figure(1)
contourf(X,Y,V_mean_mag,50,'LineColor','none');
colormap("jet")
a=6;
set(gcf, 'Units','Normalized' , "Position", [0.2, 0.2, a*0.1, a*0.1]);
xlabel('$x $ (mm)', Interpreter='latex', FontSize=15);
ylabel('$y $ (mm)', Interpreter='latex', FontSize=15);
title('Mean Velocity', Interpreter='latex', FontSize=15)
c = colorbar;
c.Label.String = 'Velocity magnitude (m/s)';
c.Label.FontSize = 12;
c.Label.Interpreter = "latex";


figure(2)
contourf(X,Y,SNR,50,'LineColor','none');
colormap("jet")
a=6;
set(gcf, 'Units','Normalized' , "Position", [0.2, 0.2, a*0.1, a*0.1]);
xlabel('$x $ (mm)', Interpreter='latex', FontSize=15);
ylabel('$y $ (mm)', Interpreter='latex', FontSize=15);
title('Signal-to-Noise Ratio', Interpreter='latex', FontSize=15)
c = colorbar;
