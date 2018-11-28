# niftiManip
These are scripts that might help you manipulate nifti files. Not all are well documented at the moment, but many are. These scripts will particularly help translate coordinates between all sorts of various spaces. writeROI can do some thresholding, binarizing, and basic arithmetic on nifti files (and then write them out as the name implies). 

Any script that does nifti writing currently assumes that you have load_untouch_nii and save_untouch_nii in your path (you can download those here: https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image?focused=3806921&tab=function ; apparently this set of scripts has some basic volume visualization and reslicing abilities but none of the scripts contained here currently use that). 

