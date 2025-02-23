function [a_th,linea_media]=theodorsen(CodiceProfilo,graph)

%%% INPUT
% CodiceProfilo [str]   Codice relativo al file .dat generato da xfoil      
%                       contenente le coordinate del profilo di interesse.
%                       Esempio: se il file è "NACA_0012_245.dat", inserire
%                       'NACA_0012_245.dat' come stringa.
%
% graph [int]           1 se si desidera motrare grafici, 0 o omesso
%                       altrimenti

%%% OUTPUT
% a_th [rad]            Angolo di Theodorsen in radianti    


addpath dati
addpath Funzioni_matlab
%% Creazione profilo
Corpo = importXfoilProfile(CodiceProfilo);
Chord=1;

x = flipud(Corpo.x);
y = flipud(Corpo.y);

Coord.x = x.*Chord;
Coord.y = y.*Chord;


%% Calcolo della corda
corda=abs(min(Coord.x)-max(Coord.x));

%% Centro il profilo nell'origine
shift=abs(min(Coord.x)+max(Coord.x))/2;
Coord.x=Coord.x-shift;

%% Calcolo della linea media
if nargin == 2 && graph == 1
    [linea_media]=calcolo_linea_media(Coord,1);
else
    [linea_media]=calcolo_linea_media(Coord);
end

%% Ridisposizione del profilo con corda orizzontale
x_BU=linea_media.x(end);
y_BU=linea_media.y(end);
Coord.x=Coord.x-x_BU;
Coord.y=Coord.y-y_BU;
linea_media.x=linea_media.x-x_BU;
linea_media.y=linea_media.y-y_BU;

%% Rotazione
alpha=-atan((linea_media.y(1)-linea_media.y(end))/(linea_media.x(1)-linea_media.x(end)));

ROT=[cos(alpha) -sin(alpha);sin(alpha) cos(alpha)];

for p=1:length(Coord.x)
    v=ROT*[Coord.x(p);Coord.y(p)];
    Coord.x(p)=v(1);
    Coord.y(p)=v(2);
end

for p=1:length(linea_media.x)
    v=ROT*[linea_media.x(p);linea_media.y(p)];
    linea_media.x(p)=v(1);
    linea_media.y(p)=v(2);
end

Coord.x=Coord.x+x_BU;
linea_media.x=linea_media.x+x_BU;

%% Calcolo della pendenza della linea media
p_l=zeros(length(linea_media.x),1);
for i=1:length(p_l)
    if i==1
        p_l(i)=(linea_media.y(i+1)-linea_media.y(i))/(linea_media.x(i+1)-linea_media.x(i));
    elseif i>1 && i<length(p_l)
        p_l(i)=(linea_media.y(i+1)-linea_media.y(i-1))/(linea_media.x(i+1)-linea_media.x(i-1));
    elseif i==length(p_l)
        p_l(i)=(linea_media.y(i)-linea_media.y(i-1))/(linea_media.x(i)-linea_media.x(i-1));
    end
end
pen_linea_media.val=p_l;
pen_linea_media.x=linea_media.x;
%% Ricalcolo la corda
corda=abs(max(linea_media.x)-min(linea_media.x));

%% Effettuo il cambio di variabile
pen_linea_media.eta=real(acos(-2.*pen_linea_media.x/corda));

%% Calcolo l'angolo di Theodorsen
a_th=zeros(1,length(pen_linea_media.x));
for i=1:length(a_th)-1
    a_th(i)=(pen_linea_media.val(i+1)+pen_linea_media.val(i)).*(pen_linea_media.eta(i+1)-pen_linea_media.eta(i))/2;
end
a_th=1/pi*sum(a_th);

%% Plot di verifica
if nargin == 2 && graph == 1
figure;
    plot(Coord.x,Coord.y,'r.')
    hold on
    plot(linea_media.x,linea_media.y,'k.-')
    plot(pen_linea_media.x,pen_linea_media.val,'-k','LineWidth',0.7)
    axis equal
    grid on
    legend("Profilo","Linea media","Pendenza linea media")
    titolo=strrep(CodiceProfilo,'_',' ');
    titolo=strrep(titolo,'.dat','');
    title(titolo)
end

end