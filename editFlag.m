function editFlag(~,~,hf)
%This function opens a dialogue box to set flags of selected nodes

h_axis=findobj(hf.Children,'flat','Tag','Axis');
h_sv=findobj(h_axis.Children,'flat','Tag','SelVerts');
sel_vert=cell2mat({h_sv.Children.UserData});
t_active=[sel_vert.t];
fg_id_active=[sel_vert.fg_id];

%re-order active nodes with earliest time first
[t_active,sorti]=sort(t_active,'ascend');
fg_id_active=fg_id_active(sorti);

prompt=sprintf(['\nFlag list:\n\n' ...
    '   0: Not matched (default)\n\n'...
    '   1: Confirmed with no match\n\n'...
    '   2: Ignored, noisy intensity\n\n'...
    '   3: Ignored, terminal bouton\n\n'...
    '   4: Ignored, cross-over\n']);

flagnumber=inputdlg(prompt,'Flag Peak',[1 35]);

%Check flagid
if ~isempty(flagnumber) && ~isempty(flagnumber{1})
    flagnumber=flagnumber{1};
    flagnumber=str2double(flagnumber);
    if ~ismember(flagnumber,[0,1,2,3,4])
        disp('Not a valid flag');
    else
        flagnumber(flagnumber==0)=nan;
        UserData=hf.UserData;hf.UserData=[];
        [lia,~]=ismember(UserData.Graph.fg_id,fg_id_active);
        UserData.Graph.fg_flag(lia)=flagnumber;
        hf.UserData=UserData;
    end
else
    disp('Not a valid flag');
end

deselectVert([],[],hf);
updatePlots(hf,5);
end