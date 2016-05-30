% this function generate the synthetic data for video saliency following
% the protocol in paper
%       Visualizing Data with Motion
% Input
%   motion:         'flicker, direction, velocity' the motion type
%   resolution:     [174, 174] the resolution of the image
%   fps:            the frame rate in millisecond
%   parameter:      the extra parameter for the motion type in millisecond
%       velocity_fore:  the velocity of foreground
%       velocity_back:  the velocity of background
%       direction_fore: the direction of foreground
%       direction_back: the direction of background
%       flicker_fore:   the flicker rate of the foreground
%       flicker_back:   the flicker rate of the background
function [data target]=video_saliency_synthetic(motion, parameter, frames)
%% ------------------------------------------------------------------------
% parse the input
if nargin<3 || isempty(frames)
    frames=400;
end
if nargin<2 || isempty(parameter)
    parameter=[];
end
parameter=video_saliency_parameter(parameter);
motion=lower(motion);
%% ------------------------------------------------------------------------
% set up the data
% generate the centers
[x y]=meshgrid(15:29:174, 15:29:174);
% generate the on/off flag
target=randi([2 5], 1, 2);
% mask for the object
[p q]=meshgrid(-6:6, -2:2);
mask=[p(:), q(:)];
%% ------------------------------------------------------------------------
% generate the data
if strcmp(motion, 'flicker')
    data=video_saliency_flicker(cat(3, x, y), target, mask, frames, parameter);
else
    if strcmp(motion, 'direction')
        data=video_saliency_direction(cat(3, x, y), target, mask, frames, parameter);
    else
        data=video_saliency_velocity(cat(3, x, y), target, mask, frames, parameter);
    end
end
end
%% ========================================================================
% check the parameter
function parameter=video_saliency_parameter(parameter)
if ~isfield(parameter, 'flicker_fore') || isempty(parameter.flicker_fore)
    parameter.flicker_fore=10;
end
if ~isfield(parameter, 'flicker_back') || isempty(parameter.flicker_back)
    parameter.flicker_back=20;
end
if ~isfield(parameter, 'coherent') || isempty(parameter.coherent)
    parameter.coherent=true;
end
if ~isfield(parameter, 'velocity_fore') || isempty(parameter.velocity_fore)
    parameter.velocity_fore=2;
end
if ~isfield(parameter, 'velocity_back') || isempty(parameter.velocity_back)
    parameter.velocity_back=1;
end
if ~isfield(parameter, 'direction_fore') || isempty(parameter.direction_fore)
    parameter.direction_fore=pi/2;
end
if ~isfield(parameter, 'direction_back') || isempty(parameter.direction_back)
    parameter.direction_back=0;
end
end
%% ========================================================================
% flicker_fore and flicker_back are in the unit of fps
% Input:
%   velocity:   pixels per frame
function data=video_saliency_velocity(centers, target, mask, frames, parameter)
    data=zeros(174, 174, frames);
    flag=true(size(centers(:, :, 1)));
    for t=1: frames
        % background
        x=centers(:, :, 1)+round(t*parameter.velocity_back*cos(parameter.direction_back));
        y=centers(:, :, 2)+round(t*parameter.velocity_back*sin(parameter.direction_back));
        % foreground
        x(target(1), target(2))=centers(target(1), target(2), 1)+...
            round(t*parameter.velocity_fore*cos(parameter.direction_back));
        y(target(1), target(2))=centers(target(1), target(2), 2)+...
            round(t*parameter.velocity_fore*sin(parameter.direction_back));
        % draw it
        data(:, :, t)=video_saliency_draw(x, y, flag, mask);
    end
end
%% ========================================================================
% flicker_fore and flicker_back are in the unit of fps
% Input:
%   velocity:   pixels per frame
function data=video_saliency_direction(centers, target, mask, frames, parameter)
    data=zeros(174, 174, frames);
    flag=true(size(centers(:, :, 1)));
    for t=1: frames
        % background
        x=centers(:, :, 1)+round(t*parameter.velocity_back*cos(parameter.direction_back));
        y=centers(:, :, 2)+round(t*parameter.velocity_back*sin(parameter.direction_back));
        % foreground
        x(target(1), target(2))=centers(target(1), target(2), 1)+...
            round(t*parameter.velocity_back*cos(parameter.direction_fore));
        y(target(1), target(2))=centers(target(1), target(2), 2)+...
            round(t*parameter.velocity_back*sin(parameter.direction_fore));
        % draw it
        data(:, :, t)=video_saliency_draw(x, y, flag, mask);
    end
end
%% ========================================================================
% flicker_fore and flicker_back are in the unit of fps
function data=video_saliency_flicker(centers, target, mask, frames, parameter)
    data=zeros(174, 174, frames);
    if parameter.coherent==false
        offset=rand(size(centers(:, :, 1)))*parameter.flicker_back;
    else
        offset=rand(1)*parameter.flicker_back+zeros(size(centers(:, :, 1)));
    end
    for t=1: frames
        tt=t+offset;
        % for backeground
        flag=tt-floor(tt/parameter.flicker_back)*parameter.flicker_back<parameter.flicker_back/2;
        % for foreground
        flag(target(1), target(2))=tt(target(1), target(2))-...
            floor(tt(target(1), target(2))/parameter.flicker_fore)*parameter.flicker_fore<parameter.flicker_fore/2;
        % draw it
        data(:, :, t)=video_saliency_draw(centers(:, :, 1), centers(:, :, 2), flag, mask);
    end
end
%% ========================================================================
% the real draw function
function img=video_saliency_draw(x, y, flag, mask)
    img=zeros(174, 174);
    for i=1: size(flag, 1)
        for j=1: size(flag, 2)
            if flag(i, j)
                % wrap the pattern if necessary
                yy=mod((x(i, j)+mask(:, 1)), 29)+(i-1)*29+1;
                xx=mod((y(i, j)+mask(:, 2)), 29)+(j-1)*29+1;
                img(sub2ind([174 174], yy, xx))=1;
            end
        end
    end
end
