function [networkR,networkP,networkNames] = networkDecode(inFile,networksFolder,brainMask,arg)

brainMask = load_untouch_nii(brainMask);
BrainVox = find(reshape(brainMask.img,[prod(size(brainMask.img)),1]) == 1);
brainVox = find(brainMask.img == 1);

if ischar(inFile) == 1
    inFileNifti = load_untouch_nii(inFile);
    inFileMat = inFileNifti.img;
else
    inFileMat = inFile;
    warning('We will use the networks file as a template')
end

switch arg
    case 'positive'
        [binaryOutFile, binaryImage] = binarizeNifti(inFile,'positive','n');
    case 'negative'
        [binaryOutFile, binaryImage] = binarizeNifti(inFile,'negative','n');
    case 'all'
        [binaryOutFile, binaryImage] = binarizeNifti(inFile,'all','n');
end
binaryImage = reshape(binaryImage,[prod(size(binaryImage)),1]);

networks = dirClean(networksFolder);
for i = 1:size(networks,1)
    networkNames{i} = [networksFolder '/' networks(i).name];
    networkNifti = load_untouch_nii(networkNames{i});
    networkMat = double(networkNifti.img);
    networkMatR = reshape(networkMat,[prod(size(networkMat)),1]);
    [networkR(i),networkP(i)] = corr(double(binaryImage(brainVox)),double(networkMatR(brainVox)));
end
