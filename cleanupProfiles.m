function [UserData] = cleanupProfiles(UserData)
%This function takes the initial analysisStatus set by user and removes
%conflicting information from all loaded profiles. 

channel=UserData.inform.channel{1};
for ti=1:numel(UserData.Profile)
    if UserData.AnalysisStatus==1
        %Remove all annotations and fiiting information
        UserData.Profile{ti}.fit.(channel)=struct();
        UserData.Profile{ti}.annotate.ignore=false(size(UserData.Profile{ti}.d.optim));
    elseif UserData.AnalysisStatus==2
        %Remove all fitting information
        UserData.Profile{ti}.fit.(channel)=struct();
    elseif UserData.AnalysisStatus==3
        %Do nothing, retain all information
    end   
end

%Check if removal gave results as expected.
[prevstat,newstat]=setAnalysisStatus(UserData);
UserData.AnalysisStatus=newstat;

if prevstat~=newstat
   disp('Warning - cleanupProfiles.m did not return expected result.') 
end
end