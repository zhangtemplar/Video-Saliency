% this experiment checks the temporal effects of the visual saliency method
img2=imread('rock.jpg');
if size(img2, 3)~=1
    img2=rgb2gray(img2);
end
img=imread('Rmosaic.jpg');
if size(img, 3)~=1
    img=rgb2gray(img);
end
x_rand=128*rand(2, 256);
object=round(128*rand(33, 33));
f1=fopen('syn_visual_result.txt', 'w');
% try different temporal scale
% background
for k=[256 128 64 32 16]
    % object 1
    for j1=[256 128 64 32 16]
        % object 2
        for j2=[256 128 64 32 16]
            fprintf(1, '%3d\t%3d\t%3d\t', k, j1, j2);
            % create the video
            x=round(32+32*[(1+sin((1: 256)*pi/j1)); (1+cos((1: 256)*pi/j1))]+x_rand);
            x2=round(128+64*[sin((1: 256)*pi/j2); cos((1: 256)*pi/j2)]);
            y=.5+.5*sin((1: 256)*pi/k);
            data=ones(256, 256, 256, 'uint8');
            for i=1: size(data, 3)
                data(:, :, i)=uint8(y(i)*img+(1-y(i))*img2);
                data(max(x(1, i)-16, 1): min(x(1, i)+16, 256), max(x(2, i)-16, 1): min(x(2, i)+16, 256), i)=object;
                data(max(x2(1, i)-16, 1): min(x2(1, i)+16, 256), max(x2(2, i)-16, 1): min(x2(2, i)+16, 256), i)=object;
            end
            % compute the saliency
            sal=dense_video_saliency(data);
            % record the saliency value for each target
            sal_object=zeros(2, 256);
            for i=1: size(data, 3)
                tmp=sal(max(x(1, i)-16, 1): min(x(1, i)+16, 256), max(x(2, i)-16, 1): min(x(2, i)+16, 256), i);
                sal_object(1, i)=sum(tmp(:));
                tmp=sal(max(x2(1, i)-16, 1): min(x2(1, i)+16, 256), max(x2(2, i)-16, 1): min(x2(2, i)+16, 256), i);
                sal_object(2, i)=sum(tmp(:));
            end
            fprintf(1, '%e\t%e\n', sum(sal_object(1, :)), sum(sal_object(2, :)));
            fwrite(f1, sal_object', 'double');
        end
    end
end
fclose(f1);
f1=fopen('syn_visual_result.txt', 'r');
sal_object=fread(f1, [256 inf], 'double');
fclose(f1);
save('syn_visual_result', 'sal_info', 'sal_object');
