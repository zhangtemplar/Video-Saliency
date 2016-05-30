function [sal mask video_info]=compute_fixation_diem(mask_list, video_name)
    factor=4;
    video=mmreader(video_name);
    video_info=struct('Height', video.Height, 'Width',...
        video.Width, 'NumberOfFrames', video.NumberOfFrames,...
        'FrameRate', video.FrameRate);
    clear video;
    data=zeros(video_info.Height, video_info.Width, video_info.NumberOfFrames, 'uint8');
    h=waitbar(0, 'read in the eye fixation data');
    screen_size=[960 1280];
    offset=-screen_size(1)/2+video_info.Height/2;
    %% ====================================================================
    for i=1: length(mask_list)
        waitbar(i/length(mask_list), h, mask_list(i).name);
        % the feature are
        % [frame] [left_x] [left_y] [left_dilation] [left_event]...
        % [right_x] [right_y] [right_dil] [right_event]
        % for event
        % -1 = Error/dropped frame
        % 0 = Blink
        % 1 = Fixation [recommended]
        % 2 = Saccade
        A=importdata(mask_list(i).name);
        for t=1: size(A, 1)
            % note that, the frame rate of eye fixation could be different
            % from the video
            x=-1;
            y=-1;
            % left eye is good
            if A(t, 5)==1 && A(t, 9)==1
                x=(A(t, 2)+A(t, 6))/2;
                y=(A(t, 3)+A(t, 7))/2;
            else if A(t, 5)==1
                    x=A(t, 2);
                    y=A(t, 3);
            % right eye is ok
                else if A(t, 9)==1
                        x=A(t, 6);
                        y=A(t, 7);
                    end
                end
            end
            x=round(x);
            y=round(y);
            y=y+offset;
            % add this information to the data
            if x>=1 && y>=1 && x<=video_info.Width && y<=video_info.Height
                data(y, x, t)=data(y, x, t)+1;
            end
        end
    end
    clear A;
    % convert to a sparse matrix
    sal=cell(1, size(data, 3));
    sal_sum=0;
    for t=1: size(data, 3)
        waitbar(t/size(data, 3), h, num2str(t, '%04d'));
        fixation=extract_fixation(data(:, :, t));
        if size(fixation, 1)<1
            sal{t}=sparse(floor((video_info.Height-1)/factor)+1,...
                floor((video_info.Width-1)/factor)+1);
            continue;
        end
        sal{t}=ksdensity2d(fixation, 1: factor: video_info.Height, 1: factor: video_info.Width);
        sal{t}(sal{t}<=eps)=0;
        sal{t}=sparse(sal{t});
        sal_sum=sal_sum+sum(sal{t}(:));
    end
    close(h);
    clear data;
    %% ====================================================================
    % convert to a mask
    sal_sum=sal_sum/length(sal)/numel(sal{1});
    mask=cell(1, length(sal));
    for t=1: length(sal)
        mask{t}=sal{t}>=sal_sum;
    end
end

function fixation=extract_fixation(img)
    fixation=zeros(sum(img(:)), 2);
    [y x k]=find(img);
    offset=1;
    for t=1: length(k)
        fixation(offset: offset+k(t)-1, 1)=y(t);
        fixation(offset: offset+k(t)-1, 2)=x(t);
        offset=offset+k(t);
    end
end
