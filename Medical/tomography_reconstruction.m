img = phantom('Modified Shepp-Logan', 256);
imshow(img, [])

theta = 1:180;
new = zeros(256,256);
sum_vec = zeros(180, 256);

for i = 1:length(theta)
   
    temp = imrotate(img, theta(i), 'bilinear', 'crop');
    sum_vec(i,:) = sum(temp, 1);
    
    new = imrotate(new, -1, 'bilinear', 'crop') + sum_vec(i,:);
    
end

imshow(sum_vec,[]);
new = mat2gray(new)/256;
figure, imshow(new,[]);