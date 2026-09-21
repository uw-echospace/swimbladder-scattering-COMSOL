clear
close all
clc

%% Input files and panel labels

plot_specs = struct( ...
    'input_file', { ...
        'rockfish_radiationpattern_dorsoventral_xy.csv', ...
        'rockfish_radiationpattern_dorsoventral_xz.csv', ...
        'midshipman_radiationpattern_dorsoventral_zx.csv', ...
        'midshipman_radiationpattern_dorsoventral_zy.csv'}, ...
    'species_name', { ...
        'Rockfish', ...
        'Rockfish', ...
        'Midshipman', ...
        'Midshipman'}, ...
    'plane_label', { ...
        'XY Plane', ...
        'XZ Plane', ...
        'ZX Plane', ...
        'ZY Plane'}, ...
    'output_file', { ...
        'rockfish_monostatic_scattering_xy_panel.png', ...
        'rockfish_monostatic_scattering_xz_panel.png', ...
        'midshipman_monostatic_scattering_zx_panel.png', ...
        'midshipman_monostatic_scattering_zy_panel.png'});

%% Plot formatting

line_width = 4;
marker_size = 9;
marker_step = 12;

axis_font_size     = 17;
subplot_title_size = 22;
panel_title_size   = 30;
label_font_size    = 19;
axis_line_width    = 2;

% Frequencies expected in every COMSOL export
frequencies = [10000 30000 50000 70000];
frequency_labels = {'10 kHz', '30 kHz', '50 kHz', '70 kHz'};

% One color and marker for each frequency
frequency_colors = [ ...
    0.00 0.45 0.74; ... % Blue
    0.47 0.67 0.19; ... % Green
    0.93 0.69 0.13; ... % Gold
    0.85 0.10 0.10];    % Red

frequency_markers = {'o', '^', 'd', 's'};

% Species-specific absolute target-strength scales
% Rockfish span approximately -123 to -68 dB.
rockfish_radial_min  = -125;
rockfish_radial_max  = -65;
rockfish_radial_step = 10;

% Midshipman span approximately -122 to -99 dB.
midshipman_radial_min  = -125;
midshipman_radial_max  = -95;
midshipman_radial_step = 5;

%% Assemble four square 2-by-2 figure panels

for plot_number = 1:numel(plot_specs)

    input_file = plot_specs(plot_number).input_file;
    data = readmatrix(input_file);

    if size(data, 2) < 3
        error(['%s must contain three columns: angle (degrees), ', ...
            'frequency (Hz), and target strength (dB).'], input_file)
    end

    % Remove COMSOL header rows and invalid numerical rows.
    data = data(all(isfinite(data(:,1:3)), 2), 1:3);

    if isempty(data)
        error('No valid numerical data were found in %s.', input_file)
    end

    available_frequencies = unique(data(:,2));

    if ~all(ismember(frequencies, available_frequencies))
        error(['%s does not contain all four expected frequencies: ', ...
            '10, 30, 50, and 70 kHz.'], input_file)
    end

    % Use the broad rockfish scale for panels 1-2 and the tighter
    % midshipman scale for panels 3-4.
    if plot_number <= 2
        radial_min  = rockfish_radial_min;
        radial_max  = rockfish_radial_max;
        radial_step = rockfish_radial_step;
    else
        radial_min  = midshipman_radial_min;
        radial_max  = midshipman_radial_max;
        radial_step = midshipman_radial_step;
    end

    radial_values = radial_min:radial_step:radial_max;
    radial_positions = radial_values - radial_min;
    radial_labels = string(radial_values);

    % A square canvas keeps the 2-by-2 panel balanced and legible.
    fig = figure( ...
        'Color', 'w', ...
        'Position', [100 50 1300 1300]);

    panel = tiledlayout(fig, 2, 2, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');

    % Reserve space for the overall title and target-strength label.
    panel.OuterPosition = [0.055 0.09 0.89 0.82];

    for frequency_number = 1:numel(frequencies)

        current_frequency = frequencies(frequency_number);
        frequency_rows = data(:,2) == current_frequency;

        theta_degrees = data(frequency_rows, 1);
        target_strength = data(frequency_rows, 3);

        [theta_degrees, sort_index] = sort(theta_degrees);
        target_strength = target_strength(sort_index);

        % MATLAB polarplot expects radians.
        theta_radians = deg2rad(theta_degrees);

        % Map negative dB values to nonnegative polar radii.
        polar_radius = target_strength - radial_min;
        polar_radius = min(max(polar_radius, 0), ...
            radial_max - radial_min);

        pax = polaraxes(panel);
        pax.Layout.Tile = frequency_number;

        line_style = ['-' frequency_markers{frequency_number}];

        polarplot( ...
            pax, ...
            theta_radians, ...
            polar_radius, ...
            line_style, ...
            'Color', frequency_colors(frequency_number,:), ...
            'LineWidth', line_width, ...
            'MarkerIndices', ...
                1:marker_step:numel(theta_radians), ...
            'MarkerSize', marker_size, ...
            'MarkerEdgeColor', ...
                frequency_colors(frequency_number,:), ...
            'MarkerFaceColor', 'none');

        % Angular-axis formatting
        pax.ThetaZeroLocation = 'right';
        pax.ThetaDir = 'counterclockwise';
        pax.ThetaTick = 0:45:315;
        pax.ThetaTickLabel = compose('%d°', pax.ThetaTick);

        % Radial-axis formatting
        pax.RLim = [0 radial_max-radial_min];
        pax.RTick = radial_positions;
        pax.RTickLabel = radial_labels;
        pax.RAxisLocation = 135;
        pax.RAxis.Label.String = '';

        % Clear, high-contrast formatting
        pax.FontSize = axis_font_size;
        pax.FontWeight = 'bold';
        pax.LineWidth = axis_line_width;
        pax.GridAlpha = 0.40;
        pax.MinorGridAlpha = 0.20;

        title( ...
            pax, ...
            frequency_labels{frequency_number}, ...
            'FontSize', subplot_title_size, ...
            'FontWeight', 'bold');
    end

    panel_title = sprintf('%s Monostatic Scattering Pattern — %s', ...
        plot_specs(plot_number).species_name, ...
        plot_specs(plot_number).plane_label);

    title( ...
        panel, ...
        panel_title, ...
        'FontSize', panel_title_size, ...
        'FontWeight', 'bold');

    annotation( ...
        fig, ...
        'textbox', ...
        [0.25 0.025 0.50 0.055], ...
        'String', 'Target strength (dB re 1 m)', ...
        'FontSize', label_font_size, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'EdgeColor', 'none');

    output_file = fullfile( ...
        pwd, plot_specs(plot_number).output_file);

    exportgraphics(fig, output_file, 'Resolution', 300);

    fprintf('%s %s panel saved to:\n%s\n', ...
        plot_specs(plot_number).species_name, ...
        plot_specs(plot_number).plane_label, ...
        output_file);
end