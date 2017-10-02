% This function works with AM, AMlbl for branches, or AMlbl for trees.
% Trees are optimized separately.
% Branch positions (r) are optimized, but calibers (R) remain fixed
% Branch and end points can be fixed or optimized:
% Optimize_bps = 1,0 optimize branch points.
% Optimize_tps = 1,0 optimize terminal (start, end) points.
% AMlbl in the output is labled for trees
% This version of the code is normalized for pointsperpixel as in the paper

function [AMlbl,r,I_F,count]=Optimize_Trace(Orig,AMlbl,r,Rtypical,Optimize_bps,Optimize_tps,pointsperum,MaxIterations,alpha_r,betta_r,adjustPPM,output)

epsilon=1; % added for stability
MinChange_I=10^-6;
MinChange_L=betta_r*10^-6;

% adjust vertex density
if adjustPPM==1
    [AM,r,~] = AdjustPPM(AMlbl,r,ones(size(r,1),1),pointsperum);
    AM=spones(AM);
else
    AM=spones(AMlbl);
end

if output==1
    disp('F1 trace optimization started.')
    format short g
    display(['        Iteration   ',   'I-cost   ',   '    L-cost   ',   ' Total Fitness'])
end

[it,jt]=find(triu(AM,1));
N=length(AM);
B=sparse(diag(sum(AM,2))-AM);
B3=2.*pointsperum.*blkdiag(alpha_r.*B,alpha_r.*B,alpha_r.*B);

W=ceil(2.5*Rtypical)*2+1;
NW=(W+1)/2;
[xtemp,ytemp,ztemp]=ndgrid(-(NW-1):(NW-1),-(NW-1):(NW-1),-(NW-1):(NW-1));

sizeIm=size(Orig);
if length(sizeIm)==2
    sizeIm(3)=1;
end

Orig=double(Orig(:));
Orig=Orig./max(Orig);
M=mean(Orig);

tps=(sum(AM)==1);
bps=(sum(AM)>2);
move=true(N,1);
if Optimize_tps==0
    move(tps)=false;
end
if Optimize_bps==0
    move(bps)=false;
end

neighb1=nan(N,1);
neighb1(it)=jt;
neighb1(isnan(neighb1))=find(isnan(neighb1));
neighb1(bps)=NaN;
neighb2=nan(N,1);
neighb2(jt)=it;
neighb2(isnan(neighb2))=find(isnan(neighb2));
neighb2(bps)=NaN;

del_r=zeros(size(r));
I_Q=zeros(N,1); I_Qx=zeros(N,1); I_Qy=zeros(N,1); I_Qz=zeros(N,1);
I_Pxx=zeros(N,1); I_Pxy=zeros(N,1); I_Pxz=zeros(N,1); I_Pyy=zeros(N,1); I_Pyz=zeros(N,1); I_Pzz=zeros(N,1);
I_F=zeros(N,1);

temp3=1/(Rtypical^3*pi^1.5*pointsperum);
temp4=1/(Rtypical^4*pi^1.5*pointsperum);
temp5=1/(Rtypical^5*pi^1.5*pointsperum);

count=1;
exitflag=0;
stepback=0;
while exitflag==0 && count<=MaxIterations
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Intensity cost, LoG filter
        for i=1:N
            xtemp1=xtemp(:)+round(r(i,1));
            ytemp1=ytemp(:)+round(r(i,2));
            ztemp1=ztemp(:)+round(r(i,3));
            temp_ind=(xtemp1>=1 & xtemp1<=sizeIm(1) & ytemp1>=1 & ytemp1<=sizeIm(2) & ztemp1>=1 & ztemp1<=sizeIm(3));
            indIm=xtemp1(temp_ind)+(ytemp1(temp_ind)-1).*sizeIm(1)+(ztemp1(temp_ind)-1).*(sizeIm(1)*sizeIm(2));
    
            Itemp=ones(size(xtemp1)).*M;
            Itemp(temp_ind)=Orig(indIm);
    
            xR=(r(i,1)-xtemp1)./Rtypical;
            yR=(r(i,2)-ytemp1)./Rtypical;
            zR=(r(i,3)-ztemp1)./Rtypical;
            r2R2=(xR.^2+yR.^2+zR.^2);
    
            EXP=exp(-r2R2).*Itemp;
            Q=EXP.*(-10/3+(4/3).*r2R2);
            P=EXP.*(28/3-(8/3).*r2R2);
    
            I_Q(i)=sum(Q).*temp5;
            I_Qx(i)=sum(Q.*xR).*temp4;
            I_Qy(i)=sum(Q.*yR).*temp4;
            I_Qz(i)=sum(Q.*zR).*temp4;
    
            Px=P.*xR;
            Py=P.*yR;
            Pz=P.*zR;
            I_Pxx(i)=sum(Px.*xR).*temp5;
            I_Pxy(i)=sum(Px.*yR).*temp5;
            I_Pxz(i)=sum(Px.*zR).*temp5;
            I_Pyy(i)=sum(Py.*yR).*temp5;
            I_Pyz(i)=sum(Py.*zR).*temp5;
            I_Pzz(i)=sum(Pz.*zR).*temp5;
    
            I_F(i)=sum(EXP.*(1-(2/3).*r2R2))*temp3;
        end   
    
    dFcostdrR=[I_Qx;I_Qy;I_Qz]-B3*r(:);
    d2IcostdRr2=[diag(sparse(I_Pxx+I_Q)),diag(sparse(I_Pxy)),diag(sparse(I_Pxz));
        diag(sparse(I_Pxy)),diag(sparse(I_Pyy+I_Q)),diag(sparse(I_Pyz));
        diag(sparse(I_Pxz)),diag(sparse(I_Pyz)),diag(sparse(I_Pzz+I_Q))]-B3-epsilon.*diag(sparse(ones(3*N,1)));
    
    Icost=sum(I_F);
    Lcost=sum(sum((r(it,:)-r(jt,:)).^2,2))*pointsperum;
    Fitness=Icost-alpha_r.*Lcost;
    
    if count>1 && stepback==0
        ChangeIcost=abs((Icost-oldIcost)/oldIcost);
        ChangeLcost=abs((Lcost-oldLcost)/oldLcost);
        exitflag=~(ChangeIcost>MinChange_I || ChangeLcost>MinChange_L);
        if ChangeIcost>0.5 || ChangeLcost>0.5
            warning('Trace may be unstable. Decrease Optimization Step Size and/or increase Trace Stiffness parameter.')
        end
    end
    
    if exitflag==0
        if output==1
            disp(full([count, Icost, Lcost, Fitness]))
        end
        count=count+1;
        stepback=0;
        
        oldIcost=Icost;
        oldLcost=Lcost;
        r_old=r;
        
        del_rR=d2IcostdRr2\dFcostdrR;
        
        del_r(:)=del_rR(1:3*N);
        l=r(neighb1,:)-r(neighb2,:);
        l=l./(sum(l.^2,2).^0.5*ones(1,3));
        l(isnan(l))=0;
        del_r=del_r-(sum(del_r.*l,2)*ones(1,3)).*l;
        abs_del_r=sum(del_r.^2,2).^0.5;
        inst_ind=abs_del_r>0.1;
        del_r(inst_ind,:)=del_r(inst_ind,:)./(abs_del_r(inst_ind)*ones(1,3)).*0.1;
        
        r(move,:)=r(move,:)-betta_r.*del_r(move,:);
        % r ranges from 0.5 to sizeIm+0.5 in Matlab and [0 sizeIm] in Java and SWC
        r(r(:,1)<0.5,1)=0.5; r(r(:,1)>sizeIm(1)+0.5,1)=sizeIm(1)+0.5;
        r(r(:,2)<0.5,2)=0.5; r(r(:,2)>sizeIm(2)+0.5,2)=sizeIm(2)+0.5;
        r(r(:,3)<0.5,3)=0.5; r(r(:,3)>sizeIm(3)+0.5,3)=sizeIm(3)+0.5;
    else
        r=r_old;
        betta_r=betta_r./1.1;
        count=count-1;
        stepback=1;
    end
end

r=r_old;
AMlbl = LabelTreesAM(AM);

if output==1
    disp('F1 trace optimization is complete.')
    if ChangeIcost>MinChange_I || ChangeLcost>MinChange_L
        disp('The algorithm did not converge to solution with default precision.')
        disp('Consider increasing Optimization Step Size and/or Maximum Number of Iterations.')
    end
end
