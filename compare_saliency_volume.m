function [tp fp gp gn]=compare_saliency_volume(sal, mask, threshold)
    if nargin<3 || isempty(threshold)
        threshold=0:0.1:1;
    end
    % apply the center bias
%     [x y]=meshgrid(1: size(sal, 2), 1: size(sal, 1));
%     center_bias=1-sqrt((x/size(sal, 2)-1/2).^2+(y/size(sal, 1)-1/2).^2)*sqrt(2);
%     for t=1: size(sal, 3)
%         sal(:, :, t)=sal(:, :, t).*center_bias;
%     end
    threshold=threshold*4*mean(sal(:));
    fp=zeros(size(threshold));
    tp=zeros(size(threshold));
    gp=zeros(size(threshold));
    gn=zeros(size(threshold));
    for i=1: length(threshold)
        sal_mask=sal>threshold(i);
        for t=1: length(mask)
            fp(i)=fp(i)+sum(sum(sal_mask(:, :, t).*(~mask{t})));
            tp(i)=tp(i)+sum(sum(sal_mask(:, :, t).*(mask{t})));
            gp(i)=gp(i)+sum(sum(mask{t}));
            gn(i)=gn(i)+sum(sum(~mask{t}));
        end
    end
end
