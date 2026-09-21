clear
close all
clc

%% File names

chu_file    = 'air_sphere_rscat0.25_Chu.csv';
comsol_file = 'air_sphere_rscat0.25_COMSOL.csv';

comsol_label = 'COMSOL model';

output_file = fullfile(pwd, ...
    'air_sphere_TS_vs_ka.png');

%% Physical parameters

% Sphere radius in meters
% Change this if rscat = 0.25 uses different units
sphere_radius = 0.25;

% Speed of sound in the surrounding water (m/s)
c_water = 1500;

%% Plot settings

marker_step = 2;
num_x_ticks = 7;

comsol_color  = [0.00 0.45 0.74];
comsol_marker = 'o';

line_width  = 2.5;
marker_size = 10;

%% Import and clean Chu data

chu_data = readmatrix(chu_file);

if size(chu_data, 2) < 2
    error('The Chu CSV must contain at least two columns.')
end

chu_data = chu_data( ...
    all(isfinite(chu_data(:,1:2)), 2), 1:2);

chu_data = chu_data(chu_data(:,1) > 0, :);

if isempty(chu_data)
    error(['No valid positive-frequency data were found ', ...
        'in the Chu CSV.'])
end

[f_chu, idx_chu] = sort(chu_data(:,1));
TS_chu = chu_data(idx_chu, 2);

%% Import and clean COMSOL data

comsol_data = readmatrix(comsol_file);

if size(comsol_data, 2) < 2
    error('The COMSOL CSV must contain at least two columns.')
end

comsol_data = comsol_data( ...
    all(isfinite(comsol_data(:,1:2)), 2), 1:2);

comsol_data = comsol_data(comsol_data(:,1) > 0, :);

if isempty(comsol_data)
    error(['No valid positive-frequency data were found ', ...
        'in the COMSOL CSV.'])
end

[f_comsol, idx_comsol] = sort(comsol_data(:,1));
TS_comsol = comsol_data(idx_comsol, 2);

%% Restrict data to the shared frequency range

f_min = max(min(f_chu), min(f_comsol));
f_max = min(max(f_chu), max(f_comsol));

if f_min >= f_max
    error(['The Chu and COMSOL datasets do not share ', ...
        'an overlapping frequency range.'])
end

valid_chu = ...
    f_chu >= f_min & f_chu <= f_max;

f_chu_plot  = f_chu(valid_chu);
TS_chu_plot = TS_chu(valid_chu);

valid_comsol = ...
    f_comsol >= f_min & f_comsol <= f_max;

f_comsol_plot  = f_comsol(valid_comsol);
TS_comsol_plot = TS_comsol(valid_comsol);

%% Convert frequency to ka

ka_chu = ...
    2*pi*f_chu_plot*sphere_radius/c_water;

ka_comsol = ...
    2*pi*f_comsol_plot*sphere_radius/c_water;

ka_min = 2*pi*f_min*sphere_radius/c_water;
ka_max = 2*pi*f_max*sphere_radius/c_water;

%% Select aligned marker positions

marker_idx = 1:marker_step:numel(f_comsol_plot);

f_markers  = f_comsol_plot(marker_idx);
ka_markers = ka_comsol(marker_idx);

% Interpolate Chu values at the COMSOL marker frequencies
TS_chu_markers = interp1( ...
    log10(f_chu), ...
    TS_chu, ...
    log10(f_markers), ...
    'linear');

%% Create figure

figure( ...
    'Color', 'w', ...
    'Position', [100 100 1150 700])

hold on

%% Plot Chu analytical curve

semilogx(ka_chu, TS_chu_plot, ...
    'Color', 'k', ...
    'LineStyle', '-', ...
    'LineWidth', line_width, ...
    'DisplayName', 'Chu analytical model')

% Filled Chu markers aligned with COMSOL markers
semilogx(ka_markers, TS_chu_markers, ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'MarkerSize', marker_size, ...
    'MarkerEdgeColor', 'k', ...
    'MarkerFaceColor', 'k', ...
    'HandleVisibility', 'off')

%% Plot COMSOL curve

semilogx(ka_comsol, TS_comsol_plot, ...
    'Color', comsol_color, ...
    'LineStyle', '-', ...
    'LineWidth', line_width, ...
    'DisplayName', comsol_label)

% Hollow COMSOL markers
semilogx(ka_markers, TS_comsol_plot(marker_idx), ...
    'LineStyle', 'none', ...
    'Marker', comsol_marker, ...
    'MarkerSize', marker_size, ...
    'MarkerEdgeColor', comsol_color, ...
    'MarkerFaceColor', 'none', ...
    'LineWidth', 1.5, ...
    'HandleVisibility', 'off')

%% Axis limits

xlim([ka_min ka_max])
ylim([-120 0])

%% Labels and title

xlabel('\it{ka}', ...
    'Interpreter', 'tex', ...
    'FontSize', 23, ...
    'FontWeight', 'bold')

ylabel('Target strength (dB re 1 m)', ...
    'FontSize', 23, ...
    'FontWeight', 'bold')

title('Air Sphere Target Strength', ...
    'FontSize', 25, ...
    'FontWeight', 'bold')

%% Legend

legend('show', ...
    'Location', 'southeast', ...
    'FontSize', 19, ...
    'FontWeight', 'bold', ...
    'Box', 'on')

%% Axis formatting

ax = gca;
ax.XScale = 'log';

% Geometrically spaced ka ticks
ka_ticks = logspace( ...
    log10(ka_min), ...
    log10(ka_max), ...
    num_x_ticks);

ax.XTick = ka_ticks;
ax.XTickLabel = compose('%.3g', ka_ticks);

set(ax, ...
    'Color', 'w', ...
    'FontSize', 20, ...
    'FontWeight', 'bold', ...
    'LineWidth', 1.5, ...
    'TickLength', [0.015 0.015], ...
    'TickDir', 'out', ...
    'XMinorTick', 'on', ...
    'YMinorTick', 'on', ...
    'Box', 'on')

grid on

ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.GridAlpha = 0.20;
ax.MinorGridAlpha = 0.10;

%% Export figure

exportgraphics(gcf, output_file, ...
    'Resolution', 300);

fprintf('Figure saved to:\n%s\n', output_file);