function [output] = maskInNIFTIs(inMaps,maskFiles,outDir,parallelArg)
%outputs inMap inside outMap

if iscell(inMaps) == 0
    inMaps = cellstr(inMaps);
end
    
if iscell(maskFiles) == 0
    maskFiles = cellstr(maskFiles);
end   

fileNumMax = length(inMaps);
maskNumMax = length(maskFiles);

switch parallelArg
    case 'yes'
        parfor fileNum = 1:fileNumMax
            disp([num2str((fileNum/fileNumMax)*100) '% of files processed...'])
            for maskNum = 1:maskNumMax
                disp([num2str((maskNum/maskNumMax)*100) '% of rois processed for given file...'])
                [output] = maskNIFTI(inMaps{fileNum},maskFiles{maskNum},outDir);
            end
        end
    case 'no'
        for fileNum = 1:fileNumMax
            for maskNum = 1:maskNumMax
                disp([num2str((fileNum/fileNumMax)*100) '% of files processed...'])
                [output] = maskNIFTI(inMaps{fileNum},maskFiles{maskNum},outDir);
            end
        end
end

function [output] = maskNIFTI(inMap,maskFile,outDir)

inMap = checkGZ(inMap,'yes');
maskFile = checkGZ(maskFile,'yes');

try
    mapFile = load_untouch_nii(inMap);
    maskMat = load_untouch_nii(maskFile);
    %maskFileMat = find(maskFile.img ~= 0 & isfinite(maskFile.img));
catch
    disp('There is something wrong with your input files...')
end
%mapMasked = mapFile(find(maskFile.img ~= 0 & isfinite(maskFile.img)));
tmpMapMat = mapFile.img(:,:,:,1);
tmpMaskMat = maskMat.img(:,:,:,1);
mapFileReshaped = reshape(tmpMapMat,[size(tmpMapMat,1)*size(tmpMapMat,2)*size(tmpMapMat,3),1]);
maskMatReshaped = reshape(tmpMaskMat,[size(tmpMaskMat,1)*size(tmpMaskMat,2)*size(tmpMaskMat,3),1]);

idx = find(maskMatReshaped ~= 0 & isfinite(maskMatReshaped));
%tmpMat(idx) = mapFileReshaped(idx);
maskMatReshaped(idx) = mapFileReshaped(idx);
tmpMatReshaped = reshape(maskMatReshaped,[size(maskMat.img,1),size(maskMat.img,2),size(maskMat.img,3),1]);
%tmpMatReshaped(:,:,:,2) = zeros;
maskMat.img = double(tmpMatReshaped);
outNameIdx = strfind(inMap,'/');
outNameMap = inMap(outNameIdx(end)+1:end-4);
outNameIdx = strfind(maskFile,'/');
outNameMask = maskFile(outNameIdx(end)+1:end-4);
output = 'Success';
save_untouch_nii(maskMat,[outDir '/' outNameMap '_Inside' outNameMask '.nii'])
