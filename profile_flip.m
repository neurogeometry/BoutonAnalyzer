function P=profile_flip(P)
%This is used within gui_alignment to flip the direction of the profile,
%during the annotation and alignment process, before profiles are fitted.

ind=numel(P.r.optim(:,1)):-1:1;
P.AM.optim=P.AM.optim(ind,ind);
P.r.optim=P.r.optim(ind,:);

dmax=P.d.optim(end);
P.d.optim=dmax-P.d.optim;
P.d.optim=P.d.optim(ind);
%Other distances e.g. d.aligned and d.alignedxy are re-calculated within
%AlignTraces from flipped r.optim and flipped d.optim.

channel=fieldnames(P.I);
for ch=1:numel(channel)
    filter=fieldnames(P.I.(channel{ch}));
    for fi=1:numel(filter)
        updateflds=fieldnames(P.I.(channel{ch}).(filter{fi}));
        for uf=1:numel(updateflds)
            P.I.(channel{ch}).(filter{fi}).(updateflds{uf})=...
                P.I.(channel{ch}).(filter{fi}).(updateflds{uf})(ind);
        end
    end
end
P.annotate.ind=P.annotate.ignore(ind);
end
