function AlignTraces(hf)
%This is a callback for aligning the traces without fitted peaks.
%1. Profiles will be flipped if necessary
%2. Landmarks will be updated to match indices
%3. Landmarks will be used to align profiles
%3. Canvas will be updated
%4. Edges for landmarks will be shown

%At least 2 landmarks are required to ensure ordering of traces. Alignment
%with 2 will also switch on access to Annotation mode.

UserData=hf.UserData;
if size(UserData.AlignVerts.ind,2)>1
    %1. Profiles will be flipped if necessary------------------------------
    % UserData.AlignVerts.ind is assumed to be sorted at this stage
    toflip=sign(sum(sign(diff(UserData.AlignVerts.ind,[],2)),2));
    if sum(toflip)==0
        toflip=toflip>0;
    else
        toflip=~(toflip==sign(sum(toflip)));
    end
    toflip_ti=find(toflip);
    for i=1:numel(toflip_ti)
        UserData.Profile{toflip_ti(i)}=profile_flip(UserData.Profile{toflip_ti(i)});
        UserData.AlignVerts.ind(toflip_ti(i),:)=numel(UserData.Profile{toflip_ti(i)}.d.optim)-UserData.AlignVerts.ind(toflip_ti(i),:)+1;
    end
    
    %2. Landmarks used to align profiles-----------------------------------
    Time=cell(numel(UserData.Profile),1);
    for ti=1:numel(UserData.Profile)
        Time{ti}.d=UserData.Profile{ti}.d.optim;
        Time{ti}.d_man=Time{ti}.d;
        Time{ti}.fg_ind=UserData.AlignVerts.ind(ti,:)';
        Time{ti}.fg_manid=(1:numel(Time{ti}.fg_ind))';
        Time{ti}.deform_man=zeros(size(Time{ti}.d));
    end
    Time=distance_align(Time);
    
    for ti=1:numel(UserData.Profile)
        UserData.Profile{ti}.d.aligned=Time{ti}.d_man;
    end
    
    %3. Landmarks used to align profiles - based on 2D distances-----------
    Time=cell(numel(UserData.Profile),1);
    for ti=1:numel(UserData.Profile)
        Time{ti}.d=px2um(UserData.Profile{ti}.r.optim);
        Time{ti}.d_man=Time{ti}.d;
        Time{ti}.fg_ind=UserData.AlignVerts.ind(ti,:)';
        Time{ti}.fg_manid=(1:numel(Time{ti}.fg_ind))';
        Time{ti}.deform_man=zeros(size(Time{ti}.d));
    end
    Time=distance_align(Time);
    
    for ti=1:numel(UserData.Profile)
        UserData.Profile{ti}.d.alignedxy=Time{ti}.d_man;
    end
end
hf.UserData=[];hf.UserData=UserData;%For speed reasons

end