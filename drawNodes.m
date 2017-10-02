function [] = drawNodes(hf)
%Plots graph nodes to for matching
h_axis=findobj(hf.Children,'flat','Tag','Axis');

h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
h_object=findobj(h_operationpanel.Children,'flat','Tag','Object');

if strcmp(h_mode.SelectedObject.String,'Detect Peaks') && strcmp(h_object.SelectedObject.String,'Match Peaks')
    UserData=hf.UserData;
    cnvs_peaks_x=UserData.Graph.r(:,1)+UserData.shiftx(UserData.Graph.t);
    cnvs_peaks_y=UserData.Graph.r(:,2)+UserData.shifty(UserData.Graph.t);
    h_nodes=findobj(h_axis.Children,'flat','Tag','Nodes');
    if isempty(h_nodes)
        line(cnvs_peaks_y,cnvs_peaks_x,...
            'Marker','o','MarkerSize',5,'MarkerEdgeColor',[0.5 0.5 1],'MarkerFaceColor','none','LineStyle','none','LineWidth',1,...
            'UserData',struct('nodeind',UserData.Graph.nodeind,'fg_id',UserData.Graph.fg_id),...
            'Parent',h_axis,'Tag','Nodes','ButtonDownFcn',{@selectVert,hf});
    else
        h_nodes.XData=cnvs_peaks_y;
        h_nodes.YData=cnvs_peaks_x;
        h_nodes.UserData=struct('nodeind',UserData.Graph.nodeind,'fg_id',UserData.Graph.fg_id);
    end
    uistack(h_nodes,'top');
else
    delete(findobj(h_axis.Children,'flat','Tag','Nodes'));
end
end