function Profile2Graph(hf)
%This function creates graph representation with fitted peaks across
%timepoints as nodes, and matched peaks connected by edges.

UserData=hf.UserData;hf.UserData=[];
channel=UserData.inform.channel{1};

n_nodes=0;
for ti=1:numel(UserData.Profile)
    n_nodes=n_nodes+numel(UserData.Profile{ti}.fit.(channel).LoGxy.fg.id);
end

Graph.AM=zeros(n_nodes);
Graph.r=nan(n_nodes,2);
Graph.t=nan(n_nodes,1);
Graph.nodeind=nan(n_nodes,1);
Graph.fg_id=nan(n_nodes,1);
Graph.fg_manid=nan(n_nodes,1);
Graph.fg_ind=nan(n_nodes,1);
Graph.fg_flag=nan(n_nodes,1);
Graph.updatelbl=[];%This is used to update only selected labels while plotting
ss=1;
for ti=1:numel(UserData.Profile)
    ee=ss+numel(UserData.Profile{ti}.fit.(channel).LoGxy.fg.id)-1;
    Graph.t(ss:ee)=ti;
    Graph.r(ss:ee,:)=UserData.Profile{ti}.r.optim((UserData.Profile{ti}.fit.(channel).LoGxy.fg.ind),[1,2]);
    Graph.nodeind(ss:ee)=(1:numel(UserData.Profile{ti}.fit.(channel).LoGxy.fg.id));
    Graph.fg_id(ss:ee)=UserData.Profile{ti}.fit.(channel).LoGxy.fg.id;
    Graph.fg_manid(ss:ee)=UserData.Profile{ti}.fit.(channel).LoGxy.fg.manid;
    Graph.fg_ind(ss:ee)=UserData.Profile{ti}.fit.(channel).LoGxy.fg.ind;
    Graph.fg_flag(ss:ee)=UserData.Profile{ti}.fit.(channel).LoGxy.fg.flag;
    ss=ee+1;
end

%Initialize AM from loaded data
mid=unique(Graph.fg_manid(~isnan(Graph.fg_manid)));
for m=1:numel(mid)
    ind=find(Graph.fg_manid==mid(m));
    for i=1:(numel(ind)-1)
        Graph.AM(ind(i),ind(i+1))=mid(m);
        Graph.AM(ind(i+1),ind(i))=mid(m);
    end
end
[Graph.AM,Graph.fg_manid]=relabelGraph(Graph.AM,Graph.fg_id);
UserData.Graph=Graph;
hf.UserData=UserData;
end