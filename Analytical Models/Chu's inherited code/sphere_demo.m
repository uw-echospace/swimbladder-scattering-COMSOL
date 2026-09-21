%% demo program to call elastic_fs.m

clear

addpath(genpath(pwd)) % matlab Sphere  -end

out_flag=1;				% complex form function
scale=1;				% linear spacing in ka
proc_flag=1;			% 1 = backscattering vs ka (fixed theta); 2 = backscattering vs angle (fixed ka)
n=1000;					% number of computation points 
theta_ka=180;		    % if proc_flag = 1: 180 = backscattering; 0 = forward scattering
                        % if proc_flag = 2:  theta_ka = fixed ka 

object_index=1;
switch object_index
    case 1   % ridig & fixed
        if proc_flag == 1
            x0=0.01;					% starting ka value
            xe=30;					    % end ka value
            para_rgd=[n x0 xe theta_ka];
            [ka, fm]=rgd_sft_fs(proc_flag,1,scale,out_flag,para_rgd);
        else
            th0 = 0;
            th1 = 360;
            para_rgd=[n th0 th1 theta_ka];
            [ths, fm]=rgd_sft_fs(proc_flag,1,scale,out_flag,para_rgd);
        end
    case 2
        %% bubble at surface
        g=0.0012;h=0.22;ka0=1;
        if proc_flag == 1
            x0=0.001;			    % starting ka value
            xe=20;					% end ka value
            scale=2;                % log scale
            para_fld=[n x0 xe g h theta_ka];
            [ka, fm]=fluid_fs(proc_flag,scale,out_flag,para_fld);
        else
            th0 = 0;
            th1 = 360;
            para_fld=[n th0 th1 ka0 g h theta_ka];
            [ths, fm]=fluid_fs(proc_flag,scale,out_flag,para_fld);
        end
    case 3
        %% solid elastic sphere
%         %% parameters of stainless steel
%         g=7.8;					% density ratio
%         hc=3.74;			    % compressional sound speed contrast
%         hs=2.08;			    % sheer speed contrast
%         %%  Tungsten Carbide
%         g=14.9160;              % density ratio
%         hc=4.6135;              % compressional sound speed contrast
%         hs=2.8312;              % sheer speed contrast
        %%  Aluminum
        g=2.6214;              % density ratio
        hc=4.2333;              % compressional sound speed contrast
        hs=2.0333;              % sheer speed contrast
        if proc_flag == 1
            x0=0.01;		        % starting ka value
            xe=30;					% end ka value
            para_ela=[n x0 xe g hc hs theta_ka];
            [ka, fm]=elastic_fs(proc_flag,scale,out_flag,para_ela);
        else
            th0 = 0;
            th1 = 360;
            para_ela=[n th0 th1 g hc hs theta_ka];
            [ths, fm]=elastic_fs(proc_flag,scale,out_flag,para_ela);
        end
end

figure(1)
if proc_flag == 1
    if scale == 1
        plot(ka,abs(fm),'linewidth',1.5)
        xlabel('ka')
    else
        loglog(ka,abs(fm),'linewidth',1.5)
        xlabel('ka')
    end
    ylabel('Form Function |f|')
    
    figure(2)
    RTS=20*log10(abs(fm));
    if scale == 1
        plot(ka,RTS,'linewidth',1.5)
        xlabel('ka')
    else
        semilogx(ka,RTS,'linewidth',1.5)
        xlabel('ka')
    end
    ylabel('Reduced TS (dB)')
    grid
else
    amp = abs(fm);
    polar(ths, amp)
end

figure(2)
a = 0.0254;
freq = ka/a*1500/2/pi;
TS = 20*log10(abs(fm)/2*a);
plot(freq/1e3,TS,'linewidth',1.5)
set(gca, 'fontsize', 12)
xlabel('Frequency (kHz)', 'fontsize',14)
ylabel('TS (dB)', 'fontsize',14)
title('Solid aluminum sphere, 0.254 m radius', 'fontsize', 16)
ylim([-80 -20])
grid on
