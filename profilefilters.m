function [II, RR]= profilefilters (r,IM,filtertype,params)

if strcmp(filtertype,'LoGxy')
    %LoGxy filter options
    LoGxy_R_min=params.filt.LoGxy_R_min;
    LoGxy_R_step=params.filt.LoGxy_R_step;
    LoGxy_R_max=params.filt.LoGxy_R_max;
    LoGxy_Rz=params.filt.LoGxy_Rz;
    [II,RR] = LoG_Filt_xy(IM,r,LoGxy_R_min,LoGxy_R_step,LoGxy_R_max,LoGxy_Rz);
elseif strcmp(filtertype,'Gauss')
    %Gaussian filter
    Gauss_R=params.filt.Gauss_R;
    [II,RR]=Gauss_Filt(IM,r,Gauss_R,1,Gauss_R);
else
    display('Filter ',filtertype, ' not found');
end
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [I,Rxy] = LoG_Filt_xy(Orig,r,Rxy_min,Rxy_step,Rxy_max,Rz)
if Rxy_min<0.1
    Rxy_min=0.1;
end
s=(Rxy_min:Rxy_step:Rxy_max)';

if isempty(s)
    Rxy=zeros(size(r(:,1)));
    I=zeros(size(r(:,1)))';
else
    r=round(r);
    del=0.01*Rxy_min;
    N=size(r,1);
    
    sizeIm=size(Orig);
    if length(sizeIm)==2
        sizeIm=[sizeIm,1];
    end
    
    W=ceil(2*max([Rxy_max,Rz]))*2+1;
    HW=(W-1)/2;
    S=[W,W,W];
    [xtemp,ytemp,ztemp]=ind2sub(S,1:prod(S));
    
    Itemp=zeros(prod(S),N);
    for i=1:N,
        xtemp1=xtemp+r(i,1)-HW-1;
        ytemp1=ytemp+r(i,2)-HW-1;
        ztemp1=ztemp+r(i,3)-HW-1;
        temp_ind=(xtemp1>=1 & xtemp1<=sizeIm(1) & ytemp1>=1 & ytemp1<=sizeIm(2) & ztemp1>=1 & ztemp1<=sizeIm(3));
        indIm=sub2ind_ASfast(sizeIm,xtemp1(temp_ind),ytemp1(temp_ind),ztemp1(temp_ind));
        
        Im_S=zeros(S);
        Im_S(temp_ind)=double(Orig(indIm));
        
        Itemp(:,i)=Im_S(:);
    end
    
    xy2=(HW+1-xtemp).^2+(HW+1-ytemp).^2;
    Gxym=exp(-(1./(s-del).^2)*xy2).*((1./(s-del).^2)*ones(1,prod(S)));
    Gxym=Gxym./(sum(Gxym,2)*ones(1,prod(S)));
    Gxyp=exp(-(1./(s+del).^2)*xy2).*((1./(s+del).^2)*ones(1,prod(S)));
    Gxyp=Gxyp./(sum(Gxyp,2)*ones(1,prod(S)));
    
    z2=(HW+1-ztemp).^2;
    Gz=exp(-(1./Rz.^2)*z2)./Rz;
    Gz=Gz./sum(Gz,2);
    
    LoG=(Gxym-Gxyp)./(2*del).*(s*ones(1,prod(S))).*(ones(length(s),1)*Gz); %correct up to a numerical factor
    
    I_LoG=LoG*Itemp;
    if length(s)>1
        [I,ind]=max(I_LoG);
        Rxy=s(ind);
    else
        I=I_LoG;
        Rxy=s.*ones(size(r(:,1)));
    end
end
I=I(:);
Rxy=Rxy(:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I,R] = Gauss_Filt(Orig,r,R_min,R_step,R_max)

if R_min<0.1
    R_min=0.1;
end
s=(R_min:R_step:R_max)';

if isempty(s)
    R=zeros(size(r(:,1)));
    I=zeros(size(r(:,1)))';
else
    r=round(r);
    N=size(r,1);
    
    sizeIm=size(Orig);
    if length(sizeIm)==2
        sizeIm=[sizeIm,1];
    end
    
    W=ceil(2*max(s))*2+1;
    HW=(W-1)/2;
    S=[W,W,W];
    [xtemp,ytemp,ztemp]=ind2sub(S,1:prod(S));
    
    Itemp=zeros(prod(S),N);
    for i=1:N,
        xtemp1=xtemp+r(i,1)-HW-1;
        ytemp1=ytemp+r(i,2)-HW-1;
        ztemp1=ztemp+r(i,3)-HW-1;
        temp_ind=(xtemp1>=1 & xtemp1<=sizeIm(1) & ytemp1>=1 & ytemp1<=sizeIm(2) & ztemp1>=1 & ztemp1<=sizeIm(3));
        indIm=sub2ind_ASfast(sizeIm,xtemp1(temp_ind),ytemp1(temp_ind),ztemp1(temp_ind));
        
        Im_S=zeros(S);
        Im_S(temp_ind)=double(Orig(indIm));
        
        Itemp(:,i)=Im_S(:);
    end
    
    r2=(HW+1-xtemp).^2+(HW+1-ytemp).^2+(HW+1-ztemp).^2;
    Gp=exp(-(1./(s).^2)*r2).*((1./(s).^3)*ones(1,prod(S)));
    Gp=Gp./(sum(Gp,2)*ones(1,prod(S)));
    
    I_Gauss=Gp*Itemp;
    if length(s)>1
        [I,ind]=max(I_Gauss);
        R=s(ind);
    else
        I=I_Gauss;
        R=s.*ones(size(r(:,1)));
    end
end
I=I(:);
R=R(:);
end

%--------------------------------------------------------------------------
function [I_mean,I_median] = Simple_Filts(Orig,r,filt_size)
r=round(r);
sizeIM=size(Orig);
HW=(filt_size-1);

minx=round(max(1,(r(:,1)-round(HW(1)/2))));
maxx=round(min((r(:,1)+round(HW(1)/2)),sizeIM(1)));
miny=round(max(1,(r(:,2)-round(HW(2)/2))));
maxy=round(min((r(:,2)+round(HW(2)/2)),sizeIM(2)));
minz=round(max(1,(r(:,3)-round(HW(3)/2))));
maxz=round(min((r(:,3)+round(HW(3)/2)),sizeIM(3)));

I_mean=nan(size(r,1),1);
I_median=nan(size(r,1),1);
for i=1:size(r,1)
    IMval=Orig(minx(i):maxx(i),miny(i):maxy(i),minz(i):maxz(i));
    I_mean(i)=mean(IMval(:));
    I_median(i)=median(IMval(:));
end
end
