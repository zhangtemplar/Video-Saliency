clear;
clc;
%% ========================================================================
% segment the video
cd('C:\Users\qzhang53\Documents\MATLAB\video_saliency\crowd\');
segment_info=[1 626 1454 2003 2687 3456 4035 4930 5597 6255 6932;...
    625 1453 2002 2686 3455 4034 4929 5596 6254 6931 7739];
% video=VideoReader('Crowd-Activity-All.avi');
% row=240;
% col=320;
% row_offset=27;
% h=waitbar(0, 'Segmenting videos');
% for i=1: size(segment_info, 2)
%     waitbar(i/size(segment_info, 2), h);
%     clip=avifile(num2str(i, 'Crowd-Activity-%02d.avi'), 'Compression', 'XVID', 'Fps', video.FrameRate);
%     for j=segment_info(1, i): segment_info(2, i)
%         img=read(video, j);
%         clip=addframe(clip, img);
%         % clip=addframe(clip, img(row_offset: row, :, :));
%     end
%     clip=close(clip);
% end
% close(h);
% clear video;
%% ========================================================================
% saliency detection
cform=makecform('srgb2lab');
flow_params = {[],4,2,[]};
h=axes('position', [0 0 1 1]);
sal_info=cell(1, size(segment_info, 2));
for i=1: size(segment_info, 2)
    video=VideoReader(num2str(i, 'Crowd-Activity-%02d.avi'));
    data=zeros(video.Height, video.Width, video.NumberOfFrames);
%     img_prev=rgb2gray(read(video, 1));
    for j=1: video.NumberOfFrames
        data(:, :, j)=rgb2gray(read(video, j));
%         img=rgb2gray(read(video, j));
%         [gx gy]=optflow_lucaskanade(img_prev, img, flow_params{:});
%         data(:, :, j)=gx+gy*1i;
%         img_prev=img;
    end
    sal=dense_video_saliency(data);
    sal_info{i}=[max(max(sal)) sum(sum(sal))];
    sal=sal/max(sal(:));
    clip=avifile(num2str(i, 'Crowd-Activity-%02d-Result.avi'), 'Compression', 'XVID', 'Fps', video.FrameRate);
    for j=1: video.NumberOfFrames
        imshow(sal(:, :, j), 'parent', h);
        colormap jet;
        set(gcf, 'Position', [100 100 video.Width, video.Height]);
        clip=addframe(clip, getframe(h));
    end
    clip=close(clip);
    clear video clip;
end
save('crowd-Activity-all', 'sal_info');
%% ========================================================================
% saliency detection
% cform=makecform('srgb2lab');
% h=axes('position', [0 0 1 1]);
% sal_info=cell(1, size(segment_info, 2));
% for i=1: size(segment_info, 2)
%     video=VideoReader(num2str(i, 'Crowd-Activity-%02d.avi'));
%     data=zeros(video.Height, video.Width, video.NumberOfFrames);
%     for j=1: video.NumberOfFrames
%         img=read(video, j);
%         data(:, :, j, :)=rgb2gray(img);
%     end
%     sal=dense_video_saliency(data);
%     sal_info{i}=[max(reshape(sal, [], video.NumberOfFrames));...
%         mean(reshape(sal, [], video.NumberOfFrames))];
%     sal=sal/mean(sal_info{i}(1, :));
%     clip=avifile(num2str(i, 'Crowd-Activity-%02d-Result.avi'), 'Compression', 'XVID', 'Fps', video.FrameRate);
%     for j=1: video.NumberOfFrames
%         imshow(sal(:, :, j), 'parent', h);
%         colormap jet;
%         set(gcf, 'Position', [100 100 video.Width, video.Height]);
%         clip=addframe(clip, getframe(h));
%     end
%     clip=close(clip);
%     clear video clip;
% end
% save('crowd-Activity-all', 'sal_info');
%% ========================================================================
% saliency detection
% cform=makecform('srgb2lab');
% h=axes('position', [0 0 1 1]);
% sal_info=cell(1, size(segment_info, 2));
% for i=1: size(segment_info, 2)
%     video=VideoReader(num2str(i, 'Crowd-Activity-%02d.avi'));
%     data=zeros(video.Height, video.Width, video.NumberOfFrames, 3);
%     for j=1: video.NumberOfFrames
%         img=read(video, j);
%         data(:, :, j, :)=reshape(applycform(img, cform), [video.Height video.Width 1 3]);
%     end
%     sal=dense_video_saliency(data(:, :, :, 1))+...
%         dense_video_saliency(data(:, :, :, 2))+...
%         dense_video_saliency(data(:, :, :, 3));
%     sal_info{i}=[max(reshape(sal, [], video.NumberOfFrames));...
%         mean(reshape(sal, [], video.NumberOfFrames))];
%     sal=sal/mean(sal_info{i}(1, :));
%     clip=avifile(num2str(i, 'Crowd-Activity-%02d-Result.avi'), 'Compression', 'XVID', 'Fps', video.FrameRate);
%     for j=1: video.NumberOfFrames
%         imshow(sal(:, :, j), 'parent', h);
%         colormap jet;
%         set(gcf, 'Position', [100 100 video.Width, video.Height]);
%         clip=addframe(clip, getframe(h));
%     end
%     clip=close(clip);
%     clear video clip;
% end
% save('crowd-Activity-all', 'sal_info');
%% ========================================================================
% check the result
sal_tmp=cell(size(sal_info));
for i=1: size(segment_info, 2)
    sal_info{i}=squeeze(sal_info{i});
    sal_tmp{i}=smooth(sal_info{i}(2, :))';
%     sal_tmp{i}=sal_tmp{i}/max(sal_tmp{i});
end
% abnormal_info=[525, 1330, 1806, 2605, 3219, 3938, 4807, 5422, 6194, 6883, 7700;...
%     614, 1439, 1985, 2684, 3428, 4017, 4928, 5595, 6234, 6912, 7739]; 
abnormal_info=[480, 1300, 1765, 2570, 3190, 3915, 4775, 5390, 6155, 6835, 7655;...
    614, 1439, 1985, 2684, 3428, 4017, 4928, 5595, 6234, 6912, 7739]; 
abnormal_info(2, :)=min(abnormal_info(2, :), abnormal_info(1, :)+50);
abnormal_info=abnormal_info-repmat(segment_info(1, :), 2, 1);
ground_truth=cell(size(sal_info));
gp=0;
gn=0;
for i=1: size(segment_info, 2)
    ground_truth{i}=false(1, size(sal_info{i}, 2));
    ground_truth{i}(abnormal_info(1, i): abnormal_info(2, i))=true;
    gp=gp+sum(ground_truth{i});
    gn=gn+sum(~ground_truth{i});
end
% compute area under curve
sal_threshold=[2:0.1:30]*1e-4;
tp=zeros(size(sal_threshold));
fp=zeros(size(sal_threshold));
for i=1: length(sal_threshold)
    for j=1: size(segment_info, 2)
        tp(i)=tp(i)+sum(sal_tmp{j}>=sal_threshold(i) & ground_truth{j});
        fp(i)=fp(i)+sum(sal_tmp{j}>=sal_threshold(i) & ~ground_truth{j});
    end
end
tp=tp/gp;
fp=fp/gn;
plot(fp, tp); 
title(num2str(-trapz(fp, tp), 'Area under cuver: %f'), 'fontsize', 24);
% for i=1: length(sal_threshold)
%     text(fp(i), tp(i), num2str(sal_threshold(i)));
% end
xlabel('False Positive Rate', 'fontsize', 24);
ylabel('True Positive Rate', 'fontsize', 24);

i=4;
tmp=smooth(sal_info{i}(2, :));
plot(tmp); 
title(num2str(i));
hold on; 
    plot(abnormal_info(:, i), tmp(abnormal_info(:, i)), 'rx'); 
hold off;
xlabel('Frame', 'fontsize', 24);
ylabel('Score', 'fontsize', 24);
axis([1 size(sal_info{i}, 2) min(tmp) max(tmp)]);


h=figure();
h1=axes('parent', h, 'position', [0.05 0.5 0.95 0.5]);
h2=axes('parent', h, 'position', [0 0 1/3 0.5]);
h3=axes('parent', h, 'position', [1/3 0 1/3 0.5]);
h4=axes('parent', h, 'position', [2/3 0 1/3 0.5]);
i=9;
tmp=squeeze(sal_info{i}); 
tmp=smooth(tmp(2, :));
plot(h1, tmp, 'LineWidth', 2); axis(h1, [1 length(tmp) 0 max(tmp)]);
video=VideoReader(num2str(i, 'Crowd-Activity-%02d.avi'));
img1=read(video, 150);
imshow(img1, 'parent', h2);
img2=read(video, 500);
imshow(img2, 'parent', h3);
img3=read(video, 550);
imshow(img3, 'parent', h4);
set(h, 'position', [100 100 960 640]);
