function UserData = calcXYshift(UserData)
%This function calculates an initial shift based on trace center of mass.
%Note: x and y directions are the same for both, trace and image. Only
%displaying the image requires flipping plot dimensions, because of imshow.


if ~isempty(UserData.View.ShiftVal)
    UserData.relshiftx=UserData.View.ShiftVal(1);
    UserData.relshifty=UserData.View.ShiftVal(2);
end 
channel=UserData.inform.channel{1};

if isempty(UserData.relshiftx) || isempty(UserData.relshifty)
    %Default alignment
    axonrelshift=25;%Distance in pixels to automatically stagger axon projections
    tgt=UserData.Profile{1}.r.optim(1,:)-UserData.Profile{1}.r.optim(end,:);
    tgt=tgt(1:2)./norm(tgt(1:2));
    prp=[tgt(2),-tgt(1)];
    prp=prp./norm(prp);
else
    %When shifts are explicitly defined
    axonrelshift=1;
    prp=[UserData.relshiftx,UserData.relshifty];
end

dx=zeros(numel(UserData.Profile),1);
dy=zeros(numel(UserData.Profile),1);
trace_cen_x=zeros(numel(UserData.Profile),1);
trace_cen_y=zeros(numel(UserData.Profile),1);

UserData.relshiftx=prp(1)*axonrelshift;
UserData.relshifty=prp(2)*axonrelshift;

for ti=1:numel(UserData.Profile)
    dr=axonrelshift*(ti-1);
    dx(ti)=round(dr.*prp(1));
    dy(ti)=round(dr.*prp(2));
    if (UserData.AnalysisStatus==1 || UserData.AnalysisStatus==2)...
            && isempty(UserData.AlignVerts.ind)
        ind_ti=1:size(UserData.Profile{ti}.r.optim,1);
        
    elseif (UserData.AnalysisStatus==1 || UserData.AnalysisStatus==2)...
            && ~isempty(UserData.AlignVerts.ind)
        ind_ti=UserData.AlignVerts.ind(ti,:);
        
    elseif UserData.AnalysisStatus==3
        ind_ti=~UserData.Profile{ti}.annotate.ignore;
        
    end
    trace_cen_x(ti)=round(mean(UserData.Profile{ti}.r.optim(ind_ti,1)));
    trace_cen_y(ti)=round(mean(UserData.Profile{ti}.r.optim(ind_ti,2)));
end

%Convention: cnvsind is related to indexing in image.
%e.g. if image size is 1024 x 1024, and y indices go from 1 to 1024.
cnvsind_minx=inf;
cnvsind_miny=inf;
cnvsind_maxx=-inf;
cnvsind_maxy=-inf;

%Calculate size of canvas
for ti=1:numel(UserData.Profile)
    %canvas indices 1 in x,y are transformed to match new trace position
    cnvsind_minx=min(cnvsind_minx,1-trace_cen_x(ti)+dx(ti));
    cnvsind_miny=min(cnvsind_miny,1-trace_cen_y(ti)+dy(ti));
    
    %canvas indices 1024 in x,y are transformed to match new trace position
    cnvsind_maxx=max(cnvsind_maxx,size(UserData.Profile{ti}.proj.(channel).xy.ax,1)-trace_cen_x(ti)+dx(ti));
    cnvsind_maxy=max(cnvsind_maxy,size(UserData.Profile{ti}.proj.(channel).xy.ax,2)-trace_cen_y(ti)+dy(ti));
end

%Calculate net shift for each trace:
net_dx=zeros(numel(UserData.Profile),1);
net_dy=zeros(numel(UserData.Profile),1);
for ti=1:numel(UserData.Profile)
    net_dx(ti)=-trace_cen_x(ti)+dx(ti)-(cnvsind_minx-1);
    net_dy(ti)=-trace_cen_y(ti)+dy(ti)-(cnvsind_miny-1);
end

UserData.Cnvs_size=[cnvsind_maxx-cnvsind_minx+1,cnvsind_maxy-cnvsind_miny+1];
UserData.shiftx=net_dx;
UserData.shifty=net_dy;
end