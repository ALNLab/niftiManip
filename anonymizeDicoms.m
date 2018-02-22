function [] = anonymizeDicoms(folder)
%folder must contain dicoms

%Alex Teghipco
%ateghipc@u.rochester.edu
%November 2015

subd=dir(folder);
for k = length(subd):-1:1
    if subd(k).isdir
        subd(k) = [ ];
        continue
    end
end

for i=1:length(subd)
    currentFile=subd(i,1).name;
    if ~isempty(findstr(currentFile,'.IM')) %% look for IM extension
        movefile([folder '/' currentFile],[folder '/' subd(k).name(1:end-4) '.dcm']);
        subd(i).name = [subd(i).name(1:end-4) '.dcm'];
    elseif isempty(findstr(subd(i).name,'.')) == 1; %% look for no extension
        movefile([folder '/' subd(i).name],[folder '/' subd(i).name '.dcm']);
        subd(i).name = [subd(i).name '.dcm'];
    end
    dicomanon([folder '/' subd(i).name],[folder '/' subd(i).name]);
end

            
            