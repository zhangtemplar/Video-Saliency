% this script extract the video for diem
% the biggest video is [720 1280 6300], where FPS=30
% so a good way is downsample to 1/4 1/4 1/3
% another good idea is we cut the video into clip according to the scene or
% the window function as we proposed. We can start simple frame difference
% method to find the scene cut.
clear;
clc;
dir_root='G:\CRCNS-DataShare\';
dir_video=[dir_root 'stimuli\'];
dir_mask=[dir_root 'data-orig\'];
subject_list={'CA\', 'JA\', 'JZ\', 'ND\', 'NM\', 'RC\', 'VC\', 'VN\'};
warning('off', 'MATLAB:audiovideo:aviset:compressionUnsupported');
cd(dir_video);
% file_list=dir('*.avi');
% for i=1: length(file_list)
%     movefile(file_list(i).name, [file_list(i).name(1: end-9) '.avi']);
% end
file_list=dir('*.avi');
for i=1: length(file_list)
    fprintf(1, 'Processing %s\n', file_list(i).name);
    if exist([dir_mask file_list(i).name(1: end-4) '.mat'], 'file')>0
        continue;
    end
    %% ====================================================================
    % process the eye fixation data
    mark_list=cell(size(subject_list));
    for j=1: length(subject_list)
        if exist([dir_mask subject_list{j} file_list(i).name(1: end-4) '.e-ceyeS'], 'file')>0
            mark_list{j}=[dir_mask subject_list{j} file_list(i).name(1: end-4) '.e-ceyeS'];
        end
    end
    [sal mask video_info]=compute_fixation_CRCNS(mark_list(~isemptycell(mark_list)), file_list(i).name);
    % remove the eye fixation data
    save([dir_mask file_list(i).name(1: end-4)], 'sal', 'mask', 'video_info');
    clear sal;
    %% ====================================================================
    % visualize the mask
%     video=mmreader(file_list(i).name);
%     video_result=avifile([dir_mask file_list(i).name(1: end-4) '.avi'],...
%             'compression', 'XVID', 'fps', 30);
%     for t=1: video.NumberOfFrames
%         img=read(video, t);
%         img=imresize(rgb2gray(img), size(mask{t}));
%         frame=cat(3, full(mask{t})*255, img);
%         frame=sc(frame, 'prob');
%         video_result=addframe(video_result, frame);
%     end
%     video_result=close(video_result);
end
