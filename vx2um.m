function [d] = vx2um (r)
%Returns value of d in microns.
%r is ordered, and has 3 columns.
%d=0 @ r(1).
paramset;
r=r.*(ones(size(r,1),1)*params.profile.umpervox);
d=cumsum(sum((r((2:end),:)-r((1:end-1),:)).^2,2).^0.5);
d=[0;d(:)];
end