function drawTraces(hf)
%Draws/Updates existing traces on the canvas.

h_axis=findobj(hf.Children,'flat','Tag','Axis');hold(h_axis,'on');
UserData=hf.UserData;
h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
h_object=findobj(h_operationpanel.Children,'flat','Tag','Object');

h_stat={};
h_status_text={};
if strcmp(h_mode.SelectedObject.String,'Align Traces') || ...
        strcmp(h_mode.SelectedObject.String,'Annotate Traces') || ...
        (strcmp(h_mode.SelectedObject.String,'Detect Peaks') && strcmp(h_object.SelectedObject.String,'Edit Peaks'))
    cc=lines(numel(UserData.Profile));
    
    for ti=1:numel(UserData.Profile)
        h_trace=findobj(h_axis.Children,'flat','Tag',['Trace-',num2str(ti)]);
        cnvs_trace_x=UserData.Profile{ti}.r.optim(:,1)+UserData.shiftx(ti);
        cnvs_trace_y=UserData.Profile{ti}.r.optim(:,2)+UserData.shifty(ti);
        if ~isempty(h_trace)
            h_trace.XData=cnvs_trace_y;
            h_trace.YData=cnvs_trace_x;
        else
            h_trace=plot(cnvs_trace_y,cnvs_trace_x,'Color',cc(ti,:),...
                'Parent',h_axis,'Tag',['Trace-',num2str(ti)],...
                'UserData',struct('t',ti),'ButtonDownFcn',{@selectVert,hf});
        end
        h_stat{numel(h_stat)+1}=h_trace;
        h_status_text{numel(h_status_text)+1}=UserData.Profile{ti}.id;
        
    end

    if ~isempty(h_stat) 
        hl=legend([h_stat{:}],h_status_text);
        hl.Tag='Trace-Legend';
        mver=version;
        mver=str2double(mver(1:3));
        if mver>=9.0
            hl.Title.String='Axon id';
        end
        hl.FontSize=11;
        hl.FontName='Calibri';
        hl.TextColor=[0 0 0];
        hl.Location='northeast';
        allprops=fieldnames(hl);
        if any(strcmp(allprops,'AutoUpdate'))
            hl.AutoUpdate='off';
        end
    end
    drawnow
    
else
    delete(findobj(h_axis.Children,'flat','-regexp','Tag','(Trace-)'));
end
end