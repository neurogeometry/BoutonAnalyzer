function Dat=automatch(Dat,channel)
%This aligns peaks in a greedy way based on daligned field.
%Input/output are the set of profiles with fitted peaks
%Function is edited to align based on xy distances

%{
Default flag convention
0: Not matched (default)
1: Confirmed with no match
2: Ignored, noisy intensity
3: Ignored, terminal bouton
4: Ignored, cross-over
%}

d_thr=0.5;%Maximum difference between position of matched peaks, in microns
%Set ids and Reset all matches and flags
for tnow=1:numel(Dat)
    Dat{tnow}.fit.(channel).LoGxy.fg.id=10000*tnow+(1:numel(Dat{tnow}.fit.(channel).LoGxy.fg.id))'; %# peaks not expected to be >10000 in one time
    Dat{tnow}.fit.(channel).LoGxy.fg.manid=nan(size(Dat{tnow}.fit.(channel).LoGxy.fg.manid));
    Dat{tnow}.fit.(channel).LoGxy.fg.flag=nan(size(Dat{tnow}.fit.(channel).LoGxy.fg.manid));
end

%manid is nan if not matched
for tnow=2:numel(Dat)
    tprev=tnow-1;
    for p=1:numel(Dat{tnow}.fit.(channel).LoGxy.fg.id) %over peaks in the current time
        while tprev>0 && isnan(Dat{tnow}.fit.(channel).LoGxy.fg.manid(p))
            [vv,ii]=min(abs(Dat{tprev}.d.alignedxy(Dat{tprev}.fit.(channel).LoGxy.fg.ind)-...
                Dat{tnow}.d.alignedxy(Dat{tnow}.fit.(channel).LoGxy.fg.ind(p))));
            %display([vv,ii])
            if vv<d_thr && sum(Dat{tnow}.fit.(channel).LoGxy.fg.manid==Dat{tprev}.fit.(channel).LoGxy.fg.manid(ii))==0
                if isnan(Dat{tprev}.fit.(channel).LoGxy.fg.manid(ii)) %Peak not matched to anything before
                    Dat{tprev}.fit.(channel).LoGxy.fg.manid(ii)=Dat{tprev}.fit.(channel).LoGxy.fg.id(ii);
                end
                Dat{tnow}.fit.(channel).LoGxy.fg.manid(p)=Dat{tprev}.fit.(channel).LoGxy.fg.manid(ii);
            end
            tprev=tprev-1;
        end
        tprev=tnow-1;
    end
end

%Add flag information
for ti=1:numel(Dat)
    %Use annotated peaks to reset flags
    Dat{ti}.fit.(channel).LoGxy.fg.flag=nan(numel(Dat{ti}.fit.(channel).LoGxy.fg.id),1);
    [~,igind,~]=intersect(Dat{ti}.fit.(channel).LoGxy.fg.ind,find(Dat{ti}.annotate.ignore));
    Dat{ti}.fit.(channel).LoGxy.fg.flag(igind)=2;
    Dat{ti}.fit.(channel).LoGxy.fg.manid(igind)=nan;
end
end