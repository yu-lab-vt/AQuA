function [rgbstack,rgbcell] = label2rgb3d_new(lblstack) 
%label2rgb3d(lblstack) take a labeled stack and turn it into a truecolor image. 
% get all of the unique ind 
ind = unique(lblstack); 
cmap = jet(numel(ind));
cmap = cmap(randperm(numel(ind)),:);
images = stack2cell(lblstack); 
rgbcell = cellfun(@(x) im2double(label2rgb(x, cmap, 'k')), images, 'UniformOutput', false);
rgbstack = cell2stack(rgbcell);
end

function images = stack2cell(stack) 
%stack2cell(stack) convert a stack of data into a cell array 
images = num2cell(zeros(size(stack,3),1)); 
if numel(size(stack)) == 3 % bw and grayscale images 
    for ii = 1:size(stack,3) 
        images{ii} = stack(:,:,ii); 
    end 
elseif numel(size(stack)) == 4 % truecolor data 
    for ii = 1:size(stack,4) 
        images{ii} = stack(:,:,:,ii); 
    end 
end 
end

function stack = cell2stack(images) 
%cell2stack converts a cell array of images to a stack (or cube of images) 
% converts a cell array of images to a stack (or cube of images) 
p = numel(images); 
dims = size(images{1}); 
stack = zeros([dims,p]); 
if numel(dims) == 2 % bw and grayscale images 
    for ii = 1:p 
        stack(:,:,ii) = images{ii}; 
    end 
elseif numel(dims) == 3 % truecolor data 
    for ii = 1:p 
        stack(:,:,:,ii) = images{ii}; 
    end 
end
end