function addPeak(~,~,hf)
%This function adds a peak to the ilst of fitted peaks
h_axis=findobj(hf.Children,'flat','Tag','Axis');
h_sv=findobj(h_axis.Children,'flat','Tag','SelVerts');
h_addpeak=h_sv.Children;

ti=h_addpeak.UserData.t;
ind=h_addpeak.UserData.ind;
UserData=hf.UserData;
channel=UserData.inform.channel{1};
if sum(UserData.Profile{ti}.fit.(channel).LoGxy.fg.ind==ind)==0
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.ind(end+1)=ind;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.id(end+1)=max(UserData.Profile{ti}.fit.(channel).LoGxy.fg.id)+1;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.mu(end+1)=nan;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.sig(end+1)=nan;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.amp(end+1)=nan;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.manid(end+1)=nan;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.autoid(end+1)=nan;
    UserData.Profile{ti}.fit.(channel).LoGxy.fg.flag(end+1)=nan;
else
    disp('Peak already present at this location')
end
hf.UserData=[];hf.UserData=UserData; %For speed reasons

updateProfile(hf);
updatePlots(hf,4);
%deselectVert([],[],hf);
end