function [n1,n2] = remEdge (src,ed,hf)
x0=ed.IntersectionPoint(1);
y0=ed.IntersectionPoint(2);
x1=src.XData(1:end-1);
x2=src.XData(2:end);
y1=src.YData(1:end-1);
y2=src.YData(2:end);

%Find distance of the intersection point from line passing through pair of
%successive points on the line. The pair of points on the line for which
%this is minimum identify the edge that was clicked on.

[~,n1]=min(((y2-y1).*x0-(x2-x1).*y0+x2.*y1-y2.*x1).^2./((y2-y1).^2+(x2-x1).^2));
n2=src.UserData.vertind(n1+1);
n1=src.UserData.vertind(n1);
hf.UserData.Graph.AM(n1,n2)=0;
hf.UserData.Graph.AM(n2,n1)=0;

hf.UserData.Graph.updatelbl=[str2double(src.Tag(6:end)),...
    hf.UserData.Graph.fg_id(n1),...
    hf.UserData.Graph.fg_id(n2)];

%Graph is relabeled in drawEdges, within UpdatePlots
deselectVert([],[],hf);
updatePlots(hf,5);
end