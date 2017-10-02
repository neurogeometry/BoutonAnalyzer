function Dat=fitLoGxy(Dat,channel)
% This function fits Gaussian profiles to find peaks in y
% Peaks are merged if separated by less than min_d
% Small peaks, less than min_A are eliminated
% Peaks with overlap greater than alpha are merged
% shape is 'G' or 'L'

paramset;
fprintf('\n--------------------------------------------------\n');
disp(['Fitting LoGxy profile for ', Dat.id])
fprintf('--------------------------------------------------\n');
fprintf('\n%-9s %-17s %-12s %-12s \n\n', 'Step','Peaks remaining','Cost(E)','abs(delE)/E');

I_axon=Dat.I.(channel).LoGxy.norm;
d_axon=Dat.d.optim;

min_d=params.fit.min_d;
alpha=params.fit.alpha;
shape='G';

% Parameters
Nsteps=params.fit.Nsteps;
min_change=params.fit.min_change;
betta0.A=params.fit.betta0;
betta0.mu=params.fit.betta0;
betta0.sigma=params.fit.betta0;

typical_bouton_size=2;
min_bouton_size=params.fit.min_bouton_size;
max_bouton_size=params.fit.max_bouton_size;
min_A=params.fit.min_A;

typical_background_size=params.fit.typical_background_size;
min_background_size=params.fit.min_background_size;

%--------------------------------------------------------------------------
LLL=d_axon(end)-d_axon(1);
N_bouton=ceil(LLL/min_d);%2
N_background=2*ceil(LLL/typical_background_size);

% boutons
A_bouton=(LLL/N_bouton/typical_bouton_size).*ones(1,N_bouton); min_A_bouton=0; max_A_bouton=max(I_axon)*1.2;
mu_bouton=(LLL/N_bouton).*(0.5:1:N_bouton-0.5); min_mu_bouton=0; max_mu_bouton=LLL;
sigma_bouton=(typical_bouton_size/4).*ones(1,N_bouton); min_sigma_bouton=min_bouton_size/4; max_sigma_bouton=max_bouton_size/4;

% background
A_background=0.3*ones(1,N_background); min_A_background=0; max_A_background=max(I_axon);
mu_background=(LLL/N_background).*(0.5:1:N_background-0.5); min_mu_background=0; max_mu_background=LLL;
sigma_background=(typical_background_size/4).*ones(1,N_background); min_sigma_background=min_background_size/4; max_sigma_background=inf;

%--------------------------------------------------------------------------
A=[A_bouton,A_background];
mu=[mu_bouton,mu_background];
sigma=[sigma_bouton,sigma_background];
N=N_bouton+N_background;
Label=[ones(1,N_bouton),zeros(1,N_background)];

count=1;
betta=betta0;
delE=inf;

I_fit=zeros(size(d_axon));
if strcmp(shape,'G')
    for i=1:N
        ind=find(abs(d_axon-mu(i))<4*sigma(i));
        I_fit(ind)=I_fit(ind)+A(i).*exp(-(d_axon(ind)-mu(i)).^2./(2*sigma(i).^2));
    end
elseif strcmp(shape,'L')
    for i=1:N
        ind=find(abs(d_axon-mu(i))<10*sigma(i));
        I_fit(ind)=I_fit(ind)+A(i)./((d_axon(ind)-mu(i)).^2./sigma(i).^2+1);
    end
end
E=sum((I_fit-I_axon).^2);

del_A=zeros(1,N); del_mu=zeros(1,N); del_sigma=zeros(1,N);
while (count<=Nsteps && abs(delE)/E>min_change) || nnz(A<min_A & Label==1)>0
    if strcmp(shape,'G')
        for i=1:N
            ind=find(abs(d_axon-mu(i))<4*sigma(i));
            d_axon_mu=d_axon(ind)-mu(i);
            FA=exp(-d_axon_mu.^2./sigma(i).^2./2);
            Fmu=d_axon_mu.*FA.*A(i)./sigma(i).^2;
            Fsigma=d_axon_mu.^2.*FA.*A(i)./sigma(i).^3;
            del_I=(I_fit(ind)-I_axon(ind));
            del_A(i)=sum(del_I.*FA);
            del_mu(i)=sum(del_I.*Fmu);
            del_sigma(i)=sum(del_I.*Fsigma);
        end
    elseif strcmp(shape,'L')
        for i=1:N
            ind=find(abs(d_axon-mu(i))<10*sigma(i));
            d_axon_mu=d_axon(ind)-mu(i);
            FA=1./(d_axon_mu.^2./sigma(i).^2+1);
            Fmu=2.*(d_axon_mu./sigma(i).^2).*FA.^2.*A(i);
            Fsigma=2.*A(i).*FA.*(1-FA)./sigma(i);
            del_I=(I_fit(ind)-I_axon(ind));
            del_A(i)=sum(del_I.*FA);
            del_mu(i)=sum(del_I.*Fmu);
            del_sigma(i)=sum(del_I.*Fsigma);
        end
    end
    
    A_temp=A-betta.A.*del_A;
    A_temp(A_temp<min_A_bouton & Label==1)=min_A_bouton;
    A_temp(A_temp<min_A_background & Label==0)=min_A_background;
    A_temp(A_temp>max_A_bouton & Label==1)=max_A_bouton;
    A_temp(A_temp>max_A_background & Label==0)=max_A_background;
    mu_temp=mu-betta.mu.*del_mu;
    mu_temp(mu_temp<min_mu_bouton & Label==1)=min_mu_bouton;
    mu_temp(mu_temp<min_mu_background & Label==0)=min_mu_background;
    mu_temp(mu_temp>max_mu_bouton & Label==1)=max_mu_bouton;
    mu_temp(mu_temp>max_mu_background & Label==0)=max_mu_background;
    sigma_temp=sigma-betta.sigma.*del_sigma;
    sigma_temp(sigma_temp<min_sigma_bouton & Label==1)=min_sigma_bouton;
    sigma_temp(sigma_temp<min_sigma_background & Label==0)=min_sigma_background;
    sigma_temp(sigma_temp>max_sigma_bouton & Label==1)=max_sigma_bouton;
    sigma_temp(sigma_temp>max_sigma_background & Label==0)=max_sigma_background;
    
    I_fit_temp=zeros(size(d_axon));
    if strcmp(shape,'G')
        for i=1:N
            ind=find(abs(d_axon-mu_temp(i))<4*sigma_temp(i));
            I_fit_temp(ind)=I_fit_temp(ind)+A_temp(i).*exp(-(d_axon(ind)-mu_temp(i)).^2./(2*sigma_temp(i).^2));
        end
    elseif strcmp(shape,'L')
        for i=1:N
            ind=find(abs(d_axon-mu_temp(i))<10*sigma_temp(i));
            I_fit_temp(ind)=I_fit_temp(ind)+A_temp(i)./((d_axon(ind)-mu_temp(i)).^2./sigma_temp(i).^2+1);
        end
    end
    E_temp=sum((I_fit_temp-I_axon).^2);
    
    delE=E_temp-E;
    if delE<0
        A=A_temp;
        mu=mu_temp;
        sigma=sigma_temp;
        I_fit=I_fit_temp;
        E=E_temp;
        count=count+1;
        
        if mod(count,100)==0
            betta=betta0;
        end
    else
        betta.A=betta.A/1.2;
        betta.sigma=betta.sigma./1.2;
        betta.mu=betta.mu./1.2;
        count=count+1;
        if mod(count,10)==0
            %disp([count,N,E,abs(delE)/E])
            fprintf('%-9.0d %-17.0d %-12.2f %-12.6f \n', count,N,E,abs(delE)/E);
        end
    end
    
    %Merge peaks based on distance
    if count>100 && mod(count,15)==0
        merge_ind=find(mu(2:end)-mu(1:end-1)<min_d & Label(2:end)==1 & Label(1:end-1)==1 & A(2:end)>0 & A(1:end-1)>0);
        if ~isempty(merge_ind)
            [~,ind]=min(mu(merge_ind+1)-mu(merge_ind));
            merge_ind=merge_ind(ind);
            mu(merge_ind)=(mu(merge_ind)*A(merge_ind)+mu(merge_ind+1)*A(merge_ind+1))/(A(merge_ind)+A(merge_ind+1));
            mu(merge_ind+1)=[];
            sigma(merge_ind)=(sigma(merge_ind)*A(merge_ind)+sigma(merge_ind+1)*A(merge_ind+1))/(A(merge_ind)+A(merge_ind+1));
            sigma(merge_ind+1)=[];
            A(merge_ind)=A(merge_ind)+A(merge_ind+1);
            A(merge_ind+1)=[];
            Label(merge_ind+1)=[];
            N=N-1;
            del_A=zeros(1,N); del_mu=zeros(1,N); del_sigma=zeros(1,N);
            
            I_fit=zeros(size(d_axon));
            if strcmp(shape,'G')
                for i=1:N
                    ind=find(abs(d_axon-mu(i))<4*sigma(i));
                    I_fit(ind)=I_fit(ind)+A(i).*exp(-(d_axon(ind)-mu(i)).^2./(2*sigma(i).^2));
                end
            elseif strcmp(shape,'L')
                for i=1:N
                    ind=find(abs(d_axon-mu(i))<10*sigma(i));
                    I_fit(ind)=I_fit(ind)+A(i)./((d_axon(ind)-mu(i)).^2./sigma(i).^2+1);
                end
            end
            E=sum((I_fit-I_axon).^2);
        end
    end
    
    %Merge peaks based on overlap
    if count>100 && mod(count,15)==5
        if strcmp(shape,'G')
            aa=sigma(2:end).^(-2)-sigma(1:end-1).^(-2);
            bb2=-(mu(2:end)./sigma(2:end).^2-mu(1:end-1)./sigma(1:end-1).^2);
            cc=mu(2:end).^2./sigma(2:end).^2-mu(1:end-1).^2./sigma(1:end-1).^2-2.*log(A(2:end)./A(1:end-1));
        elseif strcmp(shape,'L')
            aa=1./A(2:end)./sigma(2:end).^2-1./A(1:end-1)./sigma(1:end-1).^2;
            bb2=-(mu(2:end)./A(2:end)./sigma(2:end).^2-mu(1:end-1)./A(1:end-1)./sigma(1:end-1).^2);
            cc=mu(2:end).^2./A(2:end)./sigma(2:end).^2-mu(1:end-1).^2./A(1:end-1)./sigma(1:end-1).^2+1./A(2:end)-1./A(1:end-1);
        end
        D=bb2.^2-aa.*cc;
        merge_ind=find(D<0 & Label(2:end)==1 & Label(1:end-1)==1 & A(1:end-1)>0);
        if ~isempty(merge_ind)
            [~,ind]=min(mu(merge_ind+1)-mu(merge_ind));
            merge_ind=merge_ind(ind);
        else
            x1=(-bb2+D.^0.5)./aa;
            x1(aa==0)=-cc(aa==0)./bb2(aa==0)./2;
            x2=(-bb2-D.^0.5)./aa;
            x2(aa==0)=x1(aa==0);
            ind1=(x1>mu(1:end-1) & x1<mu(2:end));
            ind2=(x2>mu(1:end-1) & x2<mu(2:end));
            x0=nan(size(x1));
            x0(ind1)=x1(ind1);
            x0(ind2)=x2(ind2);
            
            if strcmp(shape,'G')
                hh=A(1:end-1).*exp(-(x0-mu(1:end-1)).^2./2./sigma(1:end-1).^2);
            elseif strcmp(shape,'L')
                hh=A(1:end-1)./((x0-mu(1:end-1)).^2./sigma(1:end-1).^2+1);
            end
            merge_ind=find(( hh>alpha.*min([A(1:end-1);A(2:end)])) & Label(2:end)==1 & Label(1:end-1)==1 & A(2:end)>0 & A(1:end-1)>0);
            if ~isempty(merge_ind)
                [~,ind]=max(hh(merge_ind)./min([A((merge_ind));A((merge_ind)+1)]));
                merge_ind=merge_ind(ind);
            end
        end
        
        if ~isempty(merge_ind)
            mu(merge_ind)=(mu(merge_ind)*A(merge_ind)+mu(merge_ind+1)*A(merge_ind+1))/(A(merge_ind)+A(merge_ind+1));
            mu(merge_ind+1)=[];
            sigma(merge_ind)=(sigma(merge_ind)*A(merge_ind)+sigma(merge_ind+1)*A(merge_ind+1))/(A(merge_ind)+A(merge_ind+1));
            sigma(merge_ind+1)=[];
            A(merge_ind)=A(merge_ind)+A(merge_ind+1);
            A(merge_ind+1)=[];
            Label(merge_ind+1)=[];
            N=N-1;
            del_A=zeros(1,N); del_mu=zeros(1,N); del_sigma=zeros(1,N);
            
            I_fit=zeros(size(d_axon));
            if strcmp(shape,'G')
                for i=1:N
                    ind=find(abs(d_axon-mu(i))<4*sigma(i));
                    I_fit(ind)=I_fit(ind)+A(i).*exp(-(d_axon(ind)-mu(i)).^2./(2*sigma(i).^2));
                end
            elseif strcmp(shape,'L')
                for i=1:N
                    ind=find(abs(d_axon-mu(i))<10*sigma(i));
                    I_fit(ind)=I_fit(ind)+A(i)./((d_axon(ind)-mu(i)).^2./sigma(i).^2+1);
                end
            end
            E=sum((I_fit-I_axon).^2);
        end
    end
    
    % remove small boutons based on amplitude
    if count>100 && mod(count,15)==10
        remove_ind=find(A<min_A & Label==1);
        if ~isempty(remove_ind)
            [~,ind]=min(A(remove_ind));
            remove_ind=remove_ind(ind);
            A(remove_ind)=[];
            mu(remove_ind)=[];
            sigma(remove_ind)=[];
            Label(remove_ind)=[];
            N=N-1;
            del_A=zeros(1,N); del_mu=zeros(1,N); del_sigma=zeros(1,N);
            
            I_fit=zeros(size(d_axon));
            if strcmp(shape,'G')
                for i=1:N
                    ind=find(abs(d_axon-mu(i))<4*sigma(i));
                    I_fit(ind)=I_fit(ind)+A(i).*exp(-(d_axon(ind)-mu(i)).^2./(2*sigma(i).^2));
                end
            elseif strcmp(shape,'L')
                for i=1:N
                    ind=find(abs(d_axon-mu(i))<10*sigma(i));
                    I_fit(ind)=I_fit(ind)+A(i)./((d_axon(ind)-mu(i)).^2./sigma(i).^2+1);
                end
            end
            E=sum((I_fit-I_axon).^2);
        end
    end
end

%--------------------------------------------------------------------------
%Convert to column vectors, and find index of nearest trace vertex
A=A(:);mu=mu(:);sigma=sigma(:);Label=Label(:);
Label(Label==0)=-1;
inds=nan(size(mu));
for k=1:length(mu)
    [~,inds(k)]=min(abs(d_axon-mu(k)));
end

%Write to Dat structure
Dat.fit.(channel).LoGxy.fg.ind=inds(Label>0);
Dat.fit.(channel).LoGxy.fg.mu=mu(Label>0);
Dat.fit.(channel).LoGxy.fg.sig=sigma(Label>0);
Dat.fit.(channel).LoGxy.fg.amp=A(Label>0);

%Background
Dat.fit.(channel).LoGxy.bg.ind=inds(Label<0);
Dat.fit.(channel).LoGxy.bg.mu=mu(Label<0);
Dat.fit.(channel).LoGxy.bg.sig=sigma(Label<0);
Dat.fit.(channel).LoGxy.bg.amp=A(Label<0);

%Registration
Dat.fit.(channel).LoGxy.fg.id=nan(size(Dat.fit.(channel).LoGxy.fg.ind));
Dat.fit.(channel).LoGxy.fg.manid=nan(size(Dat.fit.(channel).LoGxy.fg.ind));
Dat.fit.(channel).LoGxy.fg.autoid=nan(size(Dat.fit.(channel).LoGxy.fg.ind));
Dat.fit.(channel).LoGxy.fg.flag=nan(size(Dat.fit.(channel).LoGxy.fg.ind));

Dat.fit.(channel).LoGxy.d.man=Dat.d.optim;
Dat.fit.(channel).LoGxy.d.auto=Dat.d.optim;
Dat.fit.(channel).LoGxy.deform.man=nan(size(Dat.d.optim));
Dat.fit.(channel).LoGxy.deform.auto=nan(size(Dat.d.optim));
end