function [x_dorso,cf_dorso,x_ventre,cf_ventre] = letturaCF(filePath , toplot)
% Legge file cf e restituisce le coordinate

A = importdata(filePath," ",7);
fine = find(A.data(:,1) == 1);

x_dorso = A.data(1:fine(1),1);
cf_dorso = A.data(1:fine(1),2);

inizio = find(A.data(:,1)>1.95); 
ind = floor(max(size(inizio))/2) ;

x_ventre = A.data(inizio(ind) + 1:fine(2),1);
cf_ventre = A.data(inizio(ind) + 1:fine(2),2);

if nargin >= 2
	figure;
	plot(x_dorso,cf_dorso,x_ventre,cf_ventre)
	grid on
	legend("cf dorso", "cf ventre")
	title("Re = " + filePath(35)+ "$\qquad     \alpha =$ " +  filePath(38:40), 'Interpreter','latex' )
end


