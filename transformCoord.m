function [outPoints] = transformCoord(inPoints,inFile,destFile,trsfMat,FSLDIR,spaceType,warpType)
%This script takes a bunch of x y z coordinates you give it, and applies a
%transformation matrix to bring it to a new space using FSL's img2img.

%%inPoints = [x y z; x y z] vector of any size
%%inFile = 'String to the space you are transforming from'
%%destFile = 'String to the space you are transforming to'
%%trsfMat = 'String to the transformation matrix OR warp field'
%%spaceType = 'voxel' (keep it at this)
%%warpType = 'either warp or xfm' 
%%FSLDIR = 'your directory here' OR FSLDIR = [] and it will find directory
%%where fsl lives.

%Alex Teghipco
%ateghipc@u.rochester.edu
%April 2016

%% find fsl
if isempty(FSLDIR) == 1
    FSLDIR = findFSL;
end
IMG2IMG=[FSLDIR '/bin/img2imgcoord'];
setenv('FSLOUTPUTTYPE','NIFTI_GZ');
%% set output/input type
if strfind(spaceType,'voxel') > 0
    spaceArgument = ['-vox'];
else
    spaceArgument = ['-mm'];
end
%% find standard space
if inFile == 2
    inFile = [FSLDIR '/data/standard/MNI152_T1_2mm_brain.nii.gz'];
end
if inFile == 1
    inFile = [FSLDIR '/data/standard/MNI152_T1_1mm_brain.nii.gz'];
end
if destFile == 2
    destFile = [FSLDIR '/data/standard/MNI152_T1_2mm_brain.nii.gz'];
end
if destFile == 1
    destFile = [FSLDIR '/data/standard/MNI152_T1_1mm_brain.nii.gz'];
end
%% start main loop

outPoints= zeros(size(inPoints));
for i = 1:size(inPoints,1);
    x = inPoints(i,1);
    y = inPoints(i,2);
    z = inPoints(i,3);
    if strfind(warpType,'xfm')
        convert = ['echo ' num2str(x) ' ' num2str(y) ' ' num2str(z) ' | ' IMG2IMG ' -src ' inFile ' -dest ' destFile ' -xfm ' trsfMat ' ' spaceArgument];
        [ignore , outcord] = system(convert);
    else
        convert = ['echo ' num2str(x) ' ' num2str(y) ' ' num2str(z) ' | ' IMG2IMG ' -src ' inFile ' -dest ' destFile ' -warp ' trsfMat ' ' spaceArgument];
        [ignore , outcord] = system(convert);
    end
    
    %digitOut = outcord(isstrprop(outcord,'digit'));
    
    if strfind(spaceType,'voxel') > 0
        outPoints(i,:) = str2num(outcord(47:end));
    end
    
end
     
     
     
     
     