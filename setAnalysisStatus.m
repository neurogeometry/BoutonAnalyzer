function [prevstatus,currstatus] = setAnalysisStatus(UserData)
%This function sets the AnalysisStatus variable:
%1. (default) if Optimized trace + Intensity profiles present
%2. if Optimized trace + Intensity profiles + Annotations present
%3. if Optimized trace + Intensity profiles + Annotations + Fitted peaks present

%Default is state 1. All loaded files are expected to already contain
%optimized trace and intensity profiles.
%Log current status
prevstatus=UserData.AnalysisStatus;
currstatus=1;

%Check if annotations are present
for ti=1:numel(UserData.Profile)
    if sum(UserData.Profile{ti}.annotate.ignore)>0
        currstatus=2;
    end
end

%Check if fits are present for the correct channel
fitpresent=true;
for ti=1:numel(UserData.Profile)
    fitfields=fieldnames(UserData.Profile{ti}.fit.(UserData.inform.channel{1}));
    if isempty(fitfields)
        fitpresent=false;
    end
end

if fitpresent
    currstatus=3;
end
%Set current status
UserData.AnalysisStatus=currstatus;
end