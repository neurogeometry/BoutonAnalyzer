function editIgnore(src,~,hf)
%This function adds/ignores regions along aligned trace(s).
UserData=hf.UserData;hf.UserData=[];
h_axis=findobj(hf.Children,'flat','Tag','Axis');
h_sv=findobj(h_axis.Children,'flat','Tag','SelVerts');

ti_now=h_sv.Children(1).UserData.t;
inds_now=h_sv.Children(1).UserData.ind:sign(h_sv.Children(2).UserData.ind-h_sv.Children(1).UserData.ind):h_sv.Children(2).UserData.ind;
switch src.Tag
    case 'IC'
        UserData.Profile{ti_now}.annotate.ignore(inds_now)=true;
    case 'AC'
        UserData.Profile{ti_now}.annotate.ignore(inds_now)=false;
    case 'IA'
        d_now=[UserData.Profile{ti_now}.d.alignedxy(h_sv.Children(1).UserData.ind);...
            UserData.Profile{ti_now}.d.alignedxy(h_sv.Children(2).UserData.ind)];
        for ti=1:numel(UserData.Profile)
            [~,temp(1)]=min(abs(UserData.Profile{ti}.d.alignedxy-d_now(1)));
            [~,temp(2)]=min(abs(UserData.Profile{ti}.d.alignedxy-d_now(2)));
            inds=temp(1):sign(temp(2)-temp(1)):temp(2);
            UserData.Profile{ti}.annotate.ignore(inds)=true;
        end
    case 'AA'
        d_now=[UserData.Profile{ti_now}.d.alignedxy(h_sv.Children(1).UserData.ind);...
            UserData.Profile{ti_now}.d.alignedxy(h_sv.Children(2).UserData.ind)];
        for ti=1:numel(UserData.Profile)
            [~,temp(1)]=min(abs(UserData.Profile{ti}.d.alignedxy-d_now(1)));
            [~,temp(2)]=min(abs(UserData.Profile{ti}.d.alignedxy-d_now(2)));
            inds=temp(1):sign(temp(2)-temp(1)):temp(2);
            UserData.Profile{ti}.annotate.ignore(inds)=false;
        end
end
hf.UserData=UserData;

deselectVert([],[],hf);
updatePlots(hf,3);
end