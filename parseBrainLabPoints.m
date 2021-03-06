function parseBrainLabPoints(pointsFile, xbrainFolder, flipDimension, softwareSwitch) 
%% --------------------------------------------------------
%This script will extract timestamps from the .xbrain file and check them
%against the number of stimulation points in your .log file as generated by
%Brain Lab's software (run this first). If convention is not standard, the
%script can flip your coordinates along some dimension for you. If you are
%importing coordinates into BrainVoyager, it will apply a transformation to
%go from DICOM space to BV SYS space, apply a SAG transformation, and apply
%an iso-voxel transformation to your coordinates.

%Important assumption:
%   isovoxel will stretch the x dimension (i.e. y and z are both at 256).
%   Check the structure of your NIFT and/or vmr file using neuroelf or 
%   niftiManipulate if output coordinates don't look to be within the 
%   surgical corridor.  


%% --------------------------------------------------------
%Input Arguments
%pointsFile --> path to .log containing your stimulation number and dicom
%coordinates as extracted using XBrainToPoints.

%xbrainFolder --> path to directory which contains your xbrain file. Make
%sure there is only one file (reason being eventually script will process 
%all xbrain files within a given folder).

%flipDimension --> if you would like to flip one of the dimensions of the
%brain lab dicom coordinates this should be set to that dimenstion (i.e. x,
%y, or z). To be used in case brainlab data is not in radiological
%convention. Now supports multi-argument...you can flip xy, xz, xyz, etc.

%softwareSwitch --> this is either BV or FSL. If FSL we stop at flipping
%coordinates. If BV script will continue to convert dicom coordinates to BV
%space, and SAG transform, and isovoxel transform.

%% --------------------------------------------------------
%output files are in xbrain folder: 
%pointsFile.txt --> log converted into text format
%Timestamps.txt --> text file containing stimulation number and timestamp
%pointsFile_Timestamps.txt --> text file containing stimulation number,
%dicom coordinates, and timestamps.
%pointsFile_Points_Timestamps_Flipped_XDim.txt --> text file containing
%stimulation number, dicom coordinates, timestamps. The dicom coordinates
%are flipped among some dimension. This only applies if flippedDimension is
%not empty.
%pointsFile_Points_BV_ISO_TAL.txt --> text file containing stimulation
%number, dicom coordinates, timestamps. DICOM coordinates are converted
%into BV space, SAG and iso-voxel transformed. This only applies if
%softwareSwitch is BV.

%%
%example call: parseBrainLabPoints('/Volumes/LaCie/NEWESTDTI/DTI/toolboxScripts/intraopScripts/example/Points_Classic_1.log', '/Volumes/LaCie/NEWESTDTI/DTI/toolboxScripts/intraopScripts/example', 'x', 'BV') 

% --------------------------------------------------------
% Alex Teghipco -- ateghipc@u.rochester.edu -- 2015 version 2
% --------------------------------------------------------

%Ensure that all necessary scripts are loaded
Params.toolboxDir = which('dtiToolbox');
[Params.toolboxPath,toolboxName,toolboxExt] = fileparts(Params.toolboxDir);
addpath(genpath(Params.toolboxPath));

%convert to text file
copyfile(pointsFile,[pointsFile(1:end-4) '.txt']);
dir = [pointsFile(1:end-3) 'txt'];

%read in text
fileID = fopen(dir,'r');
formatSpec='%s';
text = textscan(fileID,formatSpec);
textSize = size(text{1,1},1);
outNums=zeros(textSize,1);

%convert to numbers, remove imaginary numbers
for i = 1:textSize;
    val=str2num(text{1,1}{i,1}(1:end-1));
    if isempty(val) == 1;
        val=0;
    end
    outNums(i,1)=val;
end
outNums(imag(outNums)<2) = real(outNums(imag(outNums)<2));
outNums = outNums(outNums~=0);

%reorganize matrix...
stimNumber=outNums(1:4:length(outNums));
stimNumber(1)=0;
x=outNums(2:4:length(outNums));
y=outNums(3:4:length(outNums));
z=outNums(4:4:length(outNums));
points = horzcat(stimNumber,x,y,z);
points = sortrows(points,1);

%call my bash script and extract timestamps...
extractTimestamps=['echo ' xbrainFolder ' | bash ' pwd '/TimestampExtract.sh'];
system(extractTimestamps);

%fix the semicolon within number vector "problem"
timestamps=dlmread([xbrainFolder '/Timestamps.txt' ]);
for j = 1:size(timestamps,1);
   timestampsFixed(j,1) = str2num(strcat(num2str(timestamps(j,1)),num2str(timestamps(j,2)),num2str(timestamps(j,3))));
   timestampsFixed(j,2) = timestamps(j,4);
end
timestampsFixed = unique(timestampsFixed,'rows');
timestampsFixed = sortrows(timestampsFixed,2);

try
    tf = isequal(timestampsFixed(:,2),points(:,1));
catch ME
    if tf == 1;
        msg = ['The number of stimulations in xbrain file vs timestamps does not match'];
        causeException = MException('MATLAB:myCode:dimensions',msg);
        ME = addCause(ME,causeException);
    end
    rethrow(ME);
end

points = horzcat(points,timestampsFixed(:,1));
    
%save...
dlmwrite([pointsFile(1:end-4) '_Points_Timestamps.txt'],points,' ');

%lets see if you want to flip any dimensions
if isempty(flipDimension) == 0
    if isempty(strfind(flipDimension,'x')) == 0
        points(:,2) = -1*(points(:,2));
    end
    
    if isempty(strfind(flipDimension,'y')) == 0
        points(:,3) = -1*(points(:,3));
    end
    
    if isempty(strfind(flipDimension,'z')) == 0
        points(:,4) = -1*(points(:,4));
    end
    dlmwrite([pointsFile(1:end-4) '_Points_Timestamps_Flipped' flipDimension 'Dim.txt'],points,' ');
end

%now convert to BV Space
if strcmp(softwareSwitch,'BV') == 1
    dicomCoords = points(:,2:4);
    stims = points(:,1);
    time = points(:,5);
    %bvPoints = convertBL2BV(dicomCoords);
    bvPoints = dicomCoords;
    
%now SAG transform...
    %outBVpoints = bvPoints;
    bvPoints(:,1) = 179 - bvPoints(:,1);

%now ISO transform...
    offset = 0.5 .* ( ...
    [180 * 1] - 256);
    bvPoints(:,1) = bvPoints(:,1) - offset;
    bvPoints = horzcat(stims,bvPoints,time);
    dlmwrite([pointsFile(1:end-4) '_Points_BV_ISO_TAL.txt'],bvPoints,' ');
end

