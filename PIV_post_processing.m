table_filt = readmatrix("B00001.dat");
% table_filt = table(table(:,5)==1,:);

x = table_filt(:,1);
y = table_filt(:,2);
Vx = table_filt(:,3);
Vy = table_filt(:,4);
nan = table_filt(:,5);

figure(1);
quiver(x,y,Vx,Vy);

X= reshape(x, 101, 78)';
Y= reshape(y, 101, 78)';
V_x= reshape(Vx, 101, 78)';
V_y= reshape(Vy, 101, 78)';
nan_val = reshape(nan, 101, 78)';
V_mag=sqrt(V_x.^2 + V_y.^2);

for i=1:101
    for j=1:78
        if nan_val(j,i)==0
            V_mag(j,i) = NaN;
        end
    end
end

figure(2);
contourf(X,Y,V_mag,50,'LineColor','none');
colorbar