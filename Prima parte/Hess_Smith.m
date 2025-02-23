%% Metodo di Hess-Smith

clc
close all
clear 

addpath Funzioni_matlab
addpath dati

%% Grafici
graph=0;

%% Input

% Angolo di incidenza [°]
alpha = 2;  

% Velocità all'infinito [m/s]
U_inf = 1;  
U_inf_x = U_inf * cos(deg2rad(alpha));
U_inf_y = U_inf * sin(deg2rad(alpha));
U_inf = [U_inf_x; U_inf_y];
U_inf_normal = [-U_inf(2); U_inf(1)];
U_inf_normal = U_inf_normal ./ norm(U_inf_normal);

% Geometria del profilo
CodiceProfilo = '0012_364';

% Corda del profilo
Chord = 1;

%% Creazione profilo

Corpo = importXfoilProfile(strcat('NACA_', CodiceProfilo, '.dat'));
% Prima flippa i vettori
x = flipud(Corpo.x);
y = flipud(Corpo.y);
Corpo.x = x.*Chord;
Corpo.y = y.*Chord;

figure;
plot(x, y, '.k');
axis equal

%% Creazione di una struttura di pannelli

[Centro, Normale, Tangente, Estremo_1, Estremo_2, angle, lunghezza, L2G_TransfMatrix, G2L_TransfMatrix] = CreaStrutturaPannelli(Corpo);
NPannelli = length(Centro(:,1));  
%% Inizializzazione matrici e vettori

% Ora che ho i pannelli, posso inizializzare la matrice ed i vettori
NCols = sum(NPannelli) + 1;
NRows = NCols;
matriceA = zeros(NRows, NCols);
TermineNoto = zeros(NRows, 1);

%% Creazione della matrice quadrata As

for i = 1:NPannelli
    index_i = i; % riga

    Centro_qui = Centro(i, :)';
    Normale_qui = Normale(i, :)';

    indexStart_colonna = 0;

        for j = 1:NPannelli
            index_j = indexStart_colonna + j;  % Colonna

            Estremo_1_qui = Estremo_1(j, :)';
            Estremo_2_qui = Estremo_2(j, :)';

            L2G_TransfMatrix_qui = squeeze(L2G_TransfMatrix(j, :, :));
            G2L_TransfMatrix_qui = squeeze(G2L_TransfMatrix(j, :, :));

            matriceA(index_i, index_j) = dot(ViSorgente(Centro_qui, Estremo_1_qui, Estremo_2_qui, L2G_TransfMatrix_qui, G2L_TransfMatrix_qui), Normale_qui);

            matriceA(index_i, sum(NPannelli)+1) = matriceA(index_i, sum(NPannelli)+1) + dot(ViVortice(Centro_qui, Estremo_1_qui, Estremo_2_qui, L2G_TransfMatrix_qui, G2L_TransfMatrix_qui), Normale_qui);
        end
end


%% Creazione delle componenti dei vettori a_v, c_s e c_v


Centro_Start = Centro(1, :)';
Tangente_Start = Tangente(1, :)';

Centro_End = Centro(end, :)';
Tangente_End = Tangente(end, :)';


b = 0;
for j = 1:NPannelli(1)

    index_j = j;

    Estremo_1_qui = Estremo_1(j, :)';
    Estremo_2_qui = Estremo_2(j, :)';
    L2G_TransfMatrix_qui = squeeze(L2G_TransfMatrix(j, :, :));
    G2L_TransfMatrix_qui = squeeze(G2L_TransfMatrix(j, :, :));

    a = dot(ViSorgente(Centro_Start, Estremo_1_qui, Estremo_2_qui, L2G_TransfMatrix_qui, G2L_TransfMatrix_qui), Tangente_Start);
    b = b + dot(ViVortice(Centro_Start, Estremo_1_qui, Estremo_2_qui, L2G_TransfMatrix_qui, G2L_TransfMatrix_qui), Tangente_Start);

    a = a + dot(ViSorgente(Centro_End, Estremo_1_qui, Estremo_2_qui, L2G_TransfMatrix_qui, G2L_TransfMatrix_qui), Tangente_End);
    b = b + dot(ViVortice(Centro_End, Estremo_1_qui, Estremo_2_qui, L2G_TransfMatrix_qui, G2L_TransfMatrix_qui), Tangente_End);


    matriceA(sum(NPannelli) + 1, index_j) = a;

end

matriceA(sum(NPannelli) + 1, sum(NPannelli) + 1) = b;



%% Creazione del termine noto

for j = 1:NPannelli

    Normale_qui = Normale(j, :)';

    index = j;

    TermineNoto(index) = - dot(U_inf, Normale_qui);
end

Tangente_1 = Tangente(1, :)';
Tangente_end = Tangente(end, :)';
TermineNoto(sum(NPannelli) + 1) = - dot(U_inf, (Tangente_1 + Tangente_end));

%% Risoluzione sistema lineare
Soluzione = linsolve(matriceA,TermineNoto);


%% Plot campo di velocità
if graph == 1

[X,Y]=meshgrid(-0.5:0.005:1.5,-0.4:0.005:0.4);
[ux,uy,U]=Velocita_Hess_Smith(Soluzione, U_inf, X, Y, Corpo);

figure
hold on
s=pcolor(X,Y,U);
set(s,'EdgeColor','none')
set(s,'FaceColor','interp')
colormap turbo
colorbar
plot(x, y, '-k');
axis equal
title("U")
end


%% Calcolo del cp

% Separa le coordinate del dorso e del ventre
dorso=Centro(round(end/2)+1:end,:);
ventre=Centro(1:round(end/2),:);

Tangente_dorso=Tangente(round(end/2)+1:end,:);
Tangente_ventre=Tangente(1:round(end/2),:);

lunghezza_dorso=lunghezza(round(end/2)+1:end);
lunghezza_ventre=lunghezza(1:round(end/2));


% Calcola il modulo della velocità in corrispondenza di ogni coordinata
[u_dorso,v_dorso,U_dorso]=Velocita_Hess_Smith(Soluzione, U_inf, dorso(:,1), dorso(:,2), Corpo);
[u_ventre,v_ventre,U_ventre]=Velocita_Hess_Smith(Soluzione, U_inf, ventre(:,1), ventre(:,2), Corpo);

% Calcola il cp
cp_dorso=1-U_dorso.^2./(norm(U_inf).^2);
cp_ventre=1-U_ventre.^2./(norm(U_inf).^2);
cp=[cp_ventre; cp_dorso];

clc
figure
plot(dorso(:,1),-cp_dorso,'b-','LineWidth',0.7)
hold on
grid on
plot(ventre(:,1),-cp_ventre,'r-','LineWidth',0.7)
title('$C_P$','interpreter','latex','FontWeight','bold')
xlabel('$\frac{x}{c}$[/]','interpreter','latex','FontWeight','bold')
ylabel('$-C_p$[/]','interpreter','latex','FontWeight','bold')
legend("Dorso","Ventre")


%% Calcolo del Cl
%%% Tramite la definizione esatta
cn_dorso=zeros(length(cp_dorso),1);
cn_ventre=zeros(length(cp_ventre),1);

ca_dorso=zeros(length(cp_dorso),1);
ca_ventre=zeros(length(cp_ventre),1);

% Integro il cp
% Coefficiente forza normale
for i=1:length(cp_dorso)
    cn_dorso(i)=(cp_dorso(i).*lunghezza_dorso(i)./Chord);
end

for i=1:length(cp_ventre)
    cn_ventre(i)=(cp_ventre(i).*lunghezza_ventre(i)./Chord);
end

cn=sum(cn_ventre)-sum(cn_dorso);

% Coefficiente forza assiale
for i=1:length(cp_dorso)
    ca_dorso(i)=(cp_dorso(i).*lunghezza_dorso(i)./Chord).*(Tangente_dorso(i,2)./Tangente_dorso(i,1));
end

for i=1:length(cp_ventre)
    ca_ventre(i)=(cp_ventre(i).*lunghezza_ventre(i)./Chord).*(Tangente_ventre(i,2)./Tangente_ventre(i,1));
    if ca_ventre(i) == Inf
        ca_ventre(i)=0;
    end
end

ca=sum(ca_dorso)-sum(ca_ventre);

% Coefficiente di portanza esatto
Cl_es=cn*cosd(alpha)-ca*sind(alpha);

%%% Tramite uso della circolazione per unità di lunghezza
gamma=Soluzione(end);
l_tot=sum(lunghezza);

% Circolazione totale
Gamma=l_tot*gamma;
Cl_circ=2*Gamma/norm(U_inf);


%% calcolo CM_C4

% calcolo CM al bordo d'attacco
rx=zeros(1,NPannelli);
ry=zeros(1,NPannelli);
cm=zeros(1,NPannelli);

LE = Centro(round(end/2),:);

for i = 1:NPannelli
    rx(i) = Centro(i,1)-LE(1);
    ry(i) = Centro(i,2)-LE(2);
end
r = [rx',ry',zeros(NPannelli,1)];
Normalecross = [Normale,zeros(NPannelli,1)];

for i = 1:NPannelli
    cm(i) = cp(i).*lunghezza(i)./Chord^2*dot(cross(r(i,:),Normalecross(i,:)),[0,0,1]);
end

CM_le = -sum(cm);

% calcolo CM a C/4
%considerando le coordinate di xfoil è possibile affermare che
CM0 = CM_le; 
CM_C4 = CM0-abs(Cl_es)/4;

%% Esportazione dati
% I dati relativi al cp, alle coordinate x in cui è calcolato il cp, al Cl
% e al Cm vengono salvati in una struttura in cui corrispondono
% rispettivamente ai campi ".cp", ".x", ".Cl", ".Cm"

% I dati relativi al cp sono duplicati e salvati separatemente per dorso e
% ventre in: ".cp_dorso", ".x_dorso", ".cp_ventre", ".x_ventre"

% Il file viene salvato nella cartella "dati_MATLAB"
Dati_HS.cp=cp;
Dati_HS.cp_dorso=cp_dorso;
Dati_HS.cp_ventre=cp_ventre;
Dati_HS.x=Centro(:,1);
Dati_HS.x_dorso=dorso(:,1);
Dati_HS.x_ventre=ventre(:,1);
Dati_HS.Cl=Cl_es;
Dati_HS.Cm=CM_C4;

writestruct(Dati_HS,'dati/Dati_HS.json')