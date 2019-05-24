
im_0 = rgb2gray(imread('im0.png'));
im_1 = rgb2gray(imread('im1.png'));

im_0 = imresize(im_0, [512, 512]);
im_1 = imresize(im_1, [512, 512]);
% im_0 = padarray(im_0,[4 4],'both');
% im_1 = padarray(im_1,[4 4],'both');

disparity = zeros(size(im_1));

for i = 1:size(im_1,1) - 7
    for j = 1:size(im_1,2) - 7
        
        im_right = im_1(i:i+7,j:j+7);
        im_left = im_0(i:i+7,j:end);
        disparity(i,j) = (cal_error(im_left, im_right, j+3));        
    end
end

imshow(disparity, [])

function [disparity] = cal_error(im_left, im_right, right_center)
% im_left: 8x20
% im_right: 8x8
    
    error = intmax;
    
        for j = 1:size(im_left,2) - 7
            
            % Sum of Squared Differences
            % Normalized Correlation
            val = sum(sum( (im_right - im_left(:, j:j+7)).^2 ));
            
            if val < error
                disparity = abs(right_center - j+3);
                error = val;
            end
        end
    
end