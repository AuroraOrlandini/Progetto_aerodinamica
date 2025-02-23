function [err_CL, err_CM, err_CP,cp_xf,CLxf,CMxf, err_Adorso_perc, err_Aventre_perc ] = confrontoNACA(Dati_HS,N)
%restituisce gli errori percentuali su CL, CM e CP 
%funziona solo per profili NACA, per i nostri scopi viene forzato il 0012
%ad angolo di incidenza 2 gradi. 
% N definisce il numero di pannelli, 
% Dati_HS è la struct che viene salvata in Hess_Smith_func


CodiceProfilo = "0012";
alpha = 2;

% Cp
cp_dorso_HS=Dati_HS.cp_dorso';
cp_ventre_HS=Dati_HS.cp_ventre';
cp_HS=Dati_HS.cp';
% Coordinate
x_dorso_HS=Dati_HS.x_dorso';
x_ventre_HS=Dati_HS.x_ventre';
x_HS=Dati_HS.x';

%Cl 
CLHS = round(Dati_HS.Cl, 4);

%CM 
CMHS = round(Dati_HS.Cm,4);

% Importazione dati da xfoil
filecp =  "NACA_"+CodiceProfilo+"_2_cp.txt";
filecc = "clcm_NACA0012.dat";
Dati_xf = importdata(filecp);
cc = importdata(filecc);

% Cp
cp_xf=flip(Dati_xf.data(:,2));
cp_ventre_xf=cp_xf(1:round(end/2));
cp_dorso_xf=cp_xf(round(end/2)+1:end);

%Cl 
CLxf = cc.data(1,1);
CMxf = cc.data(1,2);

% Coordinate
x_xf = flip(Dati_xf.data(:,1));
x_ventre_xf=x_xf(1:round(end/2));
x_dorso_xf=x_xf(round(end/2)+1:end);

cp_dorso_interp = interp1(x_dorso_xf,cp_dorso_xf,x_dorso_HS);
cp_ventre_interp = interp1(x_ventre_xf,cp_ventre_xf,x_ventre_HS);

err_dorso = cp_dorso_HS  - cp_dorso_interp ;
err_ventre = cp_ventre_HS - cp_ventre_interp;

err_dorso_perc = abs(err_dorso)./max(cp_dorso_interp)*100;
err_ventre_perc =abs(err_ventre)./max(cp_ventre_interp)*100;

err_CP = [err_ventre_perc ; err_dorso_perc];

err_CL = (CLHS - CLxf)/CLxf*100;
err_CM = (CMHS - CMxf)/CMxf*100;

Axf_dorso = trapz(x_dorso_xf,abs(cp_dorso_xf));
Ahs_dorso = trapz(x_dorso_HS,abs(cp_dorso_HS));

Axf_ventre = trapz(x_ventre_xf,abs(cp_ventre_xf));
Ahs_ventre = trapz(x_ventre_HS,abs(cp_ventre_HS));

%errore sull'area sottesa al cp
err_Adorso_perc = (Ahs_dorso-Axf_dorso)/Axf_dorso*100;
err_Aventre_perc = (Ahs_ventre-Axf_ventre)/Axf_ventre*100;
