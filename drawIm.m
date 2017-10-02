function h_Im = drawIm(hf)
%This function obtains view panel parameters and plots image that is
%already calculated by updateIm(hf). Context menu items for the Image are
%cleaned up witin this function.

View=hf.UserData.View;
h_axis=findobj(hf.Children,'flat','Tag','Axis');
axes(h_axis);%Set current axis
h_Im=findobj(h_axis.Children,'flat','Tag','Image');
if isempty(h_Im)
    h_Im=imshow(hf.UserData.Im,[],'Parent',h_axis);hold on;h_Im.Tag='Image';
    delete(findobj(hf.Children,'flat','Tag','ImageCM'));%Deleting previous context menus
else
    h_Im.CData=hf.UserData.Im;
end
h_Im.UIContextMenu=uicontextmenu(hf);

axis(h_axis,'on');
if isempty(View.CVal)
    h_axis.CLim=[0,mean(hf.UserData.Im(hf.UserData.Im>0))+5*std(hf.UserData.Im(hf.UserData.Im>0))];
else
    h_axis.CLim=View.CVal;
end
uistack(h_Im,'bottom');
end