function remPeak(src,ed,hf)
h_axis=findobj(hf.Children,'flat','Tag','Axis');
h_sv=findobj(h_axis.Children,'flat','Tag','SelVerts');
h_addpeak=h_sv.Children;
UserData=hf.UserData;
ti=h_addpeak.UserData.t;
ind=h_addpeak.UserData.ind;
channel=UserData.inform.channel{1};

logind=(UserData.Profile{ti}.fit.(channel).LoGxy.fg.ind==ind);
if sum(logind)==0
    disp('No peak present. Nothing to delete');
    %fg_field=fieldnames(hf.UserData.Profile{ti}.fit.(channel).LoGxy.fg);
else
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.ind(logind)=[];
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.mu(logind)=[];
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.sig(logind)=[];
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.amp(logind)=[];
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.id(logind)=[];
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.manid(logind)=[];
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.autoid(logind)=[];
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.flag(logind)=[];
end
hf.UserData=[];hf.UserData=UserData;
updateProfile(hf);
updatePlots(hf,4);
deselectVert([],[],hf);

end