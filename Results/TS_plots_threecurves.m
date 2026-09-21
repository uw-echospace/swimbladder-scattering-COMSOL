clear
close all
clc

%% File names

chu_file     = 'soft_sphere_Chu.csv';
comsol_file1 = 'soft_sphere_COMSOL.csv';             
comsol_file2 = 'soft_sphere_physicsmesh_COMSOL.csv'; 

%% Import data

chu_data     = readmatrix(chu_file);
comsol_data1 = readmatrix(comsol_file1);
comsol_data2 = readmatrix(comsol_file2);

% Check that the files contain the required columns
if size(chu_data, 2) < 2
    error('The Chu CSV must contain at least two columns.')
end

if size(comsol_data1, 2) < 3
    error('The original COMSOL CSV must contain at least three columns.')
end

if size(comsol_data2, 2) < 2
    error('The physics-mesh COMSOL CSV must contain at least two columns.')
end

% Remove headers, missing values, and nonnumeric rows
chu_data = chu_data( ...
    all(isfinite(chu_data(:,1:2)), 2), :);

comsol_data1 = comsol_data1( ...
    all(isfinite(comsol_data1(:,[1 3])), 2), :);

comsol_data2 = comsol_data2( ...
    all(isfinite(comsol_data2(:,1:2)), 2), :);

% Check that valid data remain
if isempty(chu_data)
    error('No valid numeric data were found in the Chu CSV.')
end

if isempty(comsol_data1)
    error('No valid numeric data were found in the original COMSOL CSV.')
end

if isempty(comsol_data2)
    error('No valid numeric data were found in the physics-mesh COMSOL CSV.')
end

%% Extract frequency and target strength

f_chu  = chu_data(:,1);
TS_chu = chu_data(:,2);

% Original three-column COMSOL CSV
f_comsol1  = comsol_data1(:,1);
TS_comsol1 = comsol_data1(:,3);

% Physics-controlled mesh two-column COMSOL CSV
f_comsol2  = comsol_data2(:,1);
TS_comsol2 = comsol_data2(:,2);

%% Remove nonpositive frequencies

% A logarithmic frequency axis requires positive values
valid_chu = f_chu > 0;
f_chu     = f_chu(valid_chu);
TS_chu    = TS_chu(valid_chu);

valid_comsol1 = f_comsol1 > 0;
f_comsol1     = f_comsol1(valid_comsol1);
TS_comsol1    = TS_comsol1(valid_comsol1);

valid_comsol2 = f_comsol2 > 0;
f_comsol2     = f_comsol2(valid_comsol2);
TS_comsol2    = TS_comsol2(valid_comsol2);

if isempty(f_chu) || isempty(f_comsol1) || isempty(f_comsol2)
    error('Each dataset must contain at least one positive frequency.')
end

%% Sort by frequency

[f_chu, idx] = sort(f_chu);
TS_chu = TS_chu(idx);

[f_comsol1, idx] = sort(f_comsol1);
TS_comsol1 = TS_comsol1(idx);

[f_comsol2, idx] = sort(f_comsol2);
TS_comsol2 = TS_comsol2(idx);

%% Determine the full frequency range

% Use the union of the ranges rather than only the range shared by all
% datasets. This allows curves beginning below 1 kHz to be displayed.
f_min = min([ ...
    min(f_chu), ...
    min(f_comsol1), ...
    min(f_comsol2)]);

f_max = max([ ...
    max(f_chu), ...
    max(f_comsol1), ...
    max(f_comsol2)]);

%% Interpolate Chu values at valid COMSOL frequencies

% Interpolation is only performed where COMSOL frequencies fall within
% the available Chu frequency range.
chu_f_min = min(f_chu);
chu_f_max = max(f_chu);

valid_comsol1_for_chu = ...
    f_comsol1 >= chu_f_min & ...
    f_comsol1 <= chu_f_max;

valid_comsol2_for_chu = ...
    f_comsol2 >= chu_f_min & ...
    f_comsol2 <= chu_f_max;

f_comsol_combined = unique([ ...
    f_comsol1(valid_comsol1_for_chu);
    f_comsol2(valid_comsol2_for_chu)]);

if ~isempty(f_comsol_combined)
    TS_chu_at_comsol = interp1( ...
        log10(f_chu), ...
        TS_chu, ...
        log10(f_comsol_combined), ...
        'linear');
else
    TS_chu_at_comsol = [];
end

%% Plot

figure('Color', 'w')

% Chu analytical curve
semilogx(f_chu/1000, TS_chu, ...
    'k-', ...
    'LineWidth', 2)

hold on

% Black points on the Chu curve at COMSOL frequencies
if ~isempty(f_comsol_combined)
    semilogx(f_comsol_combined/1000, TS_chu_at_comsol, ...
        'ko', ...
        'MarkerSize', 6, ...
        'MarkerFaceColor', 'k', ...
        'LineStyle', 'none')
end

% Original COMSOL curve
semilogx(f_comsol1/1000, TS_comsol1, ...
    'r-o', ...
    'LineWidth', 2, ...
    'MarkerSize', 6, ...
    'MarkerEdgeColor', 'r', ...
    'MarkerFaceColor', 'r')

% Physics-controlled mesh COMSOL curve
semilogx(f_comsol2/1000, TS_comsol2, ...
    'b-s', ...
    'LineWidth', 2, ...
    'MarkerSize', 6, ...
    'MarkerEdgeColor', 'b', ...
    'MarkerFaceColor', 'b')

%% Labels and title

xlabel('Frequency (kHz)', ...
    'FontSize', 16, ...
    'FontWeight', 'bold')

ylabel('Target strength (dB re 1 m)', ...
    'FontSize', 16, ...
    'FontWeight', 'bold')

title('Soft Sphere Target Strength', ...
    'FontSize', 18, ...
    'FontWeight', 'bold')

if ~isempty(f_comsol_combined)
    legend( ...
        'Chu analytical model', ...
        'Chu at COMSOL frequencies', ...
        'COMSOL model (\lambda/6)', ...
        'COMSOL model (physics-controlled mesh)', ...
        'Location', 'best', ...
        'FontSize', 12)
else
    legend( ...
        'Chu analytical model', ...
        'COMSOL model (\lambda/6)', ...
        'COMSOL model (physics-controlled mesh)', ...
        'Location', 'best', ...
        'FontSize', 12)
end

%% Axis formatting

grid on
box on

% Display the full range covered by any dataset
xlim([f_min f_max]/1000)
ylim([-80 20])

% Candidate tick positions in kHz
candidate_ticks = [ ...
    0.001 0.002 0.005 ...
    0.01 0.02 0.05 ...
    0.1 0.2 0.5 ...
    1 2 5 10 20 30 40 50 60 70 80 90 100];

x_limits = [f_min f_max]/1000;

ticks_to_show = candidate_ticks( ...
    candidate_ticks >= x_limits(1) & ...
    candidate_ticks <= x_limits(2));

if ~isempty(ticks_to_show)
    xticks(ticks_to_show)
    xticklabels(string(ticks_to_show))
end

ax = gca;

ax.FontSize = 14;
ax.FontWeight = 'bold';
ax.LineWidth = 1.2;
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';

%% Export figure

output_file = fullfile( ...
    pwd, 'soft_sphere_threeTS.png');

exportgraphics(gcf, output_file, ...
    'Resolution', 300);

fprintf('Figure saved to:\n%s\n', output_file);