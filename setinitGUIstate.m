function setinitGUIstate(hf)
%This function prompts user to keep or discard previous alignment history.
%The profiles are cleaned up based on the user selection.

%Find required operation panel handles
h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
h_mode_align=findobj(h_mode.Children,'flat','String','Align Traces');
h_mode_annotate=findobj(h_mode.Children,'flat','String','Annotate Traces');
h_mode_editmatch=findobj(h_mode.Children,'flat','String','Detect Peaks');
h_object=findobj(h_operationpanel.Children,'flat','Tag','Object');
h_object_traces=findobj(h_object.Children,'flat','String','Edit Peaks');

if hf.UserData.AnalysisStatus==1 %------------Default----------------------
    h_mode.SelectedObject=h_mode_align;
    h_object.SelectedObject=h_object_traces;
    
elseif hf.UserData.AnalysisStatus==2 %-----Annotations present-------------
    modechoice = questdlg('Found annotations. Proceed with caution!', ...
        'Warning', ...
        'Discard & Redo','Preserve & Continue','Preserve & Continue');
    if isempty(modechoice)
        disp('No choice provided. Previously marked annotations are retained.');
        modechoice='Keep & continue';
    end
    switch modechoice
        
        case 'Discard & Redo'
            h_mode.SelectedObject=h_mode_align;
            h_object.SelectedObject=h_object_traces;
            hf.UserData.AnalysisStatus=1;
        case 'Preserve & Continue'
            h_mode.SelectedObject=h_mode_annotate;
            h_object.SelectedObject=h_object_traces;
    end
    
elseif hf.UserData.AnalysisStatus==3 %-----Fitted peaks present------------
    modechoice = questdlg('Found fitted peaks', ...
        'Warning', ...
        'Discard & redo','Keep & continue','Keep & continue');
    
    if isempty(modechoice)
        disp('No choice provided. Previously detected and tracked peaks are retained.');
        modechoice='Keep & continue';
    end
    switch modechoice
        case 'Discard & redo'
            h_mode.SelectedObject=h_mode_align;
            h_object.SelectedObject=h_object_traces;
            hf.UserData.AnalysisStatus=1;
        case 'Keep & continue'
            h_mode.SelectedObject=h_mode_editmatch;
            h_object.SelectedObject=h_object_traces;
    end
end
end