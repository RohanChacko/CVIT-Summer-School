im_brain = double(niftiread('../CVIT_workshop_medical_image/Brats data/Brats18_2013_24_1_t1.nii'));
im_tumor = double(niftiread('../CVIT_workshop_medical_image/Brats data/Brats18_2013_24_1_seg.nii'));

% Variable declaration
k = 3;                                                                     % Clusters
threshold = 1e-10;
delta = intmax;                                                            
restarts = 10;                                                             % Random restarts
res = 0;
least_error = intmax;

data_points = im_brain;
cluster_val = zeros(size(im_brain));

% Vector initialisation
new = zeros(k,3);
best_cluster = cluster_val;
best_center = new;
error = zeros(size(im_brain));

while res < restarts
    
    initial = floor(100*rand(k,3));
    
    while delta > threshold

        for i = 1:size(im_brain,1)
            for j = 1:size(im_brain,2)

            [error(i,j,:) ,cluster_val(i,j,:)] = min((vecnorm((data_points(initial) - data_points(i,j))'))');
            
            end
        end

        for i = 1:k

            [r,c,v] = ind2sub(size(data_points),find(data_points == i));
            ind = cat(2,r,c,v);
            if length(ind) ~= 0
%                 size(data_points(ind))
                new(i,1) = mean(data_points(ind,1));
                new(i,2) = mean(data_points(ind,2));  
                new(i,3) = mean(data_points(ind,3));  
            end
        end

        delta = double(max(new - initial));
        initial = new;
    end
    
    if least_error > sum(error)
        best_cluster = cluster_val;
        least_error = sum(error);
        best_center = initial;
    end
    res = res + 1;
end

find(best_cluster ~= 1)
% for i = 1:length(best_cluster)
%     [r,c,v] = ind2sub(size(data_points),find(data_points == i));
%     ind = cat(2,r,c,v);
%     data_points(ind) = 100;
%     
% end