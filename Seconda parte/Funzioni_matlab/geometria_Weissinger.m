function [Pan,PC,V,PC_mat,V_mat,S]=geometria_Weissinger(Blocco,graph)

% Discretizza l'intera geometria di ala e coda in un unico ciclo for
% calcolando gli estremi di ciascun pannello, i punti di controllo e gli 
% estremi dei vortici a ferro di cavallo. 
% Le coordinate y e z di pannelli, punti di collocazione ed estremi dei
% vortici sono ottenute interpolando linearmente le coordinate degli estremi
% di ciascun blocco.
% Le coordinate x sono ottenute interpolando bilinearmente: nella direzione
% fisica x sono utilizzate le coordinate effettive degli estremi di ciascun
% blocco, nella direzione y si utilizzano gli indici della matrice in cui
% vengono salvate le coordinate per simulare delle coordinate spaziali.

%%% Input
% Blocco [struct]       Struttura le cui righe corrispondono ai blocchi in cui
%                       è suddivisa la geometria in input.
% Blocco.p1 [1x3]       Vettore contenente le coordinate del primo vertice del
%                       blocco.
% Blocco.p2 [1x3]       Vettore contenente le coordinate del secondo vertice del
%                       blocco.
% Blocco.p3 [1x3]       Vettore contenente le coordinate del terzo vertice del
%                       blocco.
% Blocco.p4 [1x3]       Vettore contenente le coordinate del quarto vertice del
%                       blocco.
% Blocco.N_chord [int]  Numero di pannelli del blocco lungo la corda.
% Blocco.N_span [int]   Numero di pannelli del blocco lungo l'apertura alare.

%%% Output
% Pan [struct]      Struttura suddivisa nei campi x, y, z, e norm. Ciascun 
%                   campo è una matrice contenente le rispettive coordinate 
%                   dei vertici dei pannelli di ciascun blocco. Il campo 
%                   norm è la normale uscente del rispettivo pannello.

% PC  [struct]      Struttura suddivisa nei campi x,y, z e norm. Ciascun
%                   campo è un vettore contenente le rispettive coordinate
%                   dei punti di collocazione di ciascun blocco. 
%                   Il campo norm è la normale uscente di ciascun punto di 
%                   collocazione del rispettivo blocco.

% V   [Struct]      Struttura suddivisa nei campi up e down, ciascuno
%                   suddiviso nei sottocampi x, y, z e norm. Ciascun campo
%                   è un vettore contenente le rispettive coordinate degli
%                   estremi degli assi dei vortici contenuti nei pannelli
%                   (up per le coordinate del vertice ad ordinata maggiore,
%                   down per le coordinate del vertice ad ordinata minore).
%                   Il campo norm è la normale al pannello sul quale giace
%                   ciascun vortice dello stesso blocco.

% PC_mat [struct]   Come PC, ma i dati sono organizzati in matrici che
%                   consentono di risalire alla connettività tra gli
%                   elementi.

% V_mat [struct]    Come V, ma i dati sono organizzati in matrici che
%                   consentono di risalire alla connettività tra gli
%                   elementi.

% S [vect]          Vettore contenente le superfici di ciascun blocco in
%                   input


%% Inizializzazione

% Vettore contenente il numero di pannelli per ciascun blocco in input
N_block=([Blocco.N_span]).*([Blocco.N_chord]);
N_half=sum(N_block);

% Struttura per le coordinate dei pannelli
Pan(2*size(Blocco,2)) = struct();

% Matrice per i punti di collocazione
PC_x=zeros(2*N_half,1);
PC_y=zeros(2*N_half,1);
PC_z=zeros(2*N_half,1);
PC_norm=zeros(2*N_half,3);

% Struttura i punti di collocazione
PC_mat(2*size(Blocco,2)) = struct();

% Matrice per gli estremi dei vortici
V_up_x=zeros(2*N_half,1);
V_up_y=zeros(2*N_half,1);
V_up_z=zeros(2*N_half,1);
V_up_norm=zeros(2*N_half,3);

V_down_x=zeros(2*N_half,1);
V_down_y=zeros(2*N_half,1);
V_down_z=zeros(2*N_half,1);
V_down_norm=zeros(2*N_half,3);

% Struttura per le gli estremi dei vortici
V_mat(2*size(Blocco,2)) = struct();

% Matrice per le superfici
S=zeros(1,size(Blocco,2));

%% Generazione pannelli, punti di collocazione, vortici
for i=1:size(Blocco,2)
    X=zeros(Blocco(i).N_span+1,Blocco(i).N_chord+1);
    Y=X;
    Z=X;
    %% Superficie
    S(i)=0.5*(norm(Blocco(i).p1-Blocco(i).p2)+norm(Blocco(i).p3-Blocco(i).p4))*sqrt( (Blocco(i).p1(2)-Blocco(i).p4(2))^2 + (Blocco(i).p1(3)-Blocco(i).p4(3))^2 );

    %% Coordinate z
    % Pannelli
    Z=linspace(Blocco(i).p4(3),Blocco(i).p1(3),size(Z,1))'*ones(1,size(Z,2));
    % Punti di collocazione
    Zc=linspace((Z(1,1)+Z(2,1))/2,(Z(end-1,1)+Z(end,1))/2,size(Z,1)-1)'*ones(1,size(Z,2)-1);
    % Estremi vortici
    Zv=Z(:,1:end-1);

    %% Coordinate y 
    % Pannelli
    Y=linspace(Blocco(i).p4(2),Blocco(i).p1(2),size(Y,1))'*ones(1,size(Y,2));
    % Punti di collocazione
    Yc=linspace((Y(1,1)+Y(2,1))/2,(Y(end-1,1)+Y(end,1))/2,size(Y,1)-1)'*ones(1,size(Y,2)-1);
    % Estremi vortici
    Yv=Y(:,1:end-1);

    %% Coordinate x 
    % Pannelli
    X_ref=[linspace(Blocco(i).p4(1),Blocco(i).p1(1),size(X,1))' linspace(Blocco(i).p3(1),Blocco(i).p2(1),size(Y,1))'];
    S_ref1=[zeros(size(X,1),1) , ones(size(X,1),1)];
    S_ref2=[linspace(0,1,size(X,1))' linspace(0,1,size(X,1))'];
    X_q1=ones(size(X,1),1)*linspace(0,1,size(X,2));
    X_q2=linspace(0,1,size(X,1))'*ones(1,size(X,2));
    X=interp2(S_ref1,S_ref2,X_ref,X_q1,X_q2);
    % Punti di collocazione
    X_refc=[linspace((X(1,1)+X(2,1))/2+0.75*((X(1,2)+X(2,2))/2-(X(1,1)+X(2,1))/2),(X(end-1,1)+X(end,1))/2+0.75*((X(end-1,2)+X(end,2))/2-(X(end-1,1)+X(end,1))/2),size(X,1)-1)' linspace((X(1,end-1)+X(2,end-1))/2+0.75*((X(1,end)+X(2,end))/2-(X(1,end-1)+X(2,end-1))/2),(X(end-1,end-1)+X(end,end-1))/2+0.75*((X(end-1,end)+X(end,end))/2-(X(end-1,end-1)+X(end,end-1))/2),size(X,1)-1)'];
    S_ref1c=[zeros(size(X,1)-1,1) , ones(size(X,1)-1,1)];
    S_ref2c=[linspace(0,1,size(X,1)-1)' linspace(0,1,size(X,1)-1)'];
    X_q1c=ones(size(X,1)-1,1)*linspace(0,1,size(X,2)-1);
    X_q2c=linspace(0,1,size(X,1)-1)'*ones(1,size(X,2)-1);
    Xc=interp2(S_ref1c,S_ref2c,X_refc,X_q1c,X_q2c);
    % Estremi vortici
    X_refv=[linspace(X(1,1)+0.25*(X(1,2)-X(1,1)),X(end,1)+0.25*(X(end,2)-X(end,1)),size(X,1))' linspace(X(1,end-1)+0.25*(X(1,end)-X(1,end-1)),X(end,end-1)+0.25*(X(end,end)-X(end,end-1)),size(X,1))'];
    X_q1v=ones(size(X,1),1)*linspace(0,1,size(X,2)-1);
    X_q2v=linspace(0,1,size(X,1))'*ones(1,size(X,2)-1);
    Xv=interp2(S_ref1,S_ref2,X_refv,X_q1v,X_q2v);

    %% Parametri del blocco corrente
    % Elementi nel blocco corrente
    N_cur=N_block(i);

    % Elementi totali nei blocchi precedenti
    if i == 1
        N_prec=0;
    else
        N_prec=sum(N_block(1:i-1));
    end
    %% Salvataggio coordinate pannelli
    % Blocco di input
    Pan(i).x=X;
    Pan(i).y=Y;
    Pan(i).z=Z;
    Pan(i).norm=cross(Blocco(i).p2-Blocco(i).p1,Blocco(i).p3-Blocco(i).p2)./norm(cross(Blocco(i).p2-Blocco(i).p1,Blocco(i).p3-Blocco(i).p2));
    % Blocco simmetrico rispetto a x (altra semi-ala)
    Pan(i+size(Blocco,2)).x=flipud(X);
    Pan(i+size(Blocco,2)).y=flipud(-Y);
    Pan(i+size(Blocco,2)).z=flipud(Z);
    Pan(i+size(Blocco,2)).norm=[Pan(i).norm(1) -Pan(i).norm(2) Pan(i).norm(3)];

    %% Salvataggio coordinate punti di collocazione
    % Blocco di input
    Xs=Xc';
    Ys=Yc';
    Zs=Zc';
    PC_mat(i).x=Xc;
    PC_mat(i).y=Yc;
    PC_mat(i).z=Zc;
    PC_x(N_prec+1:N_cur+N_prec)=Xs(:);
    PC_y(N_prec+1:N_cur+N_prec)=Ys(:);
    PC_z(N_prec+1:N_cur+N_prec)=Zs(:);
    PC_norm(N_prec+1:N_cur+N_prec,:)=(Pan(i).norm'*ones(1,length(Xs(:))))';
    % Blocco simmetrico rispetto a x (altra semi-ala)
    Xs=flipud(Xc)';
    Ys=flipud(-Yc)';
    Zs=flipud(Zc)';
    PC_mat(i+size(Blocco,2)).x=flipud(Xc);
    PC_mat(i+size(Blocco,2)).y=flipud(-Yc);
    PC_mat(i+size(Blocco,2)).z=flipud(Zc);
    PC_x(N_half+N_prec+1:N_half+N_cur+N_prec)=Xs(:);
    PC_y(N_half+N_prec+1:N_half+N_cur+N_prec)=Ys(:);
    PC_z(N_half+N_prec+1:N_half+N_cur+N_prec)=Zs(:);
    PC_norm(N_half+N_prec+1:N_half+N_cur+N_prec,:)=(Pan(i+size(Blocco,2)).norm'*ones(1,length(Xs(:))))';

    %% Salvataggio coordinate vortici
    % Blocco di input
    % Estremi superiori
    Xs=Xv(1:end-1,:)';
    Ys=Yv(1:end-1,:)';
    Zs=Zv(1:end-1,:)';
    V_mat(i).up.x=Xv(1:end-1,:);
    V_mat(i).up.y=Yv(1:end-1,:);
    V_mat(i).up.z=Zv(1:end-1,:);
    V_up_x(N_prec+1:N_cur+N_prec)=Xs(:);
    V_up_y(N_prec+1:N_cur+N_prec)=Ys(:);
    V_up_z(N_prec+1:N_cur+N_prec)=Zs(:);
    V_up_norm(N_prec+1:N_cur+N_prec,:)=(Pan(i).norm'*ones(1,length(Xs(:))))';
    % Estremi inferiori
    Xs=Xv(2:end,:)';
    Ys=Yv(2:end,:)';
    Zs=Zv(2:end,:)';
    V_mat(i).down.x=Xv(2:end,:);
    V_mat(i).down.y=Yv(2:end,:);
    V_mat(i).down.z=Zv(2:end,:);
    V_down_x(N_prec+1:N_cur+N_prec)=Xs(:);
    V_down_y(N_prec+1:N_cur+N_prec)=Ys(:);
    V_down_z(N_prec+1:N_cur+N_prec)=Zs(:);
    V_down_norm(N_prec+1:N_cur+N_prec,:)=(Pan(i).norm'*ones(1,length(Xs(:))))';
    % Blocco simmetrico rispetto a x (altra semi-ala)
    % Estremi superiori
    Xs=flipud(Xv);
    Xs=(Xs(1:end-1,:))';
    Ys=flipud(Yv);
    Ys=(-Ys(1:end-1,:))';
    Zs=flipud(Zv);
    Zs=(Zs(1:end-1,:))';
    V_mat(i+size(Blocco,2)).up.x=Xs';
    V_mat(i+size(Blocco,2)).up.y=Ys';
    V_mat(i+size(Blocco,2)).up.z=Zs';
    V_up_x(N_half+N_prec+1:N_half+N_cur+N_prec)=Xs(:);
    V_up_y(N_half+N_prec+1:N_half+N_cur+N_prec)=Ys(:);
    V_up_z(N_half+N_prec+1:N_half+N_cur+N_prec)=Zs(:);
    V_up_norm(N_half+N_prec+1:N_half+N_cur+N_prec,:)=(Pan(i+size(Blocco,2)).norm'*ones(1,length(Xs(:))))';
    % Estremi inferiori
    Xs=flipud(Xv);
    Xs=(Xs(2:end,:))';
    Ys=flipud(Yv);
    Ys=(-Ys(2:end,:))';
    Zs=flipud(Zv);
    Zs=(Zs(2:end,:))';
    V_mat(i+size(Blocco,2)).down.x=Xs';
    V_mat(i+size(Blocco,2)).down.y=Ys';
    V_mat(i+size(Blocco,2)).down.z=Zs';
    V_down_x(N_half+N_prec+1:N_half+N_cur+N_prec)=Xs(:);
    V_down_y(N_half+N_prec+1:N_half+N_cur+N_prec)=Ys(:);
    V_down_z(N_half+N_prec+1:N_half+N_cur+N_prec)=Zs(:);
    V_down_norm(N_half+N_prec+1:N_half+N_cur+N_prec,:)=(Pan(i+size(Blocco,2)).norm'*ones(1,length(Xs(:))))';
end

PC.x=PC_x';
PC.y=PC_y';
PC.z=PC_z';
PC.norm=PC_norm;

V.up.x=V_up_x';
V.up.y=V_up_y';
V.up.z=V_up_z';
V.up.norm=V_up_norm;

V.down.x=V_down_x';
V.down.y=V_down_y';
V.down.z=V_down_z';
V.down.norm=V_down_norm;

S=[S S];

if nargin > 1 && graph~=0
%% Plot
figure
plot3(PC.x,PC.y,PC.z,'kx','LineWidth',1)
grid on
hold on
quiver3(V.up.x,V.up.y,V.up.z,V.down.x-V.up.x,V.down.y-V.up.y,V.down.z-V.up.z,'off',"Color",'r')

for i=1:2*size(Blocco,2)
    mesh(Pan(i).x,Pan(i).y,Pan(i).z,"EdgeColor",'k',"FaceAlpha",0)
    % quiver3(Pan(i).x,Pan(i).y,Pan(i).z,ones(size(Pan(i).x)).*Pan(i).norm(1),ones(size(Pan(i).y)).*Pan(i).norm(2),ones(size(Pan(i).z)).*Pan(i).norm(3),0)
    axis equal
end
title("Geometria")
end
end