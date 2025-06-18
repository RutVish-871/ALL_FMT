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

X= reshape(x, 26,20)';
Y= reshape(y, 26,20)';
U_davis= reshape(Vx, 26,20)';
V_davis= reshape(Vy, 26,20)';
nan_val = reshape(nan, 26,20)';
mag_davis=sqrt(U_davis.^2 + V_davis.^2);

for i=1:26
    for j=1:20
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
c = colorbar;
c.Label.String = 'Velocity magnitude ($m/s$)';
colormap(jet)
quiver(x,y,Vx,Vy, 'Color','k');
xlabel('$x$ (mm)', Interpreter='latex');
ylabel('$y$ (mm)', Interpreter='latex');
title('Velocity contours with Vectors', Interpreter='latex')