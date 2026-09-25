# Running a COMSOL model from a MATLAB script

## In the COMSOL GUI

1. Clear previous solver and job configurations.
2. Remove all results and plot nodes.
3. Compact the model history.
4. Save the model as a MATLAB script.

## In the MATLAB script

1. On line 1, set the function name to match your model:

   ```matlab
   function out = TS_rigid_sphere
   ```

2. On line 12, specify the directory where the model will run. You can use `pwd` for the current MATLAB directory.
3. Immediately before the final `out = model` line, add:

   ```matlab
   model.study('std1').run;

   resultsDir = fullfile(pwd, 'results');
   if ~exist(resultsDir, 'dir')
       mkdir(resultsDir);
   end

   mphsave(model, fullfile(resultsDir, 'TS_rigid_sphere_output.mph'));
   ```

Replace `TS_rigid_sphere` in the function name and output filename with your model’s name. The added code runs the study, creates a `results` subdirectory, and saves the output `.mph` file there.
