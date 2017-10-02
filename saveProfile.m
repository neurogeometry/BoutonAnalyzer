function saveProfile(src,ed,hf)
%Works with gui_alignments
h_operationpanel=findobj(hf.Children,'flat','Tag','Operation');
h_mode=findobj(h_operationpanel.Children,'flat','Tag','Mode');
h_object=findobj(h_operationpanel.Children,'flat','Tag','Object');

pathlist;
an=1;se=1;ax=1;

if isfield(hf.UserData,'Graph') && ...
        strcmp(h_mode.SelectedObject.String,'Detect Peaks') &&...
        strcmp(h_object.SelectedObject.String,'Edit Peaks')
    %Profile contains information not updated in the graph
    Profile2Graph(hf);
    Graph2Profile(hf);
elseif isfield(hf.UserData,'Graph') && ...
        strcmp(h_mode.SelectedObject.String,'Detect Peaks') &&...
        strcmp(h_object.SelectedObject.String,'Match Peaks')
    %Graph contains information not updated in the profile
    Graph2Profile(hf);
    Profile2Graph(hf);
end

%Saving is disabled if only Landmarks (in Align Traces mode) are added.
%Profile structures will be saved either after annotations or after
%fitting.
if hf.UserData.AnalysisStatus==2 || hf.UserData.AnalysisStatus==3
    if hf.UserData.AnalysisStatus==2
        disp('Saving alignment and annotations to individual axon profiles.');
    end
    
    for ti=1:numel(hf.UserData.Profile)
        stack_id=[hf.UserData.inform.animal{an},hf.UserData.inform.timepoint{ti},hf.UserData.inform.section{se}];
        profile_id=hf.UserData.inform.axon{ax};
        fname=isunixispc([profile_pth,stack_id,filesep,profile_id,'.mat']);
        %Check directory
        if ~exist(isunixispc([profile_pth,stack_id]),'dir')
            mkdir(isunixispc(profile_pth),stack_id);
            display(['Creating directory: ', isunixispc([profile_pth,stack_id])]);
        end
        Profile=hf.UserData.Profile{ti};
        save(fname,'-struct','Profile');
        clear Profile;
        display(['Saved profile in ',fname]);
    end
    
    if hf.UserData.AnalysisStatus==3
        Profile=hf.UserData.Profile;
        AxonMat=analysis_getmat(Profile);
        
        %Check directory
        if ~exist(isunixispc(proc_pth),'dir')
            mkdir(isunixispc(proc_pth));
            display(['Creating directory: ', isunixispc([profile_pth,stack_id])]);
        end
        
        %Save .mat file
        fname=[proc_pth,[hf.UserData.inform.animal{1},hf.UserData.inform.section{1},hf.UserData.inform.channel{1},'-',hf.UserData.inform.timepoint{1},'_to_',hf.UserData.inform.timepoint{end},'-',hf.UserData.inform.axon{1},'.mat']];
        save(fname,'-struct','AxonMat');
        disp(['Saved results as .mat file ',fname]);
        
        %Save .dat file with limited information
        fname=[proc_pth,[hf.UserData.inform.animal{1},hf.UserData.inform.section{1},hf.UserData.inform.channel{1},'-',hf.UserData.inform.timepoint{1},'_to_',hf.UserData.inform.timepoint{end},'-',hf.UserData.inform.axon{1},'.txt']];
        fid=fopen(fname,'w');fspec=[];
        fprintf(fid,'Files aligned:\r\n');
        ttspec=[];
        for ti=1:numel(Profile)
            fprintf(fid,'%s\r\n',hf.UserData.Profile{ti}.id);
            fspec=[fspec,' %',num2str(8),'.3f'];
            ttspec=[ttspec,' %+',num2str(8),'s'];
        end
        fspec=[fspec,'\r\n'];
        ttspec=['\r\n',ttspec,'\r\n'];
        fprintf(fid,'\r\n\r\nWeights (w):\r\n');
        fprintf(fid,ttspec,hf.UserData.inform.timepoint{:});
        fprintf(fid,fspec,AxonMat.w);
        sprintf(fspec,AxonMat.w);
        fprintf(fid,'\r\n\r\nProbabilities (P):\r\n');
        fprintf(fid,ttspec,hf.UserData.inform.timepoint{:});
        fprintf(fid,fspec,AxonMat.P);
        fclose(fid);
        disp(['Saved results as .txt file ',fname]);
    end
end
end