%% Grafici Weissinger
% Genera i dati necessari al confronto delle geometrie alari del Cessna 172
% e del Lockheed U-2, sia in presenza che in assenza delle code, ad angoli
% di incidenza tra 0° e 10°, rho=1.225, U=100 m/s.
% Attenzione: richiede tempo

clear
clc
close all

addpath Funzioni_matlab
%% Valutazione solo ali

U_inf_mag=100;
alpha=0:1:10;
rho=1.225;
Coda=0;
graph_weiss=0; % plot di cl, alpha ind, cd, gamma da weissinger
graph_geom=0; % plot della geometria dell'ala da geometria weissinger

[CL_cessna,CD_cessna,L_2D_cessna,D_2D_cessna,C_2D_cessna,Coord_cessna,Circ_cessna,Pan_cessna,Semi_s_cessna]=Weissinger("Cessna 172",Coda,U_inf_mag,alpha,rho,graph_weiss,graph_geom);
[CL_u2,CD_u2,L_2D_u2,D_2D_u2,C_2D_u2,Coord_u2,Circ_u2,Pan_u2,Semi_s_u2]=Weissinger("U2",Coda,U_inf_mag,alpha,rho,graph_weiss,graph_geom);
% [CL_ellissi,CD_ellissi,L_2D_ellissi,D_2D_ellissi,C_2D_ellissi,Coord_ellissi,Circ_ellissi]=Weissinger("Ala ellittica",Coda,U_inf_mag,alpha,rho,graph_weiss,graph_geom,graph_ellisse);

% Percentuale di apertura alare
% Coord_perc_ell.ala=(Coord_ellissi.ala)./(abs(max(Coord_ellissi.ala)));
Coord_perc_cessna.ala=(Coord_cessna.ala)./Semi_s_cessna;
Coord_perc_u2.ala=(Coord_u2.ala)./Semi_s_u2;
Coord_perc_cessna_el.ala=(Coord_cessna.ala_el)./(max(abs(Coord_cessna.ala_el)));
Coord_perc_u2_el.ala=(Coord_u2.ala_el)./(max(abs(Coord_u2.ala_el)));

%% CL, CD
h=figure;
title('C_L e C_D delle sole ali','FontWeight','bold')
hold on
grid on
xlabel('\alpha [°] incidenza','FontWeight','bold')
yyaxis left
ylabel('C_L','FontWeight','bold')
% plot(alpha,CL_ellissi,'LineWidth',1)
plot(alpha,CL_cessna,'LineWidth',1)
plot(alpha,CL_u2,'LineWidth',1.5)
plot([alpha(1) alpha(end)],[0 2*pi*deg2rad(alpha(end))],'-k','LineWidth',1)
legend('Cessna 172 (AR: 7.32)','U-2 (AR: 10.51)','2\pi','Location','northwest')
yyaxis right
ylabel('C_D','FontWeight','bold')
% plot(alpha,CD_ellissi,'HandleVisibility','off','LineWidth',1)
plot(alpha,CD_cessna,'HandleVisibility','off','LineWidth',1)
plot(alpha,CD_u2,'HandleVisibility','off','LineWidth',1.5)

% Per salvataggio
saveas(h,'Grafici\Ali_CL_CD','epsc')
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'Grafici\Ali_CL_CD','-dpdf','-r0')

%% plot resistenza 2D e circolazione
% 
% 
% figure
% hold on
% title('Resistenza e circolazione senza code','FontWeight','bold')
% yyaxis left
% xlabel('% apertura alare','FontWeight','bold')
% ylabel('d [N/m]','FontWeight','bold')
% plot(Coord_perc_ell.ala,D_2D_ellissi.ala,'LineWidth',1) %,'Linestyle','-','Color','#0072BD'
% plot(Coord_perc_cessna.ala,D_2D_cessna.ala,'LineWidth',1) %,'LineStyle','--','Color','#7E2F8E'
% plot(Coord_perc_u2.ala,D_2D_u2.ala,'LineWidth',1.5) %,'LineStyle','-.','Color','#4DBEEE'
% legend('ala ellittica', 'Cessna 172', 'U2')
% yyaxis right
% ylabel('\Gamma [m^2/s]','FontWeight','bold')
% plot(Coord_perc_ell.ala,C_2D_ellissi.ala,'HandleVisibility','off','LineWidth',1) %,'Linestyle','-','Color','#A2142F'
% plot(Coord_perc_cessna.ala,C_2D_cessna.ala,'HandleVisibility','off','LineWidth',1) %,'LineStyle','--','Color','#D95319'
% plot(Coord_perc_u2.ala,C_2D_u2.ala,'HandleVisibility','off','LineWidth',1.5) %,'LineStyle','-.','Color','#EDB120'

%% Resistenza e circolazione
h=figure;
tiledlayout(2,1,"TileSpacing","none");
nexttile
title('Resistenza indotta e Circolazione','FontWeight','bold')
hold on
grid on

% Resistenza indotta
yyaxis left
ylabel('d [N/m]','FontWeight','bold')
% Ali
plot([Coord_perc_cessna.ala(1:end/2)],[D_2D_cessna.ala(1:end/2)],'LineWidth',1,'LineStyle','-')
plot([Coord_perc_u2.ala(end/2+1:end)],[D_2D_u2.ala(end/2+1:end)],'LineWidth',1,'LineStyle','-',"HandleVisibility","off")

% Circolazione
yyaxis right
ylabel('-\Gamma [m^2/s]','FontWeight','bold')
% Ali
plot([Coord_perc_u2_el.ala(1:round(end/2))],[C_2D_u2.ala_el(1:round(end/2))],'LineWidth',1,'LineStyle','-','Color','k')
plot([Coord_perc_cessna_el.ala(round(end/2)+1:end)],[C_2D_cessna.ala_el(round(end/2)+1:end)],'LineWidth',1,'LineStyle','-','Color','k',"HandleVisibility","off")
plot([Coord_perc_cessna.ala(1:end/2)],-C_2D_cessna.ala(1:end/2),'LineWidth',1,'LineStyle','-','Color','r',"HandleVisibility","off","HandleVisibility","off")
plot([Coord_perc_u2.ala(end/2+1:end)],-C_2D_u2.ala(end/2+1:end),'LineWidth',1,'LineStyle','-','Color','r',"HandleVisibility","off","HandleVisibility","off")
% Code
ax = gca();
ax.YColor = 'r';
legend("Ala","\Gamma ellittica")

nexttile
hold on
grid on
for i=1
    mesh(Pan_u2(i).x./4.82,-Pan_u2(i).y./15.75,Pan_u2(i).z,Circ_u2(i).vort,"EdgeColor",'k',"FaceColor","flat")
end
for i=1:2
    mesh(Pan_cessna(i).x./1.63,Pan_cessna(i).y./5.5,Pan_cessna(i).z,Circ_cessna(i).vort,"EdgeColor",'k',"FaceColor","flat")
end
colorbar
colormap turbo
view(90,90)
ylabel('% Apertura alare','FontWeight','bold')
xlabel('\Gamma [m^2/s]','FontWeight','bold')
pbaspect([0.5 3 1])

% Per salvataggio
saveas(h,'Grafici\Distribuzioni_Ali','epsc')
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'Grafici\Distribuzioni_Ali','-dpdf','-r0')

%% Polari
h=figure;
hold on
grid on
title('Polari delle sole ali','FontWeight','bold')
% plot(CD_ellissi,CL_ellissi,'LineWidth',1)
plot(CD_cessna,CL_cessna,'LineWidth',1.5)
plot(CD_u2,CL_u2,'LineWidth',1.5)
legend('Cessna 172 (solo ala)','U-2 (solo ala)','Location','northwest')
xlabel('C_D','FontWeight','bold')
ylabel('C_L','FontWeight','bold')

% Per salvataggio
saveas(h,'Grafici\Polari_Ali','epsc')
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'Grafici\Polari_Ali','-dpdf','-r0')


%% valutazione con la coda

U_inf_mag=100;
alpha=0:1:10;
rho=1.225;
Coda=1;
graph_weiss=0; % plot di cl, alpha ind, cd, gamma da weissinger
graph_geom=0; % plot della geometria dell'ala da geometria weissinger
graph_ellisse=0; % plot della semiala ellittica da blocchi weissinger

[CL_cessna_c,CD_cessna_c,L_2D_cessna_c,D_2D_cessna_c,C_2D_cessna_c,Coord_cessna_c,Circ_cessna_c,Pan_cessna,Semi_s_cessna]=Weissinger("Cessna 172",Coda,U_inf_mag,alpha,rho,graph_weiss,graph_geom);
[CL_u2_c,CD_u2_c,L_2D_u2_c,D_2D_u2_c,C_2D_u2_c,Coord_u2_c,Circ_u2_c,Pan_u2,Semi_s_u2]=Weissinger("U2",Coda,U_inf_mag,alpha,rho,graph_weiss,graph_geom);

% Percentuali di apertura alare
Coord_perc_cessna.coda=(Coord_cessna_c.coda)./Semi_s_cessna(1);
Coord_perc_u2.coda=(Coord_u2_c.coda)./Semi_s_u2(1);
Coord_perc_cessna_el.ala=(Coord_cessna_c.ala_el)./(max(abs(Coord_cessna_c.ala_el)));
Coord_perc_cessna_el.coda=(Coord_cessna_c.coda_el)./(max(abs(Coord_cessna_c.ala_el)));
Coord_perc_u2_el.ala=(Coord_u2_c.ala_el)./(max(abs(Coord_u2_c.ala_el)));
Coord_perc_u2_el.coda=(Coord_u2_c.coda_el)./(max(abs(Coord_u2_c.ala_el)));


%% plot cl e cd 
% colori più chiari senza coda
h=figure;
title('Confronto C_L e C_D','FontWeight','bold')
hold on
grid on
xlabel('\alpha [°] incidenza','FontWeight','bold')
yyaxis left
ylabel('C_L','FontWeight','bold')
plot(alpha,CL_cessna,'LineStyle','-','LineWidth',1.5,'Color','#0072BD')
plot(alpha,CL_u2,'LineStyle','-','LineWidth',1.5,'Color','#4DBEEE')
plot(alpha,CL_cessna_c,'LineStyle','--','LineWidth',1.5,'Color','#0072BD')
plot(alpha,CL_u2_c,'LineStyle','--','LineWidth',1.5,'Color','#4DBEEE')
plot([alpha(1) alpha(end)],[0 2*pi*deg2rad(alpha(end))],'-k','LineWidth',1)


yyaxis right
ylabel('C_D','FontWeight','bold')
plot(alpha,CD_cessna,'LineStyle','-','LineWidth',1.5,'Color','#D95319')
plot(alpha,CD_u2,'LineStyle','-','LineWidth',1.5,'Color','#EDB120')
plot(alpha,CD_cessna_c,'LineStyle','--','LineWidth',1.5,'Color','#D95319')
plot(alpha,CD_u2_c,'LineStyle','--','LineWidth',1.5,'Color','#EDB120')

leg=legend({' ',' ',' ',' ','2\pi','Cessna 172 (solo ala)','U-2 (solo ala)','Cessna 172','U-2'},'Location','northwest','NumColumns',2);
title(leg,'$C_L$ \hspace{1.5 cm} $C_D$ \hspace{3.4 cm}','interpreter','latex')

% Per salvataggio
saveas(h,'Grafici\Ali_code_CL_CD','epsc')
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'Grafici\Ali_code_CL_CD','-dpdf','-r0')
 

%% plot polari
h=figure;
hold on
grid on
title('Confronto polari con e senza coda','FontWeight','bold')
plot(CD_cessna,CL_cessna,'LineStyle','-','LineWidth',1.5,'Color','#0072BD')
plot(CD_cessna_c,CL_cessna_c,'LineStyle','--','LineWidth',1.5,'Color','#0072BD')
plot(CD_u2,CL_u2,'LineStyle','-','LineWidth',1.5,'Color','#4DBEEE')
plot(CD_u2_c,CL_u2_c,'LineStyle','--','LineWidth',1.5,'Color','#4DBEEE')
legend('Cessna 172 (solo ala)','Cessna 172','U-2 (solo ala)','U-2','Location','northwest')
xlabel('C_D','FontWeight','bold')
ylabel('C_L','FontWeight','bold')

% Per salvataggio
saveas(h,'Grafici\Polari_Ali_Code','epsc')
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'Grafici\Polari_Ali_Code','-dpdf','-r0')

%% circolazione e resistenza
h=figure;
tiledlayout(2,1,"TileSpacing","none");
nexttile
title('Resistenza indotta e Circolazione','FontWeight','bold')
hold on
grid on

% Resistenza indotta
yyaxis left
ylabel('d [N/m]','FontWeight','bold')
% Ali
plot([Coord_perc_cessna.ala(1:end/2)],[D_2D_cessna_c.ala(1:end/2)],'LineWidth',1,'LineStyle','-')
plot([Coord_perc_u2.ala(end/2+1:end)],[D_2D_u2_c.ala(end/2+1:end)],'LineWidth',1,'LineStyle','-',"HandleVisibility","off")
% Code
plot([Coord_perc_cessna.coda(1:end/2)],[D_2D_cessna_c.coda(1:end/2)],'LineWidth',1,'LineStyle','--')
plot([Coord_perc_u2.coda(end/2+1:end)],[D_2D_u2_c.coda(end/2+1:end)],'LineWidth',1,'LineStyle','--',"HandleVisibility","off")

% Circolazione
yyaxis right
ylabel('-\Gamma [m^2/s]','FontWeight','bold')
% Ali
plot([Coord_perc_u2_el.ala(1:round(end/2))],[C_2D_u2_c.ala_el(1:round(end/2))],'LineWidth',1,'LineStyle','-','Color','k')
plot([Coord_perc_cessna_el.ala(round(end/2)+1:end)],[C_2D_cessna_c.ala_el(round(end/2)+1:end)],'LineWidth',1,'LineStyle','-','Color','k',"HandleVisibility","off")
plot([Coord_perc_cessna.ala(1:end/2)],-C_2D_cessna_c.ala(1:end/2),'LineWidth',1,'LineStyle','-','Color','r',"HandleVisibility","off","HandleVisibility","off")
plot([Coord_perc_u2.ala(end/2+1:end)],-C_2D_u2_c.ala(end/2+1:end),'LineWidth',1,'LineStyle','-','Color','r',"HandleVisibility","off","HandleVisibility","off")
% Code
plot([Coord_perc_u2_el.coda(1:round(end/2))],[C_2D_u2_c.coda_el(1:round(end/2))],'LineWidth',1,'LineStyle','-','Color','k','Marker','none',"HandleVisibility","off")
plot([Coord_perc_cessna_el.coda(round(end/2)+1:end)],[C_2D_cessna_c.coda_el(round(end/2)+1:end)],'LineWidth',1,'LineStyle','-','Color','k','Marker','none',"HandleVisibility","off")
plot([Coord_perc_cessna.coda(1:end/2)],-C_2D_cessna_c.coda(1:end/2),'LineWidth',1,'LineStyle','--','Marker','none','Color','r',"HandleVisibility","off")
plot([Coord_perc_u2.coda(end/2+1:end)],-C_2D_u2_c.coda(end/2+1:end),'LineWidth',1,'LineStyle','--','Marker','none','Color','r',"HandleVisibility","off")
ax = gca();
ax.YColor = 'r';
legend("Ala","Coda","\Gamma ellittica")

nexttile
hold on
grid on
for i=1:2
    mesh(Pan_u2(i).x./11.2,-Pan_u2(i).y./15.75,Pan_u2(i).z,Circ_u2_c(i).vort,"EdgeColor",'k',"FaceColor","flat")
end
for i=1:size(Pan_cessna,2)/2
    mesh(Pan_cessna(i).x./5.67,Pan_cessna(i).y./5.5,Pan_cessna(i).z,Circ_cessna_c(i).vort,"EdgeColor",'k',"FaceColor","flat")
end
colorbar
colormap turbo
view(90,90)
xlabel('\Gamma [m^2/s]','FontWeight','bold')
ylabel('% Apertura alare','FontWeight','bold')

% Per salvataggio
saveas(h,'Grafici\Distribuzioni_Ali_Code','epsc')
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(h,'Grafici\Distribuzioni_Ali_Code','-dpdf','-r0')

%% Contronto dati
Aereo=["Cessna 172 (solo ala)";"Cessna 172";"Lockheed U-2 (solo ala)";"Lockheed U-2"];
AR=[7.32;NaN;10.51;NaN];
CL_alpha=[(CL_cessna(end)-CL_cessna(1))/(deg2rad(alpha(end))-deg2rad(alpha(1)));
            (CL_cessna_c(end)-CL_cessna_c(1))/(deg2rad(alpha(end))-deg2rad(alpha(1)));
            (CL_u2(end)-CL_u2(1))/(deg2rad(alpha(end))-deg2rad(alpha(1)));
            (CL_u2_c(end)-CL_u2_c(1))/(deg2rad(alpha(end))-deg2rad(alpha(1)))];
V_per_CL_alpha=[NaN;(CL_alpha(2)-CL_alpha(1))/CL_alpha(1)*100;NaN;(CL_alpha(4)-CL_alpha(3))/CL_alpha(3)*100];
CL_max=[max(CL_cessna); max(CL_cessna_c); max(CL_u2); max(CL_u2_c)];
V_per_CL_max=[NaN;(CL_max(2)-CL_max(1))/CL_max(1)*100;NaN;(CL_max(4)-CL_max(3))/CL_max(3)*100];
CD_max=[max(CD_cessna); max(CD_cessna_c); max(CD_u2); max(CD_u2_c)];
V_per_CD_max=[NaN;(CD_max(2)-CD_max(1))/CD_max(1)*100;NaN;(CD_max(4)-CD_max(3))/CD_max(3)*100];

Tabella=table(Aereo,AR,CL_alpha,V_per_CL_alpha,CL_max,V_per_CL_max,CD_max,V_per_CD_max);
disp(Tabella)


