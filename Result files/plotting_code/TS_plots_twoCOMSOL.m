clear
close all
clc

%% File names

comsol_file1 = 'soft_sphere_physicsmesh_COMSOL.csv';
comsol_file2 = 'soft_sphere_physicsmesh_PMB_COMSOL.csv';

%% Import data

comsol_data1 = readmatrix(comsol_file1);
comsol_data2 = readmatrix(comsol_file2);

% Ensure that both CSV files contain at least two columns
if size(comsol_data1, 2) < 2
    error('%s must contain frequency and target strength.', ...
        comsol_file1)
end

if size(comsol_data2, 2) < 2
    error('%s must contain frequency and target strength.', ...
        comsol_file2)
end

% Remove headers, missing values, and nonnumeric rows
comsol_data1 = comsol_data1( ...
    all(isfinite(comsol_data1(:,1:2)), 2), :);

comsol_data2 = comsol_data2( ...
    all(isfinite(comsol_data2(:,1:2)), 2), :);

% Check that valid data remain
if isempty(comsol_data1)
    error('No valid numeric data were found in %s.', ...
        comsol_file1)
end

if isempty(comsol_data2)
    error('No valid numeric data were found in %s.', ...
        comsol_file2)
end

%% Extract frequency and target strength

f_comsol1  = comsol_data1(:,1);
TS_comsol1 = comsol_data1(:,2);

f_comsol2  = comsol_data2(:,1);
TS_comsol2 = comsol_data2(:,2);

% Remove nonpositive frequencies because a logarithmic axis is used
valid1 = f_comsol1 > 0;
f_comsol1  = f_comsol1(valid1);
TS_comsol1 = TS_comsol1(valid1);

valid2 = f_comsol2 > 0;
f_comsol2  = f_comsol2(valid2);
TS_comsol2 = TS_comsol2(valid2);

%% Sort both datasets by frequency

[f_comsol1, idx] = sort(f_comsol1);
TS_comsol1 = TS_comsol1(idx);

[f_comsol2, idx] = sort(f_comsol2);
TS_comsol2 = TS_comsol2(idx);

%% Plot

figure('Color', 'w')

% First COMSOL target-strength curve
semilogx(f_comsol1/1000, TS_comsol1, ...
    'r-o', ...
    'LineWidth', 2, ...
    'MarkerSize', 6, ...
    'MarkerEdgeColor', 'r', ...
    'MarkerFaceColor', 'r')

hold on

% Second COMSOL target-strength curve
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

legend( ...
    'Perfectly Matched Layer', ...
    'Perfectly Matched Boundary', ...
    'Location', 'best', ...
    'FontSize', 12)

%% Axis formatting

grid on
box on

% Include the complete range of both datasets
f_min = min([f_comsol1; f_comsol2]);
f_max = max([f_comsol1; f_comsol2]);

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
ax.FontSize = 14;
ax.FontWeight = 'bold';
ax.LineWidth = 1.2;
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';

%% Export figure

output_file = fullfile( ...
    pwd, 'soft_sphere_PMBvsPML.png');

exportgraphics(gcf, output_file, ...
    'Resolution', 300);

fprintf('Figure saved to:\n%s\n', output_file);