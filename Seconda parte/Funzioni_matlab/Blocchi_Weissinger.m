function [Blocco,Blocchi_ala,Blocchi_coda]=Blocchi_Weissinger(Aereo,Coda)

% Contiene gli input geometrici necessari alla discretizzazione compiuta da
% geometria_Weissinger.m 
% L'ala e l'eventuale coda sono inserite come una serie di blocchi, ognuno
% di essi contente una lista delle sue coordinate perimetrali.
% Questo permette di strudiare geometrie complette con corde, angoli di diedro
% e di freccia variabili lungo l'apertura.

%%% Input
% Aereo [string]        Nome identificativo del velivolo (Cessna 172, U2, 
%                       Ala ellittica, Ala base, Test1, Test2, Test3)
%
% Coda [int]            1 se si desidera la coda, 0 o omesso altrimenti

%%% Output
% Blocco [struct]       Blocchi di input per "Geometria_Weissinger"
%
% Blocchi_ala [vect]    Lista dei blocchi componenti l'ala
%
% Blocchi_coda [vect]   Lista dei blocchi componenti la coda (se richiesta)

if Aereo == "Cessna 172"

lambda=deg2rad(1.7); 
% Ala
% Blocco 1
Blocco(1).p1=[0 0 0];
Blocco(1).p2=[1.63 0 0];
Blocco(1).p3=[1.63 2.68 2.68*tan(lambda)];
Blocco(1).p4=[0 2.68 2.68*tan(lambda)];
Blocco(1).N_chord=6;
Blocco(1).N_span=15;

% Blocco 2
Blocco(2).p1=Blocco(1).p4;
Blocco(2).p2=Blocco(1).p3;
Blocco(2).p3=[1.28 5.5 (5.5)*tan(lambda)];
Blocco(2).p4=[0.15 5.5 (5.5)*tan(lambda)];
Blocco(2).N_chord=6;
Blocco(2).N_span=15;

% Coda
Blocchi_ala=[1 2];
if nargin>1 && Coda==1
    Blocchi_coda=[3 4];
    % Blocco 3
    Blocco(3).p1=[4.38 0 -0.5];
    Blocco(3).p2=[5.03 0 -0.5];
    Blocco(3).p3=[5.67 0.22 -0.5];
    Blocco(3).p4=[4.42 0.22 -0.5];
    Blocco(3).N_chord=6;
    Blocco(3).N_span=2;
    
    % Blocco 4
    Blocco(4).p1=Blocco(3).p4;
    Blocco(4).p2=Blocco(3).p3;
    Blocco(4).p3=[5.42 1.64 -0.5];
    Blocco(4).p4=[4.65 1.64 -0.5];
    Blocco(4).N_chord=6;
    Blocco(4).N_span=6;
else
    Blocchi_coda=[];
end

elseif Aereo=="Ala ellittica"
    %% Prova ala ellittica

% Semiassi ellisse
a = 88/2;
b = 10;

% Definizione ellisse
fun = @(Y) ((1-(Y.^2/a^2))*b^2).^(1/2);
fun2 = @(Y) -((1-(Y.^2/a^2))*b^2).^(1/2);
Y = linspace(0,a,20);

% Definizione coordinate 
X_piu = fun(Y); 
X_meno = fun2(Y);
Z = zeros(1,length(Y));

% if graph_ellisse==1
% % Plot ellisse
% figure
% plot3([X_piu; X_meno],Y,Z)
% axis equal
% end
Blocco(length(Y)-2) = struct();
%definizione blocchi
for i = 1:length(Y)-2
        Blocco(i).p1=[X_meno(i) Y(i) Z(i)];
        Blocco(i).p2=[X_piu(i) Y(i) Z(i)];
        Blocco(i).p3=[X_piu(i+1) Y(i+1) Z(i+1)];
        Blocco(i).p4=[X_meno(i+1) Y(i+1) Z(i+1)];
        Blocco(i).N_chord=10;
        Blocco(i).N_span=2;
end

% Specifiche blocchi
Blocchi_ala=1:size(Blocco,2);
Blocchi_coda=[];
elseif Aereo=="Ala base"

%% Nostra ala
% Blocco 1
Blocco(1).p1=[0 0 0];
Blocco(1).p2=[3 0 0];
Blocco(1).p3=[2.5 2 0.1];
Blocco(1).p4=[0.5 2 0.1];
Blocco(1).N_chord=5;
Blocco(1).N_span=7;

% Blocco 2
Blocco(2).p1=Blocco(1).p4;
Blocco(2).p2=Blocco(1).p3;
Blocco(2).p3=[3 9 0];
Blocco(2).p4=[2 9 0];
Blocco(2).N_chord=5;
Blocco(2).N_span=15;

% Specifiche blocchi
Blocchi_ala=[1 2];
if nargin>1 && Coda==1
    Blocchi_coda=3;
    % Blocco 3
    Blocco(3).p1=[8 0 0];
    Blocco(3).p2=[10 0 0];
    Blocco(3).p3=[10 2 0.5];
    Blocco(3).p4=[9.5 2 0.5];
    Blocco(3).N_chord=5;
    Blocco(3).N_span=5;
else
    Blocchi_coda=[];
end
%% Test di riferimento slide
elseif Aereo=="Test1"
% Blocco 1
Blocco(1).p1=[0 0 0];
Blocco(1).p2=[3 0 0];
Blocco(1).p3=[4.5 5 0];
Blocco(1).p4=[2.5 5 0];
Blocco(1).N_chord=10;
Blocco(1).N_span=19;

% Specifiche blocchi
Blocchi_ala=1;
Blocchi_coda=[];

elseif Aereo=="Test2"
% Blocco 1
Blocco(1).p1=[0 0 0];
Blocco(1).p2=[3 0 0];
Blocco(1).p3=[3 8 0];
Blocco(1).p4=[0 8 0];
Blocco(1).N_chord=5;
Blocco(1).N_span=30;

% Specifiche blocchi
Blocchi_ala=1;
Blocchi_coda=[];

elseif Aereo=="Test3"
%% Esempio ala + coda slide
% Blocco 1
Blocco(1).p1=[0 0 0];
Blocco(1).p2=[3 0 0];
Blocco(1).p3=[2.5529 6 -0.5229];
Blocco(1).p4=[1.5529 6 -0.5229];
Blocco(1).N_chord=11;
Blocco(1).N_span=40;

% Specifiche blocchi
Blocchi_ala=1;
if nargin>1 && Coda==1
    Blocchi_coda=2;
    % Blocco 2
    Blocco(2).p1=[5 0 0.5];
    Blocco(2).p2=[6.5 0 0.5];
    Blocco(2).p3=[6.5209 3 0.7615];
    Blocco(2).p4=[5.5209 3 0.7615];
    Blocco(2).N_chord=6;
    Blocco(2).N_span=20;
else
    Blocchi_coda=[];
end

elseif Aereo=="U2"
% Blocco 1
Blocco(1).p1=[0 0 0];
Blocco(1).p2=[4.82 0 0];
Blocco(1).p3=[3.26 15.75 0];
Blocco(1).p4=[2.09 15.75 0];
Blocco(1).N_chord=8;
Blocco(1).N_span=20;

% Specifiche blocchi
Blocchi_ala=1;
if nargin>1 && Coda==1
    Blocchi_coda=2;
    % Blocco 2
    Blocco(2).p1=[8.71 0 0.85];
    Blocco(2).p2=[11.2 0 0.85];
    Blocco(2).p3=[10.65 4.07 0.85];
    Blocco(2).p4=[9.54 4.07 0.85];
    Blocco(2).N_chord=5;
    Blocco(2).N_span=8;
else
    Blocchi_coda=[];
end

end
end