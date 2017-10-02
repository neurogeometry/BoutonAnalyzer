function [] = updateIm(hf)
%This compiles the image based on current shift values calculated using
%calcXYshifts and stored in the figure handle
UserData=hf.UserData;
View=UserData.View;
Im=zeros(UserData.Cnvs_size);

sizeim=size(UserData.Profile{1}.proj.(View.Channel).xy.ax);%All prjections are the same size;
xrange=[UserData.shiftx(:)+1,UserData.shiftx(:)+sizeim(1)];
yrange=[UserData.shifty(:)+1,UserData.shifty(:)+sizeim(2)];
for ti=1:numel(UserData.Profile)
    CurrentIm=UserData.Profile{ti}.proj.(View.Channel).xy.ax;
    if View.Norm %True/False value expected
        UserData.normfactor(ti)=mean(UserData.Profile{ti}.I.(View.Channel).Gauss.raw(~UserData.Profile{ti}.annotate.ignore));
        CurrentIm=CurrentIm./UserData.normfactor(ti);
    end
    Im(xrange(ti,1):xrange(ti,2),yrange(ti,1):yrange(ti,2))=...
        max(Im(xrange(ti,1):xrange(ti,2),yrange(ti,1):yrange(ti,2)),CurrentIm);
end
UserData.Im=Im;
hf.UserData=[];
hf.UserData=UserData;
end