function setViewPanelProp(hf)
%Radio button properties are initialized at default values. Updates to
%those are directly provided by user. Contrast and Shift value updates are
%obtained every time the image is updated.

h_axis=findobj(hf.Children,'flat','Tag','Axis');
h_Im=findobj(h_axis.Children,'flat','Tag','Image');
h_viewpanel=findobj(hf.Children,'flat','Tag','ViewPanel');
%h_ch=findobj(h_viewpanel.Children,'flat','Tag','Channel');
%h_norm=findobj(h_viewpanel.Children,'flat','Tag','RelativeIntensity');
h_contrast=findobj(h_viewpanel.Children,'flat','Tag','ContrastValue');
h_shift=findobj(h_viewpanel.Children,'flat','Tag','ShiftValue');

if isempty(h_Im)
    h_contrast.String='';
else
    h_contrast.String=sprintf('%0.1f, %0.1f',h_axis.CLim(1),h_axis.CLim(2));
end

if isempty(hf.UserData.relshiftx) || isempty(hf.UserData.relshifty)
    h_shift.String='';
else
    h_shift.String=sprintf('%0.0f, %0.0f',hf.UserData.relshiftx,hf.UserData.relshifty);
end
end