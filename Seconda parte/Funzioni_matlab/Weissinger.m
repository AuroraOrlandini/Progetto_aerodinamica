function [CL,CD,L_2D,D_2D,C_2D,Coord,Circ,Pan,Semi_span]=Weissinger(Aereo,Coda,U_inf_mag,alpha,rho,graph_weiss,graph_geom)

% Implementazione del metodo di Weissinger così come descritto in: Moran, Jack 
% 1984 An introduction to theoretical and computational aerodynamics. John Wiley
% & sons
% Nello specifico, le forze agenti su ciascun pannello sono calcolate con il 
% Teorema di Kutta-Joukowski in 3 dimensioni (F = rho*U x Gamma), per poi 
% sommarle e proiettarle in direzione normale e tangente alla velocità 
% asintotica per ottenere i carichi aerodinamici complessivi. 

%%% INPUT
% Aereo [string]    Codice identificativo del velivolo richiesto (come
%                   indicato in Blocchi_Weissinger.m)
%
% Coda [int]        1 se si desidera la coda, 0 o omesso altrimenti
%
% U_inf_mag [num]   Intensità della velocità asintotica [m/s]
%
% alpha [num]       Angolo di incidenza [deg]
%
% rho [num]         Densità corrente asintotica [kg/m^3]
%
% graph_weiss [int] 1 per i grafici delle quantità calcolate, 0 altrimenti
%
% graph_geom [int]  1 per i grafici della geometria discretizzata, 0 altrimenti 

%%% OUTPUT
% CL [num]          Coefficiente di portanza
%
% CD [num]          Coefficiente di resistenza indotta
%
% L_2D [vect]       Distribuzione di portanza per unità di apertura sulla
%                   superficie alare [N/m]
%
% D_2D [vect]       Distribuzione di resistenza indotta per unità di apertura 
%                   sulla superficie alare [N/m]
%
% C_2D [vect]       Distribuzione di circolazione lungo l'apertura alare
%                   della superficie [m/s]
%
% Coord [mat]       Coordinate relative alla posizione in cui le quantità
%                   sopra citate sono calcolate [m]
%
% Circ [struct]     Circolazione associata ai pannelli di ciascun blocco.
%                   A ciascuna riga corrisponde un blocco, così come inserito in 
%                   Blocchi_Weissinger.m.
%
% Pan [struct]      Struttura suddivisa nei campi x, y, z [m]. Ciascun 
%                   campo è una matrice contenente le rispettive coordinate 
%                   dei vertici dei pannelli di ciascun blocco così come 
%                   inserito in Blocchi_Weissinger.m. Il campo norm è la
%                   normale uscente del rispettivo pannello.
%
% Semi_span         Semi apertura alare [m] (necessaria per creare grafici 
%                   dei risultati)


addpath Funzioni_matlab


%% suddivisione pianta in pannelli
[Blocco,Blocchi_ala,Blocchi_coda]=Blocchi_Weissinger(Aereo,Coda);


%% Generazione geometria
[Pan,PC,V,PC_mat,~,S]=geometria_Weissinger(Blocco,graph_geom);

% Numero di pannelli lungo l'apertura alare per ciascun blocco
N_span_ala=[Blocco(Blocchi_ala).N_span Blocco(Blocchi_ala).N_span];
if isempty(Blocchi_coda)==0
N_span_coda=[Blocco(Blocchi_coda).N_span Blocco(Blocchi_coda).N_span];
end

% Aggiorno array blocchi
Blocchi_ala=[Blocchi_ala ,Blocchi_ala+size(Blocco,2)];
if isempty(Blocchi_coda)==0
Blocchi_coda=[Blocchi_coda ,Blocchi_coda+size(Blocco,2)];
end

N_cur_ala=0;
N_cur_coda=0;
it_ala=1;
it_coda=1;
Max_y_ala=-Inf;
Min_y_ala=Inf;
if isempty(Blocchi_coda)==0
    Max_y_coda=-Inf;
    Min_y_coda=Inf;
end

for i=1:2*size(Blocco,2)
    if any(i==Blocchi_ala)
        %%% ALA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Estensione in apertura di ciascun pannello
        Db_ala(N_cur_ala+1:N_cur_ala+N_span_ala(it_ala))=abs(Pan(i).y(1:end-1,1)-Pan(i).y(2:end,1));

        % Coordinate dei punti di controllo
        % Coord_ala(N_cur_ala+1:N_cur_ala+N_span_ala(it_ala),1) = (-(Pan(i).x(1:end-1,1)+Pan(i).x(2:end,1))./2 +(Pan(i).x(1:end-1,end)+Pan(i).x(2:end,end))./2)./4 +(Pan(i).x(1:end-1,1)+Pan(i).x(2:end,1))./2;
        Coord_ala(N_cur_ala+1:N_cur_ala+N_span_ala(it_ala),2)=[PC_mat(i).y(:,1)];
        % Coord_ala(N_cur_ala+1:N_cur_ala+N_span_ala(it_ala),3) = [PC_mat(i).z(:,1)];

        % Normale punti di controllo
        % n_ala(N_cur_ala+1:N_cur_ala+N_span_ala(it_ala),:)=(Pan(i).norm'*ones(1,length(Coord_ala(N_cur_ala+1:N_cur_ala+N_span_ala(it_ala),1))))';

        % Coordinate estreme y
        Max_y_ala=max([max(max(Pan(i).y)) Max_y_ala]);
        Min_y_ala=min([min(min(Pan(i).y)) Min_y_ala]);

        N_cur_ala=N_cur_ala+N_span_ala(it_ala);
        it_ala=it_ala+1;
    else
        %%% CODA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Estensione in apertura di ciascun pannello
        Db_coda(N_cur_coda+1:N_cur_coda+N_span_coda(it_coda))=abs(Pan(i).y(1:end-1,1)-Pan(i).y(2:end,1));
        
        % Coordinate dei punti di controllo 
        % Coord_coda(N_cur_coda+1:N_cur_coda+N_span_coda(it_coda),1) = (-(Pan(i).x(1:end-1,1)+Pan(i).x(2:end,1))./2 +(Pan(i).x(1:end-1,end)+Pan(i).x(2:end,end))./2)./4 +(Pan(i).x(1:end-1,1)+Pan(i).x(2:end,1))./2;
        Coord_coda(N_cur_coda+1:N_cur_coda+N_span_coda(it_coda),2)=[PC_mat(i).y(:,1)];
        % Coord_coda(N_cur_coda+1:N_cur_coda+N_span_coda(it_coda),3) = [PC_mat(i).z(:,1)];
        
        % Normale punti di controllo
        % n_coda(N_cur_coda+1:N_cur_coda+N_span_coda(it_coda),:)=(Pan(i).norm'*ones(1,length(Coord_coda(N_cur_coda+1:N_cur_coda+N_span_coda(it_coda),1))))';

        % Coordinate estreme y
        Max_y_coda=max([max(max(Pan(i).y)) Max_y_coda]);
        Min_y_coda=min([min(min(Pan(i).y)) Min_y_coda]);

        N_cur_coda=N_cur_coda+N_span_coda(it_coda);
        it_coda=it_coda+1;
    end
end


%% Costruzione matrice A e termine noto
% Preallocazione della matrice A
A=zeros(2*([Blocco.N_span]*[Blocco.N_chord]'));

% Preallocazione termine noto
b=zeros(2*([Blocco.N_span]*[Blocco.N_chord]'),1);

% Seleziono il punto di controllo "i"
for i=1:size(A,1)
    % Calcolo il contributo del vortice "j" sul punto di controllo "i"
    for j=1:size(A,2)
        % Velocità indotta dal vortice "j" (compresa dei segmenti semi-infiniti) nel punto di controllo "i"
        v_vort=Velocita_Vortice([V.up.x(j) V.up.y(j) V.up.z(j)],[V.down.x(j) V.down.y(j) V.down.z(j)],[PC.x(i) PC.y(i) PC.z(i)]);

        % Elemento "ij" della matrice A (proiezione di v_vort lungo la normale nel punto di controllo)
        A(i,j)=v_vort*PC.norm(i,:)';
    end
end

% Preallocazione variabili per calcolo carichi aerodinamici
L=zeros(1,length(alpha));
D=zeros(1,length(alpha));
C=zeros(1,length(alpha));
Circ(2*size(Blocco,2)) = struct();
F(2*size(Blocco,2)) = struct();

for a=1:length(alpha)
    U_inf=[cosd(alpha(a)) 0 sind(alpha(a))].*U_inf_mag;
for i=1:size(A,1)
    % Elemento "i" del termine noto (opposto della proiezione della velocità asintotica lungo la normale nel punto di controllo)
    b(i)=-U_inf*PC.norm(i,:)';
end
    

%% Risoluzione sistema lineare
Gamma=A\b;


%% Calcolo forze
forze=zeros(size(A,1),3);
v_vort_f=zeros(size(A,1),3);
for i=1:size(A,1)
    % Calcolo il contributo del vortice "j" sul punto di controllo "i"
    for j=1:size(A,2)
        v_vort_f(j,:)=Gamma(j).*Velocita_Vortice([V.up.x(j) V.up.y(j) V.up.z(j)],[V.down.x(j) V.down.y(j) V.down.z(j)],[V.up.x(i)+V.down.x(i) V.up.y(i)+V.down.y(i) V.up.z(i)+V.down.z(i)].*0.5);
    end
    forze(i,:)=Gamma(i).*rho.*cross(U_inf+[sum(v_vort_f(:,1)) sum(v_vort_f(:,2)) sum(v_vort_f(:,3))],([V.down.x(i) V.down.y(i) V.down.z(i)]-[V.up.x(i) V.up.y(i) V.up.z(i)])./norm([V.down.x(i) V.down.y(i) V.down.z(i)]-[V.up.x(i) V.up.y(i) V.up.z(i)]));
end
forze_s=forze;


%% Calcolo quantità aerodinamiche
N_cur_ala=0;
N_cur_coda=0;
it_ala=1;
it_coda=1;

for i=1:2*size(Blocco,2)
    % Assegnazione di ciascun vortice al rispettivo pannello
    Circ(i).vort=reshape(Gamma(1:(size(Pan(i).x,1)-1)*(size(Pan(i).x,2)-1)),size(Pan(i).x,2)-1,size(Pan(i).x,1)-1)';

    % Assegnazione di ciascuna forza al rispettivo pannello
    F(i).x=reshape(forze_s(1:(size(Pan(i).x,1)-1)*(size(Pan(i).x,2)-1),1),size(Pan(i).x,2)-1,size(Pan(i).x,1)-1)';
    F(i).y=reshape(forze_s(1:(size(Pan(i).x,1)-1)*(size(Pan(i).x,2)-1),2),size(Pan(i).x,2)-1,size(Pan(i).x,1)-1)';
    F(i).z=reshape(forze_s(1:(size(Pan(i).x,1)-1)*(size(Pan(i).x,2)-1),3),size(Pan(i).x,2)-1,size(Pan(i).x,1)-1)';

    % Rimuovo dall'elenco delle circolazioni quelle assegnate
    Gamma(1:(size(Pan(i).x,1)-1)*(size(Pan(i).x,2)-1))=[];
    forze_s(1:(size(Pan(i).x,1)-1)*(size(Pan(i).x,2)-1),:)=[];

    if any(i==Blocchi_ala)
        %%% ALA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Circolazione, portanza e resistenza 2D per sezioni ala
        lift=zeros(1,size(Circ(i).vort,1));
        drag=zeros(1,size(Circ(i).vort,1));
        circ=zeros(1,size(Circ(i).vort,1));
        for k=1:size(Circ(i).vort,1)
        lift(k)=dot([sum(F(i).x(k,:)) sum(F(i).y(k,:)) sum(F(i).z(k,:))],[-U_inf(3)/U_inf_mag 0 U_inf(1)/U_inf_mag]);
        drag(k)=dot([sum(F(i).x(k,:)) sum(F(i).y(k,:)) sum(F(i).z(k,:))],U_inf./U_inf_mag);
        circ(k)=sum(Circ(i).vort(k,:));
        end
        L_2D_ala(N_cur_ala+1:N_cur_ala+N_span_ala(it_ala))=lift;
        D_2D_ala(N_cur_ala+1:N_cur_ala+N_span_ala(it_ala))=drag;
        C_2D_ala(N_cur_ala+1:N_cur_ala+N_span_ala(it_ala))=circ;

        N_cur_ala=N_cur_ala+N_span_ala(it_ala);
        it_ala=it_ala+1;
    else
        %%% CODA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Circolazione, portanza e resistenza 2D per sezioni coda
        lift=zeros(1,size(Circ(i).vort,1));
        drag=zeros(1,size(Circ(i).vort,1));
        circ=zeros(1,size(Circ(i).vort,1));
        for k=1:size(Circ(i).vort,1)
        lift(k)=dot([sum(F(i).x(k,:)) sum(F(i).y(k,:)) sum(F(i).z(k,:))],[-U_inf(3)/U_inf_mag 0 U_inf(1)/U_inf_mag]);
        drag(k)=dot([sum(F(i).x(k,:)) sum(F(i).y(k,:)) sum(F(i).z(k,:))],U_inf./U_inf_mag);
        circ(k)=sum(Circ(i).vort(k,:));
        end
        L_2D_coda(N_cur_coda+1:N_cur_coda+N_span_coda(it_coda))=lift;
        D_2D_coda(N_cur_coda+1:N_cur_coda+N_span_coda(it_coda))=drag;
        C_2D_coda(N_cur_coda+1:N_cur_coda+N_span_coda(it_coda))=circ;

        N_cur_coda=N_cur_coda+N_span_coda(it_coda);
        it_coda=it_coda+1;
    end
end


%% Circolazione portanza e resistenza complessiva
L_ala=L_2D_ala*Db_ala';
D_ala=D_2D_ala*Db_ala';
C_ala=sum(C_2D_ala);
if isempty(Blocchi_coda)==0
    L_coda=L_2D_coda*Db_coda';
    D_coda=D_2D_coda*Db_coda';
    C_coda=sum(C_2D_coda);
    D(a)=D_ala+D_coda;
    L(a)=L_ala+L_coda;
    C(a)=C_ala+C_coda;
else
    L(a)=L_ala;
    D(a)=D_ala;
    C(a)=C_ala;
end
end


%% Coefficienti aerodinamici

CD=D./(0.5*rho*sum(S(Blocchi_ala))*U_inf_mag.^2);
CL=L./(0.5*rho*sum(S(Blocchi_ala))*U_inf_mag.^2);


%% Ordinamento delle variabili
[Coord_ala(:,2),sortIdx] = sort(Coord_ala(:,2),'descend');
L_2D_ala=L_2D_ala(sortIdx);
D_2D_ala=D_2D_ala(sortIdx);
C_2D_ala=C_2D_ala(sortIdx);

if isempty(Blocchi_coda)==0
    [Coord_coda(:,2),sortIdx] = sort(Coord_coda(:,2),'descend');
    L_2D_coda=L_2D_coda(sortIdx);
    D_2D_coda=D_2D_coda(sortIdx);
    C_2D_coda=C_2D_coda(sortIdx);
end


%% Angolo di incidenza indotta
alpha_ind_ala=atan(D_2D_ala./L_2D_ala);
if isempty(Blocchi_coda)==0
    alpha_ind_coda=rad2deg(atan(D_2D_coda./L_2D_coda));
end


%% Circolazione ellittica
C_tot_ala=abs(trapz([Max_y_ala; Coord_ala(:,2); Min_y_ala],[0 C_2D_ala 0]));
ellissi_ala=@(x) sqrt((C_tot_ala*4/(pi*abs(Max_y_ala-Min_y_ala))).^2.*(1-x.^2./((0.5*abs(Max_y_ala-Min_y_ala))^2)));
if isempty(Blocchi_coda)==0
    C_tot_coda=abs(trapz([Max_y_coda; Coord_coda(:,2); Min_y_coda],[0 C_2D_coda 0]));
    ellissi_coda=@(x) sqrt((C_tot_coda*4/(pi*abs(Max_y_coda-Min_y_coda))).^2.*(1-x.^2./((0.5*abs(Max_y_coda-Min_y_coda))^2)));
end

fprintf("\nAspect ratio = %f\n",abs(Max_y_ala-Min_y_ala)^2/sum(S(Blocchi_ala)))

% Salvataggio variabili
L_2D.ala=L_2D_ala;
D_2D.ala=D_2D_ala;
C_2D.ala=C_2D_ala;
C_2D.ala_el=ellissi_ala(Min_y_ala:0.01:Max_y_ala);
Coord.ala=Coord_ala(:,2);
Coord.ala_el=Min_y_ala:0.01:Max_y_ala;
Semi_span(1)=abs(Max_y_ala-Min_y_ala)*0.5;

if isempty(Blocchi_coda)==0
    L_2D.ala=L_2D_ala;
    D_2D.ala=D_2D_ala;
    C_2D.ala=C_2D_ala;
    L_2D.coda=L_2D_coda;
    D_2D.coda=D_2D_coda;
    C_2D.coda=C_2D_coda;
    C_2D.coda_el=ellissi_coda(Min_y_coda:0.01:Max_y_coda);
    Coord.coda=Coord_coda(:,2);
    Coord.coda_el=Min_y_coda:0.01:Max_y_coda;
    Semi_span(2)=abs(Max_y_coda-Min_y_coda)*0.5;
end

if nargin > 5 && graph_weiss==1
%% Plot
% Circolazione sulla pianta alare
figure
for i=1:2*size(Blocco,2)
    mesh(Pan(i).x,Pan(i).y,Pan(i).z,Circ(i).vort,"EdgeColor",'k',"FaceColor","flat")
    grid on
    hold on
    axis equal
    colorbar
    colormap turbo
end
quiver3(PC.x',PC.y',PC.z',forze(:,1),forze(:,2),forze(:,3),'k')
title("Intensità circolazione")

% Portanza
figure
plot(Coord_ala(:,2),L_2D_ala,'LineWidth',1)
hold on
grid on
if isempty(Blocchi_coda)==0
plot(Coord_coda(:,2),L_2D_coda,'LineWidth',1)
end
if isempty(Blocchi_coda)==0
    legend("Ala","Coda")
else
    legend("Ala")
end
title("Portanza per unità di apertura",'FontWeight','bold')
xlabel('$Apertura$ [m]','interpreter','latex','FontWeight','bold')
ylabel('$l$ [N/m]','interpreter','latex','FontWeight','bold')

% Resistenza
figure
plot(Coord_ala(:,2),D_2D_ala,'LineWidth',1)
hold on
grid on
if isempty(Blocchi_coda)==0
plot(Coord_coda(:,2),D_2D_coda,'LineWidth',1)
end

if isempty(Blocchi_coda)==0
    legend("Ala","Coda")
else
    legend("Ala")
end
title("Resistenza indotta per unità di apertura",'FontWeight','bold')
xlabel('$Apertura$ [m]','interpreter','latex','FontWeight','bold')
ylabel('$d$ [N/m]','interpreter','latex','FontWeight','bold')

% Circolazione
figure
plot(Coord_ala(:,2),abs(C_2D_ala),'LineWidth',1)
hold on
grid on
plot(Coord.ala_el,C_2D.ala_el,'k--','LineWidth',0.7)
legend("Ala","\Gamma ellittica")
if isempty(Blocchi_coda)==0
plot(Coord_coda(:,2),abs(C_2D_coda),'LineWidth',1)
plot(Coord.coda_el,C_2D.coda_el,'k--','LineWidth',0.7)
legend("Ala","\Gamma ellittica","Coda")
end
title("Intensità Circolazione",'FontWeight','bold')
xlabel('$Apertura$ [m]','interpreter','latex','FontWeight','bold')
ylabel('\Gamma [m^2/s]','FontWeight','bold')

% Angolo di incidenza indotto
figure
plot(Coord_ala(:,2),alpha_ind_ala,'LineWidth',1)
hold on
grid on
if isempty(Blocchi_coda)==0
plot(Coord_coda(:,2),alpha_ind_coda,'LineWidth',1)
end

if isempty(Blocchi_coda)==0
    legend("Ala","Coda")
else
    legend("Ala")
end
title("Angolo di incidenza indotto",'FontWeight','bold')
ylabel('\alpha_{ind} [°]','FontWeight','bold')

% Cl alfa e polare
if length(alpha)>1
    figure
    plot(alpha,CL)
    grid on
    ylabel("C_L")
    xlabel("Alpha")
    title("C_L alpha")

    figure
    plot(CD,CL)
    grid on
    xlabel("C_D")
    ylabel("C_L")
    title("Polare")
end
end
end
