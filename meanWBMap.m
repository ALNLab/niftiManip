function [inFileMatMean, outFile] = meanWBMap(inFile,inMat,inCoords,matCoords,template)
%This function will open inFile, match it to inCoords and create a mean WB
%map from all columns of inMat. inMat must have as many rows as inCoords.
%inFile must be the path to a nifti file. inCoords must be adjusted (i.e.
%in matlab nifti space). Template is a file for 

%get template from path if necessary
scriptPath = mfilename('fullpath');
if template == 2
    load([scriptPath(1:end-10) '/2mmTemplate.mat'])
elseif template == 1
    load([scriptPath(1:end-10) '/1mmTemplate.mat'])
elseif ischar(template) == 1
    template = load_untouch_nii(template);
elseif isempty(template) == 1
    template = load_untouch_nii(inFile);
end

%check to make sure variables are of the right size
if size(inCoords,1) ~= size(inMat,1)
    error('You do not have as many variables in your data as you have in your coordinates (i.e. rows)')
end

%get your params straight for file writting
%template = load_untouch_nii(inFile);
outFile = [inFile(1:end-4) '_meanWB.nii'];

%get voxels from inFile
[inFile_matlabSpaceS, ~, ~, ~, ~, ~, ~] = voxelize(inFile,'true');

%Find those voxels in inCoords
tf = ismember(inCoords,inFile_matlabSpaceS,'rows');
%inFileCoords = inCoords(find(tf == 1),:);

%extract the relevant part of the inMat matrix and get the mean.
inFileMatMean = mean(inMat(find(tf == 1),:),'omitnan');

%save out the means
niftiMat = zeros(size(template.img));
niftiMat(matCoords) = inFileMatMean;
template.img = double(niftiMat);
template.hdr.dime.datatype = 16;
template.hdr.dime.bitpix = 32;
template.untouch = 0;
save_nii(template,outFile)


%function [meanWB, outFile] = meanWBMap(inFolder,outFile)
% [pathstr,name,ext] = fileparts(inFolder);
% if isempty(ext) == 1
%     inDir = dir([inFolder '/*.nii']);
%     %templateFile = checkGZ(templateFile,'yes');
%     %templateNii = load_untouch_nii(templateFile);
%     
%     for i = 1:size(inDir,1)
%         disp(['Generating voxel matrix...' num2str((i/size(inDir,1)*100))])
%         inFile = load_untouch_nii([inFolder '/' inDir(i).name]);
%         tmpMat = inFile.img(:,:,:,1);
%         inMat(:,i) = reshape(tmpMat,[size(tmpMat,1)*size(tmpMat,2)*size(tmpMat,3)],1);
%     end
%     meanWB = mean(inMat,2);
%     meanWB(:,2) = zeros;
%     inFile.img = double(reshape(meanWB,[size(tmpMat,1),size(tmpMat,2),size(tmpMat,3),2]));
%     save_untouch_nii(inFile,outFile)
% else
%     disp('You gave me a file...I am assuming that you want to get the average for the file...')
%     inFile = load_untouch_nii(inFolder);
%     tmpMat = inFile.img(:,:,:,1);
%     inMat = reshape(tmpMat,[size(tmpMat,1)*size(tmpMat,2)*size(tmpMat,3)],1);
%     meanWB = mean(inMat);
% %     meanWB(:,2) = zeros;
% %     inFile.img = double(reshape(meanWB,[size(tmpMat,1),size(tmpMat,2),size(tmpMat,3),2]));
% %     save_nii(inFile,outFile)
% end
% 
