function [] = gui_alignment_defineframe(hf)

gui_alignment_layout;

%------------------------------Operation Panel-----------------------------
h_operation=uipanel('Parent',hf);h_operation.Tag='Operation';
h_operation.Units='pixels';h_operation.Position=[panel_l,operationpanel_b,panel_w,operationpanel_h];
h_operation.Title='';

%Mode select
h_mode = uibuttongroup('Tag','Mode','Parent',h_operation,...
    'Units','pixels','Position',[0,operationpanel_mode_b,panel_w,operationpanel_mode_h],...
    'SelectionChangedFcn',{@operationPanelController,hf},...
    'Title','','BorderType','none');
modechoices={'Align Traces','Annotate Traces','Detect Peaks'};
nbtn=3;
for n=1:nbtn
    mode_rb=uicontrol('Style','radiobutton','Parent',h_mode);
    mode_rb.Units='pixels';mode_rb.Position=[stdbuff_w,(nbtn-n)*(rbtn_h+minbuff_h)+stdbuff_h+1, element_w, rbtn_h];
    mode_rb.String=modechoices{n};
    mode_rb.Enable='off';
end

%Object select
h_object = uibuttongroup('Tag','Object','Parent',h_operation,...
    'Units','pixels','Position',[0,operationpanel_object_b,panel_w,operationpanel_object_h],...
    'SelectionChangedFcn',{@operationPanelController,hf},...
    'Title','');%,'BorderType','none');
objectchoices={'Edit Peaks','Match Peaks'};
nbtn=numel(objectchoices);
for n=1:nbtn
    obj_rb=uicontrol('Style','radiobutton','Parent',h_object);
    obj_rb.Units='pixels';obj_rb.Position=[stdbuff_w,(nbtn-n)*(rbtn_h+minbuff_h)+stdbuff_h+1, element_w, rbtn_h];
    obj_rb.String=objectchoices{n};
    obj_rb.Enable='off';
end

%Save profile button
uicontrol('Style', 'pushbutton','Tag','SaveProfile','Parent',h_operation,...
    'Units','pixels','Position',[stdbuff_w, savebutton_b+1, element_w, pushbutton_h],...
    'String', 'Save','Callback',{@saveProfile,hf},'Enable','off');

%New Axon button
uicontrol('Style', 'pushbutton','Tag','LoadNextAxon','Parent',h_operation,...
    'Units','pixels','Position',[stdbuff_w, newaxonbtn_b+1 element_w, pushbutton_h],...
    'String', 'Load Next','Callback',{@loadnext,hf},'Enable','on');

%------------------------------View Panel----------------------------------
h_viewpanel=uipanel('Parent',hf);h_viewpanel.Tag='ViewPanel';
h_viewpanel.Units='pixels';h_viewpanel.Position=[panel_l,viewpanel_b,panel_w,viewpanel_h];
h_viewpanel.Title='View Options';

%Contrast setting
uicontrol('Style', 'text','Parent',h_viewpanel,...
    'Units','pixels','Position', [stdbuff_w, view_intrange_b+txtbx_h+minbuff_h, element_w, txt_h],...
    'String','Intensity range');

uicontrol('Style','edit','Parent',h_viewpanel,'Tag','ContrastValue',...
    'Units','pixels','Position',[stdbuff_w,view_intrange_b, element_w, txtbx_h],...
    'Callback',{@viewPanelController,hf},...
    'ToolTipString','e.g. 0, 100');

%Position setting
uicontrol('Style', 'text','Parent',h_viewpanel,...
    'Units','pixels','Position', [stdbuff_w, view_shift_b+txtbx_h+minbuff_h, element_w, txt_h],...
    'String',sprintf('Shift: down, right (px)'));

uicontrol('Style','edit','Tag','ShiftValue','Parent',h_viewpanel,...
    'Units','pixels','Position',[stdbuff_w, view_shift_b, element_w, txtbx_h],...
    'Callback',{@viewPanelController,hf},...
    'ToolTipString','e.g. -10, 15');


%Toggle channel
sel_ch = uibuttongroup('Tag','Channel','Parent',h_viewpanel,...
    'Units','pixels','Position',[0, view_chnrb_b, panel_w, view_chnrb_h],...
    'SelectionChangedFcn',{@viewPanelController,hf},...
    'Title','Channel','BorderType','none');
nbtn=3;
channel=fieldnames(hf.UserData.Profile{1}.proj);
for n=1:nbtn
    ch_rb=uicontrol('Style','radiobutton','Parent',sel_ch);
    ch_rb.Units='pixels';ch_rb.Position=[stdbuff_w,(nbtn-n)*(rbtn_h+minbuff_h)+minbuff_h, element_w, rbtn_h];
    if n<=numel(channel)
        ch_rb.String=channel{n};
        ch_rb.Enable='on';
    else
        ch_rb.String='-NA-';
        ch_rb.Enable='off';
    end
end
sel_ch.SelectedObject=findobj(sel_ch,'String',hf.UserData.inform.channel{1});

%Toggle normalized
h_norm = uibuttongroup('Tag','RelativeIntensity','Parent',h_viewpanel,...
    'Units','pixels','Position',[0,stdbuff_h,panel_w,view_relintrb_h],...
    'SelectionChangedFcn',{@viewPanelController,hf},...
    'Title','Image intensity','BorderType','none');
normchoices={'Raw','Normalized'};
nbtn=numel(normchoices);
for n=1:nbtn
    norm_rb=uicontrol('Style','radiobutton','Parent',h_norm);
    norm_rb.Units='pixels';norm_rb.Position=[stdbuff_w,(nbtn-n)*(rbtn_h+minbuff_h)+minbuff_h, element_w, rbtn_h];
    norm_rb.String=normchoices{n};
    norm_rb.Enable='on';
end
h_norm.SelectedObject=findobj(h_norm,'String','Raw');

%----------------------------Initialize axis-------------------------------
h_axis=axes('Parent',hf);h_axis.Tag='Axis';
h_axis.Units='pixels';h_axis.Position=[2*buff.w+panel_w+buff.h,buff.h,xyaxis_w,xyaxis_w];
h_axis.YLabel.String='X axis, [pixels]';h_axis.XLabel.String='Y axis, [pixels]';
h_axis.XLim=[0 1000];h_axis.YLim=[0 1000];
h_axis.Color=[0.4 0.4 0.4];box(h_axis,'on');
h_axis.NextPlot='add';

%Initialize selected vertices group
h_sv=hggroup('Parent',h_axis);
h_sv.Tag='SelVerts';
end

function [] = loadnext(~,~,hf)
    close(hf);
    if ~isvalid(hf)
        gui_alignment([]);
    else
        disp('Current axon was retained. Load new axon operation terminated.')
    end
end