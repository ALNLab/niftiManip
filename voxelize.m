function [voxelROI_matlabSpaceS, voxelROI_niftiSpaceS, voxelROI_empty_matlabSpaceS, voxelROI_empty_niftiSpaceS, voxelROI_matlabSpaceI, emptyVoxels_matlabSpaceI, voxelData] = voxelize(inFile,nonzero)
% This function will extract all of the voxels out of a provided nifti image as well as their associated intensity values. 
%
% The function will output as a seperate vector, the data for each voxel (i.e. voxelData), and coordinates for nonzero values
% (voxelROI_matlabSpaceS, voxelROI_niftiSpaceS, voxelROI_matlabSpaceI) and zero values (voxelROI_matlabSpaceS, 
% voxelROI_empty_matlabSpaceS, voxelROI_matlabSpaceI, emptyVoxels_matlabSpaceI). These coordinates are further divided in output
% vectors that assign matlab space based indices to voxles (voxelROI_matlabSpace, voxelROI_empty_matlabSpaceS, voxelROI_matlabSpaceI, 
% emptyVoxels_matlabSpaceI; i.e. where voxels indexing starts at 1) and nifti space indices (voxelROI_niftiSpaceS, voxelROI_empty_niftiSpaceS; 
% i.e. where indexing starts at zero). Further, voxel identities for nifti space are provided as linear indices rather than subscripts
% (i.e. where there is one index for each coordinate rather than x,y,z; in voxelROI_matlabSpaceI and emptyVoxels_matlabSpaceI)
%
% Inputs:
% inFile : the path to the file you want to extract coordinates/data from. 
% nonZero : if set to 'false', nonzero voxel identities will not be extracted (i.e. voxelROI_empty_matlabSpaceS, voxelROI_empty_niftiSpaceS, emptyVoxels_matlabSpaceI will all be empty)
%
% This script assumes that you have "Tools for NIfTI and ANALYZE image" toolbox installed in matlab. 
%
% Alex Teghipco (ateghipc@uci.edu)
%
and output both voxels in 'system space' as well as 'mm space'. These two different vectors of voxels will 

if ischar(inFile) == 1
    inFileNifti = load_untouch_nii(inFile); %assumes file in 2mm space
    inFileMat = inFileNifti.img;
    dim = size(inFileMat);
    if size(dim,2) == 4
        warning('Your file has multiple brain maps...extracting only the first')
        inFileMat = inFileMat(:,:,:,1);
    end    
else
    inFileMat = inFile;
    %deal with linear indices here
end

switch nonzero
    case 'true'
        voxelROI_matlabSpaceI = find(inFileMat);
        emptyVoxels_matlabSpaceI = find(inFileMat==0);
        
        [voxelROI_matlabSpaceS(:,1),voxelROI_matlabSpaceS(:,2),voxelROI_matlabSpaceS(:,3)] = ind2sub(size(inFileMat),voxelROI_matlabSpaceI);
        [voxelROI_empty_matlabSpaceS(:,1),voxelROI_empty_matlabSpaceS(:,2),voxelROI_empty_matlabSpaceS(:,3)] = ind2sub(size(inFileMat),voxelROI_matlabSpaceI);
        voxelROI_niftiSpaceS = voxelROI_matlabSpaceS - 1;
        voxelROI_empty_niftiSpaceS = voxelROI_empty_matlabSpaceS - 1;
        voxelData = inFileMat(voxelROI_matlabSpaceI);
    case 'false'
        voxelROI_matlabSpaceI = 1:prod(size(inFileMat));
        emptyVoxels_matlabSpaceI = find(inFileMat == 0);
        
        [voxelROI_matlabSpaceS(:,1),voxelROI_matlabSpaceS(:,2),voxelROI_matlabSpaceS(:,3)] = ind2sub(size(inFileMat),voxelROI_matlabSpaceI);
        [voxelROI_empty_matlabSpaceS(:,1),voxelROI_empty_matlabSpaceS(:,2),voxelROI_empty_matlabSpaceS(:,3)] = ind2sub(size(inFileMat),voxelROI_matlabSpaceI);
        voxelROI_niftiSpaceS = voxelROI_matlabSpaceS - 1;
        voxelROI_empty_niftiSpaceS = voxelROI_empty_matlabSpaceS - 1;
        voxelData = inFileMat(voxelROI_matlabSpaceI);
end
