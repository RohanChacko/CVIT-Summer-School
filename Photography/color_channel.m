% Superimposing color channnels to get a colored image for old RGB color 
% glass plates

clc;
clear;
close all;

im = imread('RGB_Alignment/00029u.tif');
% ColorCombineNaive(im);
ColorCombineLoss(im);

function [output] = ColorCombineLoss(im)
% Method: Normalised Correlation

    % Note: Tweaking the initial amount of image strips to be removed improves
    % final image quality immensely. 
    im = im(0.02*size(im,1):0.99*size(im,1),0.1*size(im,2):0.9*size(im,2));
    div = floor(size(im,1)/3);
      
    im_B = im(1:div,:);
    im = im(div + 1:end,:);
    
    c = normxcorr2(im_B, im);
    [ypeak, xpeak] = find(c == max(c(:)));
    yoffset = ypeak - size(im_B,1);
    xoffset = xpeak - size(im_B,2);
    
    if yoffset < 0
        yoffset = yoffset*-1;
    end
    
    im_G = im(yoffset:yoffset+size(im_B,1) - 1, :);
    im_new = im(yoffset+size(im_B,1):end,:);
    
    if size(im_new,1) <= size(im_B,1)
        im_new = padarray(im_new, [size(im_B,1)], 255, 'post');
    end    
    
    d = normxcorr2(im_B, im_new);
    [ypeak, xpeak] = find(d == max(d(:)));
    yoffset = ypeak - size(im_B,1);
    xoffset = xpeak - size(im_B,2);
    
    if yoffset < 0
        yoffset = yoffset*-1;
    end
    
    im_R = im_new(yoffset:yoffset+size(im_B,1) - 1, :);
        
    out = cat(3,im_R, im_G, im_B);
    figure('name', 'Individual glass plates'),
    subplot(1,3,1);
    imshow(im_R);
    title('Red glass plate');
    
    subplot(1,3,2);
    imshow(im_G);
    title('Green glass plate');
    
    subplot(1,3,3);
    imshow(im_B);
    title('Blue glass plate');
    
    figure('name','Combined Color Image'),
    imshow(out);
    title('Combined Color Image');
    
end



function [output] = ColorCombineNaive(im)
% Method: Individually extract 1/3rd of the image for each color channel
% and combine

    im = im(100:size(im,1) - 100,:);
    div = floor(size(im,1)/3);
    rem = mod(size(im,1), 3);
    
    im_B = im(1:div,:);
%     figure,imshow(im_B);
    
    im_G = im(rem/2 + div:2*div,:);
    % figure, imshow(im_G);

    im_R = im(rem/2 + 2*div:size(im,1), :);
    % imshow(im_R);

    mini = min([size(im_R,1),size(im_G,1),size(im_B,1)]);
    im_R = imresize(im_R, [mini, size(im_R,2)]);
    im_G = imresize(im_G, [mini, size(im_G,2)]);
    im_B = imresize(im_B, [mini, size(im_B,2)]);
    out = cat(3,im_R, im_G, im_B);

    figure,
    imshow(out);

end
