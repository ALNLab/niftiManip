function writeROI(inData,varargin)
%% Required Inputs and Summary:
% This is a general function for writting nifti files. Its utility is in
% several different thresholding/manipulation features. The necessary
% argument is a vector of data (inData). If this is the only argument, this
% vector must contain coordinate position followed by the data you want to
% write at that coordinate. This vector may be in any orientation (i.e.
% voxels can be rows or columns), but we assume your voxel identities come
% before the data. If you provide your data for writing in this manner, we
% will only support the writting of a single nifti file (i.e. you must only
% have one data point per coordinate that you provide). This is because
% your input coordinates may be either linear indices (i.e. 1-col voxel
% IDs) or subscripts (i.e. 3-col voxel IDs) and we cannot disambiguate
% between the two if you provide multiple sets of data for writting. If you
% want to write multiple files, provide coordinates and data seperately
% using the inData and inCoords arguments. The script can also threshold
% your data before writing toa nifti file based on some user specified
% threshold (i.e. threshVal argument), or if a p-value vector is provided
% (i.e. pVals argument) it will threshold your data based on a predefined
% set of p-values (0.05, 0.01, 0.001, and 0.0001) using both standard
% correction and FDR. Finally, the script can also take a top X% of each of
% your sets of data to write. These thresholds can be combined. For
% example, you can take the top 5% of data and then only write the values
% that are significant. In many cases, your data and sometimes coordinate
% vectors can be extracted from filepaths to nifti data that you supply so
% you don't need to feed any vectors into the inputs. See below for more
% information. Files will be automatically appended with the parameters
% that you set. 
%
% FINAL IMPORTANT ASSUMPTION: if you don't provide a template (i.e.
% template argument) we will assume that you are working with data in 2mm
% mni space. Each coordinate must be unique. 
% 
%% Required Inputs:
% inData : This is either data followed by coordinates (coords can be rows
% or cols) or only data. Coordinates can be linear indices or subscripts If
% this is the only argument you provide, you must take care to only have
% one  data point for each coordinate. If you provide other arguments, this
% variable should contain as many datapoints as you want to write per
% coordinate, but you must then provide coordinates seperately in inCoords.
% Each vector of data will be written as a seperate map. Instead of
% providing a vector, this can be a path to a nifti file. The data from
% that file will be used in substitute. 
%
%% Optional Inputs:
% inCoords : These are your coordinates associated with each data point you
% want to write into a nifti file supplied in inData. These can be either
% indicies or subscripts and each coord must be unique. This can also be a
% path to a nifti file, in which case only nonzero voxel coordinates will
% be used as your inCoords argument.
%
% outPaths : full directory to write data to, plus whatever base name you
% want to give your file (i.e. please exclude file extensions). If you have
% multiple columns in inData, you can provide multiple filepaths to write
% out. If you only have a single column, this variable can be a string,
% otherwise each path should be a row within a cell. If you do not provide
% as many file names as you have columns in inData, then the last file name
% you provided will be used for all of the missing names. Files are
% appended based on the type of thresholding that you chose. If this
% variable is left empty, your files will be placed in the working
% directory, but if you don't distinguish multiple input files (i.e. inData
% cols), your data will be overwritten.
%
% templatePath : this is either a path to your template file, or the
% already imported nifti structure (using load_untoch_nii). The size of the
% image, and the nifti header are used to write out your new files (i.e.
% your voxels MUST correspond to this image dimensions/resolution). If this
% is left empty, a 2mm MNI template will be used. If this is set to 1, then
% a 1mm MNI template will be used. 2mm and 1mm templates will be loaded in
% from the same folder script if user does not specify location of
% template.
%
% adjustedSwitch : if this is set to 'true', then coordinates will be
% adjusted for matlab indexing. In nifti, voxel space indexing starts at
% zero, but this corresponds to row 1 in matlab. This will essentially just
% add 1 to your coordinates. Otherwise, set to 'false'. If your ROI is very
% large (like a hemisphere or a couple lobes) the value you set here will
% probably not matter because an error will occur if you select the wrong
% option and the script will automatically attempt the alternative. 
%
% threshVal : if this is not empty, your inData will be thresholded by this
% given value. Otherwise, the script will simply write out all of inData.
% You can specify whether you'd like to threshold only things above this
% value, or everything between this value and its inverse (see threshTail). 
%
% pVals : this is a vector identical to inData in size that provides p -
% values for each observed row/col combination. When provided, it will be
% used to threshold your inData using 0.01, 0.05, 0.001 and 0.0001
% thresholds both with standard correction and FDR. You can edit p
% thresholds in defaults. 
%
% threshTail : this determines whether only values above the threshold will
% be considered, or whether you don't want to consider anything lying between
% the threshold and its inverse. If this is set to 'two', then any value
% above the supplied threshold, or below the reciprocal of that threshold
% will be removed. If this is set to 'one' only values above the threshold
% will be considered. This argument also applies to top, in whcih case you
% will only be taking the top positive values of your data, or the top
% absolute values of your data. 
%
% top : This will remove all voxels not in the top X% of inData. If
% top.Switch is set to 'true', then top.Percent is a whole number that
% corresponds to the top X% of inData that you want to keep. Otherwise, set
% to 'false'. If using top, you must specify tails. 
%
%% Examples:
% I want to take a t-test image that already exists and threshold it by a
% p-image that already exists (for example from the tfce pipeline in
% parcellationTtest.m. We can use the t-test image as inData, the pVals
% image as the p-values to threshold and the coordinates file:  
% writeROI('/Users/ateghipc/Desktop/spt/ROI/PT/clusterStats/ttest/Kmeans_solution_2_Cluster_1v2_ttest_FC_Tval_2mmSpace.nii','/Users/ateghipc/Dropbox (UCI)/PT/data/FC_TFCE_TTEST_pcorr_neg.nii','/Users/ateghipc/Dropbox (UCI)/PT/scripts/FC_TTEST_TFCE_neg',[],'false',[],'/Users/ateghipc/Dropbox (UCI)/PT/data/FC_TFCE_TTEST_pcorr_neg.nii',[],[])


% writeROI(inData,inCoords,outPaths,templatePath,adjustedSwitch,threshVal,pVals,threshTail,topSwitch)
% writeROI([3,2,12,55;3,1,4,8;3,10,435,4],[50, 80, 25; 25 25 25; 50 50 50],{[pwd '/Test1']; [pwd '/Test2']; [pwd '/Test3']},[],'true',1,[],[],'false')
%
%% Alex Notes: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Alex Teghipco (alex.teghipco@uci.edu)
% Last update 7/9/17

%% Defaults
inCoords = [];
outPaths = {pwd};
scriptPath = which('writeROI');
scriptPath = scriptPath(1:end-11);
templatePath = load([scriptPath '/2mmTemplate.mat'],'template');
adjustedSwitch = 'false';
threshVal = [];
pVals = [];
threshTail = 'false';
top.Switch = 'false';
pThreshs = [0.05 0.01 0.001 0.0001];

%% Import user-specified settings
fixedargn = 1;
if nargin > (fixedargn + 0)
    if ~isempty(varargin{1})
        inCoords = varargin{1};
    end
end
if nargin > (fixedargn + 1)
    if ~isempty(varargin{2})
        outPaths = varargin{2};
    end
end
if nargin > (fixedargn + 2)
    if ~isempty(varargin{3})
        templatePath = varargin{3};
    end
end
if nargin > (fixedargn + 3)
    if ~isempty(varargin{4})
        adjustedSwitch = varargin{4};
    end
end
if nargin > (fixedargn + 4)
    if ~isempty(varargin{5})
        threshVal = varargin{5};
    end
end
if nargin > (fixedargn + 5)
    if ~isempty(varargin{6})
        pVals = varargin{6};
    end
end
if nargin > (fixedargn + 6)
    if ~isempty(varargin{7})
        threshTail = varargin{7};
    end
end
if nargin > (fixedargn + 7)
    if ~isempty(varargin{8})
        top = varargin{8};
    end
end

%% Setup
% If templatePath is a structure we will assume it is in standard nifti
% structure format
if isstruct(templatePath) == 1
    warning('Using pre-defined 2MM MNI template')
    if isfield(templatePath,'template') == 1
        template = templatePath.template;
    else
        template = templatePath;
        warning('Assuming your template path is actually a preloaded nifti structure')
    end
else
    %if templatePath is 1 then load up a pre-assembled 1mm template
    if templatePath == 1
        warning('Using pre-defined 1MM MNI template')
        templatePath = load([scriptPath '/1mmTemplate.mat','template']);
    end
    %if templatePath is a file, then check if it is unzipped.
    if exist(templatePath,'file') == 2
        disp('Your nifti input was unzipped for import ... ')
        templatePath = checkGZ(templatePath,'yes');
        template = load_untouch_nii(templatePath);
    end
end

dims=size(template.img);
if size(dims,2) > 3
    warning('Your template has multiple maps...using only the first')
    template.img = template.img(:,:,:,1);
    template.hdr.dime.dim = [3 size(template.img,1) size(template.img,2) size(template.img,3) 1 1 1 1];
end

clear templatePath
brainVox = find(template.img);

% If you have given a file as your input data we will assume extract data
% from it.
if ischar(inData) == 1
    [~, inCoords, ~, ~, ~, ~,inData] = voxelROI(inData,'false');
    adjustedSwitch = 'false';
end

% If you have given a file as your input coords we will assume this is a
% binary mask that correponds to the data you want to write, and we will
% turn off adjusting voxels for nifti indexing.
if ischar(inCoords) == 1
    [~, inCoords, ~, ~, ~, ~] = voxelROI(inCoords,'true');
    adjustedSwitch = 'false';
end

% Figure out whether rows or cols of inCoords correspond to variables and
% force rows to correspond to voxels
if size(inData,2) > size(inData,1)
    inData = inData';
else
    if size(inData,2) == size(inData,1)
        warning('Input of inData is ambigous 3x3 matrix so we are going to assume coordinates are row vectors')
    end
end

% If you haven't given me coords, we will try to see if your coords are in
% the inData variable
if isempty(inCoords) == 1
    if size(inData,2) == 2
        warning('We are assuming that your coordinates are in the first row of your data vector')
        inCoords = inData(:,1);
        inData = inData(:,2);
    elseif size(inData,2) == 4
        warning('We are assuming that your coordinates are in the three rows of your data vector')
        inCoords = inData(:,1:3);
        inData = inData(:,4);
    elseif size(inData,2) == 3 || size(inData,2) > 4
        error('We cannot analyze your inData vector ... it is unclear whether you have provided coordinates as linear indices or subscripts')
    end
end

% If you have given a file as your input p-values we will extract data from
% it. If we still haven't found your coordinates we will extract
% coordinates from nonzero elements of the p-value file. If coordinates
% already exist we will extract all values from p-value file. 
if ischar(pVals) == 1 && isempty(inCoords) == 1
    [~, inCoords, ~, ~, ~, ~,pVals] = voxelROI(pVals,'true');
    adjustedSwitch = 'false';
elseif ischar(pVals) == 1 && isempty(inCoords) == 0
    [~, ~, ~, ~, ~, ~,pVals] = voxelROI(pVals,'false');
end

% Figure out whether rows or cols of inCoords correspond to voxels and make
% rows correspond to voxels
if size(inCoords,2) > size(inCoords,1)
    inCoords = inCoords';
else
    if size(inCoords,2) == size(inCoords,1)
        warning('Input of inCoords is ambigous 3x3 matrix so we are going to assume coordinates are row vectors')
    end
end

% Check if the number of voxels in data vector matches that of coordinates
if size(inCoords,1) ~= size(inData,1)
    error('The size of your coordinates does not match the size of your data...')
end

% Convert linear to subscript
if size(inCoords,2) == 1
    warning('Assuming you have given me linear indices instead of subscripts as input coords (and that they match the template you have given) ...')
else
    switch adjustedSwitch
        case 'false'
            try
                inCoords = sub2ind(size(template.img),inCoords(:,1),inCoords(:,2),inCoords(:,3));
            catch
                warning('You have some subscripts that do not exist in the template. We are going to assume that you accidentally forgot to adjust coordinates for nifti space')
                inCoords = sub2ind(size(template.img),inCoords(:,1)+1,inCoords(:,2)+1,inCoords(:,3)+1);
            end
        case 'true'
            try
                inCoords = sub2ind(size(template.img),inCoords(:,1)+1,inCoords(:,2)+1,inCoords(:,3)+1);
            catch
                warning('You have some subscripts that do not exist in the template. We are going to assume that you have already adjusted your coordinates for nifti space')
                inCoords = sub2ind(size(template.img),inCoords(:,1),inCoords(:,2),inCoords(:,3));
            end
    end
end

%If only one output file name is given and as a string, convert it to a
%cell for easier output file name processing
if ischar(outPaths) == 1
    outPaths = cellstr(outPaths);
end

%If you intended to write out more files than you gave names, then make all
%missing file names the last known file name. It assumes missing files
%always come after known files.
if isempty(inData) == 0
    files = cell(size(inData,2),1);
    if size(outPaths,1) < size(inData,2)
        lastName = size(outPaths,1);
        missingEnd = size(inData,2);
        for i = lastName:missingEnd
            if i >= lastName
                files{i} = outPaths{lastName};
            end
        end
    else
        files = outPaths;
    end
    clear outPaths
end

%% Main loop that applies thresholds
for i = 1:size(inData,2)
    tmpData = inData(:,i);
    switch top.Switch
        case 'false'
            if isempty(threshVal) == 1
                if isempty(pVals) == 1
                    disp('Applying no threshold ...')
                    outMat = zeros(size(template.img,1),size(template.img,2),size(template.img,3));
                    outMat(inCoords) = tmpData;
                    template.hdr.dime.datatype = 16;
                    template.hdr.dime.bitpix = 32;
                    template.untouch = 1;
                    template.img = double(outMat);
                    save_untouch_nii(template,files{1,1})
                else
                    % Now threshold by p-values if they exist and write out significant
                    % voxels
                    disp('Applying only p-threshold ...')
                    for k = 1:length(pThreshs)
                        tmpData = inData(:,i);
                        outFileName = [files{i,1} '_pCorr_' num2str(pThreshs(k))];
                        tmpDataPThresh = find(pVals < pThreshs(k));
                        tmpData(tmpDataPThresh) = 0;
                        outMat = zeros(size(template.img,1),size(template.img,2),size(template.img,3));
                        outMat(inCoords) = tmpData;
                        template.img = outMat;
                        save_untouch_nii(template,[outFileName '.nii'])
                    end
                    pValsFDR = pVals;
                    pValstmp = double(pVals(brainVox));
                    pValstmpFDR = mafdr(pValstmp);
                    pValsFDR(brainVox) = pValstmpFDR;
                    warning('For FDR we are assuming all nonzero voxels in your template correspond to a brain mask')
                    for k = 1:length(pThreshs)
                        tmpData = inData(:,i);
                        outFileName = [files{i,1} '_pCorrFDR_' num2str(pThreshs(k))];
                        tmpDataPThresh = find(pValsFDR < pThreshs(k));
                        tmpData(tmpDataPThresh) = 0;
                        outMat = zeros(size(template.img,1),size(template.img,2),size(template.img,3));
                        outMat(inCoords) = tmpData;
                        template.img = outMat;
                        save_untouch_nii(template,[outFileName '.nii'])
                    end
                end
            else
                if isempty(pVals) == 1
                    disp('Applying only user specified threshold ...')
                    tmpData = inData(:,i);
                    for j = 1:size(threshVal,1)
                        switch threshTail
                            case 'one'
                                tmpDataThresh = find(tmpData > threshVal(j));
                                outFileName = [files{i,1} '_OneTailThreshold_' num2str(threshVal)]; %%append filename with your threshold
                            case 'two'
                                tmpDataThresh = find(abs(tmpData) > threshVal(j));
                                outFileName = [files{i,1} '_TwoTailThreshold_' num2str(threshVal)]; %%append filename with your threshold
                        end
                        tmpData(tmpDataThresh) = 0;
                        outMat = zeros(size(template.img,1),size(template.img,2),size(template.img,3));
                        outMat(inCoords) = tmpData;
                        template.img = outMat;
                        save_untouch_nii(template,[outFileName '.nii'])
                    end
                else
                    disp('Applying user specified threshold with p-value thresholds ...')
                    tmpData = inData(:,i);
                    for j = 1:size(threshVal,1)
                        switch threshTail
                            case 'one'
                                tmpDataThresh = find(tmpData > threshVal(j));
                                outFileNames{i,1} = [files{i,1} '_OneTailThreshold_' num2str(threshVal)]; %%append filename with your threshold
                            case 'two'
                                tmpDataThresh = find(abs(tmpData) > threshVal(j));
                                outFileNames{i,1} = [files{i,1} '_TwoTailThreshold_' num2str(threshVal)]; %%append filename with your threshold
                        end
                        tmpData(tmpDataThresh) = 0;
                        for k = 1:length(pThreshs)
                            tmpData2 = tmpData;
                            outFileName = [outFileNames{i,1} '_pCorr_' num2str(pThreshs(k))];
                            tmpDataPThresh = find(pVals < pThreshs(k));
                            tmpData2(tmpDataPThresh) = 0;
                            outMat = zeros(size(template.img,1),size(template.img,2),size(template.img,3));
                            outMat(inCoords) = tmpData2;
                            template.img = outMat;
                            save_untouch_nii(template,[outFileName '.nii'])
                        end
                        pValsFDR = pVals;
                        pValstmp = double(pVals(brainVox));
                        pValstmpFDR = mafdr(pValstmp);
                        pValsFDR(brainVox) = pValstmpFDR;
                        warning('For FDR we are assuming all nonzero voxels in your template correspond to a brain mask')
                        for k = 1:length(pThreshs)
                            tmpData2 = tmpData;
                            outFileName = [outFileNames{i,1} '_pCorrFDR_' num2str(pThreshs(k))];
                            tmpDataPThresh = find(pValsFDR < pThreshs(k));
                            tmpData2(tmpDataPThresh) = 0;
                            outMat = zeros(size(template.img,1),size(template.img,2),size(template.img,3));
                            outMat(inCoords) = tmpData2;
                            template.img = outMat;
                            save_untouch_nii(template,[outFileName '.nii'])
                        end
                    end
                end
            end
        case 'true'
            topPercentage = round(size(inData,1)*((top.Percent)/100));
            switch threshTail
                case 'one'
                    [~, sortedRealIdx]= sort(tmpData);
                    files{i,1} = [files{i,1} '_Top_' num2str(top.Percent) '_Percent_PositiveValues_'];
                    
                case 'two'
                    [~, sortedRealIdx]= sort(abs(tmpData));
                    files{i,1} = [files{i,1} '_Top_' num2str(top.Percent) '_Percent_AbsoluteValues_'];
            end
            removeIdx = sortedRealIdx(1:end-topPercentage);
            tmpData(removeIdx) = 0;
            if isempty(threshVal) == 1
                if isempty(pVals) == 1
                    disp(['Taking top ' num2str(top.Percent) ' % of data ... ']);
                    outMat = zeros(size(template.img,1),size(template.img,2),size(template.img,3));
                    outMat(inCoords) = tmpData;
                    template.img = outMat;
                    save_untouch_nii(template,[files{i,1}(1:end-1) '.nii'])
                else
                    % Now threshold by p-values if they exist and write out significant
                    % voxels
                    disp('Taking top 5% of data and applying p-threshold ...')
                    for k = 1:length(pThreshs)
                        tmpData2 = tmpData;
                        outFileName = [files{i,1} '_pCorr_' num2str(pThreshs(k))];
                        tmpDataPThresh = find(pVals < pThreshs(k));
                        tmpData2(tmpDataPThresh) = 0;
                        outMat = zeros(size(template.img,1),size(template.img,2),size(template.img,3));
                        outMat(inCoords) = tmpData2;
                        template.img = outMat;
                        save_untouch_nii(template,[outFileName '.nii'])
                    end
                    pValsFDR = pVals;
                    pValstmp = double(pVals(brainVox));
                    pValstmpFDR = mafdr(pValstmp);
                    pValsFDR(brainVox) = pValstmpFDR;
                    warning('For FDR we are assuming all nonzero voxels in your template correspond to a brain mask')
                    for k = 1:length(pThreshs)
                        tmpData2 = tmpData;
                        outFileName = [files{i,1} '_pCorrFDR_' num2str(pThreshs(k))];
                        tmpDataPThresh = find(pValsFDR < pThreshs(k));
                        tmpData2(tmpDataPThresh) = 0;
                        outMat = zeros(size(template.img,1),size(template.img,2),size(template.img,3));
                        outMat(inCoords) = tmpData2;
                        template.img = outMat;
                        save_untouch_nii(template,[outFileName '.nii'])
                    end
                end
            else
                disp('Taking top 5% of data, then applying user thresholds, then applying p-thresholds...')
                tmpData2 = tmpData;
                for j = 1:size(threshVal,1)
                    switch threshTail
                        case 'one'
                            tmpDataThresh = find(tmpData2 > threshVal(j));
                            outFileNames{i,1} = [files{i,1} '_OneTailThreshold_' num2str(threshVal)]; %%append filename with your threshold
                        case 'two'
                            tmpDataThresh = find(abs(tmpData2) > threshVal(j));
                            outFileNames{i,1} = [files{i,1} '_TwoTailThreshold_' num2str(threshVal)]; %%append filename with your threshold
                    end
                    tmpData2(tmpDataThresh) = 0;
                    for k = 1:length(pThreshs)
                        tmpData3 = tmpData2;
                        outFileName = [outFileNames{i,1} '_pCorr_' num2str(pThreshs(k))];
                        tmpDataPThresh = find(pVals < pThreshs(k));
                        tmpData3(tmpDataPThresh) = 0;
                        outMat = zeros(size(template.img,1),size(template.img,2),size(template.img,3));
                        outMat(inCoords) = tmpData3;
                        template.img = outMat;
                        save_untouch_nii(template,[outFileName '.nii'])
                    end
                    pValsFDR = pVals;
                    pValstmp = double(pVals(brainVox));
                    pValstmpFDR = mafdr(pValstmp);
                    pValsFDR(brainVox) = pValstmpFDR;
                    warning('For FDR we are assuming all nonzero voxels in your template correspond to a brain mask')
                    for k = 1:length(pThreshs)
                        tmpData3 = tmpData2;
                        outFileName = [outFileNames{i,1} '_pCorrFDR_' num2str(pThreshs(k))];
                        tmpDataPThresh = find(pValsFDR < pThreshs(k));
                        tmpData3(tmpDataPThresh) = 0;
                        outMat = zeros(size(template.img,1),size(template.img,2),size(template.img,3));
                        outMat(inCoords) = tmpData3;
                        template.img = outMat;
                        save_untouch_nii(template,[outFileName '.nii'])
                    end
                end
            end
    end
end
 