% this scripts creates the synthetic data for simulation experiment
clear;
clc;
object=round(128*rand(33, 33));
%% ========================================================================
% no background
data1=255*ones(256, 256, 256, 'uint8');
x=round(32+32*[(1+sin((1: 256)*pi/32)); (1+cos((1: 256)*pi/32))]+128*rand(2, 256));
video=avifile('data1.avi');
video.Fps=10;
for i=1: size(data1, 3)
    data1(max(x(1, i)-16, 1): min(x(1, i)+16, 256), max(x(2, i)-16, 1): min(x(2, i)+16, 256), i)=object;
    video=addframe(video, repmat(data1(:, :, i), [1 1 3]));
%     imshow(data1(:, :, i));
%     pause(0.02);
end
video=close(video);
%% ========================================================================
% complex background
img=imread('Rmosaic.jpg');
if size(img, 3)~=1
    img=rgb2gray(img);
end
data2=repmat(img, [1 1 256]);
video=avifile('data2.avi');
video.Fps=10;
for i=1: size(data2, 3)
    data2(max(x(1, i)-16, 1): min(x(1, i)+16, 256), max(x(2, i)-16, 1): min(x(2, i)+16, 256), i)=object;
    video=addframe(video, repmat(data2(:, :, i), [1 1 3]));
%     imshow(data2(:, :, i));
%     pause(0.02);
end
video=close(video);
%% ========================================================================
% complex and changing background
img2=imread('rock.jpg');
if size(img2, 3)~=1
    img2=rgb2gray(img2);
end
data3=ones(256, 256, 256, 'uint8');
y=.5+.5*sin((1: 256)*pi/64);
video=avifile('data3.avi');
video.Fps=10;
img=double(img);
img2=double(img2);
for i=1: size(data3, 3)
    data3(:, :, i)=uint8(y(i)*img+(1-y(i))*img2);
    data3(max(x(1, i)-16, 1): min(x(1, i)+16, 256), max(x(2, i)-16, 1): min(x(2, i)+16, 256), i)=object;
    video=addframe(video, repmat(data3(:, :, i), [1 1 3]));
%     imshow(data3(:, :, i));
%     pause(0.02);
end
video=close(video);
%% ========================================================================
% complex background, complex movement
x2=round(128+64*[sin((1: 256)*pi/32); cos((1: 256)*pi/32)]);
data4=ones(256, 256, 256, 'uint8');
video=avifile('data4.avi');
video.Fps=10;
for i=1: size(data4, 3)
    data4(:, :, i)=uint8(y(i)*img+(1-y(i))*img2);
    data4(max(x(1, i)-16, 1): min(x(1, i)+16, 256), max(x(2, i)-16, 1): min(x(2, i)+16, 256), i)=object;
    data4(max(x2(1, i)-16, 1): min(x2(1, i)+16, 256), max(x2(2, i)-16, 1): min(x2(2, i)+16, 256), i)=object;
    video=addframe(video, repmat(data4(:, :, i), [1 1 3]));
%     imshow(data4(:, :, i));
%     pause(0.02);
end
video=close(video);
%% ========================================================================
% experiment
sal1=dense_video_saliency(data1);
sal2=dense_video_saliency(data2);
sal3=dense_video_saliency(data3);
sal4=dense_video_saliency(data4);
sal=sal4>mean(sal4(:)*8);
for i=1: size(sal, 3)
    imshow(sal(:, :, i));
    pause(0.04);
end
video=avifile('result.avi', 'Fps', 8, 'Compression', 'XVID');
h=figure();
h=axes('position', [0 0 1 1], 'parent', h);
for i=1: size(data4, 3)
	imagesc(sal4(:, :, i)); axis image; axis off; title('Proposed: Multi-scale, 3D FFT');
%    subplot(221); imshow(data4(:, :, i)); title('Input');
%    subplot(222); imagesc(sal4(:, :, i)); axis image; axis off; title('Proposed: Multi-scale, 3D FFT');
%    subplot(223); imagesc(qsal(:, :, i)); axis image; axis off; title('QFT: Single-scale, 2D QFT, Motion');
%    subplot(224); imagesc(sal(:, :, i)); axis image; axis off; title('Proposed: Single-scale, 3D FFT');

set(gcf, 'position', [100 100 256 256]);
    video=addframe(video, getframe(h));
end
video=close(video);
% for comparison
% data=data4+1i*cat(3, zeros(256, 256), (data4(:, :, 2: end)-data4(:, :, 1: end-1)));
% sal=dense_video_saliency(data);
% sal=sal/max(sal(:));
sigma=0.006*(sqrt(256^2+256^2));
radius=round(sigma*6)+1;
h=fspecial('gaussian', radius, sigma);
data=double(data4);
sal=zeros(size(data));
for i=2: size(data, 3)
    tmp=data(:, :, i)+1i*abs(data(:, :, i)-data(:, :, i-1));
    tmp=fft(tmp);
    tmp=abs(ifft(tmp./(abs(tmp)+eps))).^2;
    tmp=imfilter(tmp, h);
    sal(:, :, i)=tmp;
end
sal=sal./max(sal(:));
video=avifile('result_QFT.avi', 'Fps', 8, 'Compression', 'XVID');
h=figure();
h=axes('position', [0 0 1 1], 'parent', h);
for i=1: size(data, 3)
	% imagesc(sal(:, :, i)); axis image; axis off; title('Proposed: Multi-scale, 3D FFT');
    imshow(sal(:, :, i)); colormap jet;
    set(gcf, 'position', [100 100 256 256]);
    video=addframe(video, getframe(h));
end
video=close(video);




h=figure();
h1=axes('parent', h, 'position', [0 0 0.5 0.5]);
h2=axes('parent', h, 'position', [0 0.5 0.5 0.5]);
h3=axes('parent', h, 'position', [0.5 0 0.5 0.5]);
h4=axes('parent', h, 'position', [0.5 0.5 0.5 0.5]);
i=1;
imshow(data4(:, :, i), 'parent', h2); colormap gray; freezeColors;
imshow(img_t, 'parent', h1); text(32, 192, num2str(i), 'parent', h1, 'fontsize', 24);freezeColors;
imshow(sal4(:, :, i), 'parent', h4); colormap jet; freezeColors;
imshow(sal(:, :, i), 'parent', h3); colormap jet; freezeColors;
set(h, 'position', [100 100 512 512]);
waitforbuttonpress();
video=avifile('simulation_result_data4.avi', 'Compression', 'XVID', 'FPS', 8);
for i=1: 256
    imshow(data4(:, :, i), 'parent', h2); colormap gray; freezeColors;
    imshow(img_t, 'parent', h1); text(32, 192, num2str(i), 'parent', h1, 'fontsize', 24);freezeColors;
    imshow(sal4(:, :, i), 'parent', h4); colormap jet; freezeColors;
    imshow(sal(:, :, i), 'parent', h3); colormap jet; freezeColors;
    set(h, 'position', [100 100 512 512]);
    video=addframe(video, getframe(h));
end
video=close(video);
