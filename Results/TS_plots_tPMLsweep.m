clear
close all
clc

%% File name

comsol_file = 'soft_sphere_PMLsweep_COMSOL.csv';

%% Import data

comsol_data = readmatrix(comsol_file);

% Required columns:
% Column 1: PML thickness, m
% Column 2: Frequency, Hz
% Column 3: Target strength, dB re 1 m

if size(comsol_data, 2) < 3
    error(['The CSV must contain at least three columns: ', ...
        'PML thickness, frequency, and target strength.'])
end

% Remove headers, missing values, and nonnumeric rows
comsol_data = comsol_data( ...
    all(isfinite(comsol_data(:,1:3)), 2), 1:3);

if isempty(comsol_data)
    error('No valid numeric data were found in the CSV file.')
end

%% Extract data

pml_thickness = comsol_data(:,1);
frequency     = comsol_data(:,2);
target_strength = comsol_data(:,3);

% Remove nonpositive frequencies because a logarithmic axis is used
valid_frequency = frequency > 0;

pml_thickness  = pml_thickness(valid_frequency);
frequency      = frequency(valid_frequency);
target_strength = target_strength(valid_frequency);

if isempty(frequency)
    error('No positive frequencies were found in the CSV file.')
end

%% Identify PML thickness values

thickness_values = unique(pml_thickness, 'sorted');
number_of_curves = numel(thickness_values);

%% Plot

figure('Color', 'w')

% Generate distinguishable colors
curve_colors = lines(number_of_curves);

marker_styles = {'o', 's', '^', 'd', 'v', '>', '<', 'p', 'h'};

legend_labels = strings(number_of_curves, 1);

for i = 1:number_of_curves

    current_thickness = thickness_values(i);

    % Select rows for this PML thickness
    current_rows = pml_thickness == current_thickness;

    f_current  = frequency(current_rows);
    TS_current = target_strength(current_rows);

    % Sort by frequency
    [f_current, idx] = sort(f_current);
    TS_current = TS_current(idx);

    % Select marker
    marker_index = mod(i - 1, numel(marker_styles)) + 1;
    current_marker = marker_styles{marker_index};

    % Plot using logarithmic frequency axis
    semilogx(f_current/1000, TS_current, ...
        '-', ...
        'Color', curve_colors(i,:), ...
        'LineWidth', 4, ...
        'Marker', current_marker, ...
        'MarkerSize', 8, ...
        'MarkerEdgeColor', curve_colors(i,:), ...
        'MarkerFaceColor', curve_colors(i,:))

    % Turn hold on only after the first semilogx call
    if i == 1
        hold on
    end

    legend_labels(i) = sprintf( ...
        'PML thickness = %g m', current_thickness);
end

%% Labels and title

xlabel('Frequency (kHz)', ...
    'FontSize', 48, ...
    'FontWeight', 'bold')

ylabel('Target strength (dB re 1 m)', ...
    'FontSize', 28, ...
    'FontWeight', 'bold')

title('Effect of PML Thickness on Target Strength', ...
    'FontSize', 28, ...
    'FontWeight', 'bold')

legend(legend_labels, ...
    'Location', 'best', ...
    'FontSize', 22)

%% Axis formatting

grid on
box on

% Complete frequency range
f_min = min(frequency);
f_max = max(frequency);

xlim([f_min f_max]/1000)
ylim([-80 20])

% Candidate ticks in kHz
candidate_ticks = [ ...
    0.05 0.1 0.2 0.5 ...
    1 2 5 10 20 30 40 50 60 70 80 90];

x_limits = [f_min f_max]/1000;

ticks_to_show = candidate_ticks( ...
    candidate_ticks >= x_limits(1) & ...
    candidate_ticks <= x_limits(2));

xticks(ticks_to_show)
xticklabels(string(ticks_to_show))

ax = gca;

% Explicitly guarantee logarithmic scaling
ax.XScale = 'log';

ax.FontSize = 28;
ax.FontWeight = 'bold';
ax.LineWidth = 1.2;
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';

%% Export figure

output_file = fullfile( ...
    pwd, 'soft_sphere_PML_thickness_comparison.png');

exportgraphics(gcf, output_file, ...
    'Resolution', 300);

fprintf('Figure saved to:\n%s\n', output_file);