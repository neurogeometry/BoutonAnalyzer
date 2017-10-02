%im_pth - Raw image files parent folder (.mat, and .tif multiplane or directory with .tif single planes)
%man_pth - Path for manual trace (.swc files)
%profile_pth - Path for profile data structure (.mat files)
%proj_pth - Path where results are stored (.mat and .txt files)

pth=pwd;%Gets current path
[projectdir,currdir]=fileparts(pth);
datdir=isunixispc([projectdir,filesep,'Data',filesep]);

im_pth=isunixispc([datdir,'Images/']);
man_pth=isunixispc([datdir,'Traces/']);
profile_pth=isunixispc([datdir,'Profiles/']);
proc_pth=isunixispc([datdir,'Results/']);
tmp_pth=[pwd,filesep,'tmp',filesep];
if ~exist(tmp_pth,'dir')
    mkdir(tmp_pth);
end
%Check for custom defined paths
if exist([tmp_pth,'paths.mat'],'file')
    custompth=load([tmp_pth,'paths.mat'],'im_pth','man_pth','profile_pth','proc_pth');
    if ismember('im_pth',fieldnames(custompth))
        im_pth=custompth.im_pth;
    end
    
    if ismember('man_pth',fieldnames(custompth))
        man_pth=custompth.man_pth;
    end
    
    if ismember('profile_pth',fieldnames(custompth))
        profile_pth=custompth.profile_pth;
    end
    
    if ismember('proc_pth',fieldnames(custompth))
        proc_pth=custompth.proc_pth;
    end
    clear custompth;
end