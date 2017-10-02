function [AM,r,ignore] = orderprofile(AM,r,ignore,startt)
%Order r and AM. %AM labels are removed.

AM = max(AM,AM');
AM=spones(AM);
del=find(sum(AM,2)==0);
AM(del,:)=[];AM(:,del)=[];r(del,:)=[];

%Step along trace assuming no branching
ind=zeros(size(AM,1),1);
ind(1)=startt;

endpt=find(sum(AM,1)==1);
endpt(endpt==startt)=[];
[~,ind(2)]=find(AM(ind(1),:));
i=3;
while ind(i-1)~=endpt
    [~,next]=find(AM(ind(i-1),:));
    ind(i)=next(next~=ind(i-2));
    i=i+1;
end

AM=AM(ind,ind);
r=r(ind,:); %because I will be ordered based on r
ignore=ignore(ind);
end