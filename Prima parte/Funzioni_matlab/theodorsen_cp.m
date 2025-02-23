function [alpha_theo_xf] = theodorsen_cp(codiceprofilo, alpha_start, alpha_end, alpha_step) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Questa funzione calcola l'angolo di progetto utilizzando i valori di
% coefficiente di pressione estrapolati da xfoil.
% Input:    CodiceProfilo: nome del profilo come stringa
%           alpha_start: angolo d'incidenza di partenza
%           alpha_end: angolo d'incidenza finale
%           alpha_step: passo a cui valutare il range di angoli d'incidenza
% Output:   alpha_theo_xf: angolo di progetto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


alpha = [alpha_start:alpha_step:alpha_end]; %range di alpha per 
% l'iterazione in J

system("chmod +x ./bash_profilo_sottile.sh"); %rende eseguibile il file bash
system(" ./bash_profilo_sottile.sh "+codiceprofilo); %riduce lo spessore 
%profilo a 0.01

codiceprofilo_new = codiceprofilo+"_thin.dat"; %codice del profilo il cui 
%spessore è stato ridotto

%%% CALCOLO DELL'ANGOLO DI PROGETTO: XFOIL
% calcolato come l'angolo di incidenza tale per cui il picco minimo di Cp
% (nel grafico di Cp) viene massimizzato. Per il confronto utilizza i 
% valori di Cp calcolati da xfoil.

Cp_min=[];

system("chmod +x ./bash_new.sh"); %rende eseguibile il file bash
system(" ./bash_new.sh "+alpha_start+" "+alpha_end+" "+alpha_step+ ...
    " "+codiceprofilo_new); %salva un file di Cp per ogni alpha del range dato

for i = 1 : length(alpha)
    alpha_new(i,:)=sprintf("%.3f",alpha(i));
    Dati_xf = importdata("./dati/"+codiceprofilo_new+"_"+alpha_new(i,:)+"_cp.txt");
    % Coordinate a cui so il Cp

% Identifico il bordo d'attacco
    [X_min,I]=min(Dati_xf.data(:,1)); 
% Determino fino a quanto allontanarmi dal BA
    lim=abs((max(Dati_xf.data(:,1))-min(Dati_xf.data(:,1)))/10); 

% Divido il Cp tra dorso e ventre (non importa quale sia sopra e quale sia sotto)
    Cp_sup=flip(Dati_xf.data(1:I,2));
    X_sup=flip(Dati_xf.data(1:I,1));
    Cp_inf=Dati_xf.data(I:end,2);
    X_inf=Dati_xf.data(I:end,1); 

% Cerco i punti stazionari del Cp su Cp_sup
    Cp_staz_sup=[];
    X_cor=min(Dati_xf.data(:,1));
    J=1;
    der_old=1;
while X_cor < X_min+lim
    der_new=(Cp_sup(J+1)-Cp_sup(J))/(X_sup(J+1)-X_sup(J));
% Se la derivata ha cambiato segno rispetto all'iterazione precedente,
% o se è la prima iterazione, salvo il valore del Cp, poichè si tratta di 
% un potenziale minimo
    if J==1 || der_new*der_old<0
        Cp_staz_sup=[Cp_staz_sup Cp_sup(J)];
    end
    X_cor=X_sup(J+1);
    J=J+1;
    der_old=der_new;
end

% Cerco i punti stazionari del Cp su Cp_inf
    Cp_staz_inf=[];
    X_cor=min(Dati_xf.data(:,1));
    J=1;
    der_old=1;
while X_cor < X_min+lim
    der_new=(Cp_inf(J+1)-Cp_inf(J))/(X_inf(J+1)-X_inf(J));
    % Se la derivata ha cambiato segno rispetto all'iterazione precedente, o se è la prima iterazione, salvo il valore del Cp, poichè si tratta di un potenziale minimo
    if J==1 || der_new*der_old<0
        Cp_staz_inf=[Cp_staz_inf Cp_inf(J)];
    end
    X_cor=X_inf(J+1);
    J=J+1;
    der_old=der_new;
end 

% Calcolo il minimo dei punti stazionari di Cp_sup e di Cp_inf 
min_sup=min(Cp_staz_sup);
min_inf=min(Cp_staz_inf);

% Calcolo il minimo assoluto dell'intervallo
Cp_min(i)=min([min_sup min_inf]);
end

% troviamo il massimo tra i cp minimi sul bordo di attacco
[Cp_max,ind]=max(Cp_min);
alpha_theo_xf=alpha(ind);

% rimozione dei file generati da xfoil
system("rm ./dati/"+codiceprofilo_new+"_*");
system("rm ./dati/"+codiceprofilo_new);
system("rm instruction_xfoil.txt");
system("rm Dati_HS.json");
end