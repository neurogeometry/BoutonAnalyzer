function updateProfile(hf)
%This function ensures that assigned fg.id are in a sorted order based on
%distance along the trace. In addition, removal of peaks can require
%re-labeling of existing matches, which is accomplished by the call to
%addrempeaklbl

UserData=hf.UserData;hf.UserData=[];%For speed reasons
channel=UserData.inform.channel{1};
current_fgid=[];
relbl_fgid=[];
match_id=[];

Time=cell(numel(UserData.Profile),1);
for ti=1:numel(UserData.Profile)
    Time{ti}.fg_id=UserData.Profile{ti}.fit.(channel).LoGxy.fg.id;
    Time{ti}.fg_manid=UserData.Profile{ti}.fit.(channel).LoGxy.fg.manid;
    Time{ti}.fg_ind=UserData.Profile{ti}.fit.(channel).LoGxy.fg.ind;
end

for ti=1:numel(UserData.Profile)
    current_fgid=cat(1,current_fgid,Time{ti}.fg_id(:));
    match_id=cat(1,match_id,Time{ti}.fg_manid(:));
    
    [~,si]=sort(Time{ti}.fg_ind(:));%Index, not id
    temp=nan(size(Time{ti}.fg_id(:)));
    temp(si)=min(Time{ti}.fg_id)+(1:numel(Time{ti}.fg_id(:)))-1;
    relbl_fgid=cat(1,relbl_fgid,temp(:));
end
[~,new_match_id] = addrempeaklblAM (relbl_fgid,match_id);

for ti=1:length(Time)
    [lia,~]=ismember(current_fgid,Time{ti}.fg_id);
    in_ti=find(lia);
    
    mu=nan(size(in_ti));
    amp=nan(size(in_ti));
    sig=nan(size(in_ti));
    flg=nan(size(in_ti));
    fgid=relbl_fgid(in_ti);
    old_fgid=current_fgid(in_ti);
    manid=new_match_id(in_ti);
    autoid=nan(size(in_ti));
    ind=Time{ti}.fg_ind(:);
    for inlist=1:numel(fgid)
        inorig=find(UserData.Profile{ti}.fit.(channel).LoGxy.fg.id==old_fgid(inlist));
        if ~isempty(inorig)
            mu(inlist)=UserData.Profile{ti}.fit.(channel).LoGxy.fg.mu(inorig);
            amp(inlist)=UserData.Profile{ti}.fit.(channel).LoGxy.fg.amp(inorig);
            sig(inlist)=UserData.Profile{ti}.fit.(channel).LoGxy.fg.sig(inorig);
            flg(inlist)=UserData.Profile{ti}.fit.(channel).LoGxy.fg.flag(inorig);
        end
    end
    
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.ind=ind;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.mu=mu;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.sig=sig;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.amp=amp;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.id=fgid;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.manid=manid;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.autoid=autoid;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.flag=flg;
    
    [~,si]=sort(UserData.Profile{ti}.fit.(channel).LoGxy.fg.ind);
    fn=fieldnames(UserData.Profile{ti}.fit.(channel).LoGxy.fg);
    for f=1:numel(fn)
        UserData.Profile{ti}.fit.(channel).LoGxy.fg.(fn{f})=UserData.Profile{ti}.fit.(channel).LoGxy.fg.(fn{f})(si);
    end
end
hf.UserData=UserData;
end

%--------------------------------------------------------------------------
function [AM,matchidnew] = addrempeaklblAM (origid,matchid)
%This function takes a list of unique bouton id and matched bouton id
%to create an adjacency matrix. matchid is updated to reflect AM. This will
%be used to ensure consistency after changing bouton labels.

AM=zeros(size(origid,1));
matchidnew=nan(size(origid,1),1);
mid=unique(matchid(~isnan(matchid)));
for m=1:numel(mid)
    conid=sort(origid(matchid==mid(m)));
    matchidnew(matchid==mid(m))=conid(1);
    [~,AMind] = ismember(conid,origid);
    for i=1:(numel(AMind)-1)
        AM(AMind(i),AMind(i+1))=conid(1);
        AM(AMind(i+1),AMind(i))=conid(1);
    end
end
end