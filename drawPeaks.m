function h_peaks=drawPeaks(hf)
%Draws peaks on the axis if in 'Detect Peaks' mode, with the seleccted
%object being 'Edit Peaks'

h_axis=findobj(hf.Children,'flat','Tag','Axis');

h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
h_object=findobj(h_operationpanel.Children,'flat','Tag','Object');

if strcmp(h_mode.SelectedObject.String,'Detect Peaks') && strcmp(h_object.SelectedObject.String,'Edit Peaks')
    cc=lines(numel(hf.UserData.Profile));
    channel=hf.UserData.inform.channel{1};
    for ti=1:numel(hf.UserData.Profile)
        udata.ti=ti;
        udata.fgind=hf.UserData.Profile{ti}.fit.(channel).LoGxy.fg.ind;
        cnvs_peaks_x=hf.UserData.Profile{ti}.r.optim(udata.fgind,1)+hf.UserData.shiftx(ti);
        cnvs_peaks_y=hf.UserData.Profile{ti}.r.optim(udata.fgind,2)+hf.UserData.shifty(ti);
        h_peaks=findobj(h_axis.Children,'flat','Tag',['Peaks-',num2str(ti)]);
        
        if isempty(h_peaks)
            h_peaks=plot(cnvs_peaks_y,cnvs_peaks_x,'^','MarkerSize',12,'Color',cc(ti,:),...
                'UserData',udata,'ButtonDownFcn',{@selectVert,hf},...
                'Parent',h_axis,'Tag',['Peaks-',num2str(ti)]);
        else
            h_peaks.XData=cnvs_peaks_y;
            h_peaks.YData=cnvs_peaks_x;
            h_peaks.UserData=udata;
        end
        uistack(h_peaks,'top');
    end
    drawnow;
    
else
    for ti=1:numel(hf.UserData.Profile)
        delete(findobj(h_axis.Children,'flat','Tag',['Peaks-',num2str(ti)]));
    end
end
end