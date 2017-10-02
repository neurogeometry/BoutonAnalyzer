function viewPanelController(src,~,hf)
%This is called to update the plots whenever view panel properties are
%changed. This function determines what objects need to be updated
%Allowed src.Tag:'Channel','RelativeIntensity','ContrastValue','ShiftValue'

getViewPanelProp(hf);
switch src.Tag
    case 'Channel'
        updatePlots(hf,1)
    case 'RelativeIntensity'
        hf.UserData.View.CVal=[];
        updatePlots(hf,1);
    case 'ContrastValue'
        updatePlots(hf,1)
    case 'ShiftValue'
        %Clear existing nodes,edges and nodestatus
        h_axis=findobj(hf.Children,'flat','Tag','Axis');
        delete(findobj(h_axis.Children,'flat','Tag','Nodes'));
        delete(findobj(h_axis.Children,'flat','-regexp','Tag','(Edge-)'));
        delete(findobj(h_axis.Children,'flat','-regexp','Tag','(NodeStatus)'));
        delete(findobj(h_axis.Children,'flat','Tag','Nodes'));
        updatePlots(hf,2)
end

setViewPanelProp(hf);
end