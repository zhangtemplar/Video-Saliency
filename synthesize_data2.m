% this code is to verify the assumption that, the temporal detection is
% actually a high pass filter, thus the phase only transform is meaningful
clear;
clc;
object=round(128*rand(33, 33));
img=imread('Rmosaic.jpg');
if size(img, 3)~=1
    img=rgb2gray(img);
end
img2=imread('rock.jpg');
if size(img2, 3)~=1
    img2=rgb2gray(img2);
end
x=round(32+32*[(1+sin((1: 256)*pi/32)); (1+cos((1: 256)*pi/32))]+128*rand(2, 256));
y=.5+.5*sin((1: 256)*pi/64);
x2=round(128+64*[sin((1: 256)*pi/32); cos((1: 256)*pi/32)]);
x1=round(128+64*[sin((1: 256)*pi/1); cos((1: 256)*pi/1)]);
data1=ones(256, 256, 256, 'uint8');
data2=ones(256, 256, 256, 'uint8');
for i=1: size(data1, 3)
    data1(:, :, i)=uint8(y(i)*img+(1-y(i))*img2);
    data1(max(x(1, i)-16, 1): min(x(1, i)+16, 256), max(x(2, i)-16, 1): min(x(2, i)+16, 256), i)=object;
    data1(max(x2(1, i)-16, 1): min(x2(1, i)+16, 256), max(x2(2, i)-16, 1): min(x2(2, i)+16, 256), i)=object;
    data2(:, :, i)=uint8(y(i)*img+(1-y(i))*img2);
    data2(max(x(1, i)-16, 1): min(x(1, i)+16, 256), max(x(2, i)-16, 1): min(x(2, i)+16, 256), i)=object;
    data2(max(x1(1, i)-16, 1): min(x1(1, i)+16, 256), max(x1(2, i)-16, 1): min(x1(2, i)+16, 256), i)=object;
%     video=addframe(video, repmat(data1(:, :, i), [1 1 3]));
%     imshow(data4(:, :, i));
%     pause(0.02);
end
sal1=dense_video_saliency(double(data1));
sal2=dense_video_saliency(double(data2));
sal1=sal1/max(sal1(:));
sal2=sal2/max(sal2(:));
h=figure();
h1=axes('parent', h, 'position', [0 0 0.5 0.5]);
h2=axes('parent', h, 'position', [0 0.5 0.5 0.5]);
h3=axes('parent', h, 'position', [0.5 0 0.5 0.5]);
h4=axes('parent', h, 'position', [0.5 0.5 0.5 0.5]);
i=1;
imshow(data1(:, :, i), 'parent', h1); colormap gray; freezeColors;
imshow(data2(:, :, i), 'parent', h2); colormap gray; freezeColors;
imshow(sal1(:, :, i), 'parent', h3); colormap jet; freezeColors;
imshow(sal2(:, :, i), 'parent', h4); colormap jet; freezeColors;
set(h, 'position', [100 100 512 512]);
waitforbuttonpress();
video=avifile('simulation_result_data4.avi', 'Compression', 'XVID', 'FPS', 8);
for i=1: 256
    imshow(data2(:, :, i), 'parent', h2); colormap gray; freezeColors;
    imshow(data1(:, :, i), 'parent', h1); colormap gray; freezeColors;
    imshow(sal2(:, :, i), 'parent', h4); colormap jet; freezeColors;
    imshow(sal1(:, :, i), 'parent', h3); colormap jet; freezeColors;
    set(h, 'position', [100 100 512 512]);
    video=addframe(video, getframe(h));
end
video=close(video);
