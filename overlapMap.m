function overlapMap(map1s,map2s,outDir,relationOverlap,threshSwitch)
% This script takes in two NIFTI files and outputs a file showing overlap.
% Within areas of overlap you can choose for the script to plot average of
% intensity between two maps, higher value between the two maps, intensity
% of first map, or intensity of second map. CHECK FSLDIR before running.

%map1s is a series of NIFTI files. If you want to use GUI leave map1s
%argument blank: ''.

%map2s is a series of NIFTI files to compare map1s to. Rows must match
%which two files two compare.

%outDir is a folder to output overlap files. Overlap files will be named as
%input files with '_OVERLAP'.

%relationOverlap takes in one of the following arguments:
%AVG=plots average intensity value within overlap voxels.
%MAP1=plots intensity of map1s in overlap voxels.
%MAP2=plots intensity of map2s in overlap voxels.
%WINNER=plots intensity that is higher between map1s and map2s in
%overlap voxels.
%LOOSER=plots intensity that is lower between map1s and map2s in overlap
%voxels.

%threshSwitch is a two column one row input. First row corresponds to
%threshold to be applied to each map in your first map vector. Second row
%corresponds to threshold to be applied to each map in your second map
%vector.

%example:
%map1s={'/cantlonData/LAB_MEMBERS/Alex/DTI_Radiations002/analysisData/Tractograms/Left1/fdt_paths.nii.gz'};
%map2={'/cantlonData/LAB_MEMBERS/Alex/DTI_Radiations002/analysisData/Tractograms/Left2/fdt_paths.nii.gz'};
%outName={'/cantlonData/LAB_MEMBERS/Alex/DTI_Radiations002/analysisData/Tractograms/Left1and2.nii.gz'};

%Alex Teghipco
%ateghipc@u.rochester.edu
%April 2016

% %%%%%%%%%%%%%% Set all FSL variables
% fslDir=getenv('FSLDIR');
% FSLMEANTS=[fslDir '/bin/fslmeants'];
% FSLMATHS=[fslDir '/bin/fslmaths'];
% setenv('FSLOUTPUTTYPE','NIFTI_GZ');
%%%%%%%%%%%%%%

if exist(outDir,'dir') == 0
    mkdir(outDir);
end

if isempty(map1s) == 1
    map1s=uipickfiles('Prompt','Select your first vector of brain maps.','FilterSpec','/Users/ateghipc/Desktop/Fischer/fcAnalysis/lesionedFC/WBCorrelations/LLIcorrelations/leftTemp/LIFG')';
    %sort(map1s);
end
if isempty(map2s) == 1
    map2s=uipickfiles('Prompt','Select your second vector of brain maps.','FilterSpec','/Users/ateghipc/Desktop/Fischer/fcAnalysis/lesionedFC/WBCorrelations/LLIcorrelations/leftTemp/LIFG')';
    %sort(map2s);
end

%h = waitbar(0,'Starting analysis...code monkeys hard at work');

for i = 1:size(map1s,1)
    map1=map1s{i,1};
    map2=map2s{i,1};
    
    %insert gunzip here
    
    k=strfind(map1,'/');
    file = map1((k(end))+1:end-7);
    outName=[outDir '/' file '_OVERLAP.nii.gz'];
    % waitbar((i / (size(map1s,1))),h,['Working on ' file]);
    
    if isempty(threshSwitch) == 0
        thr1=num2str(threshSwitch(1,1));
        threshMap1 = [FSLMATHS ' ' map1 ' -thr ' thr1 ' ' outDir '/' file 'Group1_thr_' thr1 '.nii.gz'];
        system(threshMap1);
        map1 = [outDir '/' file 'Group1_thr_' thr1 '.nii.gz'];
        
        thr2=num2str(threshSwitch(1,2));
        threshMap2 = [FSLMATHS ' ' map2 ' -thr ' thr2 ' ' outDir '/' file 'Group2_thr_' thr2 '.nii.gz'];
        system(threshMap2);
        map2 = [outDir '/' file 'Group2_thr_' thr2 '.nii.gz'];
    end
   
    
    Map1Nifti=load_untouch_nii(map1);
    Map2Nifti=load_untouch_nii(map2);
    Map1mat=Map1Nifti.img;
    Map2mat=Map2Nifti.img;
    
    
    testMat=zeros(1,2);
    outMat=zeros(size(Map1mat));
    
    for x = 1:size(Map1mat,1)
        for y = 1:size(Map1mat,2)
            for z = 1:size(Map1mat,3)
                
                if isempty(strfind(relationOverlap,'AVG')) == 0
                    if Map1mat(x,y,z) ~= 0 && Map2mat(x,y,z) ~= 0 && Map1mat(x,y,z) ~=-Inf && Map2mat(x,y,z) ~=-Inf && isnan(Map1mat(x,y,z)) == 0 && isnan(Map2mat(x,y,z)) == 0;
                        testMat(1,1)= Map1mat(x,y,z);
                        testMat(1,2)= Map2mat(x,y,z);
                        outMat(x,y,z) = mean(testMat);
                    else
                        outMat(x,y,z) = NaN;
                    end
                end
                
                if isempty(strfind(relationOverlap,'MAP1')) == 0
                    if Map1mat(x,y,z) ~= 0 && Map2mat(x,y,z) ~= 0 && Map1mat(x,y,z) ~=-Inf && Map2mat(x,y,z) ~=-Inf && isnan(Map1mat(x,y,z)) == 0 && isnan(Map2mat(x,y,z)) == 0;
                        outMat(x,y,z) = Map1mat(x,y,z);
                        outMat(x,y,z) = Map1mat(x,y,z);
                    else
                        outMat(x,y,z) = NaN;
                    end
                end
                
                if isempty(strfind(relationOverlap,'MAP2')) == 0
                    if Map1mat(x,y,z) ~= 0 && Map2mat(x,y,z) ~= 0 && Map1mat(x,y,z) ~=-Inf && Map2mat(x,y,z) ~=-Inf && isnan(Map1mat(x,y,z)) == 0 && isnan(Map2mat(x,y,z)) == 0;
                        outMat(x,y,z) = Map2mat(x,y,z);
                        outMat(x,y,z) = Map2mat(x,y,z);
                    else
                        outMat(x,y,z) = NaN;
                    end
                end
                
                if isempty(strfind(relationOverlap,'WINNER')) == 0
                    if Map1mat(x,y,z) ~= 0 && Map2mat(x,y,z) ~= 0 && Map1mat(x,y,z) ~=-Inf && Map2mat(x,y,z) ~=-Inf && isnan(Map1mat(x,y,z)) == 0 && isnan(Map2mat(x,y,z)) == 0;
                        testMat(1,1)= Map1mat(x,y,z);
                        testMat(1,2)= Map1mat(x,y,z);
                        outMat(x,y,z) = max(testMat);
                    else
                        outMat(x,y,z) = NaN;
                    end
                end
                
                if isempty(strfind(relationOverlap,'LOOSER')) == 0
                    if Map1mat(x,y,z) ~= 0 && Map2mat(x,y,z) ~= 0 && Map1mat(x,y,z) ~=-Inf && Map2mat(x,y,z) ~=-Inf && isnan(Map1mat(x,y,z)) == 0 && isnan(Map2mat(x,y,z)) == 0;
                        testMat(1,1)= Map1mat(x,y,z);
                        testMat(1,2)= Map1mat(x,y,z);
                        outMat(x,y,z) = max(testMat);
                    else
                        outMat(x,y,z) = NaN;
                    end
                end
            end
        end
    end
   
    Map1Nifti.img=(outMat);
    save_untouch_nii(Map1Nifti, outName);
    
end

