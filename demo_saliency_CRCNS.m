% this script run spatiotemporal saliency on DIEM dataset
clear;
clc;
%% ========================================================================
% parameters
dir_root='G:\CRCNS-DataShare\';
dir_video=[dir_root 'stimuli\'];
dir_mask=[dir_root 'data-orig\'];
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
threshold=[0:0.02:0.2 0.3:0.1:1]';
warning('off', 'MATLAB:audiovideo:aviset:compressionUnsupported');
warning('off', 'MATLAB:audiovideo:aviaddframe:frameheightpaddedframeheightpadded');
%% ========================================================================
% main algorithm
cd(dir_video)
list_video=dir('*.avi');
fp=zeros(length(threshold), length(list_video));
tp=zeros(length(threshold), length(list_video));
gp=zeros(length(threshold), length(list_video));
gn=zeros(length(threshold), length(list_video));
for i=1: length(list_video)
    fprintf(1, 'processing %s', list_video(i).name);
    if exist([dir_result list_video(i).name(1: end-4)], 'dir')>0
        fprintf(1, '\n');
        continue;
    end
    mkdir([dir_result list_video(i).name(1: end-4)]);
    video=mmreader(list_video(i).name);
    %% --------------------------------------------------------------------
    load([dir_mask list_video(i).name(1: end-4)], 'mask');
    % saliency computation
    data1=zeros(floor((video.Height-1)/spatial_factor)+1,...
        floor((video.Width-1)/spatial_factor)+1, video.NumberOfFrames);
    data2=zeros(floor((video.Height-1)/spatial_factor)+1,...
        floor((video.Width-1)/spatial_factor)+1, video.NumberOfFrames);
    data3=zeros(floor((video.Height-1)/spatial_factor)+1,...
        floor((video.Width-1)/spatial_factor)+1, video.NumberOfFrames);
    % -----------------------------------------------------------------
    % read the video
    for t=1: video.NumberOfFrames
        % we need to switch the color space
        % we use opponent colorspace Boosting Saliency in Color Image Features
        img=double(imresize(read(video, t), 1/4));
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
        list_video(i).name(1: end-4) '.avi'],...
        'compression', 'XVID', 'fps', 30);
    for t=1: size(sal, 3)
        img1=cat(3, sal(:, :, t)/rho, data3(:, :, t)/256/sqrt(3)); 
        img1=sc(img1, 'prob'); 
        img2=cat(3, full(mask{t}), data3(:, :, t)/256/sqrt(3)); 
        img2=sc(img2, 'prob'); 
        video_result=addframe(video_result, cat(2, img1, img2));
    end
    video_result=close(video_result);
    % -----------------------------------------------------------------
    % compare the result
    [tp2 fp2 gp2 gn2]=compare_saliency_volume(sal, mask, threshold);
    tp(:, i)=tp(:, i)+tp2;
    fp(:, i)=fp(:, i)+fp2;
    gp(:, i)=gp(:, i)+gp2;
    gn(:, i)=gn(:, i)+gn2;
    fprintf(1, '\t%f\n', max(2*tp(:, i)./(tp(:, i)+fp(:, i)+gp(:, i))));
end
%% ========================================================================
% generate the graph we want
% -------------------------------------------------------------------------
% AUC
x=[sum(fp, 2)./sum(gn, 2), sum(tp, 2)./sum(gp, 2)];
x=cat(1, x, [0 0]);
plot(x(:, 1), x(:, 2), 'LineWidth', 2, 'Marker', '+');
xlabel('False Postive Rate', 'FontSize', 18);
ylabel('True Postive Rate', 'FontSize', 18);
hleg=legend(num2str(trapz(x(:, 1), x(:, 2)), 'AUC=%f'), 'Location', 'SouthEast');
set(hleg, 'FontSize', 18);
% -------------------------------------------------------------------------
% generate the AUC for each video
AUC=zeros(size(fp, 2), 1);
for i=1: size(fp, 2)
    x=[fp(:, i)./gn(:, i), tp(:, i)./gp(:, i)];
    x=cat(1, x, [0 0]);
    AUC(i)=-trapz(x(:, 1), x(:, 2));
end
video_name=cell(size(list_video));
for i=1: length(video_name)
    video_name{i}=list_video(i).name(1: end-4);
end
bar(AUC); 
set(gca, 'Xtick', 1: length(AUC), 'XtickLabel', video_name);
axis([0.5 length(AUC)+0.5 0 1]);
xticklabel_rotate([], 60);
