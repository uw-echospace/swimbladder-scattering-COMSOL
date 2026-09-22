function out = TS_rigid_sphere
%
% TS_rigid_sphere.m
%
% Model exported on Aug 3 2026, 11:18 by COMSOL 6.4.0.429.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath(pwd);

model.label('TS_rigid_sphere.mph');

model.param.set('R_scat', '5 [cm]', 'Radius of spherical scatterer');
model.param.set('R_dom', '10 [cm]', 'Radius of medium domain');
model.param.set('t_PML', '1 [cm]', 'Thickness of PML');
model.param.set('f0', '500 [Hz]', 'frequency');
model.param.set('c_dom', '1500 [m/s]', 'speed of sound in domain');
model.param.set('lambda', 'c_dom/f0', 'Wavelength');

model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 3);

model.result.table.create('tbl1', 'Table');
model.result.table.create('tbl2', 'Table');

model.component('comp1').mesh.create('mesh1');

model.component('comp1').geom('geom1').geomRep('comsol');
model.component('comp1').geom('geom1').create('sph1', 'Sphere');
model.component('comp1').geom('geom1').feature('sph1').label('Solid Sphere Scatterer');
model.component('comp1').geom('geom1').feature('sph1').set('r', 'R_scat');
model.component('comp1').geom('geom1').create('sph2', 'Sphere');
model.component('comp1').geom('geom1').feature('sph2').set('r', 'R_dom');
model.component('comp1').geom('geom1').create('sph3', 'Sphere');
model.component('comp1').geom('geom1').feature('sph3').set('r', 'R_dom + t_PML');
model.component('comp1').geom('geom1').feature('sph3').set('layername', {'Layer 1'});
model.component('comp1').geom('geom1').feature('sph3').setIndex('layer', 't_PML', 0);
model.component('comp1').geom('geom1').run;
model.component('comp1').geom('geom1').run('fin');

model.component('comp1').variable.create('var1');
model.component('comp1').variable('var1').set('lambda', 'mat1.def.c/f0');

model.component('comp1').view('view1').hideEntities.create('hide1');
model.component('comp1').view('view1').hideEntities('hide1').geom('geom1', 2);
model.component('comp1').view('view1').hideEntities('hide1').set([6 10 21 23]);
model.view.create('view2', 3);

model.component('comp1').material.create('mat1', 'Common');
model.component('comp1').material('mat1').selection.set([]);
model.component('comp1').material('mat1').propertyGroup('def').func.create('eta', 'Piecewise');
model.component('comp1').material('mat1').propertyGroup('def').func.create('Cp', 'Piecewise');
model.component('comp1').material('mat1').propertyGroup('def').func.create('rho', 'Piecewise');
model.component('comp1').material('mat1').propertyGroup('def').func.create('k', 'Piecewise');
model.component('comp1').material('mat1').propertyGroup('def').func.create('cs', 'Interpolation');
model.component('comp1').material('mat1').propertyGroup('def').func.create('an1', 'Analytic');
model.component('comp1').material('mat1').propertyGroup('def').func.create('an2', 'Analytic');
model.component('comp1').material('mat1').propertyGroup('def').func.create('an3', 'Analytic');
model.component('comp1').material('mat1').selection.set([1 2 3 4 5 7 8 9 10]);

model.component('comp1').coordSystem.create('pml1', 'PML');
model.component('comp1').coordSystem('pml1').selection.set([1 2 3 4 7 8 9 10]);

model.component('comp1').physics.create('acpr', 'PressureAcoustics', 'geom1');
model.component('comp1').physics('acpr').selection.set([]);
model.component('comp1').physics('acpr').create('bpf1', 'BackgroundPressureField', 3);
model.component('comp1').physics('acpr').feature('bpf1').selection.set([5]);
model.component('comp1').physics('acpr').create('shb3', 'SoundHard', 2);
model.component('comp1').physics('acpr').feature('shb3').selection.set([13 14 15 16 24 25 30 31]);
model.component('comp1').physics('acpr').create('efc1', 'ExteriorFieldCalculation', 2);
model.component('comp1').physics('acpr').feature('efc1').selection.set([9 10 11 12 22 23 29 34]);
model.component('comp1').physics('acpr').create('ssb1', 'SoundSoft', 2);
model.component('comp1').physics('acpr').feature('ssb1').selection.set([13 14 15 16 24 25 30 31]);

model.component('comp1').mesh('mesh1').create('ftet1', 'FreeTet');
model.component('comp1').mesh('mesh1').create('swe2', 'Sweep');
model.component('comp1').mesh('mesh1').feature('ftet1').selection.geom('geom1', 3);
model.component('comp1').mesh('mesh1').feature('ftet1').selection.set([5 6]);
model.component('comp1').mesh('mesh1').feature('swe2').selection.geom('geom1', 3);
model.component('comp1').mesh('mesh1').feature('swe2').selection.set([1 2 3 4 7 8 9 10]);

model.result.table('tbl1').comments('Point Evaluation 1');
model.result.table('tbl2').comments('Point Evaluation 1');

model.component('comp1').view('view1').set('transparency', true);

model.component('comp1').material('mat1').label('Water, liquid');
model.component('comp1').material('mat1').set('family', 'water');
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('pieces', {'273.15' '413.15' '1.3799566804-0.021224019151*T^1+1.3604562827E-4*T^2-4.6454090319E-7*T^3+8.9042735735E-10*T^4-9.0790692686E-13*T^5+3.8457331488E-16*T^6'; '413.15' '553.75' '0.00401235783-2.10746715E-5*T^1+3.85772275E-8*T^2-2.39730284E-11*T^3'});
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('argunit', 'K');
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('fununit', 'Pa*s');
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('pieces', {'273.15' '553.75' '12010.1471-80.4072879*T^1+0.309866854*T^2-5.38186884E-4*T^3+3.62536437E-7*T^4'});
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('argunit', 'K');
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('fununit', 'J/(kg*K)');
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('smooth', 'contd1');
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('pieces', {'273.15' '293.15' '0.000063092789034*T^3-0.060367639882855*T^2+18.9229382407066*T-950.704055329848'; '293.15' '373.15' '0.000010335053319*T^3-0.013395065634452*T^2+4.969288832655160*T+432.257114008512'});
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('argunit', 'K');
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('fununit', 'kg/m^3');
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('pieces', {'273.15' '553.75' '-0.869083936+0.00894880345*T^1-1.58366345E-5*T^2+7.97543259E-9*T^3'});
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('argunit', 'K');
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('fununit', 'W/(m*K)');
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('table', {'273' '1403';  ...
'278' '1427';  ...
'283' '1447';  ...
'293' '1481';  ...
'303' '1507';  ...
'313' '1526';  ...
'323' '1541';  ...
'333' '1552';  ...
'343' '1555';  ...
'353' '1555';  ...
'363' '1550';  ...
'373' '1543'});
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('interp', 'piecewisecubic');
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('fununit', {'m/s'});
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('argunit', {'K'});
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('funcname', 'alpha_p');
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('expr', '-1/rho(T)*d(rho(T),T)');
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('args', {'T'});
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('fununit', '1/K');
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('argunit', {'K'});
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('plotfixedvalue', {'273.15'});
model.component('comp1').material('mat1').propertyGroup('def').func('an1').set('plotargs', {'T' '273.15' '373.15'});
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('funcname', 'gamma_w');
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('expr', '1+(T/Cp(T))*(alpha_p(T)*cs(T))^2');
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('args', {'T'});
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('fununit', '1');
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('argunit', {'K'});
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('plotfixedvalue', {'273.15'});
model.component('comp1').material('mat1').propertyGroup('def').func('an2').set('plotargs', {'T' '273.15' '373.15'});
model.component('comp1').material('mat1').propertyGroup('def').func('an3').set('funcname', 'muB');
model.component('comp1').material('mat1').propertyGroup('def').func('an3').set('expr', '2.79*eta(T)');
model.component('comp1').material('mat1').propertyGroup('def').func('an3').set('args', {'T'});
model.component('comp1').material('mat1').propertyGroup('def').func('an3').set('fununit', 'Pa*s');
model.component('comp1').material('mat1').propertyGroup('def').func('an3').set('argunit', {'K'});
model.component('comp1').material('mat1').propertyGroup('def').func('an3').set('plotfixedvalue', {'273.15'});
model.component('comp1').material('mat1').propertyGroup('def').func('an3').set('plotargs', {'T' '273.15' '553.75'});
model.component('comp1').material('mat1').propertyGroup('def').set('thermalexpansioncoefficient', {'alpha_p(T)' '0' '0' '0' 'alpha_p(T)' '0' '0' '0' 'alpha_p(T)'});
model.component('comp1').material('mat1').propertyGroup('def').set('bulkviscosity', 'muB(T)');
model.component('comp1').material('mat1').propertyGroup('def').set('dynamicviscosity', 'eta(T)');
model.component('comp1').material('mat1').propertyGroup('def').set('ratioofspecificheat', 'gamma_w(T)');
model.component('comp1').material('mat1').propertyGroup('def').set('electricconductivity', {'5.5e-6[S/m]' '0' '0' '0' '5.5e-6[S/m]' '0' '0' '0' '5.5e-6[S/m]'});
model.component('comp1').material('mat1').propertyGroup('def').set('heatcapacity', 'Cp(T)');
model.component('comp1').material('mat1').propertyGroup('def').set('density', 'rho(T)');
model.component('comp1').material('mat1').propertyGroup('def').set('thermalconductivity', {'k(T)' '0' '0' '0' 'k(T)' '0' '0' '0' 'k(T)'});
model.component('comp1').material('mat1').propertyGroup('def').set('soundspeed', 'c_dom');
model.component('comp1').material('mat1').propertyGroup('def').addInput('temperature');

model.component('comp1').coordSystem('pml1').set('ScalingType', 'Spherical');

model.component('comp1').physics('acpr').selection.set([1 2 3 4 5 7 8 9 10]);
model.component('comp1').physics('acpr').feature('bpf1').set('pamp', 1);
model.component('comp1').physics('acpr').feature('bpf1').set('c_mat', 'from_mat');
model.component('comp1').physics('acpr').feature('ssb1').active(false);

model.component('comp1').mesh('mesh1').feature('size').set('hauto', 4);
model.component('comp1').mesh('mesh1').feature('size').set('custom', 'on');
model.component('comp1').mesh('mesh1').feature('size').set('hmax', 'lambda/10');
model.component('comp1').mesh('mesh1').feature('swe2').selection('sourceface').set([9 10 11 12 22 23 29 34]);
model.component('comp1').mesh('mesh1').feature('swe2').selection('targetface').set([5 6 7 8 20 21 28 35]);
model.component('comp1').mesh('mesh1').run;

model.study.create('std1');
model.study('std1').create('param', 'Parametric');
model.study('std1').create('freq', 'Frequency');
model.study('std1').feature('param').set('pname', {'f0'});
model.study('std1').feature('param').set('plistarr', {'10^(range(log10(500), 1/20, log10(90000)))'});
model.study('std1').feature('param').set('punit', {'Hz'});
model.study('std1').feature('freq').set('plist', 'f0');

model.study('std1').run;

% Save the model and its numerical solution in the submission directory.
resultsDir = fullfile(pwd, 'results');
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end
mphsave(model, fullfile(resultsDir, 'TS_rigid_sphere_output.mph'));

out = model;
