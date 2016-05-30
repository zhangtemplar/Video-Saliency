% this function implements video saliency based on QFT in this paper
%   Spatio-temporal Saliency Detection Using Phase Spectrum of Quaternion
%   Fourier Transform
% for color image
% please use the following form x=[height width color frame];
function z=video_saliency_QFT(x, sigma, radius)
    % padding x
    [R C T N]=size(x);
    z=zeros(R, C, T);
    % smooth the input [optional]
    % multi scale saliency
    % note a common strategy of setting sigma is make it 1/50 of the
    % diagonal of the image. 
    if nargin<2 || isempty(sigma)
        sigma=0.05*C;%min(r, c);
    end
    if nargin<3 || isempty(radius)
        radius=round(sigma*6)+1;
    end
    H=fspecial('gaussian', radius, sigma);
    if N==1
        % it is a gray scale image
        img=squeeze(x(:, :, 1, :));
        img_prev=img;
        data=quaternion(img, zeros(size(img)), zeros(size(img)), img);
        z(:, :, 1)=imfilter(image_salency_QFT(data), H);
        for t=2: T
            img=squeeze(x(:, :, t, :));
            data=quaternion(abs(img-img_prev), zeros(size(img)), zeros(size(img)), img);
            z(:, :, t)=imfilter(image_salency_QFT(data), H);
            img_prev=img;
        end
    else
        % for color
        img=rgb2opponent(squeeze(x(:, :, 1, :)));
        data=quaternion(img(:, :, 3), img(:, :, 1), img(:, :, 2), img(:, :, 3));
        z(:, :, 1)=imfilter(image_salency_QFT(data), H);
        img_prev=img;
        for t=2: T
            img=rgb2opponent(x(:, :, :, t));
            data=quaternion(abs(img_prev(:, :, 3)-img(:, :, 3)), img(:, :, 1), img(:, :, 2), img(:, :, 3));
            z(:, :, t)=imfilter(image_salency_QFT(data), H);
            img_prev=img;
        end
    end
end

function z=image_salency_QFT(x)
    z=fft2(x);
    z=abs(ifft2(z./(abs(z)+eps))).^2;
end
