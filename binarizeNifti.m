function [binaryOutFile, binaryImage] = binarizeNifti(varargin)

% [binaryOutFile, binaryImage] = binarizeNifti(inFile,arg,write)
% [binaryOutFile, binaryImage] = binarizeNifti(inFile,'all','y')
%if arg is all every nonzero value is binarized
%if arg is positive, only positive values are binarized
%if arg is negative, only negative values are binarized
%if arg is threshold, only negative values are binarized


fixedargn = 0;
if nargin > (fixedargn + 0)
    if ~isempty(varargin{1})
        inFile = varargin{1};
    end
else
    [FileName,PathName,FilterIndex] = uigetfile('*.nii*','Please choose a file to binarize');
    inFile = [PathName FileName];
end

if nargin > (fixedargn + 1)
    if ~isempty(varargin{2})
        arg = varargin{2};
    end
else
    diagArg = inputdlg('Which values in your image would you like to binarize? (all/positive/negative/threshold)','Select a set of values to binarize within image',1,{'all'});
    arg = diagArg{1,1};
end

if nargin > (fixedargn + 2)
    if ~isempty(varargin{2})
        write = varargin{2};
    end
else
    diagWrite = inputdlg('Do you want to write an output file?(y/n)','Output',1,{'y'});
    write = diagWrite{1,1};
end

if ischar(inFile) == 0
    error('Input must be a nifti file (string)!')
end

[inFilePath,inFileName,~] = fileparts(inFile);
binaryOutFile = [inFilePath '/' inFileName];
inFileNifti = load_untouch_nii(inFile);
binaryImage = inFileNifti.img;

switch arg
    case 'all'
        nonZero = find(binaryImage);
        binaryOutFile = [binaryOutFile '_allValues_'];
    case 'positive'
        neg = find(binaryImage < 0);
        binaryImage(neg) = 0;
        nonZero = find(binaryImage > 0);
        binaryOutFile = [binaryOutFile '_positiveValues_'];
    case 'negative'
        pos = find(binaryImage > 0);
        binaryImage(pos) = 0;
        nonZero = find(binaryImage < 0);
        binaryOutFile = [binaryOutFile '_negativeValues_'];
    case 'threshold'
        diagThresh = inputdlg({'Enter threshold:','Two-tailed threhsold? (y/n):'},'Input threshold for image binarization',1,{'0','y'});
        tail = diagThresh{2,1};
        thresh = diagThresh{1,1};
        switch tail
            case 'y'
                binaryImage = abs(binaryImage);
        end
        underThresh = find(binaryImage < thresh);
        binaryImage(underThresh) = 0;
        nonZero = find(binaryImage > thresh);
        binaryOutFile = [binaryOutFile '_thresh' num2str(thresh) '_'];
end

binaryImage(nonZero) = 1;

switch write
    case 'y'
        inFileNifti.img = binaryImage;
        save_untouch_nii(inFileNifti,[binaryOutFile 'binarized.nii']);
end
