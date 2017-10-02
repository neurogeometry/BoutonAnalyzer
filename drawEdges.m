function drawEdges(hf)
%This plots both peak vertices and the lines indicating matches
h_axis=findobj(hf.Children,'flat','Tag','Axis');

h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
h_object=findobj(h_operationpanel.Children,'flat','Tag','Object');

if strcmp(h_mode.SelectedObject.String,'Detect Peaks') && strcmp(h_object.SelectedObject.String,'Match Peaks')
    %All matched nodes receive label corresponding to the earliest node that is
    %part of the list.
    
    UserData=hf.UserData;hf.UserData=[];
    cnvs_peaks_x=UserData.Graph.r(:,1)+UserData.shiftx(UserData.Graph.t);
    cnvs_peaks_y=UserData.Graph.r(:,2)+UserData.shifty(UserData.Graph.t);
    
    for l=1:numel(UserData.Graph.updatelbl)
        %Deletes only labels that are affected when adding or removing edges
        delete(findobj(h_axis.Children,'flat','-regexp','Tag',['(Edge-',num2str(UserData.Graph.updatelbl(l)),')']));
    end
    
    [UserData.Graph.AM,UserData.Graph.fg_manid]=relabelGraph(UserData.Graph.AM,UserData.Graph.fg_id);
    
    %This block updates the full graph if no edges are already displayed
    %Used when modes are switched
    if isempty(findobj(h_axis.Children,'flat','-regexp','Tag','(Edge-)'))
        lbl_list=UserData.Graph.AM(UserData.Graph.AM>0);
        lbl_list=unique(lbl_list);
    else
        lbl_list=UserData.Graph.updatelbl;
    end
    cc=lines(7);
    
    %One line plot per label
    for l=1:numel(lbl_list)
        [n1,n2]=find(UserData.Graph.AM==lbl_list(l));
        if ~(isempty(n1) || isempty(n2))
            n1=n1(:);n2=n2(:);
            X=cnvs_peaks_x([n1;n2(end)]);
            Y=cnvs_peaks_y([n1;n2(end)]);
            nodestr.vertind=[n1;n2(end)];
            line(Y,X,'Color',cc((mod(lbl_list(l),7))+1,:),'LineWidth',1,...
                'Tag',['Edge',sprintf('-%d',lbl_list(l))],...
                'UserData',nodestr,...
                'ButtonDownFcn',{@remEdge,hf},'Parent',h_axis)
        end
    end
    UserData.Graph.updatelbl=[];
    drawnow;
    hf.UserData=UserData;

else
    delete(findobj(h_axis.Children,'flat','-regexp','Tag','(Edge-)'));
end
end