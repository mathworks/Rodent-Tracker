function [Image, Background_Image, Image_info] = Extract_video_matrix(file)

[~,~,ext] = fileparts(file);

%Load Videos/Multi-TIFFs

% For Multi-TIFF files
if contains(ext,'.tif','IgnoreCase',true)
    Image_info = imfinfo(file);
    num_images = numel(Image_info);%Find how many slices (or frames) are in multi-TIFF file
    Background_Image = imread(file,num_images, 'Info', Image_info);%Obtains last slice/frames in image stack
    Image = zeros([size(Background_Image) num_images]);
    if size(size(Background_Image),2) == 3
        for i = 1:num_images
            Image(:,:,:,i) = imread(file, i, 'Info', Image_info);
        end
    else
        for i = 1:num_images
            Image(:,:,i) = imread(file, i, 'Info', Image_info);
        end
    end
% For Video files
else
    Image_info = VideoReader(file);
    Image = read(Image_info);
    if size(size(Image),2) > 3
        Background_Image = Image(:,:,:,end);
    else
        Background_Image = Image(:,:,end);
    end
end

if isa(Background_Image,'uint8')
Image = uint8(Image);
end
if isa(Background_Image,'uint16')
Image = uint16(Image);
end

end