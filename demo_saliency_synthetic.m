clear;
clc;
% this function compare the video saliency on the synthetic data
dir_root='C:\Users\qzhang53\Documents\MATLAB\video_saliency\';
cd(dir_root);
repeat=3;
threshold=[0:0.02:0.2 0.3:0.1:1]';
% task/method
fp=cell(3, 3);
tp=cell(3, 3);
gp=cell(3, 3);
gn=cell(3, 3);
%% ========================================================================
% flicker experiment
flicker_diff=[120 240 360 480];
flicker_offset=[0 120 240 360];
flicker_fore=repmat(flicker_diff, 4 ,1)+repmat(flicker_offset', 1, 4);
flicker_back=cat(2, flicker_fore-repmat(flicker_diff, 4 ,1), flicker_fore+repmat(flicker_diff, 4 ,1));
flicker_fore=cat(2, flicker_fore, flicker_fore);
flag=flicker_back>0 & flicker_fore>0;
flicker_back=flicker_back(flag);
flicker_fore=flicker_fore(flag);
for i=1: 3
    fp{i, 1}=zeros(length(threshold), length(flicker_back));
    tp{i, 1}=zeros(length(threshold), length(flicker_back));
    gp{i, 1}=zeros(length(threshold), length(flicker_back));
    gn{i, 1}=zeros(length(threshold), length(flicker_back));
end
% =========================================================================
for i=1: length(flicker_back)
    for k=1: repeat
        fprintf(1, 'saliency_synthetic_flicker_%d_%d\n', i, k);
    % =====================================================================
        % generate data
        [data target]=video_saliency_synthetic('flicker', struct('flicker_back',...
            flicker_back(i), 'flicker_fore', flicker_fore(i)));
        mask0=false(size(data, 1), size(data, 2));
        mask0((target(1)-1)*29+(1: 29), (target(2)-1)*29+(1: 29))=true;
        mask0=sparse(mask0);
        mask=cell(1, size(data, 3));
        for t=1: size(data, 3)
            mask{t}=mask0;
        end
        %{
    % =====================================================================
        % proposed
        sal_proposed=dense_video_saliency(data);
        [tp2 fp2 gp2 gn2]=compare_saliency_volume(sal_proposed, mask, threshold);
        fp{1, 1}(:, i)=fp{1, 1}(:, i)+fp2;
        tp{1, 1}(:, i)=tp{1, 1}(:, i)+tp2;
        gp{1, 1}(:, i)=gp{1, 1}(:, i)+gp2;
        gn{1, 1}(:, i)=gn{1, 1}(:, i)+gn2;
    % =====================================================================
        % QFT
        sal_QFT=video_saliency_QFT(data);
        [tp2 fp2 gp2 gn2]=compare_saliency_volume(sal_QFT, mask, threshold);
        fp{2, 1}(:, i)=fp{2, 1}(:, i)+fp2;
        tp{2, 1}(:, i)=tp{2, 1}(:, i)+tp2;
        gp{2, 1}(:, i)=gp{2, 1}(:, i)+gp2;
        gn{2, 1}(:, i)=gn{2, 1}(:, i)+gn2;
    % =====================================================================
        % Image signature
        sal_sigature=video_saliency_FFT(data);
        [tp2 fp2 gp2 gn2]=compare_saliency_volume(sal_sigature, mask, threshold);
        fp{3, 1}(:, i)=fp{3, 1}(:, i)+fp2;
        tp{3, 1}(:, i)=tp{3, 1}(:, i)+tp2;
        gp{3, 1}(:, i)=gp{3, 1}(:, i)+gp2;
        gn{3, 1}(:, i)=gn{3, 1}(:, i)+gn2;
    % =====================================================================
        %}
        data=data>0;
        save(sprintf('saliency_synthetic_flicker_%d_%d', i, k), 'data', 'target');
    end
end
%% ========================================================================
% flicker experiment
[direction_fore direction_back]=meshgrid((0:10:90)*pi/180, (0:10:90)*pi/180);
direction_fore=direction_fore(:);
direction_back=direction_back(:);
velocity_back=[10 18 26 34]/60;
for i=1: 3
    fp{i, 2}=zeros(length(threshold), length(direction_back));
    tp{i, 2}=zeros(length(threshold), length(direction_back));
    gp{i, 2}=zeros(length(threshold), length(direction_back));
    gn{i, 2}=zeros(length(threshold), length(direction_back));
end
% =========================================================================
for i=1: length(direction_back)
    for k=1: length(velocity_back)
    % =====================================================================
        fprintf(1, 'saliency_synthetic_direction_%d_%d\n', i, k);
        % generate data
        [data target]=video_saliency_synthetic('direction', struct('direction_back',...
            direction_back(i), 'direction_fore', direction_fore(i), 'velocity_back', velocity_back(k)));
        mask0=false(size(data, 1), size(data, 2));
        mask0((target(1)-1)*29+(1: 29), (target(2)-1)*29+(1: 29))=true;
        mask0=sparse(mask0);
        mask=cell(1, size(data, 3));
        for t=1: size(data, 3)
            mask{t}=mask0;
        end
        %{
    % =====================================================================
        % proposed
        sal_proposed=dense_video_saliency(data);
        [tp2 fp2 gp2 gn2]=compare_saliency_volume(sal_proposed, mask, threshold);
        fp{1, 2}(:, i)=fp{1, 2}(:, i)+fp2;
        tp{1, 2}(:, i)=tp{1, 2}(:, i)+tp2;
        gp{1, 2}(:, i)=gp{1, 2}(:, i)+gp2;
        gn{1, 2}(:, i)=gn{1, 2}(:, i)+gn2;
    % =====================================================================
        % QFT
        sal_QFT=video_saliency_QFT(data);
        [tp2 fp2 gp2 gn2]=compare_saliency_volume(sal_QFT, mask, threshold);
        fp{2, 2}(:, i)=fp{2, 2}(:, i)+fp2;
        tp{2, 2}(:, i)=tp{2, 2}(:, i)+tp2;
        gp{2, 2}(:, i)=gp{2, 2}(:, i)+gp2;
        gn{2, 2}(:, i)=gn{2, 2}(:, i)+gn2;
    % =====================================================================
        % Image signature
        sal_sigature=video_saliency_FFT(data);
        [tp2 fp2 gp2 gn2]=compare_saliency_volume(sal_sigature, mask, threshold);
        fp{3, 2}(:, i)=fp{3, 2}(:, i)+fp2;
        tp{3, 2}(:, i)=tp{3, 2}(:, i)+tp2;
        gp{3, 2}(:, i)=gp{3, 2}(:, i)+gp2;
        gn{3, 2}(:, i)=gn{3, 2}(:, i)+gn2;
    % =====================================================================
        %}
        data=data>0;
        save(sprintf('saliency_synthetic_direction_%d_%d', i, k), 'data', 'target');
    end
end
%% ========================================================================
% flicker experiment
[velocity_fore velocity_back]=meshgrid([10 18 26 34]/60, [10 18 26 34]/60);
velocity_fore=velocity_fore(:);
velocity_back=velocity_back(:);
direction_back=[0:45:315]/180*pi;
for i=1: 3
    fp{i, 3}=zeros(length(threshold), length(velocity_back));
    tp{i, 3}=zeros(length(threshold), length(velocity_back));
    gp{i, 3}=zeros(length(threshold), length(velocity_back));
    gn{i, 3}=zeros(length(threshold), length(velocity_back));
end
% =========================================================================
for i=1: length(velocity_back)
    for k=1: length(direction_back);
        fprintf(1, 'saliency_synthetic_velocity_%d_%d\n', i, k);
    % =====================================================================
        % generate data
        [data target]=video_saliency_synthetic('velocity', struct('velocity_back',...
            velocity_back(i), 'velocity_fore', velocity_fore(i), 'direction_back', direction_back(k)));
        mask0=false(size(data, 1), size(data, 2));
        mask0((target(1)-1)*29+(1: 29), (target(2)-1)*29+(1: 29))=true;
        mask0=sparse(mask0);
        mask=cell(1, size(data, 3));
        for t=1: size(data, 3)
            mask{t}=mask0;
        end
        %{
    % =====================================================================
        % proposed
        sal_proposed=dense_video_saliency(data);
        [tp2 fp2 gp2 gn2]=compare_saliency_volume(sal_proposed, mask, threshold);
        fp{1, 3}(:, i)=fp{1, 3}(:, i)+fp2;
        tp{1, 3}(:, i)=tp{1, 3}(:, i)+tp2;
        gp{1, 3}(:, i)=gp{1, 3}(:, i)+gp2;
        gn{1, 3}(:, i)=gn{1, 3}(:, i)+gn2;
    % =====================================================================
        % QFT
        sal_QFT=video_saliency_QFT(data);
        [tp2 fp2 gp2 gn2]=compare_saliency_volume(sal_QFT, mask, threshold);
        fp{2, 3}(:, i)=fp{2, 3}(:, i)+fp2;
        tp{2, 3}(:, i)=tp{2, 3}(:, i)+tp2;
        gp{2, 3}(:, i)=gp{2, 3}(:, i)+gp2;
        gn{2, 3}(:, i)=gn{2, 3}(:, i)+gn2;
    % =====================================================================
        % Image signature
        sal_sigature=video_saliency_FFT(data);
        [tp2 fp2 gp2 gn2]=compare_saliency_volume(sal_sigature, mask, threshold);
        fp{3, 3}(:, i)=fp{3, 3}(:, i)+fp2;
        tp{3, 3}(:, i)=tp{3, 3}(:, i)+tp2;
        gp{3, 3}(:, i)=gp{3, 3}(:, i)+gp2;
        gn{3, 3}(:, i)=gn{3, 3}(:, i)+gn2;
    % =====================================================================
        %}
        data=data>0;
        save(sprintf('saliency_synthetic_velocity_%d_%d', i, k), 'data', 'target');
    end
end
return;
%% ========================================================================
% compute the AUC
auc=cell(1, 3);
for kk=1: 3
    auc{kk}=zeros(3, size(fp{1,kk}, 2));
    for ii=1: size(auc{kk}, 1)
        for jj=1: size(auc{kk}, 2)
            auc{kk}(ii, jj)=compute_auc(fp{ii, kk}(:, jj)./gn{ii, kk}(:, jj), tp{ii, kk}(:, jj)./gp{ii, kk}(:, jj));
        end
    end
end
%% ========================================================================
% show the result
% ground according to the diff
flicker_diff=abs(flicker_fore-flicker_back);
[flicker_diff ans flicker_group]=unique(flicker_diff);
auc_flicker=zeros(3, length(flicker_diff), 2);
for i=1: 3
    for j=1: length(flicker_diff)
        mu=mean(auc{1}(i, flicker_group==j));
        sigma=std(auc{1}(i, flicker_group==j));
        auc_flicker(i, j, :)=[mu, sigma];
    end
end
figure; 
hold on; 
errorbar(flicker_diff, auc_flicker(1, :, 1), auc_flicker(1, :, 2), 'r+', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(flicker_diff, auc_flicker(2, :, 1), auc_flicker(2, :, 2), 'k*', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(flicker_diff, auc_flicker(3, :, 1), auc_flicker(3, :, 2), 'go', 'LineWidth', 2, 'MarkerSize', 8); 
hold off; 
hleg=legend({'Proposed', 'Bian[15]' 'Hou[8]'}); 
set(hleg, 'FontSize', 18);
%% ========================================================================
% show the result
% ground according to the diff
direction_diff=round(abs(direction_fore-direction_back)*18/pi)/pi*18;
[direction_diff ans direction_group]=unique(direction_diff);
auc_direction=zeros(3, length(direction_diff), 2);
for i=1: 3
    for j=1: length(direction_diff)
        mu=mean(auc{2}(i, direction_group==j));
        sigma=std(auc{2}(i, direction_group==j));
        auc_direction(i, j, :)=[mu, sigma];
    end
end
figure; 
hold on; 
errorbar(direction_diff, auc_direction(1, :, 1), auc_direction(1, :, 2), 'r+', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(direction_diff, auc_direction(2, :, 1), auc_direction(2, :, 2), 'k*', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(direction_diff, auc_direction(3, :, 1), auc_direction(3, :, 2), 'go', 'LineWidth', 2, 'MarkerSize', 8); 
hold off; 
hleg=legend({'Proposed', 'Bian[15]' 'Hou[8]'}); 
set(hleg, 'FontSize', 18);
%% ========================================================================
% show the result
% ground according to the diff
velocity_diff=round(abs(velocity_fore-velocity_back)*15)/15;
[velocity_diff ans velocity_group]=unique(velocity_diff);
auc_velocity=zeros(3, length(velocity_diff), 2);
for i=1: 3
    for j=1: length(velocity_diff)
        mu=mean(auc{3}(i, velocity_group==j));
        sigma=std(auc{3}(i, velocity_group==j));
        auc_velocity(i, j, :)=[mu, sigma];
    end
end
figure; 
hold on; 
errorbar(velocity_diff, auc_velocity(1, :, 1), auc_velocity(1, :, 2), 'r+', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(velocity_diff, auc_velocity(2, :, 1), auc_velocity(2, :, 2), 'k*', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(velocity_diff, auc_velocity(3, :, 1), auc_velocity(3, :, 2), 'go', 'LineWidth', 2, 'MarkerSize', 8); 
hold off; 
hleg=legend({'Proposed', 'Bian[15]' 'Hou[8]'}); 
set(hleg, 'FontSize', 18);
%% ========================================================================
figure;
axes('position', [0.03 0.1 0.3 0.8]);
title('Flicker', 'FontSize', 18);
hold on; 
errorbar(flicker_diff, auc_flicker(1, :, 1), auc_flicker(1, :, 2), 'r+', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(flicker_diff, auc_flicker(2, :, 1), auc_flicker(2, :, 2), 'k*', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(flicker_diff, auc_flicker(3, :, 1), auc_flicker(3, :, 2), 'go', 'LineWidth', 2, 'MarkerSize', 8); 
hold off; 
xlabel('Absolute differences of the flicker rate');
hleg=legend({'Proposed', 'Bian[15]' 'Hou[8]'}); 
set(hleg, 'FontSize', 18);
axes('position', [0.36 0.1 0.3 .8]);
title('Direction', 'FontSize', 18);
hold on; 
errorbar(direction_diff, auc_direction(1, :, 1), auc_direction(1, :, 2), 'r+', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(direction_diff, auc_direction(2, :, 1), auc_direction(2, :, 2), 'k*', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(direction_diff, auc_direction(3, :, 1), auc_direction(3, :, 2), 'go', 'LineWidth', 2, 'MarkerSize', 8); 
hold off; 
xlabel('Absolute differences of the direction');
hleg=legend({'Proposed', 'Bian[15]' 'Hou[8]'}); 
set(hleg, 'FontSize', 18);
axes('position', [0.69 0.1 0.3 .8]);
title('Velocity', 'FontSize', 18);
hold on; 
errorbar(velocity_diff, auc_velocity(1, :, 1), auc_velocity(1, :, 2), 'r+', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(velocity_diff, auc_velocity(2, :, 1), auc_velocity(2, :, 2), 'k*', 'LineWidth', 2, 'MarkerSize', 8); 
errorbar(velocity_diff, auc_velocity(3, :, 1), auc_velocity(3, :, 2), 'go', 'LineWidth', 2, 'MarkerSize', 8); 
hold off; 
xlabel('Absolute differences of the velocity');
hleg=legend({'Proposed', 'Bian[15]' 'Hou[8]'}); 
set(hleg, 'FontSize', 18);
set(gcf, 'position', [1 1 1200 320]);
