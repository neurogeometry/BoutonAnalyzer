function deselectVert(~,~,hf)
%This is used to remove all selected vertices and associated context menus
%from the figure in gui_alignment.

ha=findobj(hf.Children,'-depth',0,'Tag','Axis');
h_sv=findobj(ha.Children,'-depth',0,'Tag','SelVerts');
h_cm=findobj(hf,'Tag','SelVertCM');
delete(h_cm);
if ~isempty(h_sv)
    delete(h_sv.Children);
end
end