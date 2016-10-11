function [imShift, predShift] = alignChannels(im, maxShift)
% ALIGNCHANNELS align channels in an image.
%   [IMSHIFT, PREDSHIFT] = ALIGNCHANNELS(IM, MAXSHIFT) aligns the channels in an
%   NxMx3 image IM. The first channel is fixed and the remaining channels
%   are aligned to it within the maximum displacement range of MAXSHIFT (in
%   both directions). The code returns the aligned image IMSHIFT after
%   performing this alignment. The optimal shifts are returned as in
%   PREDSHIFT a 2x2 array. PREDSHIFT(1,:) is the shifts  in I (the first)
%   and J (the second) dimension of the second channel, and PREDSHIFT(2,:)
%   are the same for the third channel.
%



% Sanity check
assert(size(im,3) == 3);
assert(all(maxShift > 0));
predShift = zeros(2, 2);
padding = floor([.2*size(im, 2), .2*size(im, 1), .6*size(im, 2), .6*size(im, 1)]);
img_c = imcrop(im, padding);
%% Align the Red and Blue images to the Green channel
predShift (1,:) = imageAlign(img_c(:,:,1),img_c(:,:,2),15);
predShift (2,:) = imageAlign(img_c(:,:,3),img_c(:,:,2),15);
newR = circshift(im(:,:,1), floor(predShift (1,:)));
newB = circshift(im(:,:,3), floor(predShift (2,:)));
%% recombine
imShift = cat(3, newR, im(:,:,2), newB);
imShift = imageCrop(imShift);

function offset = imageAlign(image, reference, movement)
% Align image to reference, from -movement to movement in both x and y
bestShift = inf;
for yShift = -movement:movement
    for xShift = -movement:movement
        % Shifting the image
        tmp = circshift(image, [xShift yShift]);
        %match = sum(sum(tmp.*tmp));
        match = sum(sum((tmp-reference).^2));
        if match < bestShift
            bestShift = match;
            offset = [xShift yShift];
        end
    end
end

function output  = imageCrop(img)
% Crop unwanted borders from image img

height = size(img,1);
width = size(img,2);
level = size(img,3);
c_img = img(1:floor(height/10), 1:floor(width/10), :);

vertical = 0;
horizontal = 0;

for i = 1:level
    % Find edges
    tempE= edge(c_img(:,:,i), 'canny', 0.1);
    
    % Find mean value and mask the values.
    TempVerticalAvg = mean(tempE, 1);
    TempHorizontalAvG = mean(tempE, 2);
    threshold = 3*mean(TempHorizontalAvG);
    TempVerticalMask = TempVerticalAvg > threshold;
    TempHorizontalMask = TempHorizontalAvG > threshold;
    
    % Find last values
    Tvertical = find(TempVerticalMask, 1, 'last');
    Thorizontal = find(TempHorizontalMask, 1, 'last');
    
    if Tvertical > vertical
        vertical = Tvertical;
    end
    if Thorizontal > horizontal
        horizontal = Thorizontal;
    end
end

output = imcrop(img, [horizontal vertical (width-2*horizontal) (height-2*vertical)]);