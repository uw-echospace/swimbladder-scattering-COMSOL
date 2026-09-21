%% This script calculates acoustic scattering metrics for a rigid or
% pressure-release spherical target insonified by a plane acoustic wave.
% Uses rgd_sft_fs written by Dezhang Chu, Woods Hole Oceanographic Institution
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


%% ---------------------------------------------------------
%  ASSIGN MEDIUM MATERIAL PROPERTIES
% ----------------------------------------------------------

outside = materials.water;

rho1 = outside.rho;
c1   = outside.c;

%% ---------------------------------------------------------
%  SPECIFY OBJECT TYPE
% ----------------------------------------------------------

obj_type = 2;           % 1: rigid sphere
                        % 2: soft or pressure-release sphere

if obj_type == 1
    object_name = 'Rigid sphere';
elseif obj_type == 2
    object_name = 'Pressure-release sphere';
else
    error('obj_type must be 1 for rigid or 2 for pressure release.')
end

%% ---------------------------------------------------------
%  SPECIFY SPHERE GEOMETRY
% ----------------------------------------------------------

a = 0.025;               % sphere radius, m

%% ---------------------------------------------------------
%  FREQUENCY RANGE
% ----------------------------------------------------------

f_min = 50;           % minimum frequency, Hz
f_max = 90000;          % maximum frequency, Hz
nFrequency = 1000;       % number of frequency points

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
%  rgd_sft_fs SETTINGS
% ----------------------------------------------------------

proc_flag = 1;          % 1: calculate versus ka/frequency
                        % 2: calculate versus angle

scale     = 1;          % 1: linear spacing
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
%         scattering angle in degrees]
%
% The object type is passed separately to rgd_sft_fs and is not
% included in the parameter vector.

para = [ ...
    nFrequency, ...
    ka_min, ...
    ka_max, ...
    theta0 ...
];

%% ---------------------------------------------------------
%  RUN THE SCATTERING MODEL
% ----------------------------------------------------------

[ka, form_function] = rgd_sft_fs( ...
    proc_flag, ...
    obj_type, ...
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

output_file = 'soft_sphere_Chu.csv';

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