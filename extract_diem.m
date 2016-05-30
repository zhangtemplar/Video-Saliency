% this script extract the video for diem
% the biggest video is [720 1280 6300], where FPS=30
% so a good way is downsample to 1/4 1/4 1/3
% another good idea is we cut the video into clip according to the scene or
% the window function as we proposed. We can start simple frame difference
% method to find the scene cut.
clear all;
clc;
dir_root='G:\DIEM\';
dir_video=[dir_root 'video\'];
dir_mask=[dir_root 'event_data\'];
cd(dir_root);
file_list=dir('*.7z');
warning('off', 'MATLAB:audiovideo:aviset:compressionUnsupported');
for i=1: length(file_list)
    fprintf(1, 'Processing %s\n', file_list(i).name);
    if exist([dir_mask file_list(i).name(1: end-3) '.mat'], 'file')>0
        continue;
    end
    %% ====================================================================
    % process the eye fixation data
    system(['"c:\Program Files\7-Zip\7z.exe" x ' dir_root file_list(i).name ' -y -r event_data']);
    cd(dir_mask);
    mark_list=dir('*.txt');
    [sal mask video_info]=compute_fixation_diem(mark_list, [dir_video file_list(i).name(1: end-2) 'mp4']);
    % remove the eye fixation data
    delete('*.txt');
    save([dir_mask file_list(i).name(1: end-3)], 'sal', 'mask', 'video_info');
    clear sal;
    %% ====================================================================
    % visualize the mask
    video=mmreader([dir_video file_list(i).name(1: end-2) 'mp4']);
    video_result=avifile([dir_mask file_list(i).name(1: end-3) '.avi'],...
            'compression', 'XVID', 'fps', 30);
    for t=1: video.NumberOfFrames
        img=read(video, t);
        img=imresize(rgb2gray(img), size(mask{t}));
        frame=cat(3, full(mask{t})*255, img);
        frame=sc(frame, 'prob');
        video_result=addframe(video_result, frame);
    end
    video_result=close(video_result);
    cd(dir_root);
end
