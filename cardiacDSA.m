function dsa = cardiacDSA(img, frameRate)
if nargin < 2
    frameRate  = 15; % default is 15 frames per second
end
endPhaseTimes = detectCardiacPhase(img, frameRate);
dsa = calculateDSA(img, framerate, endPhaseTimes);
