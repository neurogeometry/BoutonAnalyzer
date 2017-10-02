function [] = Graph2Profile(hf)
%Transfers the updates done to Graph using the GUI for matching into
%individual profile structures.

UserData=hf.UserData;hf.UserData=[];
channel=UserData.inform.channel{1};

%Coverting to cell format used by distance_align that incorporates matches
%based on UserData.Graph:
Time=cell(numel(UserData.Profile),1);
for ti=1:numel(UserData.Profile)
    Time{ti}.d=UserData.Profile{ti}.d.optim;
    Time{ti}.d_man=Time{ti}.d;
    Time{ti}.fg_ind=UserData.Graph.fg_ind(UserData.Graph.t==ti);
    Time{ti}.fg_manid=UserData.Graph.fg_manid(UserData.Graph.t==ti);
    Time{ti}.deform_man=zeros(size(Time{ti}.d));
end
Time=distance_align(Time);

%Updating UserData.Profile fields:
for ti=1:numel(UserData.Profile)
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.id=UserData.Graph.fg_id(UserData.Graph.t==ti);
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.manid=UserData.Graph.fg_manid(UserData.Graph.t==ti);
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.flag=UserData.Graph.fg_flag(UserData.Graph.t==ti);
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.flag(UserData.Profile{ti}.fit.(channel).LoGxy.fg.flag==0)=nan;
    UserData.Profile{ti}.fit.(channel).LoGxy.d.man=Time{ti}.d_man;
    UserData.Profile{ti}.fit.(channel).LoGxy.deform.man=Time{ti}.deform_man;
end

hf.UserData=UserData;
end