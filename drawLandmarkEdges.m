function drawLandmarkEdges(hf)
%This plots landmark points connected by edges. Landmark edges are shown
%only if mode is 'Align Traces' or 'Annotate Traces', otherwise it deletes any
%existing edges from the axis. This obtains positions based on trace
%already present on the plot.

h_axis=findobj(hf.Children,'flat','Tag','Axis');

%Delete any existing landmark edges and associated context menus.
delete(findobj(hf.Children,'flat','Tag','LandmarkEdgeCM'));
delete(findobj(h_axis.Children,'flat','Tag','LandmarkEdges'));

h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
%Following condition implies that current mode is 'Align Traces' or 'Annotate Traces':
if strcmp(h_mode.SelectedObject.String,'Align Traces')
    
    %Find traces:
    h_trace=cell(1);
    for ti=1:numel(hf.UserData.Profile)
        h_trace{ti}=findobj(h_axis.Children,'flat','Tag',['Trace-',num2str(ti)]);
    end
    
    %Obtain co-ordinates of landmark vertices and plot:
    for i=1:size(hf.UserData.AlignVerts.ind,2)
        xdat=nan(numel(hf.UserData.Profile),1);
        ydat=nan(numel(hf.UserData.Profile),1);
        for ti=1:numel(hf.UserData.Profile)
            xdat(ti)=h_trace{ti}.XData(hf.UserData.AlignVerts.ind(ti,i));
            ydat(ti)=h_trace{ti}.YData(hf.UserData.AlignVerts.ind(ti,i));
        end
        temp=uicontextmenu;
        temp.Tag='LandmarkEdgeCM';
        dat.ind=hf.UserData.AlignVerts.ind(:,i);
        plot(xdat,ydat,'o-y','Parent',h_axis,'Tag','LandmarkEdges','UIContextMenu',temp,'UserData',dat)
        uimenu(temp,'Label','Remove Landmark','Callback',{@remLandmark,hf})
    end
end
end