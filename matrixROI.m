function [presentVoxels_niftiSpace, presentVoxels_mmSpace, percentMissing, roiBrain, roiMatrix, roiMatrixBrain, templateFile] = matrixROI(inFile,inCoords,matrixFolder)
%% STEP 1: Find voxels with existing maps
for i = 1:size(inCoords,1)
    inCoords(i,4) = ~isempty(dir(['/Users/ateghipc/Desktop/spt/originalFC/native_2.3mm/*' num2str(inCoords(i,1)) '_' num2str(inCoords(i,2)) '_' num2str(inCoords(i,3)) '.nii']));
end

%% Step 2: Write out the ROI w/excluding missing voxels
percentMissing = size(find(inCoords(:,4) == 0),1)/size(inCoords,1)*100;
disp([num2str(percentMissing) '% of your ROI voxels are missing associated maps']);
presentVoxels_mmSpace = inCoords(find(inCoords(:,4) == 1),1:3);
presentVoxels_niftiSpace = convertVoxel2MM(inFile,presentVoxels_mmSpace);
writeROI(presentVoxels_niftiSpace,ones(size(presentVoxels_niftiSpace,1),1),[inFile(1:end-4) '_presentInMatrix'],[],'true',[],[],[],[])

%% STEP 3: Lets import all of these files into one matrix
parfor i = 1:size(presentVoxels_mmSpace,1)
    tmpFile = dir([matrixFolder '/*_' num2str(presentVoxels_mmSpace(i,1)) '_' num2str(presentVoxels_mmSpace(i,2)) '_' num2str(presentVoxels_mmSpace(i,3)) '.nii']);
    tmpFileNii = load_untouch_nii([matrixFolder '/' tmpFile.name])
    dims = size(tmpFileNii.img)
    if size(dims,2) > 3
        tmpFileMat = reshape(tmpFileNii.img,[prod(dims(1:3)),prod(dims(4:end))]);
        tmpFileMat(:,2:end) = [];
    else
        tmpFileMat = reshape(tmpFileNii.img,[prod(size(tmpFileNii.img)),1]);
    end
    roiMatrix(i,:) = tmpFileMat;
end

roiBrainTF = all(roiMatrix,1)';
roiBrain = find(roiBrainTF == 1);
roiMatrixBrain = roiMatrix(:,roiBrain);
templateScratch = dir([matrixFolder '/*_' num2str(presentVoxels_mmSpace(1,1)) '_' num2str(presentVoxels_mmSpace(1,2)) '_' num2str(presentVoxels_mmSpace(1,3)) '.nii']);
templateFile = load_untouch_nii([matrixFolder '/' templateScratch.name]);