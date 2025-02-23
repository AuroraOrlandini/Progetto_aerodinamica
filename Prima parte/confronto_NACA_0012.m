%% Confronto dei risultati ottenuti da xfoil e dal nostro metodo di Hess-Smith
clear
clc
close all
addpath dati

% Importazione dati da Hess-Smith
Dati_HS = readstruct('Dati_HS.json');

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
Dati_xf = importdata("cp_NACA0012.dat");
cc = importdata('clcm_NACA0012.dat');

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

%% Plot di controllo

% Cp completo
figure
plot(x_HS,-cp_HS,'LineWidth',0.7)
hold on
plot(x_xf,-cp_xf,'LineWidth',0.7)
legend("MATLAB","Xfoil")
grid on
title("$C_p$ completo",'Interpreter','latex')
xlabel('$x$[/]','interpreter','latex','FontWeight','bold')
ylabel('$-C_p$[/]','interpreter','latex','FontWeight','bold')

exportgraphics(gca,'relazione laboratorio/figures/confronto_cp.pdf','ContentType','vector')

% Cp dorso
figure
plot(x_dorso_HS,-cp_dorso_HS,'LineWidth',0.7)
hold on
plot(x_dorso_xf,-cp_dorso_xf,'LineWidth',0.7)
legend("MATLAB","Xfoil")
grid on
title("$C_p$ dorso",'Interpreter','latex')
xlabel('$x$[m]','interpreter','latex','FontWeight','bold')
ylabel('$-C_p$[/]','interpreter','latex','FontWeight','bold')

% Cp ventre
figure
plot(x_ventre_HS,-cp_ventre_HS,'LineWidth',0.7)
hold on
plot(x_ventre_xf,-cp_ventre_xf,'LineWidth',0.7)
legend("MATLAB","Xfoil")
grid on
title("$C_p$ ventre",'Interpreter','latex')
xlabel('$x$[/]','interpreter','latex','FontWeight','bold')
ylabel('$-C_p$[/]','interpreter','latex','FontWeight','bold')
hold off

%% Calcolo degli errori

Axf_dorso = trapz(x_dorso_xf,abs(cp_dorso_xf));
Ahs_dorso = trapz(x_dorso_HS,abs(cp_dorso_HS));

Axf_ventre = trapz(x_ventre_xf,abs(cp_ventre_xf));
Ahs_ventre = trapz(x_ventre_HS,abs(cp_ventre_HS));

err_Adorso_perc = (Ahs_dorso-Axf_dorso)/Axf_dorso*100;
err_Aventre_perc = (Ahs_ventre-Axf_ventre)/Axf_ventre*100;

cp_dorso_interp = interp1(x_dorso_xf,cp_dorso_xf,x_dorso_HS);
cp_ventre_interp = interp1(x_ventre_xf,cp_ventre_xf,x_ventre_HS);

err_dorso = cp_dorso_HS  - cp_dorso_interp ;
err_ventre = cp_ventre_HS - cp_ventre_interp;

err_dorso_perc = abs(err_dorso)./max(cp_dorso_interp)*100;
err_ventre_perc =abs(err_ventre)./max(cp_ventre_interp)*100;

figure 
plot(x_dorso_HS, err_dorso,'r' ,x_ventre_HS,err_ventre,'b')
grid on
legend('dorso','ventre')
title('errore nel $C_p$','Interpreter','latex')

figure 
plot(x_dorso_HS, err_dorso_perc,'r' ,x_ventre_HS,err_ventre_perc,'b')
grid on
legend('dorso','ventre')
title('errore percentuale nel $C_p$','Interpreter','latex')
xlabel('$x$[/]','interpreter','latex','FontWeight','bold')
ylabel('\%','interpreter','latex','FontWeight','bold')

exportgraphics(gca,'relazione laboratorio/figures/err_perc_cp.pdf','ContentType','vector')


err_cl = (CLHS - CLxf)/CLxf*100;
err_cm = (CMHS - CMxf)/CMxf*100;

