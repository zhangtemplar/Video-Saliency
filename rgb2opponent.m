% this function implements rgb2 opponent
function data=rgb2opponent(img)
    img=double(img);
    data=cat(3, (img(:, :, 1)-img(:, :, 2))/sqrt(2),...
        (img(:, :, 1)+img(:, :, 2)-2*img(:, :, 3))/sqrt(6),...
        (img(:, :, 1)+img(:, :, 2)+img(:, :, 3))/sqrt(3));
end
