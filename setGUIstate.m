function [] = setGUIstate(hf)
%This function enables or disables particular GUI elements based on present
%status of data (AnalysisStatus).

%Find all operation panel handles
h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
h_mode_align=findobj(h_mode.Children,'flat','String','Align Traces');
h_mode_annotate=findobj(h_mode.Children,'flat','String','Annotate Traces');
h_mode_editmatch=findobj(h_mode.Children,'flat','String','Detect Peaks');
h_object=findobj(h_operationpanel.Children,'flat','Tag','Object');
h_object_traces=findobj(h_object.Children,'flat','String','Edit Peaks');
h_object_peaks=findobj(h_object.Children,'flat','String','Match Peaks');
h_saveprofile=findobj(h_operationpanel.Children,'flat','String','Save');

%set status based on AnalysisStatus
if hf.UserData.AnalysisStatus==1
    h_mode_align.Enable='on';
    h_mode_annotate.Enable='off';
    h_mode_editmatch.Enable='off';
    h_object_traces.Enable='off';
    h_object_peaks.Enable='off';
    h_saveprofile.Enable='off';
    if size(hf.UserData.AlignVerts.ind,2)>=2 || numel(hf.UserData.Profile)==1
        h_mode_annotate.Enable='on';
        h_mode_editmatch.Enable='on';
    end
elseif hf.UserData.AnalysisStatus==2
    h_mode_align.Enable='on';
    h_mode_annotate.Enable='on';
    h_mode_editmatch.Enable='on';
    h_object_traces.Enable='off';
    h_object_peaks.Enable='off';
    h_saveprofile.Enable='on';
elseif hf.UserData.AnalysisStatus==3
    h_mode_align.Enable='on';
    h_mode_annotate.Enable='on';
    h_mode_editmatch.Enable='on';
    h_object_traces.Enable='on';
    h_object_peaks.Enable='on';
    h_saveprofile.Enable='on';
end
%{
%View panel options:
h_axis=findobj(hf.Children,'-depth',1,'Tag','Axis');
h_viewpanel=findobj(hf.Children,'flat','Tag','ViewPanel');
h_ch=findobj(h_viewpanel.Children,'flat','Tag','Channel');
h_norm=findobj(h_viewpanel.Children,'flat','Tag','RelativeIntensity');
h_contrast=findobj(h_viewpanel.Children,'flat','Tag','ContrastValue');
h_shift=findobj(h_viewpanel.Children,'flat','Tag','ShiftValue');
%}
end