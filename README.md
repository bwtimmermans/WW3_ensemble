# WW3_ensemble

### Background
Sell script to generate multiple WavewatchIII jobs.

This shell script originated during my PhD (2010), involving exploration of the effects of parameter perturbations within WavewatchIII®.
Ensemble runs were required, each employing a different set of input parameters via input namelists.
These scripts readily generalise to any code base run in a shell environment.

This revision was developed as part of a contribution to the third phase (2024-2026) of the COordinated Wave CLImate Project (COWCLIP) by Ben Timmermans and Lucy Bricheno at the National Oceanography Centre, U.K.

This code is freely available under the GNU GENERAL PUBLIC LICENSE Version 3.

### Operational Logic
Broadly, the scripts generate a run time configuraton by finding and replacing necessary parameter labels within a set of template files. Typically these include things like the experiment name, run year and so on. The selection is determined entirely by the user. Parameters for replacement are typically designated within angular parenthesise: '<your_variable>'.

#### Important parts of the code include:
1. The 'global_template' directory contains the structure template for WavewatchIII® execution. In particular, 'ww3_run.sl' is the Slurm submission script that contains most of the run time configuration and execution.
2. The 'script_ops.sh' file, within the template, is called during the generation process, rather that at run time. It provides convenient way to apply additional pre-configurarion steps such as input namelist generation.
3. The 'generate_year.sh' script produces the run time directories. In the current configuraiton it can process up to 15 variables, which are specified in the experiment details ('exp_details') file. This can be renamed and specified in 'generate_year.sh' if preferred. Parameters to be searched and replaced, and their values, must be listed (an example 'exp_details_GS256A_hist_GFDL-ESM4_1' is provided). Each line corresponds to a new experiment and is read sequentially by generate_year.sh. Files for processing are listed within generate_year.sh, and must be verified or specified before use.

