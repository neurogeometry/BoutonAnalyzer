function gui_alignment(src)
%Function allows
%1. view projections of all traces simultaneously and align traces
%2. annotate traces to exclude cross-overs etc
%3. editing and matching of peaks (putative boutons)
close(src);
temp=get(0);
fi.H=max([700,temp.ScreenSize(4)*0.8]);
fi.W=max([875,fi.H*5/4]);
fi.L=(fi.W.*0.1);
fi.B=(fi.H.*0.1);

hf=figure('Visible','off');clf(hf);
hf.Name='BoutonAnalyzer: Detection & Tracking';hf.NumberTitle='off';hf.Tag='Main';
hf.Position=[fi.L,fi.B,fi.W,fi.H];
set(hf,'KeyPressFcn',@hotkeys);
set(hf,'WindowScrollWheelFcn',@scroll2zoom);
customizeMenus(hf);

%Set data
[~,Profile,~,inform,exitstatus] = gui_loaddata(0,1,0,'gui_alignment');
if exitstatus==1
    set(hf,'CloseRequestFcn',@closereqf)
    hf.UserData.profilefig=figure('Visible','off');
    set(hf,'DeleteFcn',{@closeProfileFig,hf});
    hf.UserData.Profile=Profile;clear Profile;
    hf.UserData.inform=inform;
    
    %Set GUI related parameters
    hf.UserData.AnalysisStatus=1;
    hf.UserData.AlignVerts.ind=[];
    hf.UserData.AlignVerts.t=[];
    hf.UserData.relshiftx=[];
    hf.UserData.relshifty=[];
    hf.UserData.normfactor=[];
    
    %Define the GUI frame with all buttons and axes
    gui_alignment_defineframe(hf);
    
    %Set initial state and clean profiles:
    getViewPanelProp(hf);
    
    [~,hf.UserData.AnalysisStatus]=setAnalysisStatus(hf.UserData);
    setGUIstate(hf);
    setinitGUIstate(hf);
    hf.UserData=cleanupProfiles(hf.UserData);
    updatePlots(hf,2);
    setViewPanelProp(hf);
    hf.Visible='on';
else
    close(hf);
end
end
%This function adds nodes to an active list when an edge is selected

function hotkeys(src,ed)
%All the keyboard shortcuts are defined here
hf=src;
h_axis=findobj(hf.Children,'-depth',0,'Tag','Axis');
h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
h_object=findobj(h_operationpanel.Children,'flat','Tag','Object');

h_sv=findobj(h_axis.Children,'-depth',0,'Tag','SelVerts');
panfact=0.03;
if strcmp(ed.Key,'comma') || strcmp(ed.Key,'period')
    if ~isempty(h_sv)
        h_active=findobj(h_sv.Children,'-depth',0,'Tag','Active');
        if ~isempty(h_active) && strcmp(h_active.UserData.type,'Trace')
            vert.t=h_active.UserData.t;
            vert.ind=h_active.UserData.ind;
            vert.type=h_active.UserData.type;
            if strcmp(ed.Key,'comma')
                vert.ind=min(vert.ind+1,numel(hf.UserData.Profile{vert.t}.d.optim));
            elseif strcmp(ed.Key,'period')
                vert.ind=max(vert.ind-1,1);
            end
            xdat=hf.UserData.Profile{vert.t}.r.optim(vert.ind,1)+hf.UserData.shiftx(vert.t);
            ydat=hf.UserData.Profile{vert.t}.r.optim(vert.ind,2)+hf.UserData.shifty(vert.t);
            
            %Update active vertex
            h_active.XData=ydat;
            h_active.YData=xdat;
            set(h_active,'UserData',vert)
        end
        
        %If in edit & match mode, with trace object selected
        if strcmp(h_mode.SelectedObject.String,'Detect Peaks') && strcmp(h_object.SelectedObject.String,'Edit Peaks')
            drawProfile([],[],hf);
        end
    end
    
elseif strcmp(ed.Key,'equal')
    h_axis=findobj(hf.Children,'flat','Tag','Axis');
    h_axis.CLim(2)=h_axis.CLim(2)*0.9;
    setViewPanelProp(hf);%Update display
    getViewPanelProp(hf);%Update internal state using display
    
elseif strcmp(ed.Key,'hyphen')
    h_axis=findobj(hf.Children,'flat','Tag','Axis');
    h_axis.CLim(2)=h_axis.CLim(2)*1.1;
    setViewPanelProp(hf);
    getViewPanelProp(hf);
    
elseif strcmp(ed.Key,'d')
    deselectVert([],[],hf);
    
elseif strcmp(ed.Key,'z')
    %Activates zoom with a context menu to disable zoom mode
    hCMZ = uicontextmenu;
    uimenu('Parent',hCMZ,'Label','Switch to pan mode',...
        'Callback','pan(gcbf,''on'')');
    uimenu('Parent',hCMZ,'Label','Exit zoom mode',...
        'Callback','zoom(gcbf,''off'')');
    hZoom = zoom(gcbf);
    hZoom.UIContextMenu = hCMZ;
    zoom('on');
    
elseif strcmp(ed.Key,'x')
    %Activates pan with a context menu to disable pan mode
    hPanMZ = uicontextmenu;
    uimenu('Parent',hPanMZ,'Label','Switch to zoom mode',...
        'Callback','zoom(gcbf,''on'')');
    uimenu('Parent',hPanMZ,'Label','Exit pan mode',...
        'Callback','pan(gcbf,''off'')');
    hPan = pan(gcbf);
    hPan.UIContextMenu = hPanMZ;
    pan('on');
    
elseif strcmp(ed.Key,'a') || strcmp(ed.Key,'r') || strcmp(ed.Key,'f')
    h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
    h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
    h_object=findobj(h_operationpanel.Children,'flat','Tag','Object');
    if strcmp(h_mode.SelectedObject.String,'Align Traces')
        h_axis=findobj(hf.Children,'flat','Tag','Axis');
        h_sv=findobj(h_axis.Children,'flat','Tag','SelVerts');
        if ~isempty(h_sv.Children) && strcmp(ed.Key,'a')
            addLandmark([],[],hf);
        end
        
    elseif strcmp(h_mode.SelectedObject.String,'Detect Peaks') && ...
            strcmp(h_object.SelectedObject.String,'Edit Peaks')
        h_axis=findobj(hf.Children,'flat','Tag','Axis');
        h_sv=findobj(h_axis.Children,'flat','Tag','SelVerts');
        
        if ~isempty(h_sv.Children) && strcmp(ed.Key,'a')
            addPeak([],[],hf);
        elseif ~isempty(h_sv.Children) && strcmp(ed.Key,'r')
            remPeak([],[],hf);
        end
        
    elseif strcmp(h_mode.SelectedObject.String,'Detect Peaks') && ...
            strcmp(h_object.SelectedObject.String,'Match Peaks')
        h_sv=findobj(h_axis.Children,'flat','Tag','SelVerts');
        if numel(h_sv.Children)>1 && strcmp(ed.Key,'a')
            addEdges([],[],hf);
        elseif numel(h_sv.Children)>0 && strcmp(ed.Key,'f')
            editFlag([],[],hf);
        end
    end
    
elseif strcmp(ed.Key,'v')
    h_elements=findobj(h_axis.Children,'flat','-not','Tag','Image','-not','Tag','SelVerts');
    stateval=h_elements(1).Visible;
    if strcmp(stateval,'on')
        stateval='off';
    else
        stateval='on';
    end
    set(h_elements,'Visible',stateval);
    
elseif strcmp(ed.Key,'z')
    %Activates zoom with a context menu to disable zoom mode
    switch2zoom([],[],hf);
    
elseif strcmp(ed.Key,'x')
    %Activates pan with a context menu to disable pan mode
    switch2pan([],[],hf);
    
elseif strcmp(ed.Key,'uparrow')%up
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
end
end

function scroll2zoom(~,ed)
%Callback for zooming in and out using scroll
%h_axis=findobj(src.Children,'flat','Tag','Axis');
if ed.VerticalScrollCount<0
    zoom(1.2);
else
    zoom(1/1.2);
end
end

function closereqf(~,~)
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
