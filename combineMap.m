function [overlapVox, outMap] = combineMap(inFile1,inFile2,operator,outFile)
warning('The output overlap voxel uses subscripts ... ')

if ischar(inFile1) == 1
    inFile1Nii = load_untouch_nii(inFile1);
    inFile1Mat = inFile1Nii.img;
else
    inFile1Mat = inFile1Nii;
end
if ischar(inFile2) == 1
    inFile2Nii = load_untouch_nii(inFile2);
    inFile2Mat = inFile2Nii.img;
else
    inFile2Mat = inFile2Nii;
end

if size(inFile1Mat) ~= size(inFile2Mat)
    error('Your files are not the same size');
end

switch operator
    case add
        outMap = bsxfun(@plus,inFile1Mat,inFile2Mat);
    case subtract
        outMap = bsxfun(@minus,inFile1Mat,inFile2Mat);
    case multiply
        outMap = bsxfun(@mult,inFile1Mat,inFile2Mat);
    case divide
        outMap = bsxfun(@rdivide,inFile1Mat,inFile2Mat);
    case winner
        outMap = bsxfun(@gt,inFile1Mat,inFile2Mat);
    case looser
        outMap = bsxfun(@gl,inFile1Mat,inFile2Mat);
end

inFile1MatIdx = find(inFile1Mat ~= 0);
inFile2MatIdx = find(inFile2Mat ~= 0);
[overlapWithMap1Nonzero,overlapWithMap2Nonzero] = ismember(inFile1MatIdx,inFile2MatIdx);

if size(overlapWithMap1Nonzero,1) > size(overlapWithMap2Nonzero,1)
    overlapVox = inFile1MatIdx(find(overlapWithMap1Nonzero == 1));
    
else
    overlapVox = inFile2MatIdx(find(overlapWithMap2Nonzero == 1));
end
disp([ num2str((size(overlapVox,1)/prod(size(inFile1Mat)))*100) '% (or ' num2str(size(overlapVox,1)) ') of nonzero voxels in the images overlap' ])

if ischar(inFile1) == 1 && ischar(inFile2) == 1
    warning('Assuming your file is in 2mm MNI space for writting ... ')
    scriptPath = which('combineMap');
    scriptPath = scriptPath(1:end-11);
    load([scriptPath '/2mmTemplate.mat'],'template');
    template.img = outMap;
else
    if ischar(inFile) == 0
        template = inFile1;
    else
        template = inFile2;
    end
end

template.img = outMap;
save_untouch_nii(template,outFile)
    