function remLandmark(src,ed,hf)
h_edge=gco;
remind=nan(size(hf.UserData.AlignVerts.ind,1),1);
for ti=1:size(hf.UserData.AlignVerts.ind,1)
    remind(ti)=find(hf.UserData.AlignVerts.ind(ti,:)==h_edge.UserData.ind(ti));
end
remind=unique(remind);
hf.UserData.AlignVerts.ind(:,remind)=[];
hf.UserData.AlignVerts.t(:,remind)=[];

AlignTraces(hf);
deselectVert([],[],hf);
updatePlots(hf,2);
end