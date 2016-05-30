video=VideoReader('hard-Cloudy_Xvid.avi');
frame_interval=3;
cform=makecform('srgb2lab');
sigma=0.006*sqrt(video.Width^2+video.Height^2);
cfilter=fspecial('gaussian', round(sigma*6+1), sigma);
img_prev=read(video, 1);
img_prev=double(applycform(img_prev, cform));
for t=1+frame_interval: frame_interval: video.NumberOfFrames
    img=read(video, t);
    img_next=double(applycform(img, cform));
    data=quaternion(abs(img_next(:, :, 1)-img_prev(:, :, 1)),...
        img_next(:, :, 1), img_next(:, :, 2), img_next(:, :, 3));
    coef=fft2(data);
    sal=abs(ifft2(coef./abs(coef))).^2;
    sal=imfilter(sal, cfilter);
    subplot(121); imagesc(sal); axis image; axis off; title(num2str(t));
    subplot(122); imshow(img);
    pause(0.05);
    img_prev=img_next;
end
