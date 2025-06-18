% close all
table_filt = readmatrix("B00001.dat");
% table_filt = table(table(:,5)==1,:);

x = table_filt(:,1);
y = table_filt(:,2);
Vx = table_filt(:,3);
Vy = table_filt(:,4);
nan = table_filt(:,5);

% figure(1);
% quiver(x,y,Vx,Vy);

X= reshape(x, 101, 78)';
Y= reshape(y, 101, 78)';
U_davis= reshape(Vx, 101, 78)';
V_davis= reshape(Vy, 101, 78)';
nan_val = reshape(nan, 101, 78)';
mag_davis=sqrt(U_davis.^2 + V_davis.^2);

for i=1:101
    for j=1:78
        if nan_val(j,i)==0
            mag_davis(j,i) = NaN;
            U_davis(j,i) = NaN;
            V_davis(j,i) = NaN;
        end
    end
end

figure(1);
hold on
contourf(X,Y,mag_davis,50,'LineColor','none');

colormap(jet)
quiver(x,y,Vx,Vy, 'Color','k');

a=6;
set(gcf, 'Units','Normalized' , "Position", [0.2, 0.2, a*0.1, a*0.1]);
xlabel('$x $ (mm)', Interpreter='latex', FontSize=15);
ylabel('$y $ (mm)', Interpreter='latex', FontSize=15);
title('Velocity Contour and Vectors', Interpreter='latex', FontSize=15)
c = colorbar;
c.Label.String = 'Velocity magnitude (m/s)';
c.Label.FontSize = 12;
c.Label.Interpreter = "latex";
