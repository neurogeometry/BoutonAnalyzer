function addLandmark(~,~,hf)
%This function commits the selected vertices (one on each loaded trace) as
%a landmark and calls the trace alignment function.
UserData=hf.UserData;hf.UserData=[];
h_axis=findobj(hf.Children,'flat','Tag','Axis');
h_sv=findobj(h_axis.Children,'flat','Tag','SelVerts');

if ~isempty(h_sv)
    if ~isfield(UserData,'AlignVerts')
        UserData.AlignVerts.t=[];
        UserData.AlignVerts.ind=[];
    end
    
    temp=nan(numel(h_sv.Children),2);
    for i=1:numel(h_sv.Children)
        temp(h_sv.Children(i).UserData.t,:)=[h_sv.Children(i).UserData.ind,h_sv.Children(i).UserData.t];
    end
    UserData.AlignVerts.ind=[UserData.AlignVerts.ind,temp(:,1)];
    UserData.AlignVerts.t=[UserData.AlignVerts.t,temp(:,2)];
    
    [~,sortind]=sort(UserData.AlignVerts.ind(1,:));
    UserData.AlignVerts.ind=UserData.AlignVerts.ind(:,sortind);
    UserData.AlignVerts.t=UserData.AlignVerts.t(:,sortind);
    
    hf.UserData=UserData;
    AlignTraces(hf);
    deselectVert([],[],hf);
    updatePlots(hf,2);
end
end