function [u,v_code]=Velocita_Vortice(r_up,r_down,pc)

% Calcola la velocità normalizzata indotta in un punto da un vortice a ferro
% di cavallo i cui segmenti semi-infiniti sono all'ineati all'asse x del sistema di
% riferimento considerato.

%%% INPUT
% r_up [vect]   Vettore contente le coordinate dell'estremo superiore della
%               porzione finita del vortice a ferro di cavallo

% r_down [vect] Vettore contente le coordinate dell'estremo inferiore della
%               porzione finita del vortice a ferro di cavallo

% pc [vect]     Vettore contenente le coordinate del punto in cui si vuole
%               determinare la velocità indotta dal vortice a ferro di
%               cavallo

%%% OUTPUT
% u [vect]      Vettore contenente le componenti normalizzate della
%               velocità indotta sia dal segmento finito che dai due
%               segmenti semi-infiniti

% v_code [vect] Vettore contenente le componenti normalizzate della
%               velocità indotta solo dai due segmenti semi-infiniti


r0=r_down-r_up;
s=1;
code=0;
%% Vortice semi-infinito up

rF=r_up+[s 0 0];
r1=pc-rF;
r2=pc-r_up;

if norm(cross(r_up-rF,r_up-pc)./(norm(r_up-rF)*norm(r_up-pc)))<1e-7 %&& nargout==1
    warning("Punto di collocazione sull'asse del vortice infinito superiore")
    code=1;
end

cos_th1=1;
cos_th2=((r_up-rF)*r2')/(norm(r_up-rF)*norm(r2));

R=norm(cross(r1,r2))/(norm(r_up-rF));
e=cross(r1,r2)./norm(cross(r1,r2));

v_up=(1/(4*pi*R)).*(cos_th1-cos_th2).*e;

%% Vortice finito

r1=pc-r_up;
r2=pc-r_down;

if norm(cross(r0,r_up-pc)./(norm(r0)*norm(r_up-pc)))<1e-7 %&& nargout==1
    % disp(pc)
    % plot3(pc(1),pc(2),pc(3),'gx')
    % hold on
    % plot3([pc(1) r_down(1)],[pc(2) r_down(2)],[pc(3) r_down(3)],'g-')
    % warning("Punto di collocazione sull'asse del vortice finito")
    code=2;
end

cos_th1=(r0*r1')/(norm(r0)*norm(r1));
cos_th2=(r0*r2')/(norm(r0)*norm(r2));

R=norm(cross(r1,r2))/(norm(r0));
e=cross(r1,r2)./norm(cross(r1,r2));

v_fin=(1/(4*pi*R)).*(cos_th1-cos_th2).*e;

%% Vortice semi-infinito down

rF=r_down+[s 0 0];
r1=pc-r_down;
r2=pc-rF;

if norm(cross(r_down-rF,r_down-pc)./(norm(r_down-rF)*norm(r_down-pc)))<1e-7 %&& nargout==1
    warning("Punto di collocazione sull'asse del vortice infinito inferiore")
    code=3;
end

cos_th1=((rF-r_down)*r1')/(norm((rF-r_down))*norm(r1));
cos_th2=-1;

R=norm(cross(r1,r2))/(norm(rF-r_down));
e=cross(r1,r2)./norm(cross(r1,r2));

v_down=(1/(4*pi*R)).*(cos_th1-cos_th2).*e;

%% Somma contributi
if code==0
    u=v_down+v_up+v_fin;
elseif code==1
    u=v_down+v_fin;
elseif code==2
    u=v_down+v_up;
elseif code==3
    u=v_up+v_fin;
end
v_code=v_up+v_down;