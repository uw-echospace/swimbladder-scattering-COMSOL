%% This script calculates acoustic scattering metrics for a fluid sphere
% insonified by a plane acoustic wave.
% Uses fluid_fs written by Dezhang Chu, Woods Hole Oceanographic Institution
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
    'rho', 998.238, ...
    'c', 1500);

materials.air = struct( ...
    'name', 'Air', ...
    'rho', 1.204, ...
    'c', 343.2);


%% ---------------------------------------------------------
%  ASSIGN MATERIAL PROPERTIES
% ----------------------------------------------------------

outside = materials.water;
sphere  = materials.air;

rho1 = outside.rho;
c1   = outside.c;

rho2 = sphere.rho;
c2   = sphere.c;

%% ---------------------------------------------------------
%  SPECIFY SPHERE GEOMETRY
% ----------------------------------------------------------

a = 0.25e-02;               % sphere radius, m

%% ---------------------------------------------------------
%  DIMENSIONLESS MATERIAL RATIOS REQUIRED BY fluid_fs
% ----------------------------------------------------------

g = rho2/rho1;
h = c2/c1;

%% ---------------------------------------------------------
%  FREQUENCY RANGE
% ----------------------------------------------------------

f_min = 50;           % minimum frequency, Hz
f_max = 50000;          % maximum frequency, Hz
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
%  fluid_fs SETTINGS
% ----------------------------------------------------------

proc_flag = 1;          % 1: calculate versus ka/frequency
                        % 2: calculate versus angle

scale     = 2;          % 1: linear spacing
                        % 2: log spacing

out_flag  = 2;          % 1: magnitude of form function
                        % 2: complex form function
                        % 3: magnitude of scattering amplitude
                        %    normalized by sphere radius
                        % 4: complex scattering amplitude
                        %    normalized by sphere radius

% Parameter vector:
% para = [number of points,
%         starting ka,
%         ending ka,
%         rho2/rho1,
%         c2/c1,
%         scattering angle in degrees]

para = [ ...
    nFrequency, ...
    ka_min, ...
    ka_max, ...
    g, ...
    h, ...
    theta0 ...
];

%% ---------------------------------------------------------
%  RUN THE SCATTERING MODEL
% ----------------------------------------------------------

[ka, form_function] = fluid_fs( ...
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

% For fluid_fs, the form function and normalized scattering amplitude
% are related by:
%
% form_function = 2*sqrt(pi)*(scattering_amplitude/a)
%
% Therefore, the physical scattering amplitude is:
% out_flag = 2 returns the complex form function = 2*A/a
scattering_amplitude = (a/2).*form_function;

% Target strength referenced to 1 m; amplitude is in metres
magnitude = max(abs(scattering_amplitude), realmin);
TS = 20*log10(magnitude);

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

output_file = 'air_sphere_rscat0.25_Chu.csv';

writetable(output_table, output_file);

fprintf('Target-strength results saved to:\n%s\n', ...
    fullfile(pwd, output_file));
%% ---------------------------------------------------------
%  PLOT TARGET STRENGTH VERSUS FREQUENCY
% ----------------------------------------------------------

figure

plot(frequency/1000, TS, 'LineWidth', 2)

xlabel('Frequency (kHz)')
xscale('log')
ylabel('Target strength (dB re 1 m)')
title(sprintf( ...
    'Target strength versus frequency at \\theta = %.0f^\\circ', ...
    theta0))

grid on
xlim([f_min f_max]/1000)