function [partVals, stats] = partitionData(rois,inCoord,inVals)

rois{1} = checkGZ(rois{1},'yes');
roiFile = load_untouch_nii(rois{1});
roiMat = zeros([length(rois),size(roiFile.img)]);

for i = 1:length(rois)
    rois{i} = checkGZ(rois{i},'yes');
    roiFile = load_untouch_nii(rois{i});
    roiMat = zeros([length(rois),size(roiFile.img)]);
end

for i = 1:length(rois)
    roiFile = load_untouch_nii(rois{i});
    roiMat(i,:,:,:) = roiFile.img;
end

inCoordVox(:,1) = ((inCoord(:,1) * -1) + 90) / 2;
inCoordVox(:,2) = ((inCoord(:,2) * 1) + 126) / 2;
inCoordVox(:,3) = ((inCoord(:,3) * 1) + 72) / 2;

inCoordVoxAdjusted = inCoordVox+1;

numCols = size(inVals,2)+1;
partVals = inVals;
numErrors = 0;
for i = 1:length(inCoordVoxAdjusted)
    disp([num2str((i/length(inCoordVoxAdjusted))*100) '% of coords processed...'])
    roiIdx = roiMat(:,inCoordVoxAdjusted(i,1),inCoordVoxAdjusted(i,2),inCoordVoxAdjusted(i,3));
    findRoi = find(roiIdx ~= 0);
    if length(findRoi) > 1
        disp(['voxel # ' num2str(i) ' of ' num2str(length(inCoord)) ' voxels belongs to two clusters...check your data if this is suspicious'])
    end
    try
        partVals(i,numCols) = findRoi;
    catch
        disp(['voxel # ' num2str(i) ' of ' num2str(length(inCoord)) ' voxels is probably not in either of your rois or it belongs to two clusters'])
        disp(['Check command window: Number of catches thrown is ' num2str(numErrors)])
    end
end

missingVoxels = find(partVals(:,numCols) == 0);
disp([num2str((length(missingVoxels)/length(partVals)*100)) '% of values in your input coordinate matrix were not found in your rois'])

for i = 1:max(partVals(:,numCols));
    stats.mean(i) = mean(partVals(find(partVals(:,numCols) == i)),1);
    stats.stdev(i) = std(partVals(find(partVals(:,numCols) == i)),1);
end

if max(partVals(:,numCols)) == 2
    [tVal,dfVal] = ttest2_cell(partVals(find(partVals(:,numCols) == 1)),partVals(find(partVals(:,numCols) == 2)));   
    pVal = 2*tcdf(-abs(tVal), dfVal);
    stats.nonparamttest.TVAL = tVal;
    stats.nonparamttest.DFVAL = dfVal;
    stats.nonparamttest.PVAL = pVal;
    [h,p,ci,statVals]= ttest2(partVals(find(partVals(:,numCols) == 1)),partVals(find(partVals(:,numCols) == 2)));
    stats.paramttest.TVAL = statVals.tstat;
    stats.paramttest.DFVAL = statVals.df;
    stats.paramttest.PVAL = p;
end
