function selectVert(src,ed,hf)
%This callback on selectable vertices updates the list of selected vertices
%on left clicks. Right clicking selectable vertices will open a context
%menu
h_axis=findobj(hf.Children,'flat','Tag','Axis');
h_sv=findobj(h_axis.Children,'flat','Tag','SelVerts');

h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');

switch h_mode.SelectedObject.String
    case 'Align Traces'
        if strcmp(hf.SelectionType,'normal')
            if ~isempty(regexp(src.Tag,'(Trace)','once'))
                %If clicked object is the trace:
                vert.t=src.UserData.t;
                [~,vert.ind]=min(sum(abs(bsxfun(@minus,[src.XData(:),src.YData(:)],ed.IntersectionPoint(1:2))),2));
                vert.type='Trace';
                
                %Generate others and tag as inactive
                if isempty(h_sv.Children)
                    d_this=hf.UserData.Profile{vert.t}.d.alignedxy(vert.ind);
                    for t_other=1:numel(hf.UserData.Profile)
                        if t_other~=vert.t
                            h_trace=findobj(h_axis.Children,'Tag',['Trace-',num2str(t_other)]);
                            vert_this.t=t_other;
                            [~,vert_this.ind]=min(abs(hf.UserData.Profile{t_other}.d.alignedxy-d_this));
                            vert_this.type='Trace';
                            plot(h_trace.XData(vert_this.ind),h_trace.YData(vert_this.ind),...
                                'o','MarkerSize',10,'Color',[0.3 0.5 0.3],'LineWidth',1.5,...
                                'UserData',vert_this,'ButtonDownFcn',{@selectVert,hf},'Tag','Inactive','Parent',h_sv);hold on
                        end
                    end
                end
                
                
                h_active=plot(src.XData(vert.ind),src.YData(vert.ind),...
                    'o','MarkerSize',10,'Color',[0 1 0],'LineWidth',1.5,...
                    'UserData',vert,'ButtonDownFcn',{@selectVert,hf},'Tag','Current','Parent',h_sv);
                
                
            elseif ~isempty(regexp(src.Tag,'(ctive)','start'))
                %If clicked object belongs to list of vertices
                h_active=src;
                h_active.Color=[0 1 0];
                h_active.Tag='Current';%Temporary tag
            end
            
            %Find previously active vertex and tag as Inactive.
            del_i=[];
            h_others=findobj(h_sv,'-regexp','Tag','(ctive)');
            if ~isempty(h_others)
                for i=1:numel(h_others)
                    h_others(i).Tag='Inactive';
                    h_others(i).Color=[0.3 0.5 0.3];
                    %Delete previous vertex on same time point
                    if h_others(i).UserData.t==h_active.UserData.t
                        del_i=i;
                    end
                end
                if ~isempty(del_i)
                    delete(h_others(del_i).UIContextMenu);
                    delete(h_others(del_i));
                end
            end
            h_active.Tag='Active';
            uistack(h_sv,'top');
            
            cm=uicontextmenu;
            cm.Tag='SelVertCM';
            uimenu(cm,'Label','Add Landmark (a)','Callback',{@addLandmark,hf});
            uimenu(cm,'Label','Deselect All (d)','Callback',{@deselectVert,hf});
            set(h_sv.Children,'UIContextMenu',cm);
        end
        
    case 'Annotate Traces'
        if strcmp(hf.SelectionType,'normal')
            if ~isempty(regexp(src.Tag,'(Trace)','once'))
                vert.t=src.UserData.t;
                [~,vert.ind]=min(sum(abs(bsxfun(@minus,[src.XData(:),src.YData(:)],ed.IntersectionPoint(1:2))),2));
                vert.type='Trace';
                
                h_active=plot(src.XData(vert.ind),src.YData(vert.ind),...
                    'o','MarkerSize',10,'Color',[0 1 0],'LineWidth',1.5,...
                    'UserData',vert,'ButtonDownFcn',{@selectVert,hf},'Tag','Current','Parent',h_sv,'Selected','on','SelectionHighlight','on');
            elseif ~isempty(regexp(src.Tag,'(ctive)','start'))
                h_active=src;
                h_active.Color=[0 1 0];
                h_active.Tag='Current';%Temporary tag
            end
            
            %Find vertices on other times and delete.
            h_others=findobj(h_sv,'-regexp','Tag','(ctive)');
            del_i=nan(numel(h_others),1);
            if ~isempty(h_others)
                for i=1:numel(h_others)
                    h_others(i).Color=[0.3 0.5 0.3];
                    %Delete previous vertex is not on same time point
                    if h_others(i).UserData.t~=h_active.UserData.t
                        del_i(i)=i;
                    end
                end
                for i=1:numel(h_others)
                    if ~isnan(del_i)
                        delete(h_others(del_i(i)).UIContextMenu);
                        delete(h_others(del_i(i)));
                    end
                end
            end
            
            %If more than one vertex on the same time already present, one
            %of them is going to be the previously active vertex.
            h_others=findobj(h_sv,'-regexp','Tag','(ctive)');
            if numel(h_others)>1
                delete(findobj(h_sv,'-regexp','Tag','(Active)'));
            elseif numel(h_others)==1
                h_others.Tag='Inactive';
            end
            
            h_active.Tag='Active';
            uistack(h_sv,'top');
            
            if numel(h_sv.Children)==2
                optstate='on';
            else
                optstate='off';
            end
            cm=uicontextmenu;
            cm.Tag='SelVertCM';
            
            
            uimenu(cm,'Label','Ignore in all sessions','Callback',{@editIgnore,hf},'Tag','IA','Enable',optstate);
            uimenu(cm,'Label','Add in all sessions','Callback',{@editIgnore,hf},'Tag','AA','Enable',optstate);
            uimenu(cm,'Label','Ignore in current session','Callback',{@editIgnore,hf},'Tag','IC','Enable',optstate);
            uimenu(cm,'Label','Add in current session','Callback',{@editIgnore,hf},'Tag','AC','Enable',optstate);
            uimenu(cm,'Label','Deselect All (d)','Callback',{@deselectVert,hf});
            set(h_sv.Children,'UIContextMenu',cm);
        end
        
    case 'Detect Peaks'
        
        if ~isempty(regexp(src.Tag,'(Trace)','once'))%If clicked on obj is a trace point
            deselectVert([],[],hf);%Only 1 vertex can be selected at a time.
            
            vert.t=src.UserData.t;
            [~,vert.ind]=min(sum(abs(bsxfun(@minus,[src.XData(:),src.YData(:)],ed.IntersectionPoint(1:2))),2));
            vert.type='Trace';
            
            h_active=plot(src.XData(vert.ind),src.YData(vert.ind),...
                'o','MarkerSize',10,'Color',[0 1 0],'LineWidth',1.5,...
                'UserData',vert,'ButtonDownFcn',{@selectVert,hf},'Tag','Active','Parent',h_sv,'Selected','on','SelectionHighlight','on');
            cm=uicontextmenu;
            cm.Tag='SelVertCM';
            uimenu(cm,'Label','Add Peak (a)','Callback',{@addPeak,hf});
            uimenu(cm,'Label','Show on profile','Callback',{@drawProfile,hf},'Enable','on');
            set(h_sv.Children,'UIContextMenu',cm);
            uistack(h_sv,'top');
            
        elseif ~isempty(regexp(src.Tag,'(Peaks)','start'))%If clicked on obj is a peak
            deselectVert([],[],hf);%Only 1 vertex can be selected at a time.
            cm=uicontextmenu;
            cm.Tag='SelVertCM';
            vert.t=src.UserData.ti;
            [~,temp]=min(sum(abs(bsxfun(@minus,[src.XData(:),src.YData(:)],ed.IntersectionPoint(1:2))),2));
            %Calculate index along trace for the point found on the plotted
            %peaks:
            vert.ind=src.UserData.fgind(temp);
            vert.type='Peak';
            h_active=plot(src.XData(temp),src.YData(temp),...
                '^','MarkerSize',12,'Color',[0.8 0 0],'LineWidth',1.5,...
                'UserData',vert,'Tag','Active','Parent',h_sv,'Selected','on','SelectionHighlight','on');
            uimenu(cm,'Label','Remove Peak (r)','Callback',{@remPeak,hf});
            uimenu(cm,'Label','Show on profile','Callback',{@drawProfile,hf},'Enable','on');
            set(h_sv.Children,'UIContextMenu',cm);
            uistack(h_sv,'top');
            
        elseif ~isempty(regexp(src.Tag,'(Nodes)','start'))%If clicked on obj is a peak
            cm=uicontextmenu;
            cm.Tag='SelVertCM';
            
            %Calculate index along trace for the point found on the plotted
            %peaks:
            [~,ind]=min(sum(abs(bsxfun(@minus,[src.XData(:),src.YData(:)],ed.IntersectionPoint(1:2))),2));
            vert.nodeind=src.UserData.nodeind(ind);
            vert.fg_id=src.UserData.fg_id(ind);
            UserData=hf.UserData;
            graphind=UserData.Graph.fg_id==vert.fg_id;
            vert.t=UserData.Graph.t(graphind);
            vert.lbl=unique(nonzeros([UserData.Graph.AM(:,graphind);UserData.Graph.AM(graphind,:)']));
            if isempty(vert.lbl)
                vert.lbl=vert.fg_id;
            end
            vert.type='Node';
            
            h_active=plot(src.XData(ind),src.YData(ind),...
                'o','MarkerSize',12,'Color',[0 1 0],'LineWidth',1.5,...
                'UserData',vert,'Tag','Current','Parent',h_sv,'ButtonDownFcn',{@selectVert,hf});
            drawnow;
            %Delete other h_sv on the same time
            h_others=findobj(h_sv,'-regexp','Tag','MatchList');
            if ~isempty(h_others)
                for i=1:numel(h_others)
                    if h_others(i).UserData.t==h_active.UserData.t
                        delete(h_others(i).UIContextMenu);
                        delete(h_others(i));
                    end
                end
            end
            h_active.Tag='MatchList';
            optstate='off';
            if numel(h_sv.Children)>1
                optstate='on';
            end
            uimenu(cm,'Label','Match peaks (a)','Callback',{@addEdges,hf},'Enable',optstate);
            uimenu(cm,'Label','Flag peaks (f)','Callback',{@editFlag,hf});
            uimenu(cm,'Label','Deselect all (d)','Callback',{@deselectVert,hf});
            set(h_sv.Children,'UIContextMenu',cm);
            uistack(h_sv,'top');
            
            
        elseif strcmp(src.Tag,'MatchList')
            %If clicked object belongs to list of vertices
            if strcmp(hf.SelectionType,'normal')
                delete(src.UIContextMenu);
                delete(src);
            end
        end
        
end
end
