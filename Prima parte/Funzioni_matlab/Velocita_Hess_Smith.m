function [ux,uy,U]=Velocita_Hess_Smith(Soluzione, U_inf, x, y, Corpo)

% Determina la dimensione degli array di coordinate in input e inizializza
% le matrici con la velocità da restituire in output
ux=zeros(size(x));
uy=zeros(size(y));

% Determina le caratteristiche geometriche di ciascun pannello
[Centro, ~, ~, Estremo_1, Estremo_2, ~, ~, L2G_TransfMatrix, G2L_TransfMatrix] = CreaStrutturaPannelli(Corpo);

% Numero pannelli
N=length(Centro);

% Determina la velocità in ciascun punto x, y
for I=1:size(ux,1)
    for J=1:size(ux,2)

        % Coordinate del punto considerato
        Centro_qui=[x(I,J);y(I,J)];

        % Inizializzo le velocità parziali
        uxs_par=zeros(1,N);
        uys_par=zeros(1,N);
        uxv_par=zeros(1,N);
        uyv_par=zeros(1,N);

        for i=1:N
            % Proprietà geometriche dell'i-esimo pannello
            Estremo_1_qui = Estremo_1(i, :)';
            Estremo_2_qui = Estremo_2(i, :)';

            L2G_TransfMatrix_qui = squeeze(L2G_TransfMatrix(i, :, :));
            G2L_TransfMatrix_qui = squeeze(G2L_TransfMatrix(i, :, :));

            % Velocità indotta dalle sorgenti e dai vortici dell'i-esimo pannello
            Us=ViSorgente(Centro_qui, Estremo_1_qui, Estremo_2_qui, L2G_TransfMatrix_qui, G2L_TransfMatrix_qui);
            Uv=ViVortice(Centro_qui, Estremo_1_qui, Estremo_2_qui, L2G_TransfMatrix_qui, G2L_TransfMatrix_qui);
            uxs_par(i)=Us(1);
            uys_par(i)=Us(2);
            uxv_par(i)=Uv(1);
            uyv_par(i)=Uv(2);
        end

        % Somma i contributi di tutti i pannelli con le dovute intensità
        % aggiungendo al velocità asintotica 
        ux(I,J)=U_inf(1) + uxs_par*Soluzione(1:end-1) + uxv_par*(Soluzione(end).*ones(N,1));
        uy(I,J)=U_inf(2) + uys_par*Soluzione(1:end-1) + uyv_par*(Soluzione(end).*ones(N,1));
    end
end
% Modulo della velocità in ciascun punto x,y
U=sqrt(ux.^2 + uy.^2);
end