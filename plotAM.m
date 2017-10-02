% This function plots the tree structure contained in AM.
% The function works with labeled or not labeled AM.
% AM can be directed or undirected.
% The labels don't have to be consecutive.

function h=plotAM(AM,r,col)

if size(r,2)==2
    r=[r,zeros(size(r,1),1)];
end

AM = max(AM,AM');
AM = triu(AM);

Labels=full(AM(AM(:)>0));
Labels=unique(Labels);
L=numel(Labels);
if isempty(col)
    cc=lines(L);
else
    cc=col;
end

h=hggroup;
for f=1:L
    [i,j]=find(AM==Labels(f));
    X=[r(i,1),r(j,1)]';
    Y=[r(i,2),r(j,2)]';
    Z=[r(i,3),r(j,3)]';
    line(Y,X,Z,'Color',cc(L,:),'LineWidth',1,'Parent',h);
end
