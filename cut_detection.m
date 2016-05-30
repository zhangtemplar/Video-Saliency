function loc=cut_detection(cut, threshold, interval)
    if nargin<4 || isempty(threshold)
        % this value is determined from 50_people_brooklyn_1280x720.mp4
        threshold=0.37;
    end
    if nargin<5 || isempty(interval)
        interval=10;
    end
    % we define the cut the
    cut=2*cut(2: end-1)-cut(1: end-2)-cut(3: end);
    loc=find(cut>threshold);
    % we need to remove the ones which are too close
    loc_flag=true(size(loc));
    for i=2: length(loc);
        if loc(i)-loc(i-1)<interval
            if cut(loc(i))>cut(loc(i-1))
                loc_flag(i-1)=false;
            else
                loc_flag(i)=false;
            end
        end
    end
    loc=loc(loc_flag);
end
