function addEdges(src,ed,hf)
%This function adds an edge between matched UserData.Graph nodes (indicated by
%selected vertices)
h_axis=findobj(hf.Children,'flat','Tag','Axis');
h_sv=findobj(h_axis.Children,'flat','Tag','SelVerts');
sel_vert=cell2mat({h_sv.Children.UserData});
t_active=[sel_vert.t];
fg_id_active=[sel_vert.fg_id];
update_graph_lbl=[sel_vert.lbl];
if isempty(update_graph_lbl)
    %empty arrays can have a non-zero size which can be problematic.
    update_graph_lbl=[];
end

%re-order active nodes with earliest time first
[~,sorti]=sort(t_active,'ascend');
fg_id_active=fg_id_active(sorti);

%Modify AM to add link between active nodes.
%Ordering is assumed. Resulting AM has correct labels.
UserData=hf.UserData;
%AMind=ismember(UserData.Graph.fg_id,fg_id_active);
AMind=any(bsxfun(@eq,UserData.Graph.fg_id(:),fg_id_active(:)'),2);
AMind=find(AMind);
addind=sub2ind(size(UserData.Graph.AM),AMind(1:end-1),AMind(2:end));
UserData.Graph.AM(addind)=fg_id_active(1);

%Check to prevent illegal merges
AM = spones(UserData.Graph.AM+UserData.Graph.AM');
if sum(sum(AM,1)>2)==0
    UserData.Graph.updatelbl=update_graph_lbl;
    hf.UserData=[];
    hf.UserData=UserData;    
else
    display('Illegal operation - A given Peak cannot have multiple matches. Re-select Peaks.')
end

deselectVert([],[],hf);
updatePlots(hf,5);
end