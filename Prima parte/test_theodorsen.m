%% Validazione del calcolo geometrico dell'angolo di Theodorsen a partire
% dall'integrazione della derivata della linea media. Valori di riferimento
% riportati da "Theory of Wing Sections"
clear
clc
close all

addpath Funzioni_matlab
addpath dati

%% Dati di riferimento da "Theory of Wing Sections"
ref=[2.81 , 1.6 , 0.74 , 0 , -0.74 , -1.6];

%% Dati Xfoil
[a(1)]=theodorsen('NACA_6212_364.dat');
[a(2)]=theodorsen('NACA_6312_364.dat');
[a(3)]=theodorsen('NACA_6412_364.dat');
[a(4)]=theodorsen('NACA_6512_364.dat');
[a(5)]=theodorsen('NACA_6612_364.dat');
[a(6)]=theodorsen('NACA_6712_364.dat');
a=rad2deg(a);

%% Calcolo degli angoli di theodorsen dei profili NACA di riferimento
% L'angolo di progetto viene calcolato come l'angolo di incidenza tale per 
% cui il picco minimo di Cp sul bordo d'attacco (nel grafico di Cp, non di 
% -Cp) viene massimizzato. Per il confronto la funzeione 'theodorsen_cp' 
% utilizza i valori di coefficiente di pressione calcolati da xfoil.

%definizione dei range di alpha su cui ricercare l'angolo di theodorsen
%-osservare che sono stati scelti in modo diverso per ogni profilo in modo 
% da evitare un numero eccessivo di iterate, laddove il risultato che si
% otterrà sappiamo che ricadrà all'interno di questi intervalli
alpha_start = [ 2.60 1.40 0.00 -0.19 -0.90 -1.91];
alpha_end = [ 2.90 1.80 0.80 0.20 0.80 0.19];

%ATTENZIONE: cambiando alpha_step a cifre decimali diverse è necessario 
% modificare la funzione theodorsen_cp a riga 102, dove il valore da 
% modificare è %.3f, dove "3" descrive il numero di cifre decimali dopo 
% la virgola
alpha_step = 0.001; 

Profili =  ["NACA_6212_364.dat", "NACA_6312_364.dat", "NACA_6412_364.dat",...
    "NACA_6512_364.dat", "NACA_6612_364.dat", "NACA_6712_364.dat"];

for i = 1:size(alpha_start,2)
    [alpha_theo_xf(i) ] = theodorsen_cp(Profili(i), alpha_start(i), ...
    alpha_end(i), alpha_step);
end

% Calcolo dell'errore 
err_xf=(ref-alpha_theo_xf);


%% Plot
err=(ref-a);
h=figure;
plot(ref,'-o', 'Color', '#EDB120', 'LineWidth',1.5)
hold on
plot(a,'-o','Color','#4DBEEE', 'LineWidth',1.5)
plot(alpha_theo_xf,'-o', 'Color','#7E2F8E', 'LineWidth',1.5)
plot(err,'k-x','LineWidth',1.5)
plot(err_xf,'-x','Color', '#A2142F', 'LineWidth',1.5)
grid on
% ax = gca;
% ax.FontSize = 30; 
legend("Valori tabulati","Valori calcolati con teoria profili sottili", ...
    "Valori calcolati con metodo Cp","Errore metodo teoria profili sottili" ...
    , "Errore metodo Cp")
title("Confronto angoli di Theodorsen")
ylabel('$\mathbf{\alpha_{Th} [deg]}$','interpreter','latex','FontWeight','bold')
xlabel('Profilo di riferimento','FontWeight','bold')
xline(1,"--","NACA 6212","LabelVerticalAlignment","bottom","HandleVisibility","off")
xline(2,"--","NACA 6312","LabelVerticalAlignment","bottom","HandleVisibility","off")
xline(3,"--","NACA 6412","LabelVerticalAlignment","bottom","HandleVisibility","off")
xline(4,"--","NACA 6512","LabelVerticalAlignment","bottom","HandleVisibility","off")
xline(5,"--","NACA 6612","LabelVerticalAlignment","bottom","HandleVisibility","off")
xline(6,"--","NACA 6712","LabelVerticalAlignment","bottom","HandleVisibility","off")
yline(0,'k-',"HandleVisibility","off")
% set(gca,'XTick',[])
xlim([0.75 6.25])


saveas(h,'Grafici\Theodorsen','epsc')
% set(h,'Units','Inches');
% pos = get(h,'Position');
% set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(h,'Grafici\Confronto_Angoli_Theodorsen','-dpdf','-r0')