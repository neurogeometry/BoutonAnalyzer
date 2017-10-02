function [] = initIgnore(hf)
%This automatically ignores regions of the axon that are not traced in all
%timepoints. These regions are determined based on alignment of trace nodes.

UserData=hf.UserData;hf.UserData=[];%For speed reasons
dmin=-inf;dmax=inf;
for ti=1:numel(UserData.Profile)
    dmin=max(dmin,UserData.Profile{ti}.d.alignedxy(1));
    dmax=min(dmax,UserData.Profile{ti}.d.alignedxy(end));
end

for ti=1:numel(UserData.Profile)
    UserData.Profile{ti}.annotate.ignore(UserData.Profile{ti}.d.alignedxy<dmin | ...
        UserData.Profile{ti}.d.alignedxy>dmax)=true;
end
hf.UserData=UserData;
end