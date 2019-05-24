clear all;
clear;

im_heart = dicomread('../CVIT_workshop_medical_image/ct_heart.dcm');
im_lymph = imread('../CVIT_workshop_medical_image/lymph_node.jpg');
im_brain = niftiread('../CVIT_workshop_medical_image/Brats data/Brats18_2013_24_1_t1.nii');
out = window(im_heart, 255, 15);

function [out] = window(image, origin, width)
% Function takes an image, origin and window width. Scales the image
% matrix values according to the window size. Values lying outside the 
% window are thresholded

   image(find(image < origin - width)) = origin - width;
   image(find(image > origin + width)) = origin + width;

   % Scale image matrix to 0-255 range
   out = mat2gray(image);
   
   figure('name', 'Image Windowing')
   imshow(out,[]);
end