function BoutonAnalyzer()

temp=get(0);
fi.H=400;
fi.W=600;
fi.L=temp.ScreenSize(3)/2-fi.W/2;
fi.B=temp.ScreenSize(4)/2-fi.H/2;

hf=figure;
hf.Position=[fi.L,fi.B,fi.W,fi.H];
hf.MenuBar='none';
hf.NumberTitle='off';
hf.Name='Bouton Analyzer';

workingdir=pwd;
cbfcn=['open(''',workingdir,filesep,'User Manual.pdf'')'];
hfmenu=uimenu('Label','Help','Parent',hf);
uimenu(hfmenu,'Label','User Manual','Callback',cbfcn);
uimenu(hfmenu,'Label','Website','Callback','web(''http://www.northeastern.edu/neurogeometry/resources/bouton-analyzer/'')');

ha=axes('Parent',hf);
%Initialize axis
ha.Units='Normalized';ha.Position=[0 0.65 1 0.3];
ha.Color=[0.94 0.94 0.94];box(ha,'off');
ha.NextPlot='add';
%Plot projection
[im,~,alpha] = imread('Icon.png');
f=imshow(im,'Parent',ha);
set(f,'AlphaData',alpha);
axis(ha,'off');

pathlist;
h_viewpanel=uipanel('Parent',hf);h_viewpanel.Tag='Paths';
h_viewpanel.Units='pixels';h_viewpanel.Position=[10 100 580 160];
h_viewpanel.Title='Paths';

hf.UserData.Im=im_pth;
hf.UserData.Trace=man_pth;
hf.UserData.Profile=profile_pth;
hf.UserData.Results=proc_pth;

%Images--------------------------------------------------------------------
uicontrol('Style', 'text','Parent',h_viewpanel,...
    'Units','normalized','Position', [0.02 0.7 0.15 0.15],...
    'String','Images: ');

him=uicontrol('Style','edit','Parent',h_viewpanel,'Tag','Impthtxt',...
    'Units','normalized','Position',[0.20 0.7 0.6 0.15],...
    'String',hf.UserData.Im,'Callback',@chkpth,'Enable','on');

uicontrol('Style','pushbutton','Parent',h_viewpanel,'Tag','Impthbtn',...
    'Units','normalized','Position',[0.82 0.7 0.1 0.15],...
    'String','Choose',...
    'Callback',{@setpth,him});

%Traces--------------------------------------------------------------------
uicontrol('Style', 'text','Parent',h_viewpanel,...
    'Units','normalized','Position', [0.02 0.5 0.15 0.15],...
    'String','Traces: ');

htr=uicontrol('Style','edit','Parent',h_viewpanel,'Tag','Tracepthtxt',...
    'Units','normalized','Position',[0.20 0.5 0.6 0.15],...
    'String',hf.UserData.Trace,'Callback',@chkpth,'Enable','on');

uicontrol('Style','pushbutton','Parent',h_viewpanel,'Tag','Tracepthbtn',...
    'Units','normalized','Position',[0.82 0.5 0.1 0.15],...
    'String','Choose',...
    'Callback',{@setpth,htr});

%Profiles------------------------------------------------------------------
uicontrol('Style','text','Parent',h_viewpanel,...
    'Units','normalized','Position', [0.02 0.3 0.15 0.15],...
    'String','Profiles: ');

hpr=uicontrol('Style','edit','Parent',h_viewpanel,'Tag','Profilepthtxt',...
    'Units','normalized','Position',[0.20 0.3 0.6 0.15],...
    'String',hf.UserData.Profile,'Callback',@chkpth,'Enable','on');

uicontrol('Style','pushbutton','Parent',h_viewpanel,'Tag','Profilepthbtn',...
    'Units','normalized','Position',[0.82 0.3 0.1 0.15],...
    'String','Choose',...
    'Callback',{@setpth,hpr});

%Proc------------------------------------------------------------------
uicontrol('Style','text','Parent',h_viewpanel,...
    'Units','normalized','Position', [0.02 0.1 0.15 0.15],...
    'String','Results: ');

hprc=uicontrol('Style','edit','Parent',h_viewpanel,'Tag','Procpthtxt',...
    'Units','normalized','Position',[0.20 0.1 0.6 0.15],...
    'String',hf.UserData.Results,'Callback',@chkpth,'Enable','on');

uicontrol('Style','pushbutton','Parent',h_viewpanel,'Tag','Procpthbtn',...
    'Units','normalized','Position',[0.82 0.1 0.1 0.15],...
    'String','Choose',...
    'Callback',{@setpth,hprc});


%Launch GUi panel----------------------------------------------------------
h_viewpanel=uipanel('Parent',hf);h_viewpanel.Tag='Launch';
h_viewpanel.Units='pixels';h_viewpanel.Position=[10 10 580 80];
h_viewpanel.Title='Launch GUI';

uicontrol('Style','pushbutton','Parent',h_viewpanel,'Tag','Tracepthbtn',...
    'Units','normalized','Position',[0.30 0.55 0.4 0.4],...
    'String','Optimize Trace & Generate Profile',...
    'Callback',{@launchgui,1});

uicontrol('Style','pushbutton','Parent',h_viewpanel,'Tag','Tracepthbtn',...
    'Units','normalized','Position',[0.30 0.1 0.4 0.4],...
    'String','Detect & Track Boutons',...
    'Callback',{@launchgui,2});
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

function []=setpth(src,~,h)
histfile=[pwd,filesep,'tmp',filesep,'paths.mat'];
maindir=fileparts(pwd);
temp=uigetdir(maindir);
if temp %uigetdir returns 0 when cancelled
    h.String=[temp,filesep];%Update the text field
    if exist(histfile,'file')
        custompth=load(histfile);
    end
end
ht=findobj(src.Parent,'Tag','Impthtxt');
custompth.im_pth=ht.String;
ht=findobj(src.Parent,'Tag','Tracepthtxt');
custompth.man_pth=ht.String;
ht=findobj(src.Parent,'Tag','Profilepthtxt');
custompth.profile_pth=ht.String;
ht=findobj(src.Parent,'Tag','Procpthtxt');
custompth.proc_pth=ht.String;
save(histfile,'-struct','custompth');
end

function []=launchgui(~,~,h)
if h==1
    gui_optimization(gcbf);
elseif h==2
    gui_alignment(gcbf);
end
end

function []=chkpth(src,~)
histfile=[pwd,filesep,'tmp',filesep,'paths.mat'];
if exist(src.String,'dir')
    if ~strcmp(src.String(end),filesep)
        src.String=[src.String,filesep];
    end
    if exist(histfile,'file')
        custompth=load(histfile);
    end
    disp(['Path set: ',src.String]);
    ht=findobj(src.Parent,'Tag','Impthtxt');
    custompth.im_pth=ht.String;
    ht=findobj(src.Parent,'Tag','Tracepthtxt');
    custompth.man_pth=ht.String;
    ht=findobj(src.Parent,'Tag','Profilepthtxt');
    custompth.profile_pth=ht.String;
    ht=findobj(src.Parent,'Tag','Procpthtxt');
    custompth.proc_pth=ht.String;
    save(histfile,'-struct','custompth');
else
    disp('Directory does not exist.');
    pathlist;
    switch src.Tag
        case 'Impthtxt'
            src.String=im_pth;
        case 'Tracepthtxt'
            src.String=man_pth;
        case 'Profilepthtxt'
            src.String=profile_pth;
        case 'Procpthtxt'
            src.String=proc_pth;
    end
end
end