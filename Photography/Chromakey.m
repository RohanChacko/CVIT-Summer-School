clear;
clc;

im_bg = imread('background2_chroma.jpg');
im_fg = imread('foreground_chroma.png');

out = ChromaKey(im_bg, im_fg, [0, 255, 0]);
imshow(out);

function [output] = ChromaKey(im_bg, im_fg, keyColor)

    % Maximum accomdating error
    epsilon = 55;
    
    im_fg = imresize(im_fg, [size(im_bg,1) size(im_bg,2)]);
    
    for i = 1:size(im_fg,1)
        for j = 1:size(im_fg,2)
            
            if(abs(im_fg(i,j,1) - keyColor(1)) < epsilon && abs(im_fg(i,j,2) - keyColor(2)) < epsilon && abs(im_fg(i,j,3) - keyColor(3)) < epsilon)
               im_fg(i,j,:) = im_bg(i,j,:);
            end
        end
    end
    
    output = im_fg;
end