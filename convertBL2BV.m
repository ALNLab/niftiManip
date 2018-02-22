function [outPoints] = convertBL2BV(vect) 

%% --------------------------------------------------------
% This function converts DICOM space coordinates into SYS space for
% brainvoyager. Input vector vect must have 3 columns corresponding to x y
% and z dimensions, with rows seperating coordinates. This was designed as 
% part of intraopPoints workflow, particularly to work with 
% parseBrainLabPoints.m

%% --------------------------------------------------------
% Alex Teghipco -- ateghipc@u.rochester.edu -- 2016 Version 1
% --------------------------------------------------------

%vect = dlmread(convertedPointsFile,' ');
x = vect(:,1);
y = vect(:,2);
z = vect(:,3);
%stimNumber = vect(:,4);
%timeStamp = vect(:,5);

for i = 1:size(x,1)
%     xOut(i,1) = abs(round(x(i,1)+83.118)-179)+38;
%     yOut(i,1) = abs(round(y(i,1)+96.823)-255);
%     zOut(i,1) = abs(round(z(i,1)+23.525)-201);
     xOut(i,1) = abs(round(x(i,1)+83.118)-179)+38;
     yOut(i,1) = abs(round(y(i,1)+96.823)-255);
     zOut(i,1) = abs(round(z(i,1)+23.525)-201);
end

outPoints=horzcat(xOut,yOut,zOut);
%outPoints=horzcat(xOut,yOut,zOut,stimNumber,timeStamp);

