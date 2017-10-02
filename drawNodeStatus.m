function [] = drawNodeStatus(hf)
%Plots graph nodes to for matching
%Convention for flags:
%{
0: No match provided (default)
1: Confirmed no match
2: Ignore, noisy intensity
3: Ignore, terminal bouton intensity
4: Ignore, cross-over
%}
h_axis=findobj(hf.Children,'flat','Tag','Axis');

h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
h_object=findobj(h_operationpanel.Children,'flat','Tag','Object');
if strcmp(h_mode.SelectedObject.String,'Detect Peaks') && strcmp(h_object.SelectedObject.String,'Match Peaks')
    UserData=hf.UserData;
    cnvs_peaks_x=UserData.Graph.r(:,1)+UserData.shiftx(UserData.Graph.t);
    cnvs_peaks_y=UserData.Graph.r(:,2)+UserData.shifty(UserData.Graph.t);
    
    %Nodes without any partners
    node_i_1=sum((UserData.Graph.AM+UserData.Graph.AM')>0,2)==0 & isnan(UserData.Graph.fg_flag);
    h_nodes_1=findobj(h_axis.Children,'flat','Tag','NodeStatus-1');
    if isempty(h_nodes_1)
        line(cnvs_peaks_y(node_i_1),cnvs_peaks_x(node_i_1),...
            'Marker','o','MarkerSize',10,'MarkerEdgeColor',[0 1 1],'MarkerFaceColor','none','LineStyle','none','LineWidth',1,...
            'Parent',h_axis,'Tag','NodeStatus-1','ButtonDownFcn',{@selectVert,hf},'HitTest','off');
    else
        h_nodes_1.XData=cnvs_peaks_y(node_i_1);
        h_nodes_1.YData=cnvs_peaks_x(node_i_1);
    end
    
    % Nodes to be discarded
    %from the analysis, that were not discarded in the annotation step
    node_i_2=UserData.Graph.fg_flag>1;
    h_nodes_2=findobj(h_axis.Children,'flat','Tag','NodeStatus-2');
    if isempty(h_nodes_2)
        line(cnvs_peaks_y(node_i_2),cnvs_peaks_x(node_i_2),...
            'Marker','s','MarkerSize',10,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor','none','LineStyle','none','LineWidth',1,...
            'Parent',h_axis,'Tag','NodeStatus-2','ButtonDownFcn',{@selectVert,hf},'HitTest','off');
    else
        h_nodes_2.XData=cnvs_peaks_y(node_i_2);
        h_nodes_2.YData=cnvs_peaks_x(node_i_2);
    end
    
    %Nodes that are confirmed to not have a partner
    node_i_3=UserData.Graph.fg_flag==1;
    h_nodes_3=findobj(h_axis.Children,'flat','Tag','NodeStatus-3');
    if isempty(h_nodes_3)
        line(cnvs_peaks_y(node_i_3),cnvs_peaks_x(node_i_3),...
            'Marker','^','MarkerSize',10,'MarkerEdgeColor',[0.5 0.5 1],'MarkerFaceColor','none','LineStyle','none','LineWidth',1,...
            'Parent',h_axis,'Tag','NodeStatus-3','ButtonDownFcn',{@selectVert,hf},'HitTest','off');
    else
        h_nodes_3.XData=cnvs_peaks_y(node_i_3);
        h_nodes_3.YData=cnvs_peaks_x(node_i_3);
    end
    
    %Set legends-----------------------------------------
    h_nodes_1=findobj(h_axis.Children,'flat','Tag','NodeStatus-1');
    h_nodes_2=findobj(h_axis.Children,'flat','Tag','NodeStatus-2');
    h_nodes_3=findobj(h_axis.Children,'flat','Tag','NodeStatus-3');
    
    %Because handle can exist with no data in it:
    if ~isempty(h_nodes_1)
        h_nodes_1(isempty(h_nodes_1.XData))=[];
    end
    if ~isempty(h_nodes_2)
        h_nodes_2(isempty(h_nodes_2.XData))=[];
    end
    if ~isempty(h_nodes_3)
        h_nodes_3(isempty(h_nodes_3.XData))=[];
    end
    
    h_stat={h_nodes_2,h_nodes_1,h_nodes_3};
    h_status_text={'Ignored','Not matched','Confirmed with no match'};
    keep=~cellfun(@isempty,h_stat);
    h_stat=h_stat(keep);
    h_status_text=h_status_text(keep);
    
    if ~isempty(h_stat)
        hl=legend([h_stat{:}],h_status_text);
        hl.Tag='NodeStatus-Legend';
        mver=version;
        mver=str2double(mver(1:3));
        if mver>=9.0
            hl.Title.String='Peak status';
        end
        hl.FontSize=11;
        hl.FontName='Calibri';
        hl.TextColor=[0 0 0];
        hl.Location='northeast';
        allprops=fieldnames(hl);
        if any(strcmp(allprops,'AutoUpdate'))
            hl.AutoUpdate='off';
        end
    end
    uistack(findobj(h_axis.Children,'flat','Tag','(NodeStatus)'),'top');
else
    delete(findobj(h_axis.Children,'flat','-regexp','Tag','(NodeStatus)'));
    delete(findobj(hf.Children,'flat','-regexp','Tag','(NodeStatus)'));
end
end