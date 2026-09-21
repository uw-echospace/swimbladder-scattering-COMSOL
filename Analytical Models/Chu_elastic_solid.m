%% This script calculates acoustic scattering metrics for a solid
% elastic spherical target insonified by a plane acoustic wave.
% Uses elastic_fs written by Dezhang Chu, Woods Hole Oceanographic Institution
% (dchu@whoi.edu), Oct. 3, 2006

clear
close all
clc
addpath(genpath(pwd))

%% Material database

materials = struct();

% Fluids
materials.water = struct( ...
    'name', 'Water', ...
    'rho', 997, ...
    'c', 1500);

materials.air = struct( ...
    'name', 'Air', ...
    'rho', 1.204, ...
    'c', 343.2);

% Solids
materials.aluminum = struct( ...
    'name', 'Aluminum', ...
    'rho', 2700, ...
    'cL', 6350, ...
    'cT', 3050);

materials.steel = struct( ...
    'name', 'Steel', ...
    'rho', 7850, ...
    'cL', 5900, ...
    'cT', 3200);

% From Hosokawa and Otani (1997)
materials.bone = struct( ...
    'name', 'Bone', ...
    'rho', 1950, ...
    'cL', 3800, ...
    'cT', 2000);

% From Fine et al. (2016) and Balebail et al. (2026, in prep.)
materials.SBwall = struct( ...
    'name', 'SBwall', ...
    'rho', 1000, ...
    'cL', 1291.2, ...
    'cT', 18.258);


%% ---------------------------------------------------------
%  ASSIGN MATERIAL PROPERTIES
% ----------------------------------------------------------

outside = materials.water;
sphere  = materials.bone;

rho1 = outside.rho;
c1   = outside.c;

rho2 = sphere.rho;
c2L  = sphere.cL;
c2T  = sphere.cT;

%% ---------------------------------------------------------
%  SPECIFY SPHERE GEOMETRY
% ----------------------------------------------------------

a = 0.025;               % sphere radius, m

%% ---------------------------------------------------------
%  DIMENSIONLESS MATERIAL RATIOS REQUIRED BY elastic_fs
% ----------------------------------------------------------

g  = rho2/rho1;

hc = c2L/c1;
hs = c2T/c1;

%% ---------------------------------------------------------
%  FREQUENCY RANGE
% ----------------------------------------------------------

f_min = 50;           % minimum frequency, Hz
f_max = 70000;          % maximum frequency, Hz
nFrequency = 10000;       % number of frequency points

frequency_requested = linspace(f_min, f_max, nFrequency);

% Convert frequency to ka
ka_min = 2*pi*f_min*a/c1;
ka_max = 2*pi*f_max*a/c1;

%% ---------------------------------------------------------
%  SCATTERING ANGLE
% ----------------------------------------------------------

theta0 = 180;           % degrees
                        % 180 = backscatter
                        % 0   = forward scatter
                        % 90  = side scatter

%% ---------------------------------------------------------
%  elastic_fs SETTINGS
% ----------------------------------------------------------

proc_flag = 1;          % 1: calculate versus ka/frequency
                        % 2: calculate versus angle

scale     = 1;          % 1: linear spacing
                        % 2: log spacing

out_flag  = 1;          % 1: complex form function
                        % 2: complex scattering amplitude
                        %    normalized by sphere radius

% Parameter vector:
% para = [number of points,
%         starting ka,
%         ending ka,
%         rho2/rho1,
%         c2L/c1,
%         c2T/c1,
%         scattering angle in degrees]

para = [ ...
    nFrequency, ...
    ka_min, ...
    ka_max, ...
    g, ...
    hc, ...
    hs, ...
    theta0 ...
];

%% ---------------------------------------------------------
%  RUN THE SCATTERING MODEL
% ----------------------------------------------------------

[ka, form_function] = elastic_fs( ...
    proc_flag, ...
    scale, ...
    out_flag, ...
    para);

%% ---------------------------------------------------------
%  CONVERT ka TO FREQUENCY
% ----------------------------------------------------------

frequency = c1.*ka./(2*pi*a);

%% ---------------------------------------------------------
%  CONVERT FORM FUNCTION TO SCATTERING AMPLITUDE AND TS
% ----------------------------------------------------------

% Physical scattering amplitude, units of m
scattering_amplitude = (a/2).*form_function;

% Avoid log10(0)
magnitude = max(abs(scattering_amplitude), realmin);

% Target strength
TS = 20*log10(magnitude);

%% ---------------------------------------------------------
%  EXPORT FREQUENCY AND TARGET STRENGTH TO CSV
% ----------------------------------------------------------

output_table = table( ...
    frequency(:), ...
    TS(:), ...
    'VariableNames', {'Frequency_Hz', 'TargetStrength_dB_re_1m'});

output_file = 'bone_sphere_Chu.csv';

writetable(output_table, output_file);

fprintf('Target-strength results saved to:\n%s\n', ...
    fullfile(pwd, output_file));

%% ---------------------------------------------------------
%  PLOT TARGET STRENGTH VERSUS FREQUENCY
% ----------------------------------------------------------

figure

plot(frequency/1000, TS, 'LineWidth', 2)

xlabel('Frequency (kHz)')
ylabel('Target strength (dB re 1 m)')
title(sprintf( ...
    'Target strength versus frequency at \\theta = %.0f^\\circ', ...
    theta0))

grid on
xlim([f_min f_max]/1000)