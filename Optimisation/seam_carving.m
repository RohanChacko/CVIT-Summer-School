% Content aware resizing of image using Seam Carving

clear;
close all;
im = imread('student_material/boy_smiling.jpg');

resize = 1/3;
SeamCarving(im, resize);


function [output] = SeamCarving(im, resize)

% Manual edge detection using convolution
%
% vertical = [1 ;-1];
% horizontal = [1 -1];
% gradient_y = conv2(im,vertical);
% gradient_x = conv2(im, horizontal);
% imshow(gradient_x);
% % Resizing to matrix of smaller size ==> gradient_x
% gradient_y = gradient_y(:)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

im_color = im;
im = rgb2gray(im_color);

for iter = 1:250
    
    gradient = imgradient(im);
    cost_mat = gradient;

    for i = 2:size(gradient, 1)
        for j = 1:size(gradient, 2)

            if j == 1
                cost_mat(i,j) = cost_mat(i,j) + min([cost_mat(i-1,j) cost_mat(i-1,j+1)]);
            elseif j == size(gradient, 2)
                cost_mat(i,j) = cost_mat(i,j) + min([cost_mat(i-1,j-1) cost_mat(i-1,j)]);
            else
                cost_mat(i,j) = cost_mat(i,j) + min([cost_mat(i-1,j-1) cost_mat(i-1,j) cost_mat(i-1,j+1)]);
            end
        end
    end

    min_y = size(im,1);
    
    [~, min_x] = find(cost_mat(end,:) == min(cost_mat(end,:)));
%     im_color(min_y, min_x, :) = [0 255 0];
%     im(min_y, min_x) = intmax;
    min_x = min_x(1);
    for j = min_x:size(im_color,2) -1
      im_color(i, j, :) = [im_color(i, j+1, :)];
      im(i, j) = im(i, j+1);
    end
    i = min_y - 1;
    
    while i~= 0
        
        if min_x == 1
            vec = [intmax cost_mat(i, min_x) cost_mat(i, min_x +1)];        
        elseif min_x == size(cost_mat,2)
            vec = [cost_mat(i, min_x-1) cost_mat(i, min_x) intmax];
        else
            vec = [cost_mat(i, min_x-1) cost_mat(i, min_x) cost_mat(i, min_x+1)];
        end

        [~, temp_x] = find(vec == min(vec));
        if temp_x == 1
            min_x = min_x -1;
        elseif temp_x == 3
            min_x = min_x + 1;
        end
%         im_color(i, min_x, :) = [0 255 0];
%         im(i, min_x) = intmax;
        
        for j = min_x:size(im_color,2) -1
           im_color(i, j, :) = im_color(i, j+1, :);
           im(i, j) = im(i, j+1);
        end
        i = i - 1;
    end
    
    im_color = im_color(:,1:end -1,:);
    im = im(:,1:end -1);
end

imshow(im_color, []);
size(im_color);
end