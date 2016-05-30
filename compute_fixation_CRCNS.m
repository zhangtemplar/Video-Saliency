function [sal mask video_info]=compute_fixation_CRCNS(mask_list, video_name)
    factor=4;
    video=mmreader(video_name);
    video_info=struct('Height', video.Height, 'Width',...
        video.Width, 'NumberOfFrames', video.NumberOfFrames,...
        'FrameRate', video.FrameRate);
%     clear video;
    temporal_factor=240/video_info.FrameRate;
    data=zeros(video_info.Height, video_info.Width, video_info.NumberOfFrames, 'uint8');
    %% ====================================================================
    for i=1: length(mask_list)
        % the feature are
        % [frame] [left_x] [left_y] [left_dilation] [left_event]...
        % [right_x] [right_y] [right_dil] [right_event]
        % for event
        % -1 = Error/dropped frame
        % 0 = Blink
        % 1 = Fixation [recommended]
        % 2 = Saccade
        A=read_fixation(mask_list{i});
        for t=1: size(A, 1)
            x=floor(A(t, 1))+1;
            y=floor(A(t, 2))+1;
            % add this information to the data
            if x>=1 && y>=1 && x<=video_info.Width && y<=video_info.Height && A(t, 4)~=5 && t/temporal_factor<=size(data, 3)
                data(y, x, ceil(t/temporal_factor))=data(y, x, ceil(t/temporal_factor))+1;
            end
        end
    end
    clear A;
    %% ====================================================================
    % convert to a sparse matrix
    sal=cell(1, size(data, 3));
    sal_sum=0;
    for t=1: size(data, 3)
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
    [y x k]=find(img);
    fixation=[y x];
%     fixation=zeros(sum(img(:)), 2);
%     offset=1;
%     for t=1: length(k)
%         fixation(offset: offset+k(t)-1, 1)=y(t);
%         fixation(offset: offset+k(t)-1, 2)=x(t);
%         offset=offset+k(t);
%     end
end

function [A freq dump]=read_fixation(file_name)
    A=dlmread(file_name, ' ', 3, 0);
    f1=fopen(file_name);
    str=fgetl(f1);
    freq=sscanf(str, 'period = %dHZ');
    str=fgetl(f1);
    str=fgetl(f1);
    dump=sscanf(str, 'trash = %d');
    A=A(dump+1: end, :);
    % process saccade
    flag=false;
    for i=1: size(A, 1)
        if A(i, 4)==1 || A(i, 4)==3
            if flag==false
                prev=i;
                flag=true;
            end
        else
            if flag==true
                A(prev: i-1, 1: 2)=repmat(A(prev, 5: 6), i-prev, 1);
                flag=false;
            end
        end
    end
    % process the last
    if flag==true
        A(prev: i-1, 1: 2)=repmat(A(prev, 5: 6), i-prev, 1);
        flag=false;
    end
    fclose(f1);
end
