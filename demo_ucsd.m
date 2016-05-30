% this file processes the UCSD dataset.
% the optical flow dose'nt help other than the intensity
clear;
clc;
root_dir='C:\Users\qzhang53\Documents\MATLAB\Dataset\UCSD_Anomaly_Dataset\';
cd(root_dir);
f1=fopen('ucsd_result.txt', 'a');
h=axes('position', [0 0 1 1]);
dirlist=dir('*');
flow_params = {[],4,2,[]};
for i=3: length(dirlist)
    if ~dirlist(i).isdir% || ~isempty(strfind(dirlist(i).name, 'Train'))
        continue;
    end
    cd(dirlist(i).name);
    cd('Test');
    fprintf(1, 'Processing %s:\n', dirlist(i).name);
    fprintf(f1, 'Processing %s:\n', dirlist(i).name);
    videolist=dir('Test*');
    for j=1: length(videolist)
        % skip the ground truth
        if ~videolist(j).isdir || ~isempty(strfind(videolist(j).name, 'gt'))
            continue;
        end
        cd(videolist(j).name);
        fprintf(1, '\t%s:\n', videolist(j).name);
        fprintf(f1, '\t%s:', videolist(j).name);
        % scan the image
        imagelist=dir('*.tif');
        img_prev=imread(imagelist(1).name);
        if size(img_prev, 3)~=1
            img_prev=rgb2gray(img_prev);
        end
        data=zeros(size(img_prev, 1), size(img_prev, 2), length(imagelist));
        for k=1: length(imagelist)
            img=imread(imagelist(k).name);
            if size(img, 3)~=1
                img=rgb2gray(img);
            end
            [gx gy]=optflow_lucaskanade(img_prev, img, flow_params{:});
            data(:, :, k)=gx+gy*1i;
            img_prev=img;
        end
        % compute the visual saliency
        sal=dense_video_saliency(data);
        fprintf(f1, '%e\t', sum(sum(sal)));
        fprintf(f1, '\n');
        % save the saliency value and map
        % video=avifile(['sal_' videolist(j).name '.avi'], 'compression', 'xvid', 'fps', 10);
        sal=sal/max(sal(:));
        for k=1: length(imagelist)
            imshow(sal(:, :, k));
            colormap jet;
            set(gcf, 'position', [100 100 size(img, 2) size(img, 1)]);
            % video=addframe(video, getframe(h));
            h2=getframe(h);
            imwrite(h2.cdata, num2str(k, 'sal%03d.png'));
        end
        % video=close(video);
        cd('..');
    end
    cd('..');
    cd('..');
end
fclose(f1);
%% ========================================================================
% read the result
sal_frame={};
f1=fopen('ucsd_result.txt', 'r');
while 1
    str=fgets(f1);
    if str<0
        break;
    elseif ~isempty(strfind(str, 'ped'))
        continue;
    end
    idx=strfind(str, ':');
    A=sscanf(str(idx+1: end), '%f');
    sal_frame{end+1}=A;
end
fclose(f1);
% for i=1: length(sal_frame)
%     plot(sal_frame{i}); title(num2str(i));
%     waitforbuttonpress();
% end
% save('ucsd_result', sal_frame);
%% ========================================================================
% ground truth
TestVideoFile = {};
TestVideoFile{end+1}.gt_frame = [60:152];
TestVideoFile{end+1}.gt_frame = [50:175];
TestVideoFile{end+1}.gt_frame = [91:200];
TestVideoFile{end+1}.gt_frame = [31:168];
TestVideoFile{end+1}.gt_frame = [5:90, 140:200];
TestVideoFile{end+1}.gt_frame = [1:100, 110:200];
TestVideoFile{end+1}.gt_frame = [1:175];
TestVideoFile{end+1}.gt_frame = [1:94];
TestVideoFile{end+1}.gt_frame = [1:48];
TestVideoFile{end+1}.gt_frame = [1:140];
TestVideoFile{end+1}.gt_frame = [70:165];
TestVideoFile{end+1}.gt_frame = [130:200];
TestVideoFile{end+1}.gt_frame = [1:156];
TestVideoFile{end+1}.gt_frame = [1:200];
TestVideoFile{end+1}.gt_frame = [138:200];
TestVideoFile{end+1}.gt_frame = [123:200];
TestVideoFile{end+1}.gt_frame = [1:47];
TestVideoFile{end+1}.gt_frame = [54:120];
TestVideoFile{end+1}.gt_frame = [64:138];
TestVideoFile{end+1}.gt_frame = [45:175];
TestVideoFile{end+1}.gt_frame = [31:200];
TestVideoFile{end+1}.gt_frame = [16:107];
TestVideoFile{end+1}.gt_frame = [8:165];
TestVideoFile{end+1}.gt_frame = [50:171];
TestVideoFile{end+1}.gt_frame = [40:135];
TestVideoFile{end+1}.gt_frame = [77:144];
TestVideoFile{end+1}.gt_frame = [10:122];
TestVideoFile{end+1}.gt_frame = [105:200];
TestVideoFile{end+1}.gt_frame = [1:15, 45:113];
TestVideoFile{end+1}.gt_frame = [175:200];
TestVideoFile{end+1}.gt_frame = [1:180];
TestVideoFile{end+1}.gt_frame = [1:52, 65:115];
TestVideoFile{end+1}.gt_frame = [5:165];
TestVideoFile{end+1}.gt_frame = [1:121];
TestVideoFile{end+1}.gt_frame = [86:200];
TestVideoFile{end+1}.gt_frame = [15:108];
TestVideoFile{end+1}.gt_frame = [61:180];
TestVideoFile{end+1}.gt_frame = [95:180];
TestVideoFile{end+1}.gt_frame = [1:146];
TestVideoFile{end+1}.gt_frame = [31:180];
TestVideoFile{end+1}.gt_frame = [1:129];
TestVideoFile{end+1}.gt_frame = [1:162];
TestVideoFile{end+1}.gt_frame = [46:180];
TestVideoFile{end+1}.gt_frame = [1:180];
TestVideoFile{end+1}.gt_frame = [1:120];
TestVideoFile{end+1}.gt_frame = [1:150];
TestVideoFile{end+1}.gt_frame = [1:180];
TestVideoFile{end+1}.gt_frame = [88:180];
%% ========================================================================
% compute the performances
ground_truth=cell(size(TestVideoFile));
gp=0;
gn=0;
for i=1: length(sal_frame)
    ground_truth{i}=false(size(sal_frame{i}));
    ground_truth{i}(TestVideoFile{i}.gt_frame)=true;
    gp=gp+sum(ground_truth{i});
    gn=gn+sum(~ground_truth{i});
end
sal_tmp=cell(size(sal_frame));
for i=1: length(sal_frame)
    sal_tmp{i}=smooth(sal_frame{i});
%     sal_tmp{i}=sal_tmp{i}/max(sal_tmp{i});
end
% compute area under curve
sal_threshold=[1.0:0.2:1.8 2.0:0.1:2.3 2.32: 0.02:2.38 2.4:0.1:3.0 4.0:1.0:6.0]*1e-3;
tp=zeros(size(sal_threshold));
fp=zeros(size(sal_threshold));
for i=1: length(sal_threshold)
    for j=1: length(sal_frame)
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
