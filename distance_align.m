function [Time] = distance_align(Time)
%This code aligns profile distance in an all-to-all manner based on edges
%added using the GUI. The function expects the following fields:
% Time.d: original distance
% Time.d_man: aligned distance
% Time.fg_manid: nan if not matched to anything
% Time.fg_ind: index of point along trace
% Time.deform_man: deformation measure after alignment

Time{1}.d_man=Time{1}.d;
Time{1}.deform_man=zeros(size(Time{1}.d));

for ti=2:numel(Time)
    nodeind=~isnan(Time{ti}.fg_manid);
    now.lbl=Time{ti}.fg_manid(nodeind);
    now.dind=Time{ti}.fg_ind(nodeind);
    now.d=Time{ti}.d(now.dind);
    
    found.lbl=[];
    found.t=[];
    found.d=[];
    
    for pt=(ti-1):-1:1
        %Find all linked nodes at previous time 'pt'
        nodeind=~isnan(Time{pt}.fg_manid);
        temp.lbl=Time{pt}.fg_manid(nodeind);
        temp.dind=Time{pt}.fg_ind(nodeind);
        temp.d=Time{pt}.d_man(temp.dind);
        
        %Discard peaks not linked at current time 'ti'
        [~,ind,~]=intersect(temp.lbl,now.lbl);
        found.lbl=[found.lbl;temp.lbl(ind)];
        found.t=[found.t;pt*ones(length(ind),1)];
        found.d=[found.d;temp.d(ind)];
    end
    
    if ~isempty(ind)
        [~,keep]=unique(found.lbl);
        found.lbl=found.lbl(keep);
        found.t=found.t(keep);
        found.d=found.d(keep);
        
        [~,~,ind]=intersect(found.lbl,now.lbl);
        now.lbl=now.lbl(ind);
        now.dind=now.dind(ind);
        now.d=now.d(ind);
        
        [~,ind]=sort(found.d);
        found.lbl=found.lbl(ind);
        found.t=found.t(ind);
        found.d=found.d(ind);
        
        [~,ind]=sort(now.d);
        now.lbl=now.lbl(ind);
        now.dind=now.dind(ind);
        now.d=now.d(ind);
        
        %Align using all found links
        Time{ti}.d_man=Time{ti}.d;
        Time{ti}.deform_man=zeros(size(Time{ti}.d));
        
        if length(now.lbl)==1
            shift=found.d(1)-now.d(1);
            Time{ti}.d_man=Time{ti}.d+shift;
        else
            for i=1:length(now.lbl)-1
                now.d=Time{ti}.d(now.dind);
                
                stretch=(found.d(i+1)-found.d(i))/(now.d(i+1)-now.d(i));
                Time{ti}.d_man(now.dind(i):now.dind(i+1))=stretch*Time{ti}.d(now.dind(i):now.dind(i+1));
                
                shift=found.d(i)-Time{ti}.d_man(now.dind(i));
                Time{ti}.d_man(now.dind(i):now.dind(i+1))=Time{ti}.d_man(now.dind(i):now.dind(i+1))+shift;
                
                %First piece
                if i==1
                    shift=found.d(i)-now.d(i);
                    Time{ti}.d_man(1:now.dind(i)-1)=Time{ti}.d_man(1:now.dind(i)-1)+shift;
                end
                
                %Last piece
                if i==length(now.lbl)-1
                    shift=found.d(i+1)-now.d(i+1);
                    Time{ti}.d_man(now.dind(i+1):end)=Time{ti}.d(now.dind(i+1):end)+shift;
                end
                s=abs((Time{ti}.d_man(now.dind(i+1))-Time{ti}.d_man(now.dind(i)))/(Time{ti}.d(now.dind(i+1))-Time{ti}.d(now.dind(i))));
                Time{ti}.deform_man(now.dind(i):now.dind(i+1))=abs((s-1)/(s+1));
            end
        end
    end
end
end



