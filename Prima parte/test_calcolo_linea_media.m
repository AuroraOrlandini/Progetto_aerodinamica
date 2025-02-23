%% Calcolo della linea media
clear
clc
close all


addpath dati
addpath Funzioni_matlab

%% CALCOLO CON IL NOSTRO CODICE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Importazione profilo da coordinate Xfoil
CodiceProfilo='NACA_6212_364.dat';
close all
Corpo = importXfoilProfile(CodiceProfilo);
Chord=1;

x = flipud(Corpo.x);
y = flipud(Corpo.y);
Coord.x = x.*Chord;
Coord.y = y.*Chord;

% Calcolo della linea media
[linea_media]=calcolo_linea_media(Coord,1);