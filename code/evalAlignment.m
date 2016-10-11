
% Path to your data directory
dataDir = fullfile('..','data','demosaic');

% List of images
imageNames = {'balloon.jpeg','cat.jpg',	'ip.jpg', ... 
              'puppy.jpg','squirrel.jpg', 'pencils.jpg',...
              'house.png', 'light.png', 'sails.png', 'tree.jpeg'};
numImages = length(imageNames);
          
% Global variables
maxShift = [15 15]; % the shifts are checked within this range
display = true;     % if set to true then aligned images are shown

% Loop over methods and print results
fprintf('Evaluating alignment ..\n');
for i = 1:numImages,
    % Read image
    thisImage = fullfile(dataDir, imageNames{i});
    im = imread(thisImage);
    im = im2double(im);
    
    % Randomly shift channels
    [channels, gtShift]  = randomlyShiftChannels(im, maxShift);
    
    % Compute alignment
    [colorIm, predShift] = alignChannels(channels, maxShift);
    
    % Print results
    fprintf('%2i %s\n\t   gt shift: (%2i,%2i) (%2i,%2i)\n\t pred shift: (%2i,%2i) (%2i,%2i)\n',...
            i, imageNames{i}, gtShift(1,:), gtShift(2,:), predShift(1,:), predShift(2,:));

    % Optionally display the results
    if display
        % We will use subplot which is a way to show multiple plots/images
        % in a single figure.
        figure(1); clf;
        subplot(1,2,1); imagesc(channels); axis image off;
        title('Input image');
        
        subplot(1,2,2); imagesc(colorIm); axis image off;
        title('Aligned image');
        pause(1); %Pause for 1 second after display
    end
end