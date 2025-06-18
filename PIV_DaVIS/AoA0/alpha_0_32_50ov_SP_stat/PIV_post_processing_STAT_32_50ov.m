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

X= reshape(x, 101, 78)';
Y= reshape(y, 101, 78)';
mean_x= reshape(mean_x, 101, 78)';
mean_y= reshape(mean_y, 101, 78)';
std_x= reshape(std_x, 101, 78)';
std_y= reshape(std_y, 101, 78)';
nan_val = reshape(nan, 101, 78)';

V_mean_mag = sqrt(mean_x.^2 + mean_y.^2);
std_mag = sqrt(std_x.^2 + std_y.^2);

SNR = V_mean_mag./std_mag;

for i=1:101
    for j=1:78
        if nan_val(j,i)==0
            SNR(j,i) = NaN;
            V_mean_mag(j,i) = NaN;
            std_mag(j,i) = NaN;
        end
    end
end

figure(1)
contourf(X,Y,V_mean_mag,50,'LineColor','none');
xlabel("$x$(m)", Interpreter="latex")
ylabel("$y$(m)", Interpreter="latex")
title('Mean Velocity Magnitude ($m/s$)' , Interpreter="latex")
colormap("jet")
c = colorbar;
c.Label.String = 'Velocity m/s';

figure(2)
contourf(X,Y,SNR,50,'LineColor','none');
xlabel("$x$(m)", Interpreter="latex")
ylabel("$y$(m)", Interpreter="latex")
title('Signal-Noise Ratio' , Interpreter="latex")
colormap("jet")
colorbar