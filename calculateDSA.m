function r = calculateDSA(img, frameRate, endPhaseTimes)
%CALCULATEDSA calculates moving frame subtraction.
% DSA = CALCULATEDSA(IMG, FRAMERATE, ENDPHASETIMES)
% Calculates the subtraction sequence DSA, from the input IMG which was
% acuqired at a fixed pulse rate specified by FRAMERATE. ENDPHASETIMES are
% cardiac phase markers idntifying the same point in the cardiac cycle for
% each cardiac cycle in IMG.
%
% This software is Copyright of the University of Leeds, 2020.
% Released under the Creative Commons Non-Commercial Share-Alike license:
% CC BY-NC-SA. See https://creativecommons.org/licenses/by-nc-sa/4.0/
%

nFrames = size(img,3);
t = (0:(nFrames-1))./frameRate;

% turn t values into relative parts of the cardiac cycle
tr = zeros(size(t));

%ignore incomplete HBs
tr(t < endPhaseTimes(1)) = NaN;
tr(t > endPhaseTimes(end)) = NaN;

for h=1:(numel(endPhaseTimes)-1)
    
    % identify frames in this beat
    inThisBeat = t >= endPhaseTimes(h) & t < endPhaseTimes(h+1);
    
    % calculate heart beat duration
    dt = endPhaseTimes(h+1) - endPhaseTimes(h);
    
    % tr is not calculated (t - tstart) / dt 
    tr(inThisBeat) = (t(inThisBeat) - endPhaseTimes(h)) ./ dt;
    
end

% relative times of the mask images
masks = tr(t >= endPhaseTimes(1) & t < endPhaseTimes(2));
% and contrast images
contrasts = tr(t >= endPhaseTimes(2) & t < endPhaseTimes(end));

% number of contrast images
nContrasts = numel(contrasts);

% find the offset in frames to the first contrast image
startContrastFrame = find(t == endPhaseTimes(2));

% ditto for the first mask
firstMaskFrame = find(t == endPhaseTimes(1));

% pre-allocate results array
r = zeros(size(img,1), size(img,2), nContrasts);

% calculate DSA
for n=1:nContrasts
    
    % Select the current contrast frame
   contrastFrame = double(img(:,:,n+startContrastFrame-1));
   % and get its relative time in the heart beat
   contrastTime = contrasts(n);
   
   % find the closest matching mask image
   [~, idx] = min(abs(masks - contrastTime));
   
   % perform subtraction
   r(:,:,n) = contrastFrame - double(img(:,:,idx + firstMaskFrame-1));
   
   %fprintf("Output %d- contrast %d, mask %d\n", n, n+startContrastFrame-1, idx + firstMaskFrame-1);
end
