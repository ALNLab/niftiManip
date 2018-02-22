function [rVal,pVal,bf10,bf10rep] = matrixCorrelation(roiFile,inDataBrain,inDataBrain2)

similarityFolder = [roiFile(1:tmpStr(end)) 'dataSimilarity'];  

mat1R = corrcoef(inDataBrain','rows','pairwise');
mat1RU = triu(mat1R);
mat1RU(mat1RU == 0) = NaN;
mat1RU(mat1RU == 1) = NaN;

mat2R = corrcoef(inDataBrain2','rows','pairwise');
mat2RU = triu(mat2R);
mat2RU(mat2RU == 0) = NaN;
mat2RU(mat2RU == 1) = NaN;

[rVal,pVal] = corrcoef(mat2RU,mat1RU,'rows','complete');

mat1RU_re = reshape(mat1RU,[size(mat1RU,1)*size(mat1RU,2),1]);
mat2RU_re = reshape(mat2RU,[size(mat2RU,1)*size(mat2RU,2),1]);

figure(1)
[values, centers] = hist3([mat1RU_re, mat2RU_re],'Nbins',[50 50]);
pcolor(centers{:},values);
colorbar
axis equal
axis xy
saveas(gcf,[similarityFolder 'FC_CO_Correlation.fig'])

bf10 = corrbf(rVal(1,2),sum(1:size(mat1RU,1)));
bf10rep = corrbfrep(rVal(1,2),sum(1:size(mat1RU,1)));

figure(2)
mat1RU(isnan(mat1RU)) = 0;
mat2RU(isnan(mat2RU)) = 0;
tempMat = mat1RU + mat2RU';
imagesc(tempMat,[-1 1])
saveas(gcf,[similarityFolder 'FC_CO_Triangles.png'])
saveas(gcf,[similarityFolder 'FC_CO_Triangles.fig'])