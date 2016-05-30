function data=video_saliency_flicker(flicker_fore, flicker_back)
    if nargin<1 || isempty(flicker_fore)
        flicker_fore=.12;
    end
    if nargin<2 || isempty(flicker_back)
        flicker_back=.12;
    end
    data=zeros(174, 174);
    [x y]=meshgrid(17:29:174, 17:29:174);
end

function draw
