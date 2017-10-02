function [] = updatePlots(hf,opt)
%This is the only place where shifts are updated. Unless this is called,
%the canvas elements can remain unchanged

if opt==1
    updateIm(hf);
    drawIm(hf);
    
elseif opt==2
    UserData=calcXYshift(hf.UserData);hf.UserData=[];hf.UserData=UserData;%For speed reasons
    updateIm(hf);
    drawIm(hf);
    drawTraces(hf);
    drawLandmarkEdges(hf);
    drawIgnore(hf);
    drawPeaks(hf);
    drawEdges(hf);
    drawNodeStatus(hf);
    drawNodes(hf);
    
elseif opt==3 %Only if annotations edited
    drawIgnore(hf);
    
elseif opt==4 %Only if peaks edited
    drawPeaks(hf);
    drawProfile('Edit',[],hf);
elseif opt==5 %Only if matches edited
    drawEdges(hf);
    drawNodeStatus(hf);
    drawNodes(hf);
end
drawnow;

UserData=hf.UserData;hf.UserData=[];
[~,UserData.AnalysisStatus]=setAnalysisStatus(UserData);hf.UserData=UserData;
setGUIstate(hf);
end