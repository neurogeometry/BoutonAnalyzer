function [Im,Profile,Trace,inform,exitstatus] = gui_loaddata(loadim,loadprofile,loadtrace,callerfcn)
%This function loads the Image, Profile and Trace. The Dialogue box can be
%moved to a different function and animal, section etc. can be obtained
%from a different file for main dataset. This function will be used by
%all BoutonAnalyzer guis.

%Set default folders and options using history:
pathlist;
histfile=[tmp_pth,'loadopt.mat'];
if exist(histfile,'file')
    loaddat=load(histfile);
    if ~isfield(loaddat,callerfcn)
        loaddat.(callerfcn)=[];
    end
else
    loaddat.(callerfcn)=[];
end
%----------Begin Dialogue box----------------------------------------------
if strcmp(callerfcn,'gui_optimization')
    flds = {'Animal (specify only 1, e.g.: DL1)';...
        'Imaging Session (specify only 1, e.g.: A)';...
        'Image Stack (specify only 1, e.g.: S2)';...
        'Channel (specify up to 3, e.g. Gr, Re. Optimization will only be performed on the first';...
        'Axon (specify only 1, e.g.: A001)'
        };
    
    if isempty(loaddat.(callerfcn))
        defaults = {'DL1';...
            'A';...
            'S2';...
            'Gr';...
            'A001'};
    else
        defaults= {loaddat.(callerfcn).animal;...
            loaddat.(callerfcn).timepoint;...
            loaddat.(callerfcn).section;...
            loaddat.(callerfcn).channel;...
            loaddat.(callerfcn).axon};
    end
elseif strcmp(callerfcn,'gui_alignment')
    flds = {'Animal (specify only 1, e.g.: DL1)';...
        'Imaging Session (specify 1 or more, e.g.: A,B,C)';...
        'Image Stack (specify only 1, e.g.: S2)';...
        'Channel (specify up to 3, e.g.: Gr, Re. Boutons will only be detected based on the first';...
        'Axon (specify only 1, e.g.: A001)'
        };
    if isempty(loaddat.(callerfcn))
        defaults = {'DL1';...
            'A,B,C';...
            'S2';...
            'Gr';...
            'A001'};
    else
        defaults= {loaddat.(callerfcn).animal;...
            loaddat.(callerfcn).timepoint;...
            loaddat.(callerfcn).section;...
            loaddat.(callerfcn).channel;...
            loaddat.(callerfcn).axon};
    end
end
boxtitle = 'Select data';
numlines = [1,50];

Res = inputdlg(flds,boxtitle,numlines,defaults);
if isempty(Res)
    Res={[]};
end
if ~any(cellfun(@isempty,Res))
    exitstatus=1;
    animal=strsplit(Res{1},',');
    timepoint=strsplit(Res{2},',');
    section=strsplit(Res{3},',');
    channel=strsplit(Res{4},',');
    axon=strsplit(Res{5},',');
    
    %savedefaults
    loaddat.(callerfcn).animal=Res{1};
    loaddat.(callerfcn).timepoint=Res{2};
    loaddat.(callerfcn).section=Res{3};
    loaddat.(callerfcn).channel=Res{4};
    loaddat.(callerfcn).axon=Res{5};
    
    save(histfile,'-struct','loaddat');
    
    %Enforce restriction on how many objects of given type can be loaded---
    if strcmp(callerfcn,'gui_optimization')
        %1 animal, 1 timepoint, 1 section, multiple channels,1 axon
        if numel(animal)>1
            disp('Warning! More than one animal selected. Loading only the first.');
        end
        animal=animal(1);
        if numel(timepoint)>1
            disp('Warning! More than one timepoint selected. Loading only the first.');
        end
        timepoint=timepoint(1);
        if numel(section)>1
            disp('Warning! More than one section selected. Loading only the first.');
        end
        section=section(1);
        an=1;se=1;ti=1;
        
    elseif strcmp(callerfcn,'gui_alignment')
        %1 animal, multiple timepoints, 1 section,1 axon
        if numel(animal)>1
            disp('Warning! More than one animal selected. Loading only the first.');
        end
        animal=animal(1);
        if numel(section)>1
            disp('Warning! More than one section selected. Loading only the first.');
        end
        section=section(1);
        an=1;se=1;
    end
    %----------End Dialogue box%-------------------------------------------
    
    %----------Load image--------------------------------------------------
    
    if loadim
        for ch=1:numel(channel)
            II=[];
            
            im_id=[animal{an},timepoint{ti},section{se},channel{ch}];
            im_inpth=dir(im_pth);
            im_inpth={im_inpth(:).name}';
            im_inpth=im_inpth(~cellfun(@isempty,regexp(im_inpth,im_id,'once')));
            if numel(im_inpth)>1
                disp(['Warning -  More than one image file or folder with name ',im_id,'.']);
            end
            
            if ~isempty(im_inpth)
                im_inpth=im_inpth{1};
                [~,~,ext] = fileparts(im_inpth);
                if strcmp(ext,'.mat')
                    disp(['Loading image from ',[im_pth,im_inpth],'...'])
                    II=load([im_pth,im_inpth],'IM');
                    II=II.IM;
                else
                    if isdir([im_pth,im_inpth])
                        disp(['Loading image sequence from folder ',[im_pth,im_inpth],'...'])
                        temp=dir([im_pth,im_inpth,filesep,'*tif']);
                        im_list={temp.name};
                        for i=1:length(im_list)
                            im_list{i}=(im_list{i}(1:find(im_list{i}=='.')-1));
                        end
                        [~,ind]=sort(str2double(im_list));
                        im_list=im_list(ind);
                        for i=1:length(im_list)
                            im_list{i}=[im_list{i},'.tif'];
                        end
                        
                        [II,~,~]=ImportStackJ(isunixispc([im_pth,im_inpth,filesep]),im_list);
                    else
                        disp(['Loading image from ',[im_pth,im_inpth],'...'])
                        [II,~,~]=ImportStackJ(im_pth,{im_inpth});
                    end
                end
            elseif numel(im_inpth)==0
                disp(['Searching for image file or directory ',im_pth,im_id,'...'])
                disp('Image not found!');
                exitstatus=0;
            end
            if ~isempty(II)
                disp('Image loaded.');
                II=double(II);
            end
            Im.(channel{ch})=II;
            clear II;
        end
    else
        Im=[];
    end
    
    %----------Load profile if present-------------------------------------
    
    if loadprofile
        Profile=cell(numel(axon),numel(timepoint));
        for ti=1:numel(timepoint)
            for ax=1:numel(axon)
                profile_id=axon{ax};
                stack_id=[animal{an},timepoint{ti},section{se}];
                fname=isunixispc([profile_pth,stack_id,filesep,profile_id,'.mat']);
                if exist(fname,'file')
                    disp(['Loading profile from ',fname,'...'])
                    Profile{ax,ti}=load(fname);
                    disp('Profile loaded.')
                    exitstatus=exitstatus & any(strcmp(fieldnames(Profile{ax,ti}.fit),channel{1}));
                    if ~any(strcmp(fieldnames(Profile{ax,ti}.fit),channel{1}))
                        disp(['Selected channel: ',channel{1},' not available in ', fname])
                    end
                else
                    disp(['Searching for profile ',fname,'...'])
                    disp('Profile not found!');
                    exitstatus=0;
                    if strcmp(callerfcn,'gui_optimization')
                        exitstatus=1;
                    end
                end
            end
        end
    else
        Profile=[];
    end
    
    %----------Load manual trace .swc file---------------------------------
    
    if loadtrace
        Trace=cell(numel(axon),numel(timepoint));
        for ti=1:numel(timepoint)
            for ax=1:numel(axon)
                trace_id=axon{ax};
                stack_id=[animal{an},timepoint{ti},section{se}];
                fname=isunixispc([man_pth,stack_id,filesep,trace_id,'.swc']);
                if exist(fname,'file')
                    disp(['Loading manual trace from ',fname,'...']);
                    [AM1,r1,~]=swc2AM(fname);
                    Trace{ax}.AM=AM1;
                    Trace{ax}.r=r1;
                    Trace{ax}.R=zeros(size(r1,1),1);
                    disp('Manual trace loaded.');
                else
                    disp(['Searching for manual trace from ',fname,'...']);
                    disp('Manual trace file not found!');
                    exitstatus=0;
                end
            end
        end
    else
        Trace=[];
    end
    
    inform.animal=animal;
    inform.timepoint=timepoint;
    inform.section=section;
    inform.channel=channel;
    inform.axon=axon;
    
else
    exitstatus=0;
end

if exitstatus==0
    Im=[];
    Profile=[];
    Trace=[];
    inform=[];
end
end