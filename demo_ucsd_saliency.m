% this file processes the UCSD dataset.
% the optical flow dose'nt help other than the intensity
clear;
clc;
dir_root='C:\Users\qzhang53\Documents\MATLAB\Dataset\uscd_saliency\';
dir_image=[dir_root 'video\'];
dir_mask=[dir_root 'truth\'];
dir_result=[dir_root 'result\'];
cd(dir_root);
cd(dir_image);
dirlist=dir('*');
flow_params = {[],4,2,[]};
threshold=0:0.05:1;
% h=axes('position', [0 0 1 1]);
fmeasure=zeros(length(dirlist), length(threshold));
tp=zeros(length(dirlist), length(threshold));
fp=zeros(length(dirlist), length(threshold));
gp=zeros(length(dirlist), length(threshold));
for i=3: length(dirlist)
    if ~dirlist(i).isdir% || ~isempty(strfind(dirlist(i).name, 'Train'))
        continue;
    end
    cd(dirlist(i).name);
    fprintf(1, 'Processing %s:\n', dirlist(i).name);
    % =================================================================
    % scan the image
    imagelist=dir('*.jpg');
    img_prev=imread(imagelist(1).name);
    if size(img_prev, 3)~=1
        img_prev=rgb2gray(img_prev);
    end
    data=zeros(size(img_prev, 1), size(img_prev, 2), length(imagelist));
    for k=1: length(imagelist)
        img=imread(num2str(k, 'frame_%d.jpg'));
        if size(img, 3)~=1
            img=rgb2gray(img);
        end
        data(:, :, k)=img/255;
    end
    clear img_prev;
    % =================================================================
    % compute the visual saliency
    sal=dense_video_saliency(data);
    sal=sal/max(sal(:));
    % =================================================================
    % compute the accuracy
    clear data;
    load([dir_mask dirlist(i).name '_GT.mat']);
    for j=1: length(threshold)
        for k=1: min(size(GT, 3), length(imagelist))
            [fm1, tp1, fp1, gp1]=compute_fmeasure(sal(:, :, k)>=threshold(j), GT(:, :, k));
            tp(i, j)=tp(i, j)+tp1;
            fp(i, j)=fp(i, j)+fp1;
            gp(i, j)=gp(i, j)+gp1;
        end
        fmeasure(i, j)=2*tp(i, j)/(tp(i, j)+fp(i, j)+gp(i, j));
    end
    % =================================================================
    % save the saliency value and map
    save([dir_result dirlist(i).name '_result.mat'], 'sal');
%     video=avifile([dir_result dirlist(i).name '_sal.avi'], 'compression', 'xvid', 'fps', 10);
%     for k=1: length(imagelist)
%         imshow(sal(:, :, k));
%         colormap jet;
%         set(gcf, 'position', [100 100 size(img, 2) size(img, 1)]);
%         video=addframe(video, getframe(h));
%     end
%     video=close(video);
    cd('..');
end

