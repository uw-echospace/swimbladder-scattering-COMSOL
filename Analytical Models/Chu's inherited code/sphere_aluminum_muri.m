%% demo program to call elastic_fs.m

addpath(genpath(pwd)) % matlab Sphere  -end

% Medium params
cw0 = 1500;  % sound speed of seawater
rho0 = 1.028;    % density of seawater

% Target params
a = 0.0254;   % radius of sphere
r = 1;       % ratio b/a for non-shelled objects
rho = 2.7;   % aluminum sound speed [g/cm^3]
cc = 6350;   % aluminum compressional wave speed [m/s]
cs = 3050;   % aluminum shear wave speed [m/s]

% Model params
proc_flag=1;	% form function vs ka
out_flag=1;		% modular of form function
x0 = 1;		% starting ka value
xe = 30;		% end ka value
theta = 180;	% backscattering
n = 5000;			% number of computation points
scale = 1;		% linear spacing in ka

g = rho/rho0;   % density contrast 
hc = cc/cw0;    % compressional sound speed contrast
hs = cs/cw0;    % shear sound speed contrast
para_ela = [n x0 xe g hc hs theta];
[ka, fm] = elastic_fs(proc_flag,scale,out_flag,para_ela);

TS = 20*log10(abs(fm)*a/2);    % target strength

figure;
freq = 1500*ka/(2*pi*a);  % frequency in Hz
plot(freq*1e-3,TS,'linewidth',2);

set(gca, 'fontsize', 12)
xlabel('Frequency (kHz)', 'fontsize',14)
ylabel('TS (dB)', 'fontsize',14)
title('Solid aluminum sphere, 0.0254 m radius', 'fontsize', 16)
ylim([-80 -20])
grid on
