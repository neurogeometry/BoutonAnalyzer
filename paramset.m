%Parameter controling size of tube to remove background around axon used in gui_optimization.m
params.proj.fm_dist=5;                         %default: proj.fm_dist=5                    (Image intensity beyond this number of voxels in 
                                               %                                             3D is set to zero for visualizing axon within tube)
%Trace optimization parameters used in gui_optimization.m
params.opt.Rtypical=3;                         %default: opt.Rtypical=3
params.opt.Optimize_bps=0;                     %default: opt.Optimize_bps=0                (true/false value - optimize trace branch points or not)
params.opt.Optimize_tps=0;                     %default: opt.Optimize_tps=0                (true/false value - optimize trace terminal points or not)
params.opt.isadjustpointdensity=1;             %default: opt.isadjustpointdensity=1;       (true/false value - adjust point density on trace or not)
params.opt.pointspervoxel=0.25;                %default: opt.pointspervoxel=0.25           (0.25 corresponde to a trace point density of ~1 every 4 voxels)
params.opt.MaxIterations=500;                  %default: opt.MaxIterations=500;            (Maximum # of trace optimization steps. Inspect trace quality before adjusting this number)
params.opt.alpha_r=0.001;                      %default: opt.alpha_r=0.001                 (Controls trace stiffness)
params.opt.betta_r=10;                         %default: opt.betta_r=10                    (Optimization step size)
params.opt.output=1;                           %default: opt.output=1;                     (true/false value - print output or not)

%Parameters related to generation of profiles used in gui_optimization.m and profilefilters.m
params.profile.pointspervoxel=4;               %default: profile.pointspervoxel=4;         (Sets point density on trace, after optimization)
params.profile.umpervox=[0.26,0.26,0.80];      %default: profile.umpervox=[0.26,0.26,0.80] (Image resolution)
params.filt.types={'LoGxy','Gauss'};           %default: filt.types={'LoGxy','Gauss'}      (Type of filter used to generate intensity profile)
params.filt.LoGxy_R_min=1.5;                   %default: filt.LoGxy_R_min=1.5              (Minimum radial size (in xy plane) for multiscale LoGxy filter) 
params.filt.LoGxy_R_step=0.01;                 %default: filt.LoGxy_R_step=0.01            (Step size for multiscale LoGxy filter)
params.filt.LoGxy_R_max=3;                     %default: filt.LoGxy_R_max=3                (Maximum radial size (in xy plane) for multiscale LoGxy filter) 
params.filt.LoGxy_Rz=2;                        %default: filt.LoGxy_Rz=2                   (Fixed size in z for LoGxy filter)
params.filt.Gauss_R=2;                         %default: filt.Gauss_R=2                    (Fixed size for gaussian filter)

%Parameters related to bouton detection used in fitLoGxy.m and fitGauss.m
params.fit.Nsteps=20000;                       %default: fit.Nsteps=20000                   (Maximum number of steps for peak fitting)
params.fit.min_change=10^-6;                   %default: fit.min_change=10^-6               (Exit condition for peak fitting)
params.fit.betta0=0.1;                         %default: fit.betta0=0.1                     (Step size for optimization that is part of peak fitting)
params.fit.alpha=0.5;                          %default: fit.alpha=0.5                      (Maximum allowed overlap fraction beyond which peaks are merged)
params.fit.min_d=1;                            %default: fit.min_d=1                        (Minimum distance between distinct foreground peaks)
params.fit.min_A=0.3;                          %default: fit.min_A=0.3                      (Heuristic threshold on minimum allowed amplitude)
params.fit.typical_bouton_size=2;              %default: fit.typical_bouton_size=2          (size is 4 x sigma of foreground peaks, in microns)
params.fit.min_bouton_size=1;                  %default: fit.min_bouton_size=1              (size is 4 x sigma of foreground peaks, in microns)
params.fit.max_bouton_size=3;                  %default: fit.max_bouton_size=3              (size is 4 x sigma of foreground peaks, in microns)
params.fit.typical_background_size=50;         %default: typical_background_size=50         (size is 4 x sigma of background peaks, in microns)
params.fit.min_background_size=20;             %default: fit.min_background_size=20         (size is 4 x sigma of background peaks, in microns)
