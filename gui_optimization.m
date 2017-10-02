function gui_optimization(src)
close(src);
%This section has sizes derived from screen resolution---------------------
temp=get(0);
fi.H=max([700,temp.ScreenSize(4)*0.8]);
fi.W=max([875,fi.H*5/4]);
fi.L=(fi.W.*0.1);
fi.B=(fi.H.*0.1);
%--------------------------------------------------------------------------
hf=figure;clf(hf);hf.Visible='off';
hf.Name='BoutonAnalyzer: Optimize Trace & Generate Profile';hf.NumberTitle='off';
hf.Position=[fi.L,fi.B,fi.W,fi.H];
set(hf,'KeyPressFcn',@hotkeys);
set(hf,'WindowScrollWheelFcn',@scroll2zoom);

customizeMenus(hf);
[hf.UserData.Im,Profile,Trace,hf.UserData.inform,exitstat]=gui_loaddata(1,1,1,'gui_optimization');
if exitstat==1
    %All channels are assumed to have same dimensions, Trace and Profile are
    %cells;
    hf.UserData.Profile=Profile{1};
    hf.CloseRequestFcn=@closereq;
    
    %Order trace for faster plotting:
    startt=find(sum(Trace{1}.AM,1)==1);startt=startt(1);
    [Trace{1}.AM,Trace{1}.r,~] = orderprofile(Trace{1}.AM,Trace{1}.r,false(size(Trace{1}.r,1),1),startt);
    hf.UserData.Trace=Trace{1};
    clear Profile Trace;
    
    %Initialize profile if no trace in profile
    channel=hf.UserData.inform.channel;
    if ~isfield(hf.UserData.Profile,'AM')
        hf.UserData.Profile.AM.optim=[];
        hf.UserData.Profile.r.optim=[];
        hf.UserData.Profile.annotate.ignore=[];
        for ch=1:numel(channel)
            hf.UserData.Profile.proj.(channel{ch}).xy.full=max(permute(hf.UserData.Im.(channel{ch}),[1,2,3]),[],3);
            hf.UserData.Profile.proj.(channel{ch}).zy.full=max(permute(hf.UserData.Im.(channel{ch}),[3,2,1]),[],3);
            hf.UserData.Profile.proj.(channel{ch}).xz.full=max(permute(hf.UserData.Im.(channel{ch}),[1,3,2]),[],3);
            
            hf.UserData.Profile.proj.(channel{ch}).xy.ax=[];
            hf.UserData.Profile.proj.(channel{ch}).zy.ax=[];
            hf.UserData.Profile.proj.(channel{ch}).xz.ax=[];
        end
        hf.UserData.Opt.r=hf.UserData.Trace.r;
        hf.UserData.Opt.AM=hf.UserData.Trace.AM;
        hf.UserData.Opt.R=hf.UserData.Trace.R;
    else
        hf.UserData.Opt.r=hf.UserData.Profile.r.optim;
        hf.UserData.Opt.AM=hf.UserData.Profile.AM.optim;
        hf.UserData.Opt.R=zeros(size(hf.UserData.Profile.r.optim,1),1);
    end
    
    %Generate projections
    genproj(hf);
    gui_optimization_layout;
    
    %Initialize axis
    ha_xy=axes;ha_xy.Tag='ha_xy';ha_xy.Parent=hf;
    ha_xy.Units='pixels';ha_xy.Position=[panel_l+panel_w+buff.h+(1/3)*xyaxis_w+buff.h, buff.h, xyaxis_w, xyaxis_w];
    ha_xy.YLabel.String='X axis, [pixels]';ha_xy.XLabel.String='Y axis, [pixels]';
    ha_xy.XLim=[0 900];ha_xy.YLim=[0 900];
    ha_xy.Color=[0.4 0.4 0.4];box(ha_xy,'on');
    ha_xy.NextPlot='add';
    %Plot projection
    hi_xy=imshow(hf.UserData.Profile.proj.(channel{1}).xy.full,[],'Parent',ha_xy);hold on;
    ha_xy.CLim=[0,mean(hf.UserData.Profile.proj.(channel{1}).xy.full(:))+5*std(hf.UserData.Profile.proj.(channel{1}).xy.full(:))];
    hi_xy.Tag='hi_xy_full';
    axis(ha_xy,'on');
    
    %Initialize axis
    ha_zy=axes;ha_zy.Tag='ha_zy';ha_zy.Parent=hf;
    ha_zy.Units='pixels';ha_zy.Position=[panel_l+panel_w+buff.h+(1/3)*xyaxis_w+buff.h,xyaxis_w+2*buff.h,xyaxis_w,(1/3)*xyaxis_w];
    ha_zy.YLabel.String='Z axis, [pixels]';ha_zy.XLabel.String='Y axis, [pixels]';
    ha_zy.XLim=[0 900];ha_zy.YLim=[0 300];
    ha_zy.Color=[0.4 0.4 0.4];box(ha_zy,'on');
    ha_zy.NextPlot='add';
    %Plot projection
    hi_zy=imshow(hf.UserData.Profile.proj.(channel{1}).zy.full,[],'Parent',ha_zy);hold on;
    ha_zy.CLim=ha_xy.CLim;
    hi_zy.Tag='hi_zy_full';
    axis(ha_zy,'on');
    
    %Initialize axis
    ha_xz=axes;
    ha_xz.Tag='ha_xz';ha_xz.Parent=hf;
    ha_xz.Units='pixels';ha_xz.Position=[panel_l+panel_w+buff.h, buff.h, (1/3)*xyaxis_w, xyaxis_w];
    ha_xz.XLabel.String='Z axis, [pixels]';ha_xz.YLabel.String='X axis, [pixels]';
    ha_xz.XLim=[0 300];ha_xz.YLim=[0 900];
    ha_xz.Color=[0.4 0.4 0.4];box(ha_xz,'on');
    ha_xz.NextPlot='add';
    %Plot projection
    hi_xz=imshow(hf.UserData.Profile.proj.(channel{1}).xz.full,[],'Parent',ha_xz);hold on;
    hi_xz.Tag='hi_xz_full';
    ha_xz.CLim=ha_xy.CLim;
    axis(ha_xz,'on');
    
    %Initialize view panel-------------------------------------------------
    hv=uipanel('Parent',hf);
    hv.Units='pixels';hv.Position=[panel_l, buff.h, panel_w, viewpanel_h];
    hv.Title='View Options';
    hv.Tag='ViewControl';
        
    %Intensity range setting
    uicontrol('Style', 'text','Parent',hv,...
        'Units','pixels','Position', [stdbuff_w, view_intrange_b+txtbx_h+minbuff_h, element_w, txt_h],...
        'String','Intensity range','Tag','IntensityRange');
    
    uicontrol('Style','edit','Parent',hv,'Tag','IntensityRangeBox',...
        'Units','pixels','Position',[stdbuff_w, view_intrange_b, element_w, txtbx_h],...
        'Callback',@setintensityrange,...
        'String',sprintf('%0.0f,%0.0f',ha_xz.CLim(1),ha_xz.CLim(2)),...
        'ToolTipString','e.g. 0, 500');
    

    %Toggle channel    
    sel_ch = uibuttongroup('Tag','Channels','Parent',hv,...
        'Units','pixels','Position',[0, view_chnrb_b, panel_w, view_chnrb_h],...
        'SelectionChangedFcn',@drawim,...
        'Title','Channel','BorderType','none');
    
    nbtn=3;
    for n=1:nbtn
        ch_rb=uicontrol('Style','radiobutton','Parent',sel_ch);
        ch_rb.Units='pixels';ch_rb.Position=[stdbuff_w,(nbtn-n)*(rbtn_h+minbuff_h)+minbuff_h, element_w, rbtn_h];
        if n<=numel(channel)
            ch_rb.String=channel{n};
        else
            ch_rb.String='-NA-';
            ch_rb.Enable='off';
        end
    end
    sel_ch.SelectedObject=findobj(sel_ch,'String',channel{1});
    
    %Toggle trace
    sel_tr = uibuttongroup('Title','Trace','Tag','Trace','Parent',hv,...
        'Units','pixels','Position',[0, view_tracerb_b, panel_w, view_tracerb_h],...
        'SelectionChangedFcn',{@drawtrace,hf},'BorderType','none');
    nbtn=3;
    txtlist={'None','Initial','Optimized'};
    if isempty(hf.UserData.Profile.AM.optim)
        choice.NewValue.String='Initial';
    else
        choice.NewValue.String='Optimized';
    end
    for n=1:nbtn
        tr_rb=uicontrol('Style','radiobutton','Parent',sel_tr);
        tr_rb.Units='pixels';tr_rb.Position=[stdbuff_w,(nbtn-n)*(rbtn_h+minbuff_h)+minbuff_h, element_w, rbtn_h];
        tr_rb.String=txtlist{n};
        if strcmp(txtlist{n},'Optimized') && isempty(hf.UserData.Profile.AM.optim)
            tr_rb.Enable='off';
        end
        tr_rb.HandleVisibility='on';
    end
    sel_tr.SelectedObject=findobj(sel_tr,'String',choice.NewValue.String);
    drawtrace([],choice,hf);
    
    %Toggle tube
    sel_tube = uibuttongroup('Title','Projection','Tag','Projection','Parent',hv,...
        'Units','pixels','Position',[0, view_tuberb_b, panel_w, view_tuberb_h],...
        'SelectionChangedFcn',@drawim,'BorderType','none');
    nbtn=2;
    txtlist={'Full','Tube'};
    for n=1:nbtn
        tube_rb=uicontrol('Style','radiobutton','Parent',sel_tube);
        tube_rb.Units='pixels';tube_rb.Position=[stdbuff_w,(nbtn-n)*(rbtn_h+minbuff_h)+minbuff_h, element_w, rbtn_h];
        tube_rb.String=txtlist{n};
    end
    sel_tube.SelectedObject=findobj(sel_tube,'String','Full');
    
    %Operation panel-------------------------------------------------------
    hopt=uipanel('Parent',hf,'Tag','OptControl',...
    'Units','pixels','Position',[panel_l,operationpanel_b,panel_w,operationpanel_h],...
    'Title','','BorderType','none');
    
    
    %Optimize push buttons
    uicontrol('Style', 'pushbutton','Tag','IsOptPresent','Parent',hopt,...
        'Units','pixels','Position',[stdbuff_w,  stdbuff_h+2*(pushbutton_h+minbuff_h), element_w, pushbutton_h],...
        'String','Optimize Trace','Callback',@optim);
    
    uicontrol('Style', 'pushbutton','Tag','SaveProfile','Parent',hopt,...
        'Units','pixels','Position',[stdbuff_w, stdbuff_h+pushbutton_h+minbuff_h, element_w, pushbutton_h],...
        'String', 'Generate Profile & Save','Callback',@saveprofile,'Enable','on');
    
    uicontrol('Style', 'pushbutton','Tag','NewAxon','Parent',hopt,...
        'Units','pixels','Position',[stdbuff_w, stdbuff_h, element_w, pushbutton_h],...
        'String', 'Load Next','Callback',@loadnew,'Enable','on');
    
    hf.Visible='on';
else
    disp('Data files could not be loaded. Exiting GUI.')
end
end


%-----------------------Functions------------------------------------------
%--------------------------------------------------------------------------

%-----------------------Create projections---------------------------------
function genproj(hf)
UserData=hf.UserData;
channel=fieldnames(UserData.Im);
sizeIm=size(UserData.Im.(channel{1}));%Size of all channels is the same.

pad=20;
minr=min(UserData.Opt.r,[],1);
maxr=max(UserData.Opt.r,[],1);
minx=round(max(minr(1)-pad,1));maxx=round(min(maxr(1)+pad,sizeIm(1)));
miny=round(max(minr(2)-pad,1));maxy=round(min(maxr(2)+pad,sizeIm(2)));
minz=round(max(minr(3)-pad,1));maxz=round(min(maxr(3)+pad,sizeIm(3)));

[~,SVr,~]=AdjustPPM(UserData.Opt.AM,UserData.Opt.r,UserData.Opt.R,1);
disp('Updating projections...');

%Perform fast marching on restricted volume:
paramset;%Parameters for FastMarching
[KT]=FastMarchingTube([maxx-minx+1,maxy-miny+1,maxz-minz+1],[SVr(:,1)-minx+1,SVr(:,2)-miny+1,SVr(:,3)-minz+1],params.proj.fm_dist,[1 1 1]);
Filter=false(sizeIm);
Filter(minx:maxx,miny:maxy,minz:maxz)=KT;

for ch=1:numel(fieldnames(UserData.Im))
    Im_ax=zeros(size(UserData.Im.(channel{ch})));
    Im_ax(Filter)=UserData.Im.(channel{ch})(Filter);
    UserData.Profile.proj.(channel{ch}).xy.ax=squeeze(max(Im_ax,[],3));
    UserData.Profile.proj.(channel{ch}).zy.ax=squeeze(max(Im_ax,[],1))';
    UserData.Profile.proj.(channel{ch}).xz.ax=squeeze(max(Im_ax,[],2));
end
hf.UserData=[];
hf.UserData=UserData;
disp('Projections updated.');
end

%-----------------------Update traces--------------------------------------
function drawtrace(~,ed,hf)
ht=findobj(hf,'-depth',3,'-regexp','Tag','(ht)*');
ha_xy=findobj(hf,'-depth',2,'Tag','ha_xy');
ha_zy=findobj(hf,'-depth',2,'Tag','ha_zy');
ha_xz=findobj(hf,'-depth',2,'Tag','ha_xz');

if ~isempty(ht)
    delete(ht);
end

switch ed.NewValue.String
    case 'None'
        %Do nothing
    case 'Initial'
        plot(hf.UserData.Trace.r(:,2),hf.UserData.Trace.r(:,1),'-','Color',[0.8 0 0],'Parent',ha_xy,'Tag','ht_xy_Manual');
        plot(hf.UserData.Trace.r(:,2),hf.UserData.Trace.r(:,3),'-','Color',[0.8 0 0],'Parent',ha_zy,'Tag','ht_zy_Manual');
        plot(hf.UserData.Trace.r(:,3),hf.UserData.Trace.r(:,1),'-','Color',[0.8 0 0],'Parent',ha_xz,'Tag','ht_xz_Manual');
        
    case 'Optimized'
        if ~isempty(hf.UserData.Profile.AM.optim)
            plot(hf.UserData.Profile.r.optim(:,2),hf.UserData.Profile.r.optim(:,1),'-','Color',[0.1 0.7 0],'Parent',ha_xy,'Tag','ht_xy_Optimized');
            plot(hf.UserData.Profile.r.optim(:,2),hf.UserData.Profile.r.optim(:,3),'-','Color',[0.1 0.7 0],'Parent',ha_zy,'Tag','ht_zy_Optimized');
            plot(hf.UserData.Profile.r.optim(:,3),hf.UserData.Profile.r.optim(:,1),'-','Color',[0.1 0.7 0],'Parent',ha_xz,'Tag','ht_xz_Optimized');
        else
            disp('No optimized trace present!')
        end
end
end

%---------------Update projection on all plots-----------------------------
function drawim(~,~)
%drawim is called by two buttons, and within optimization code. Hence gcbf
%always returns the correct figure
hf=gcbf;

h_dispcontrol=findobj(hf,'-depth',2,'Tag','ViewControl');

h_ch=findobj(h_dispcontrol,'-depth',2,'Tag','Projection');
if strcmp(h_ch.SelectedObject.String,'Full')
    projtype='full';
elseif strcmp(h_ch.SelectedObject.String,'Tube')
    projtype='ax';
end

h_ch=findobj(h_dispcontrol,'-depth',2,'Tag','Channels');
channel=h_ch.SelectedObject.String;

hi_xy=findobj(hf, '-depth',2,'-regexp','Tag','(hi_xy)*');
hi_zy=findobj(hf, '-depth',2,'-regexp','Tag','(hi_zy)*');
hi_xz=findobj(hf, '-depth',2,'-regexp','Tag','(hi_xz)*');

hi_xy.CData=hf.UserData.Profile.proj.(channel).xy.(projtype);
hi_zy.CData=hf.UserData.Profile.proj.(channel).zy.(projtype);
hi_xz.CData=hf.UserData.Profile.proj.(channel).xz.(projtype);
end

%-----------------------Perform optimization-------------------------------
function optim(varargin)
hf=gcbf;
h_msg=msgbox('Please wait until optimization is completed. This may take a minute...','Trace Optimization');
UserData=hf.UserData;
%hf.UserData=[];
channel=UserData.inform.channel{1};
paramset;

[UserData.Profile.AM.optim,UserData.Profile.r.optim,~,~]=...
    Optimize_Trace(UserData.Im.(channel),UserData.Trace.AM,UserData.Trace.r,...
    params.opt.Rtypical,params.opt.Optimize_bps,params.opt.Optimize_tps,params.opt.pointspervoxel,params.opt.MaxIterations, ...
    params.opt.alpha_r,params.opt.betta_r,params.opt.isadjustpointdensity,params.opt.output);
close(h_msg);
%Subdividing trace
[UserData.Profile.AM.optim,UserData.Profile.r.optim,~]=...
    AdjustPPM(UserData.Profile.AM.optim,UserData.Profile.r.optim,zeros(size(UserData.Profile.r.optim,1),1),params.profile.pointspervoxel);

%Order trace for faster plotting:
startt=find(sum(UserData.Profile.AM.optim,1)==1);startt=startt(1);
[UserData.Profile.AM.optim,UserData.Profile.r.optim,~] = orderprofile(UserData.Profile.AM.optim,UserData.Profile.r.optim,false(size(UserData.Profile.r.optim,1),1),startt);

%Replace the trace with which tube is calculated
UserData.Opt.r=UserData.Profile.r.optim;
UserData.Opt.AM=UserData.Profile.AM.optim;
UserData.Opt.R=zeros(size(UserData.Profile.r.optim,1),1);

hf.UserData=[];
hf.UserData=UserData;

h_tr=findobj(hf,'-depth',2,'Tag','ViewControl');
h_tr=findobj(h_tr,'String','Optimized');
h_tr.Enable='on';

%Switch displayed trace to optimized trace
sel_tr=h_tr.Parent;
sel_tr.SelectedObject=h_tr;
choice.NewValue.String=h_tr.String;
drawtrace([],choice,hf);

%Generate new projections
genproj(hf);

%Update projections and refresh trace
disp('Updating plots...');
drawim([],[]);

%Refresh trace
h_tr=findobj(hf,'-depth',2,'Tag','ViewControl');
h_tr=findobj(h_tr,'Tag','Trace');
choice.NewValue.String=h_tr.SelectedObject.String;
drawtrace([],choice,hf);
disp('Updating plots completed.');

end

%-----------------------Update contrast on all axes------------------------
function setintensityrange(~,~,~)
hf=gcbf;
ha_xy=findobj(hf,'-depth',2,'Tag','ha_xy');
ha_zy=findobj(hf,'-depth',2,'Tag','ha_zy');
ha_xz=findobj(hf,'-depth',2,'Tag','ha_xz');

hv=findobj(hf.Children,'flat','Tag','ViewControl');
hir=findobj(hv.Children,'Tag','IntensityRangeBox');

change=false;
Cval=regexp(hir.String,',','split');
if numel(Cval)==2
    CVal=[str2double(Cval{1}),str2double(Cval{2})];
    if ~any(isnan(CVal))
        ha_xy.CLim=CVal;
        ha_zy.CLim=CVal;
        ha_xz.CLim=CVal;
        change=true;
    end
end

if ~change
    CVal=ha_xy.CLim;
    hir.String=[num2str(CVal(1)),' , ',num2str(CVal(2))];
    disp('Intensity range must be specified as comma separated numbers.')
end
end

%-----------------------Generating profile---------------------------------
function genprofile(varargin)
hf=gcbf;
an=1;se=1;
ax=1;ti=1;
pathlist;

Profile=hf.UserData.Profile;
paramset;

if isempty(Profile.r.optim)
    disp('Warning: Trace is not optimized. Profile generated using loaded trace.')
    Profile.AM.optim=hf.UserData.Trace.AM;
    Profile.r.optim=hf.UserData.Trace.r;
    %Subdividing trace
    [Profile.AM.optim,Profile.r.optim,~]=...
        AdjustPPM(Profile.AM.optim,Profile.r.optim,zeros(size(Profile.r.optim,1),1),params.profile.pointspervoxel);
end
%Re-order AM and r
Profile.annotate.ignore=false(size(Profile.r.optim,1),1);
startt=find(sum(Profile.AM.optim,1)==1);
startt=startt(1);
[Profile.AM.optim,Profile.r.optim,Profile.annotate.ignore]=...
    orderprofile(Profile.AM.optim,Profile.r.optim,Profile.annotate.ignore,startt);

%Calculating path distance and filter intensity
[Profile.d.optim]=vx2um(Profile.r.optim);
Profile.d.aligned=Profile.d.optim;
Profile.d.alignedxy=px2um(Profile.r.optim);
channel=hf.UserData.inform.channel;
for ch=1:numel(channel)
    for fi=1:numel(params.filt.types)
        [temp.I,temp.R]=profilefilters(Profile.r.optim,hf.UserData.Im.(channel{ch}),params.filt.types{fi},params);
        Profile.I.(channel{ch}).(params.filt.types{fi}).raw=temp.I;
        Profile.I.(channel{ch}).(params.filt.types{fi}).caliber=temp.R;
        Profile.I.(channel{ch}).(params.filt.types{fi}).norm=temp.I./mean(temp.I(~Profile.annotate.ignore));
        disp([params.filt.types{fi},' profile generated for ',channel{ch},' Channel.']);
    end
end

%Create fit and id fields
for ch=1:numel(channel)
    Profile.fit.(channel{ch})=struct();
end

stack_id=[hf.UserData.inform.animal{an},hf.UserData.inform.timepoint{ti},hf.UserData.inform.section{se}];
Profile.id=[stack_id,'-',hf.UserData.inform.axon{ax}];
Profile=orderfields(Profile,{'AM','r','d','I','annotate','fit','proj','id'});
hf.UserData.Profile=Profile;
end
%-----------------------Saving profile-------------------------------------
function saveprofile(varargin)
hf=gcbf;
an=1;se=1;
ax=1;ti=1;
pathlist;

genprofile();
Profile=hf.UserData.Profile;
if ~isempty(Profile)
    profile_id=hf.UserData.inform.axon{ax};
    stack_id=[hf.UserData.inform.animal{an},hf.UserData.inform.timepoint{ti},hf.UserData.inform.section{se}];
    fname=isunixispc([profile_pth,stack_id,filesep,profile_id,'.mat']);
    
    %Check directory
    if ~exist(isunixispc([profile_pth,stack_id]),'dir')
        mkdir(isunixispc(profile_pth),stack_id);
        display(['Creating directory: ', isunixispc([profile_pth,stack_id])]);
    end
    save(fname,'-struct','Profile');
    disp(['Saved profile in ',fname]);
else
    disp('No profile found. Generate profile before saving.');
end
end

%-----------------------Shortcuts profile----------------------------------
function hotkeys(src,ed)
%All the keyboard shortcuts are defined here
hf=src;
h_axis=gca;
panfact=0.03;
if strcmp(ed.Key,'uparrow')%up
    h_axis.YLim=h_axis.YLim-cosd(h_axis.View(1))*diff(h_axis.XLim)*panfact;
    h_axis.XLim=h_axis.XLim-sind(h_axis.View(1))*diff(h_axis.YLim)*panfact;
    
elseif strcmp(ed.Key,'downarrow')%down
    h_axis.YLim=h_axis.YLim+cosd(h_axis.View(1))*diff(h_axis.XLim)*panfact;
    h_axis.XLim=h_axis.XLim+sind(h_axis.View(1))*diff(h_axis.YLim)*panfact;
    
elseif strcmp(ed.Key,'leftarrow')%left
    h_axis.XLim=h_axis.XLim-cosd(h_axis.View(1))*diff(h_axis.XLim)*panfact;
    h_axis.YLim=h_axis.YLim+sind(h_axis.View(1))*diff(h_axis.YLim)*panfact;
    
elseif strcmp(ed.Key,'rightarrow')%right
    h_axis.XLim=h_axis.XLim+cosd(h_axis.View(1))*diff(h_axis.XLim)*panfact;
    h_axis.YLim=h_axis.YLim-sind(h_axis.View(1))*diff(h_axis.YLim)*panfact;
    
elseif strcmp(ed.Key,'equal')
    hv=findobj(hf.Children,'flat','Tag','ViewControl');
    hir=findobj(hv.Children,'Tag','IntensityRangeBox');
    CVal=h_axis.CLim;
    CVal(2)=CVal(2)*0.9;
    hir.String=[num2str(CVal(1)),' , ',num2str(CVal(2))];
    setintensityrange([],[],[]);
    
elseif strcmp(ed.Key,'hyphen')
    hv=findobj(hf.Children,'flat','Tag','ViewControl');
    hir=findobj(hv.Children,'Tag','IntensityRangeBox');
    CVal=h_axis.CLim;
    CVal(2)=CVal(2)*1.1;
    hir.String=[num2str(CVal(1)),' , ',num2str(CVal(2))];
    setintensityrange([],[],[]);
    
elseif strcmp(ed.Key,'z')
    %Activates zoom with a context menu to disable zoom mode
    switch2zoom([],[],hf);
    
elseif strcmp(ed.Key,'x')
    %Activates pan with a context menu to disable pan mode
    switch2pan([],[],hf);
end
end

function scroll2zoom(~,ed)
%Callback for zooming in and out using scroll
%h_axis=findobj(src.Children,'flat','Tag','Axis');
gca;
if ed.VerticalScrollCount<0
    zoom(1.2);
else
    zoom(1/1.2);
end
end

function closereq(~,~)
% Close request function
% to display a question dialog box
selection = questdlg('All unsaved changes will be lost. Continue?',...
    'Warning',...
    'Yes','No','No');
switch selection
    case 'Yes'
        delete(gcbf)
    case 'No'
        return
end
end

function loadnew(~,~)
hf=gcbf;
close(hf);
if ~isvalid(hf)
    gui_optimization([]);
else
    disp('Current axon was retained. Load new axon operation terminated.')
end
end

function switch2zoom(~,~,hf)
    hCMZ = uicontextmenu;
    uimenu('Parent',hCMZ,'Label','Switch to pan mode',...
        'Callback',{@switch2pan,hf});
    uimenu('Parent',hCMZ,'Label','Exit zoom mode',...
        'Callback','zoom(gcbf,''off'')');
    hZoom = zoom(hf);
    hZoom.UIContextMenu = hCMZ;
    zoom('on');
end

function switch2pan(~,~,hf)
    hPanMZ = uicontextmenu;
    uimenu('Parent',hPanMZ,'Label','Switch to zoom mode',...
        'Callback',{@switch2zoom,hf});
    uimenu('Parent',hPanMZ,'Label','Exit pan mode',...
        'Callback','pan(gcbf,''off'')');
    hPan = pan(hf);
    hPan.UIContextMenu = hPanMZ;
    pan('on');
end
