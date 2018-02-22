function generateStatmap(cords,outFolder,fileName,mmResolution,FSLDIR,intensityMat)
%takes TAL cords, converts them to MNI space mm, then MNI space voxels (for
%appropriate resolution), then draws these points on an MNI 'skeleton'
%file. This file is binarized. You can preserve intensity values as well.

%cords is matrix of TAL coordinates. 
%outFolder is output folder for file. Can be directory that exists, or
%script will create one.
%fileName is some name for the output file.
%resolution is either 1 or 2; output file resolution.
%FSLDIR: if you leave this variable blank (i.e. []) it will search for your
%fsl directory and set it for you. Alterantively put your own path here.
%Saves maybe two minute of processing time. If you have trouble wth findFSL
%set this variable manually to your fsl root directoy.
%intesityMat is a vector of intensity values where rows correspond to voxel
%identities of rows in cords. If this is left blank then intensity values
%will not be preserved.


%need to find way to use replaceVoxelsTemplate instead for speed. Currently no way of knowing
%coordinate identity for each intensity value under the hood using spm. 


%Alex Teghipco
%ateghipc@u.rochester.edu
%h = waitbar(0,'Starting analysis...code monkeys hard at work'); 

if exist(outFolder,'dir') == 0
    mkdir(outFolder)
end

%%%%%%%%%%%%%% Set all FSL variables
h = waitbar(0.2,'Looking for your FSL path');
if isempty(FSLDIR) == 1
    FSLDIR = findFSL;
end
FSLMATHS=[FSLDIR '/bin/fslmaths'];
setenv('FSLOUTPUTTYPE','NIFTI_GZ');
%%%%%%%%%%%%%%
addpath([pwd '/Conversions']); % add conversion path


%first convert to TAL
if mmResolution == 2 %find standard space to use
    standardSpace = [FSLDIR '/data/standard/MNI152_T1_2mm_brain.nii.gz']; 
end
if mmResolution == 1
    standardSpace = [FSLDIR '/data/standard/MNI152_T1_1mm_brain.nii.gz'];
end
copyfile(standardSpace,[outFolder '/template.nii.gz']);
waitbar(0.5,h,'Making copies of template and zeroing...');
makeEmpty=[FSLMATHS ' ' outFolder '/template.nii.gz' ' -mul 0 ' outFolder '/templateEMPTY.nii.gz']; %make copy of standard space file empty
system(makeEmpty);
waitbar(0.8,h,'Converting coordinates to MNI...');
MNIcords = convertMM_TAL2MNI(cords); %convert TAL to MNI
waitbar(0.9,h,'Converting MNI to mm...');
MNIcordsmm = convertMM2Voxel_MNI(MNIcords,mmResolution,FSLDIR); %convert MNI to voxels 
MNIcordsmm = unique(MNIcordsmm,'rows'); %remove duplicate rows

%now draw ... one point at a time
waitbar(0,h,'Drawing voxels now...');
for i = 1:size(MNIcordsmm,1)
    waitbar((i / (size(MNIcordsmm,1))),h,'Drawing voxels...');
    if isempty(intensityMat) ~= 1
        intensityPoint=intensityMat(i);
    else
        intensityPoint=1;
    end
    drawPoint = [FSLMATHS ' ' outFolder '/templateEMPTY.nii.gz -add ' num2str(intensityPoint) ' -roi ' num2str(MNIcordsmm(i,1)) ' 1 ' num2str(MNIcordsmm(i,2)) ' 1 ' num2str(MNIcordsmm(i,3)) ' 1 0 1 ' outFolder '/templatePOINT.nii.gz -odt float'];
    system(drawPoint);
    addPoint = [FSLMATHS ' ' outFolder '/templateEMPTY.nii.gz -add ' outFolder '/templatePOINT.nii.gz ' outFolder '/templateEMPTY.nii.gz'];
    system(addPoint);
end

if isempty(intensityMat) == 1
    binarizeImage=[FSLMATHS ' ' outFolder '/templateEMPTY.nii.gz -bin ' outFolder '/templateEMPTY.nii.gz'];
    system(binarizeImage);
end

waitbar(1,h,'Cleanup...');
copyfile([outFolder '/templateEMPTY.nii.gz'],[outFolder '/' fileName '.nii.gz']);
delete([outFolder '/templateEMPTY.nii.gz']);
delete([outFolder '/templatePOINT.nii.gz']);
delete([outFolder '/template.nii.gz']);
close(h)