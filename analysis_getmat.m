function [AxonMat] = analysis_getmat(An)
%This function creates matrices for analysis from registered data. Input is
%obtained from BoutonAnalyzer via saveProfile.m

channel=fieldnames(An{1}.fit);
remchannelind=false(numel(channel),1);
for i=1:numel(channel)
    remchannelind(i)=isempty(fieldnames(An{1}.fit.(channel{i})));
end
channel(remchannelind)=[];

fitshape='G'; %This should be the same as used in fitLoGxy.m and fitGauss.m
if strcmp(fitshape,'G')
    Ff = @(x,A,mu,sigma) (ones(size(x))*A).*exp(-(x*ones(size(A))-ones(size(x))*mu).^2./(ones(size(x))*sigma.^2)./2);
elseif strcmp(fitshape,'L')
    Ff = @(x,A,mu,sigma) (ones(size(x))*A)./((x*ones(size(A))-ones(size(x))*mu).^2./(ones(size(x))*sigma.^2)+1);
end

for ch=1:numel(channel)
    %1. Initializing matrices----------------------------------------------
    n_times=numel(An);
    max_nbtns=0;
    for ti=1:n_times
        max_nbtns=max_nbtns+numel(An{ti}.fit.(channel{ch}).LoGxy.fg.ind);
    end
    
    AxonMat.btn_id=nan(1,max_nbtns);                 %(1 x btn)This is bouton lbl assigned during registration
    AxonMat.flag=nan(n_times,max_nbtns);             %(time x btn) Flags are assigned during registration
    AxonMat.ind=nan(n_times,max_nbtns);              %(time x btn) Index along corresponding profile
    AxonMat.d=nan(1,max_nbtns);                      %(1 x btn) 1d position along the aligned profile
    AxonMat.dorig=nan(n_times,max_nbtns);            %(time x btn) 1d position along the original profile
    AxonMat.blen=nan(n_times,max_nbtns);             %(time x btn) length associated with bouton
    AxonMat.rx=nan(n_times,max_nbtns);               %(time x btn) 3d x-position of peak in each time point
    AxonMat.ry=nan(n_times,max_nbtns);               %(time x btn) 3d y-position of peak in each time point
    AxonMat.rz=nan(n_times,max_nbtns);               %(time x btn) 3d z-position of peak in each time point
    
    AxonMat.Iraw=nan(n_times,max_nbtns);             %Non-normalized intensity at location on profile.
    AxonMat.Inorm=nan(n_times,max_nbtns);            %Intensity at location on profile. Inorm is roughly Ifg+Ibg
    AxonMat.Ibg=nan(n_times,max_nbtns);              %Intensity of background at given foreground peak location
    AxonMat.sig=nan(n_times,max_nbtns);              %Peak width for every detected peak. nan otherwise
    AxonMat.amp=nan(n_times,max_nbtns);              %Intensity of fitted foreground peak. nan otherwise
    
    AxonMat.w=nan(n_times,max_nbtns);                %Normalized bouton weight
    AxonMat.P=nan(n_times,max_nbtns);                %Probability using noise model
    
    %2. Populating matrices------------------------------------------------
    dmin=-inf;dmax=inf;
    Ibg=cell(n_times,1);
    for ti=1:n_times
        Axon=An{ti};
        
        dmin=max([(Axon.fit.(channel{ch}).LoGxy.d.man(1)),dmin]);
        dmax=min([(Axon.fit.(channel{ch}).LoGxy.d.man(end)),dmax]);
        nanind=isnan(Axon.fit.(channel{ch}).LoGxy.fg.manid);
        
        %Boutons not matched are assigned manid=fg.id.
        Axon.fit.(channel{ch}).LoGxy.fg.manid(nanind)=Axon.fit.(channel{ch}).LoGxy.fg.id(nanind);
        
        [~,matind]=ismember(Axon.fit.(channel{ch}).LoGxy.fg.manid,AxonMat.btn_id);
        startind=find(isnan(AxonMat.btn_id),1,'first');
        endind=startind+sum(matind==0)-1;
        matind(matind==0)=startind:endind;
        
        AxonMat.btn_id(1,matind)=Axon.fit.(channel{ch}).LoGxy.fg.manid;
        AxonMat.flag(ti,matind)=Axon.fit.(channel{ch}).LoGxy.fg.flag;
        AxonMat.ind(ti,matind)=Axon.fit.(channel{ch}).LoGxy.fg.ind;
        AxonMat.d(1,matind)=Axon.fit.(channel{ch}).LoGxy.d.man(Axon.fit.(channel{ch}).LoGxy.fg.ind);
        AxonMat.dorig(ti,matind)=Axon.d.optim(Axon.fit.(channel{ch}).LoGxy.fg.ind);
        
        %Extra peaks are assumed as removed from dataset.
        temp=diff([dmin,AxonMat.d(1,matind),dmax]);
        blen=(temp(1:end-1)+temp(2:end))./2;
        blen(1)=blen(1)+temp(1)/2;
        blen(end)=blen(end)+temp(end)/2;
        AxonMat.blen(ti,matind)=blen;
        
        AxonMat.rx(ti,matind)=Axon.r.optim(Axon.fit.(channel{ch}).LoGxy.fg.ind,1);
        AxonMat.ry(ti,matind)=Axon.r.optim(Axon.fit.(channel{ch}).LoGxy.fg.ind,2);
        AxonMat.rz(ti,matind)=Axon.r.optim(Axon.fit.(channel{ch}).LoGxy.fg.ind,3);
        
        AxonMat.Iraw(ti,matind)=Axon.I.(channel{ch}).LoGxy.raw(Axon.fit.(channel{ch}).LoGxy.fg.ind);
        AxonMat.Inorm(ti,matind)=Axon.I.(channel{ch}).LoGxy.norm(Axon.fit.(channel{ch}).LoGxy.fg.ind);
        
        %If peaks were added manually, their intensity is nan after
        %operations by gui_alignment. Here those intensities are
        %replaced with intensity at the aligned profile location
        man_addedpeaks=find(isnan(Axon.fit.(channel{ch}).LoGxy.fg.amp));
        if numel(man_addedpeaks)>0
            Axon.fit.(channel{ch}).LoGxy.fg.amp(man_addedpeaks)=...
                Axon.I.(channel{ch}).LoGxy.norm(Axon.fit.(channel{ch}).LoGxy.fg.ind(man_addedpeaks));
        end
        AxonMat.amp(ti,matind)=Axon.fit.(channel{ch}).LoGxy.fg.amp;
        AxonMat.sig(ti,matind)=Axon.fit.(channel{ch}).LoGxy.fg.sig;
        
        Ibg{ti}=zeros(size(Axon.d.optim));
        for p=1:numel(Axon.fit.(channel{ch}).LoGxy.bg.ind)
            Ibg{ti}=Ibg{ti}+Ff(Axon.d.optim,Axon.fit.(channel{ch}).LoGxy.bg.amp(p),...
                Axon.fit.(channel{ch}).LoGxy.bg.mu(p),...
                Axon.fit.(channel{ch}).LoGxy.bg.sig(p));
        end
        AxonMat.Ibg(ti,matind)=Ibg{ti}(Axon.fit.(channel{ch}).LoGxy.fg.ind);
    end
    
    %3. Removing boutons based on flag & overlap---------------------------
    fldnm=fieldnames(AxonMat);
    
    %Remove extra columns from initialization
    remind=find(sum(isnan(AxonMat.ind),1)==size(AxonMat.ind,1));
    remind=unique(remind);
    for f=1:numel(fldnm)
        AxonMat.(fldnm{f})(:,remind)=[];
    end
    
    %Assign distances to each peak before removing based on
    %flags or non-overlapping axon region.
    %Convention for flags:
    %{
    '0: No match provided (default)
    '1: Confirmed no match
    '2: Ignore, noisy intensity
    '3: Ignore, terminal bouton intensity
    '4: Ignore, cross-over
    %}
    temp=AxonMat.flag;
    temp(isnan(temp))=0;%because nan~=0 returns true;
    temp=temp~=0 & temp~=1;
    [~,remind1]=find(temp);
    
    remind2=find(AxonMat.d<dmin | AxonMat.d>dmax);
    
    remind=unique([remind1(:);remind2(:)]);
    for f=1:numel(fldnm)
        AxonMat.(fldnm{f})(:,remind)=[];
    end
    
    %Sortind boutons in every axon by distance
    [~,sortind]=sort(AxonMat.d);
    for f=1:numel(fldnm)
        AxonMat.(fldnm{f})=AxonMat.(fldnm{f})(:,sortind);
    end
    
    %4. Replace nans with corresponding value on profile-------------------
    for ti=1:n_times
        Axon=An{ti};
        
        nanind=find(isnan(AxonMat.ind(ti,:)));
        nanind=nanind(:)';
        
        [~,minind]=min(abs(bsxfun(@minus,AxonMat.d(nanind),Axon.fit.(channel{ch}).LoGxy.d.man(:))),[],1);
        AxonMat.ind(ti,nanind)=minind;
        
        AxonMat.dorig(ti,nanind)=Axon.d.optim(minind);
        AxonMat.rx(ti,nanind)=Axon.r.optim(minind,1);
        AxonMat.ry(ti,nanind)=Axon.r.optim(minind,2);
        AxonMat.rz(ti,nanind)=Axon.r.optim(minind,3);
        AxonMat.Iraw(ti,nanind)=Axon.I.(channel{ch}).LoGxy.raw(minind);
        AxonMat.Inorm(ti,nanind)=Axon.I.(channel{ch}).LoGxy.norm(minind);
        AxonMat.Ibg(ti,nanind)=Ibg{ti}(minind);
    end
    
    %Related to normalization
    Norm=nan(n_times,1);
    for ti=1:n_times
        %Calculate normalization only based on current time:
        Gauss_bg=zeros(size(An{ti}.d.optim));
        for i=1:numel(An{ti}.fit.(channel{ch}).Gauss.bg.ind)
            Gauss_bg=Gauss_bg+Ff(An{ti}.d.optim,...
                An{ti}.fit.(channel{ch}).Gauss.bg.amp(i),...
                An{ti}.fit.(channel{ch}).Gauss.bg.mu(i),...
                An{ti}.fit.(channel{ch}).Gauss.bg.sig(i));
        end
        Norm(ti)=mean(Gauss_bg(~An{ti}.annotate.ignore));
    end
    Norm=mean(Norm);
    AxonMat.w=AxonMat.amp;
    AxonMat.w(isnan(AxonMat.w))=AxonMat.Inorm(isnan(AxonMat.w));
    AxonMat.w=AxonMat.w./Norm;
    AxonMat.w(AxonMat.w<0)=0;
    AxonMat.P=fP(AxonMat.w);
end
end

function P=fP(varargin)
alpha=0.2389;
wthr=2;
w=varargin{1};
if nargin==2
    thr=varargin{2};
else
    thr=wthr;
end
P=nan(size(w));
w(w<eps)=abs(eps);
P(:)=0.5*(1+erf((w(:)-thr)./((alpha*w(:)).^0.5)));
end