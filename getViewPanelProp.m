function getViewPanelProp(hf)
%This function gathers the view panel properties
%Output is structure View with fields:
%View.Channel
%View.Norm
%View.CVal
%View.ShiftVal

UserData=hf.UserData;hf.UserData=[];
h_viewpanel=findobj(hf.Children,'flat','Tag','ViewPanel');
h_ch=findobj(h_viewpanel.Children,'flat','Tag','Channel');
h_norm=findobj(h_viewpanel.Children,'flat','Tag','RelativeIntensity');
h_contrast=findobj(h_viewpanel.Children,'flat','Tag','ContrastValue');
h_shift=findobj(h_viewpanel.Children,'flat','Tag','ShiftValue');

%Obtain channel
View.Channel=h_ch.SelectedObject.String;

%Obtain relative intensity choice%Obtain channel
View.Norm=strcmp(h_norm.SelectedObject.String,'Normalized');

%Obtain contrast value
temp=regexp(h_contrast.String,',','split');
if numel(temp)==2
    temp=[str2double(temp{1}),str2double(temp{2})];
end
if numel(temp)==2 && ~isnan(temp(1)) && ~isnan(temp(2))
    View.CVal=temp;
else
    disp('Changing image intensity range to previous values')
    View.CVal=[];
end

%Obtain shift value
temp=regexp(h_shift.String,',','split');
if numel(temp)==2
    temp=[str2double(temp{1}),str2double(temp{2})];
end
if numel(temp)==2 && ~isnan(temp(1)) && ~isnan(temp(2))
    View.ShiftVal=temp;
else
    disp('Changing shift to previous values')
    View.ShiftVal=[];
end
UserData.View=View;
hf.UserData=UserData;
end