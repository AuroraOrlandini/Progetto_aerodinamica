%% Confronto risultati Hess-Smith, Xfoil al variare del numero dei pannelli sul profilo NACA 0012
clc
close all
clear 

addpath Funzioni_matlab
addpath dati

%% Definizione variabili
alpha = 2;
U_inf = 1;
CodiceProfilo = '0012';
Chord = 1;

%% Iterazioni con una serie di numeri di pannelli

% Per rendere eseguibile il file bash:
system("chmod +x ./bash_Npannelli.sh"); 
system("chmod +x ./bash_clcm.sh"); 

Npannelli = 100:10:360;

% Inizializzazione degli errori
err_CL = [];
err_CM = [];
err_CP = [];
cp_xf = [];
CLxf = [];
CMxf = [];
err_Adorso_perc = [];
err_Aventre_perc = [];

%Iterando su un numero di pannelli i
for i = 1:length(Npannelli)

    %- Eseguire il file bash dandogli come input il codice profilo ed il
    %  numero di pannelli
    %- bash_Npannelli: ridefinisce il numero di pannelli sul NACA  0012, 
    %  calcola Cp, Cl e CM_C4 
    system(" ./bash_Npannelli.sh "+CodiceProfilo+" "+Npannelli(i)); 
   
    Cp_xf = importdata("./NACA_"+CodiceProfilo+"_2_cp.txt");

    % Salvare solo i valori che ci interessano della polare
    system("./bash_clcm.sh");

    % Definire i nuovi punti del profilo definiti con il numero di pannelli
    % dell'iterata
    CodiceProfilo_new='profilo_Npannelli.dat';

    % Calcolo di Cp, Cl, CM_C4 tramite il metodo di Hess-Smith
    [Dati_Hess_Smith] = Hess_Smith_func(alpha, U_inf, CodiceProfilo_new, Chord);

    % Calcolo dell'errore che si commette sccegliendo un metodo piuttosto
    % che un altro
    [err_CL_new, err_CM_new, err_CP_new,cp_xf_new,CLxf_new,CMxf_new, err_Aventre_perc_new, err_Adorso_perc_new ] = confrontoNACA(Dati_Hess_Smith, Npannelli(i));
    
    coordinate = importdata("profilo_Npannelli.dat");

    
    % Salvataggio degli errori
    err_Aventre_perc = [err_Aventre_perc; err_Aventre_perc_new];
    err_Adorso_perc = [err_Adorso_perc; err_Adorso_perc_new];
    err_CL = [err_CL; err_CL_new];
    err_CM = [err_CM; err_CM_new];
    err_CP = [err_CP; err_CP_new];
    % cp_xf = [cp_xf; cp_xf_new];
    % CLxf = [CLxf; CLxf_new];
    % CMxf = [CMxf; CMxf_new];

    % Eliminare i file creati da bash_Npannelli e da confrontoNACA
    system("rm "+"NACA_"+CodiceProfilo+"_2_cp.txt");
    system("rm "+"instruction_xfoil.txt");
    system("rm "+"profilo_Npannelli.dat");
    system("rm "+"clcm_NACA0012.dat");
    system("rm "+"./Dati_HS.json");
end

%% Confronto dei vari errori che evidenzi il loro andamento al variare del
% numero di pannelli
h=figure 
plot(Npannelli, err_Aventre_perc, 'o-', 'LineWidth', 1.5);
hold on
grid on
plot(Npannelli, err_Adorso_perc, 'o-', 'LineWidth', 1.5);
plot(Npannelli, err_CL, 'o-', 'LineWidth', 1.5);
plot(Npannelli, err_CM, 'o-', 'LineWidth', 1.5);
% ax = gca;
% ax.FontSize = 30; 
legend('Errore Cp ventre','Errore Cp dorso', 'Errore Cl', 'Errore CM_{C4}');
title('Andamento degli errori al variare del numero di pannelli','Interpreter','latex')
xlabel('Numero di pannelli','interpreter','latex','FontWeight','bold')
ylabel('\%','interpreter','latex','FontWeight','bold')

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'Npannelli','-dpdf','-r0')