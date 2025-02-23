%% Calcolo degli angoli di Theodorsen tramite i due metodi implementati
clear
clc
close all

addpath Funzioni_matlab
addpath dati

%% NACA 0012-utilizzando la teoria dei profili sottili

[a_th]=theodorsen('NACA_0012_364.dat');
rad2deg(a_th)

%% AH 79 100 C-utilizzando la teoria dei profili sottili
close all
[a_th]=theodorsen('AH_79_100_C_364.dat',1);
rad2deg(a_th)

%% NACA 0012-utilizzando le considerazioni sul coefficiente di pressione
alpha_start = [-0.89, 0.00];
alpha_end = [0.012, 0.050];
alpha_step = 0.001;

[a_th_NACA] = theodorsen_cp('NACA_0012_364.dat', alpha_start(1), ...
    alpha_end(1), alpha_step);

%% AH 79 100 C-utilizzando le considerazioni sul coefficiente di pressione
[a_th_AH] = theodorsen_cp('AH_79_100_C.dat', alpha_start(2), ...
    alpha_end(2), alpha_step);
