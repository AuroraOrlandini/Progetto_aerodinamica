%% Transione e separazione per profili NACA0012 e AH79100C 
% al variare di angolo d'incidenza e numero di Reynolds.
% Genera i grafici dei dati ottenuti tramite XFOIl.

clear 
close all
clc

addpath dati
addpath Funzioni_matlab

%% Selezione profilo
nomeprofilo = "NACA0012";
% nomeprofilo = "AH79100C";
Corpo = importXfoilProfile('NACA_0012_364.dat');
% Corpo = importXfoilProfile('AH_79_100_C.dat');


%% 
directory = "./dati/transizione_" + nomeprofilo + "/";

xtr_top = zeros(3,33); 
xtr_bot = zeros(3,33); 

separato = struct(); 
toll = 1e-5;
for Re = 6:8
	pathPolare = directory + "pol_Re_" + Re + ".dat";
	pol = importdata(pathPolare, " ", 12); 
	alfa = pol.data(:,1); 
        xtr_top(Re - 5, :) = pol.data(:,6)';
    	xtr_bot(Re - 5, :) = pol.data(:,7)'; 	
	for  i = 1:length(alfa)
	        a = sprintf('%.1f', alfa(i)); 	
		pathCF = directory + "cf_Re_" + Re + "_a" + a + ".dat"; 
		[x_d,cf_d,x_v,cf_v] = letturaCF(pathCF); 
		indici_d = find(cf_d <= toll);
		indici_v = find(cf_v <= toll);
		j = size(separato,2) + 1;
		separato(j).Re = Re;
		separato(j).alpha = alfa(i);
		separato(j).xd = x_d(indici_d);
		separato(j).cfd = cf_d(indici_d);
		separato(j).xv = x_v(indici_v);
		separato(j).cfv = cf_v(indici_v);
	end
end
separato = separato(2:end);


%% Plot transizione e separazione al variare di alpha e numero di Reynolds
close all
clc
h=figure;
tiledlayout(4,1,"TileSpacing","none");
nexttile([3 1])
title('Resistenza indotta e Circolazione','FontWeight','bold')
hold on
grid on

    % figure
    colori = ["#0072BD", "#D95319", "#EDB120"];
    
    Re = [6:8];

for j = 1:length(Re)
	indici_scatter = [];
    plot(xtr_top(j,:), alfa, 'Color', colori(j), 'LineWidth', 2);
    hold on
    grid on
    plot(xtr_bot(j,:), alfa,'--', 'Color', colori(j), 'LineWidth', 1, 'HandleVisibility','off');
    
    
    for i = 1:length(alfa) 
        indici_scatter = (([separato.Re] == Re(j)) & ([separato.alpha] == alfa(i)));
        if length(separato(indici_scatter).xd) > 1
            for k = 2:length(separato(indici_scatter).xd)
                if (separato(indici_scatter).xd(k)) <= (separato(indici_scatter).xd(k- ...
                        1)) + 2e-2 & (separato(indici_scatter).xd(k)) >= (separato(indici_scatter).xd(k- ...
                        1)) - 2e-2 
                    val1 =  (separato(indici_scatter).xd(k-1));
                    val2 =  (separato(indici_scatter).xd(k));
                    line = [val1 val2];
                    alfa_plot = [alfa(i) alfa(i)];
                    scatter(separato(indici_scatter).xd,alfa(i), 2*ones(length(separato(indici_scatter).xd),1), 'MarkerEdgeColor',colori(j), 'MarkerFaceColor', colori(j),'HandleVisibility','off'); 
                end
            end
        end

        if length(separato(indici_scatter).xv) > 1

            for k = 2:length(separato(indici_scatter).xv)
                if ((separato(indici_scatter).xv(k)) <= (separato(indici_scatter).xv(k- ...
                        1)) + 1e-2 & (separato(indici_scatter).xv(k)) >= (separato(indici_scatter).xv(k- ...
                        1)) - 1e-2) 


                    val1 =  (separato(indici_scatter).xv(k-1));
                    val2 =  (separato(indici_scatter).xv(k));
                    line = [val1 val2];
                    alfa_plot = [alfa(i) alfa(i)];
                    scatter(separato(indici_scatter).xv,alfa(i), 2*ones(length(separato(indici_scatter).xv),1),'MarkerEdgeColor',colori(j), 'MarkerFaceColor', colori(j),'HandleVisibility','off'); 
                end
            end
        end
    end
end

    legend("Re = 1e" + 6 , "Re = 1e" + 7,"Re = 1e" + 8, 'Location','best');
    title("Transizione e separazione",nomeprofilo)
	ylabel("angolo d'incidenza [deg]")
	

    % figure
    nexttile
    hold on
    grid on


    Chord = 1;
    x = flipud(Corpo.x);
    y = flipud(Corpo.y);
    Corpo.x = x.*Chord;
    Corpo.y = y.*Chord;
    plot(x(1:round(end/2)), y(1:round(end/2)), '--', 'Color','k');
    hold on
    plot(x(round(end/2)+1:end), y(round(end/2)+1:end), 'k-');
    xlabel('x/c [/]')
    % ylim([-0.1 0.1])
    ylim([-0.1 0.2])
    xlim([0 1])

    saveas(h,'Grafici\NACA0012','epsc')
% saveas(h,'Grafici\Distribuzioni_Ali_Code','epsc')
% set(h,'Units','Inches');
% pos = get(h,'Position');
% set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(h,'Grafici\NACA0012','-dpdf','-r0')

