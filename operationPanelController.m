function [] = operationPanelController(src,ed,hf)

%To populate annotations
if strcmp(ed.OldValue.String,'Align Traces') && strcmp(ed.NewValue.String,'Annotate Traces')
    initIgnore(hf);
end

%To run fitting and automated matching
if (strcmp(ed.OldValue.String,'Annotate Traces') || strcmp(ed.OldValue.String,'Align Traces')) && strcmp(ed.NewValue.String,'Detect Peaks')
    h_msg=msgbox('Please wait until fitting of profiles is completed. This may take a minute...','Fitting profiles');
    UserData=hf.UserData;
    ch=UserData.inform.channel{1};
    for ti=1:numel(UserData.Profile)
        Dat=hf.UserData.Profile{ti};
        Dat.I.(ch).LoGxy.norm=...
            Dat.I.(ch).LoGxy.raw./mean((Dat.I.(ch).LoGxy.raw(~Dat.annotate.ignore)));
        
        %Normalize Gauss intensity excluding ignored regions
        Dat.I.(ch).Gauss.norm=...
            Dat.I.(ch).Gauss.raw./mean((Dat.I.(ch).Gauss.raw(~Dat.annotate.ignore)));
        
        %Fit LoGxy profile
        Dat=fitLoGxy(Dat,ch);
        
        %Fit Gauss based on LoGxy peaks
        [Dat.fit.(ch).Gauss.fg,...
            Dat.fit.(ch).Gauss.bg]=fitGauss(...
            Dat.I.(ch).Gauss.norm,...
            Dat.d.optim,...
            Dat.fit.(ch).LoGxy.fg,...
            Dat.fit.(ch).LoGxy.bg);
        
        UserData.Profile{ti}=Dat;
        clear Dat;
    end  
    UserData.Profile=automatch(UserData.Profile,ch);
    hf.UserData=[];hf.UserData=UserData;
    close(h_msg);
end

%To initialize/update graph structure for editing matches
h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
if strcmp(h_mode.SelectedObject.String,'Detect Peaks')
    if ~isfield(hf.UserData,'Graph') %If no graph present
        Profile2Graph(hf);
    end
    if strcmp(src.Parent.Tag,'Operation') %If peaks were edited
        if strcmp(ed.OldValue.String,'Edit Peaks') && strcmp(ed.NewValue.String,'Match Peaks')
            Profile2Graph(hf);
            if isvalid(hf.UserData.profilefig)
                close(hf.UserData.profilefig);
            end
        elseif strcmp(ed.OldValue.String,'Match Peaks') && strcmp(ed.NewValue.String,'Edit Peaks')
            Graph2Profile(hf);
        end
    end
end

opporder=false;
%If modes are switched to in opposite to expected order
if (strcmp(ed.OldValue.String,'Annotate Traces') || strcmp(ed.OldValue.String,'Detect Peaks')) && strcmp(ed.NewValue.String,'Align Traces')
    newval=1;%Used for clean up
    opporder=true;
end

%To populate annotations
if strcmp(ed.OldValue.String,'Detect Peaks') && strcmp(ed.NewValue.String,'Annotate Traces')
    newval=2;%Used for clean up
    opporder=true;
end

if opporder
    %Dialogue box here. If user clicks okay, clean data. Else reset to previous value.
    choice = questdlg('All unsaved changes beyond selected mode will be lost. Continue?', ...
        'Warning', ...
        'Yes','No','No');
    cc=1;
    switch choice
        case 'No'
            cc=1;
        case 'Yes'
            cc=2;
    end
    
    if cc==2
        disp('All changes beyond current mode were deleted.')
        hf.UserData.AnalysisStatus=newval;
        %If in peaks mode, revert back to trace object
        h=findobj(src.Parent,'Tag','Object');
        if strcmp(ed.OldValue.String,'Detect Peaks')
            dh=findobj(h.Children,'String','Match Peaks');
            dh.Enable='off';
            dh=findobj(h.Children,'String','Edit Peaks');
            h.SelectedObject=dh;
        end
    else
        %Revert mode here
        src.SelectedObject=ed.OldValue;
    end
    UserData=hf.UserData;
    [UserData]=cleanupProfiles(UserData);
    hf.UserData=[];hf.UserData=UserData;
    
    if isvalid(hf.UserData.profilefig)
        close(hf.UserData.profilefig);
    end
end
    
deselectVert([],[],hf);
updatePlots(hf,2);
end