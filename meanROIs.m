function [meanVals, stdVals] = meanROIs(inFiles,rois,parallelArg)
%This script will get the mean values within a ROI from some brain map. 
%The output meanVals will be a matrix that is files x rois in size. 
%roiVoxels is an array that will contain the voxels in each ROI map. 
%The organization of your input files does not matter (i.e. if you have 10 
%files your cell array can be 1x10 or 10x1). If you are analyzing 1 file w/
%either respect to inFiles or rois, then a char variable instead of a cell 
%variable will also work. If you have 2 input brain maps and 2 rois,
%note that rows in the output vector will correspond to files and columns 
%will correspond to roi pairs. 

%% Vars
% inFiles -- are the maps from which ROI voxels will be extracted. 
% ROIs -- are the maps containing your ROIs. These can be binarized or not.
% Values not equal to zero from these maps will be treated as voxels of
% interest. Inf and nan values will be ignored.
% parallelArg -- if 0 parfor will not be initiated. If set to 1, it will.

if iscell(inFiles) == 0
    inFiles = cellstr(inFiles);
end
    
if iscell(rois) == 0
    rois = cellstr(rois);
end    
    
fileNumMax = length(inFiles);
roiNumMax = length(rois);

switch parallelArg
    case 1
        parfor fileNum = 1:fileNumMax
            disp([num2str((fileNum/fileNumMax)*100) '% of files processed...'])
            for roiNum = 1:roiNumMax
                disp([num2str((roiNum/roiNumMax)*100) '% of rois processed for given file...'])
                [meanVals(fileNum,roiNum),stdVals(fileNum,roiNum)] = meanROI(inFiles{fileNum},rois{roiNum});
            end
        end
    case 0
        for fileNum = 1:fileNumMax
            for roiNum = 1:roiNumMax
                disp([num2str((fileNum/fileNumMax)*100) '% of files processed...'])
                [meanVals(fileNum,roiNum),stdVals(fileNum,roiNum)] = meanROI(inFiles{fileNum},rois{roiNum});
            end
        end
end

function [meanVal, stdVal, roiVoxels] = meanROI(inFile,roi)
%ROI doesn't have to be binarized but any value that isn't a zero will be
%included in definition of ROI

if iscell(inFile) == 1
    inFile = inFile{1};
end

if iscell(roi) == 1
    roi = roi{1};
end    

inFile = checkGZ(inFile,'yes');
roi = checkGZ(roi,'yes');

try
    inFileImg = load_untouch_nii(inFile); %load in file to extract values from
    ROIImg = load_untouch_nii(roi); %load in your ROI
catch
    disp('Extension is fine, but data could not be loaded...check your maps')
end

inFileMat = inFileImg.img;
ROIMat = ROIImg.img;

try
    roiVoxels = find(ROIMat ~= 0 & isfinite(ROIMat));
    meanVal = mean(inFileMat(roiVoxels));
    stdVal = std(inFileMat(roiVoxels));
catch
    disp('Could not get a mean...your ROI is probably empty...')
end
