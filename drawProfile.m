function [] = drawProfile(src,ed,hf)
%Plots profiles to mark active point for reference.
h_axis=findobj(hf.Children,'flat','Tag','Axis');
h_sv=findobj(h_axis.Children,'flat','Tag','SelVerts');
channel=hf.UserData.inform.channel{1};
if ~isempty(h_sv.Children)
    tt=h_sv.Children.UserData.t;
    indd=h_sv.Children.UserData.ind;
    UserData=hf.UserData;
    dplot=UserData.Profile{tt}.d.optim;
    Iplot=UserData.Profile{tt}.I.(channel).LoGxy.norm;
    fg=UserData.Profile{tt}.fit.(channel).LoGxy.fg;
    bg=UserData.Profile{tt}.fit.(channel).LoGxy.bg;
    
    %Check if figure present or create one and position it
    if isobject(hf.UserData.profilefig)
        hfp=hf.UserData.profilefig;
    end
    
    if isvalid(hfp)
        hfp.Visible='on';
        hfp.Units='pixels';
    else
        hfp=figure('Visible','on');
        hfp.Units='pixels';
        hf.UserData.profilefig=hfp;
    end
    hfp.Position=[hf.Position(1)+hf.Position(3),...
        hf.Position(2)+hf.Position(4)-hf.Position(4)/2.5,...
        hf.Position(3)/2,...
        hf.Position(4)/2.5];
    
    %Check if axis present or create one
    ax=findobj(hfp.Children,'flat','Tag','Axis');
    if isempty(ax)
        ax=axes('Parent',hfp,'Tag','Axis');
    else
        cla(ax);
    end
    
    %Check if profile present and is of the same timepoint
    hp=findobj(hf.UserData.profilefig,'Tag','Profile');
    replot=false;
    if ~isempty(hp)
        if tt==hp.UserData.t
            h_svprofile=findobj(hfp,'Tag','SelVerts');
            h_svprofile.XData=dplot(indd);
            h_svprofile.YData=Iplot(indd);
        else
            replot=true;
        end
    end
    
    if (isempty(hp) || replot || strcmp(src,'Edit'))
        cla(ax);
        cc=lines(7);
        Ff = @(x,A,mu,sigma) (ones(size(x))*A).*exp(-(x*ones(size(A))-ones(size(x))*mu).^2./(ones(size(x))*sigma.^2)./2);
        
        %Fitted peaks
        for i=1:numel(fg.ind)
            xx=(-5:0.1:+5)+dplot(fg.ind(i));
            yy=Ff(xx,fg.amp(i),dplot(fg.ind(i)),fg.sig(i));
            pxx=[xx(1);xx(:);xx(end)];pyy=[0;yy(:);0];
            patch('XData',pxx,'YData',pyy,'Parent',ax,'EdgeColor',[0.6 0.6 0.6],'FaceColor',[1 1 1],'FaceAlpha',0.1),hold on;
        end
        
        %Fitted background
        Ibg=zeros(size(dplot));
        for i=1:numel(bg.ind)
            Ibg=Ibg+Ff(dplot,bg.amp(i),dplot(bg.ind(i)),bg.sig(i));
        end
        plot(dplot,Ibg,'-','Color',[0.6 0.6 0.6],'LineWidth',1,'Parent',ax)
        
        %Peaks added by user
        added=find(isnan(fg.sig));
        for i=1:numel(added)
            xx=dplot(fg.ind(added(i)));
            yy=Iplot(fg.ind(added(i)))-Ibg(fg.ind(added(i)));
            plot([xx,xx],[0,yy],'-','Color',[1 1 1],'LineWidth',2,'Parent',ax),hold on;
        end
        
        %Profile
        plot(dplot,Iplot,'-','Color',cc(mod(tt-1,7)+1,:),'LineWidth',1.5,'Parent',ax,...
            'Tag','Profile','UserData',struct('t',tt));hold on
        
        plot(dplot(indd),Iplot(indd),'o','MarkerSize',12,'LineWidth',1.5,'Color',[0 1 0],'Parent',ax,...
            'Tag','SelVerts','UserData',struct('t',tt,'ind',indd));hold on
    end
    ax.Color=[0.2 0.2 0.2];
    ax.XLim=[dplot(indd)-15,dplot(indd)+15];
    ax.YLim=[0,10];
    ax.XLabel.String='Distance, \mu{m}';
    ax.YLabel.String='LoGxy Intensity, A.U.';
end
end

