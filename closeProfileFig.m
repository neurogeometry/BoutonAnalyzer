function [] = closeProfileFig (src,~,hf)
if src==hf
    delete(hf.UserData.profilefig);
end
end