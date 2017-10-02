function [AMlbl,matchid] = relabelGraph(AM,fg_id)
%Produce AM where trees are labeled according to root node fg_id. matchid
%is nan unless there is at least one link connecting the node to other
%node(s).

matchid=nan(size(fg_id));
AM = spones(AM+AM');
AM=triu(AM);
AMlbl=zeros(size(AM));
AV = sort(find(sum(AM,2)));
if ~isempty(AV)
    startV=AV(1);
    TreeLabel=fg_id(startV);
    matchid(startV)=TreeLabel;
end

while ~isempty(AV)
    startVnew=find(sum(AM(startV,:),1));
    if ~isempty(startVnew)
        matchid(startVnew)=TreeLabel;
        AMlbl(startV,startVnew)=AM(startV,startVnew).*TreeLabel;
        AM(startV,startVnew)=0;
        AM(startVnew,startV)=0;
        startV=startVnew;
    else
        AV=find(sum(AM,2));
        if ~isempty(AV)
            startV=AV(1);
            TreeLabel=fg_id(startV);
            matchid(startV)=TreeLabel;
        end
    end
end
end