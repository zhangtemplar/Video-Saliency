% this script run spatiotemporal saliency on DIEM dataset
% clear;
clc;
%% ========================================================================
% parameters
dir_root='G:\DIEM\';
dir_video=[dir_root 'video\'];
dir_mask=[dir_root 'event_data\'];
dir_result=[dir_root 'result\'];
% down sample the spatial resolution by 4
spatial_factor=4;
% temporal factor 
temporal_factor=3;
% expect number of clips
expect_cut=500;
% expect length of the clip
expect_frame=500;
% threshold for sgementation
threshold=(0:0.1:1)';
warning('off', 'MATLAB:audiovideo:aviset:compressionUnsupported');
warning('off', 'MATLAB:audiovideo:aviaddframe:frameheightpaddedframeheightpadded');
%% ========================================================================
% main algorithm
cd(dir_video)
list_video=dir('*.mp4');
% fp=zeros(length(threshold), length(list_video));
% tp=zeros(length(threshold), length(list_video));
% gp=zeros(length(threshold), length(list_video));
% gn=zeros(length(threshold), length(list_video));
for i=1: length(list_video)
    fprintf(1, 'processing %s', list_video(i).name);
    if exist([dir_result list_video(i).name(1: end-4)], 'dir')>0
        fprintf(1, '\n');
        continue;
    end
    mkdir([dir_result list_video(i).name(1: end-4)]);
    video=mmreader(list_video(i).name);
    %% --------------------------------------------------------------------
    % cut detection
    cut=zeros(1, video.NumberOfFrames);
    for t=1: temporal_factor: video.NumberOfFrames
        img=double(imresize(read(video, t), 1/4));
        norm_img=norm(img(:));
        if t>1
            cut(t)=norm(img(:)-img_prev(:))/max(norm_img, norm_img_prev);
        end
        img_prev=img;
        norm_img_prev=norm_img;
    end
    cut=cut(1: temporal_factor: end);
    % detect the cut
    cut_location=[1 cut_detection(cut)*3+1 video.NumberOfFrames];
    save([dir_result list_video(i).name(1: end-4) '\'...
        list_video(i).name(1: end-4)], 'cut', 'cut_location');
    %% --------------------------------------------------------------------
    load([dir_mask list_video(i).name(1: end-4)], 'mask');
    % saliency computation
    % read the video
    for k=2: length(cut_location)
        fprintf(1, '\t%f', k/length(cut_location));
        start_frame=cut_location(k-1)+temporal_factor;
        end_frame=cut_location(k)-temporal_factor;
        if end_frame-start_frame+1>expect_frame
            frame_index=start_frame: temporal_factor: end_frame;
        else
            frame_index=start_frame: end_frame;
        end
        if isempty(frame_index) || length(frame_index)<2
            continue;
        end
        data1=zeros(floor((video.Height-1)/spatial_factor)+1,...
            floor((video.Width-1)/spatial_factor)+1, length(frame_index));
        data2=zeros(floor((video.Height-1)/spatial_factor)+1,...
            floor((video.Width-1)/spatial_factor)+1, length(frame_index));
        data3=zeros(floor((video.Height-1)/spatial_factor)+1,...
            floor((video.Width-1)/spatial_factor)+1, length(frame_index));
        % -----------------------------------------------------------------
        % read the video
        for t=1: length(frame_index)
            % we need to switch the color space
            % we use opponent colorspace Boosting Saliency in Color Image Features
            img=double(imresize(read(video, frame_index(t)), 1/4));
            data1(:, :, t)=(img(:, :, 1)-img(:, :, 2))/sqrt(2);
            data2(:, :, t)=(img(:, :, 1)+img(:, :, 2)-2*img(:, :, 3))/sqrt(6);
            data3(:, :, t)=(img(:, :, 1)+img(:, :, 2)+img(:, :, 3))/sqrt(3);
        end
        % -----------------------------------------------------------------
        % compute saliency
        sal=dense_video_saliency(data1);
        sal=sal+dense_video_saliency(data2);
        sal=sal+dense_video_saliency(data3);
        % -----------------------------------------------------------------
        % show the result
        rho=mean(sal(:))*2;
        video_result=avifile([dir_result list_video(i).name(1: end-4) '\'...
            list_video(i).name(1: end-4) num2str(k-1, '_%02d.avi')],...
            'compression', 'XVID', 'fps', 30);
        for t=1: size(sal, 3)
            img1=cat(3, sal(:, :, t)/rho, data3(:, :, t)/256/sqrt(3)); 
            img1=sc(img1, 'prob'); 
            img2=cat(3, full(mask{frame_index(t)}), data3(:, :, t)/256/sqrt(3)); 
            img2=sc(img2, 'prob'); 
            video_result=addframe(video_result, cat(2, img1, img2));
        end
        video_result=close(video_result);
        % -----------------------------------------------------------------
        % compare the result
        [tp2 fp2 gp2 gn2]=compare_saliency_volume(sal, mask(frame_index), threshold);
        tp(:, i)=tp(:, i)+tp2;
        fp(:, i)=fp(:, i)+fp2;
        gp(:, i)=gp(:, i)+gp2;
        gn(:, i)=gn(:, i)+gn2;
    end
    fprintf(1, '\t%f\n', max(2*tp(:, i)./(tp(:, i)+fp(:, i)+gp(:, i))));
end
return;
clear video_info cut_location mask cut;
gn=zeros(length(threshold), length(list_video));
for i=1: length(list_video)
    video=mmreader(list_video(i).name);
    % cut detection
    cut=zeros(1, video.NumberOfFrames);
    for t=1: temporal_factor: video.NumberOfFrames
        img=double(imresize(read(video, t), 1/4));
        norm_img=norm(img(:));
        if t>1
            cut(t)=norm(img(:)-img_prev(:))/max(norm_img, norm_img_prev);
        end
        img_prev=img;
        norm_img_prev=norm_img;
    end
    cut=cut(1: temporal_factor: end);
    % detect the cut
    cut_location=[1 cut_detection(cut)*3+1 video.NumberOfFrames];
    save([dir_result list_video(i).name(1: end-4) '\'...
        list_video(i).name(1: end-4)], 'cut', 'cut_location');    
    %% --------------------------------------------------------------------
    load([dir_mask list_video(i).name(1: end-4)], 'video_info', 'mask');
    for k=2: length(cut_location)
        start_frame=cut_location(k-1)+temporal_factor;
        end_frame=cut_location(k)-temporal_factor;
        if end_frame-start_frame+1>expect_frame
            frame_index=start_frame: temporal_factor: end_frame;
        else
            frame_index=start_frame: end_frame;
        end
        if isempty(frame_index) || length(frame_index)<2
            continue;
        end
        for t=1: frame_index
            gn(:, i)=gn(:, i)+sum(sum(mask{t}~=1));
        end
    end
    clear video_info cut_location mask cut;
end
