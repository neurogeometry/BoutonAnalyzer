function drawIgnore(hf)
%Draws annotated regions on the axis if in 'Annotate Traces' mode

h_axis=findobj(hf.Children,'flat','Tag','Axis');
h_ignore=findobj(h_axis.Children,'flat','Tag','Ignored');
delete(h_ignore);

h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');

if strcmp(h_mode.SelectedObject.String,'Annotate Traces')
    for ti=1:numel(hf.UserData.Profile)
        h_trace=findobj(h_axis.Children,'flat','Tag',['Trace-',num2str(ti)]);
        showind=hf.UserData.Profile{ti}.annotate.ignore;
        plot(h_trace.XData(showind),h_trace.YData(showind),'o','Color',[0.5 0 0],'Tag','Ignored','HitTest','off')
        uistack(h_trace,'top')
    end
end
end