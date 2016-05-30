% this function implements video saliency based on QFT in this paper
%   Spatio-temporal Saliency Detection Using Phase Spectrum of Quaternion
%   Fourier Transform
% for color image
% please use the following form x=[height width color frame];
function z=video_saliency_FFT(x, sigma, radius)
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
        for t=1: T
            z(:, :, t)=imfilter(image_salency_FFT(x(:, :, t)), H);
        end
    else
        % for color
        for t=1: T
            img=rgb2gray(squeeze(x(:, :, t, :)));
            z(:, :, t)=imfilter(image_salency_FFT(img), H);
        end
    end
end

function z=image_salency_FFT(x)
    z=fft2(x);
    z=abs(ifft2(z./(abs(z)+eps))).^2;
end
