close all;
clear all;

% Variable declaration
N = 125;                                                                   % No. of datapoints
k = 5;                                                                     % Clusters
threshold = 1e-10;
delta = intmax;                                                            
restarts = 10;                                                             % Random restarts
res = 0;
least_error = intmax;

% Dataset creation
data_points = rand(N,2);
data_points(26:50,:) = data_points(1:25,:) + 2;
data_points(51:75,:) = data_points(26:50,:) + 2;
data_points(76:100,:) = data_points(51:75,:) + 2;
data_points(101:125,:) = data_points(76:100,:) + 2;
cluster_val = zeros(1,N);

% Vector initialisation
new = 10*rand(k,2);
best_cluster = cluster_val;
best_center = new;
error = zeros(1,N);

while res < restarts
    
    initial = 2*rand(k,2) + 3.5;
    
    while delta > threshold

        for i = 1:N

            [error(i) ,cluster_val(i)] = min((vecnorm((initial - data_points(i))'))');

        end

        for i = 1:k

            ind = find(cluster_val == i);
            if length(ind) ~= 0
                new(i,1) = mean(data_points(ind,1));
                new(i,2) = mean(data_points(ind,2));       
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


% Plot display
figure('name', 'K-Means Clustering'),
scatter(data_points(find(best_cluster == 1),1), data_points(find(best_cluster == 1),2), 'o')
hold on
scatter(data_points(find(best_cluster == 2),1), data_points(find(best_cluster == 2),2), '*')
scatter(data_points(find(best_cluster == 3),1), data_points(find(best_cluster == 3),2), '+')
scatter(data_points(find(best_cluster == 4),1), data_points(find(best_cluster == 4),2), 'd')
scatter(data_points(find(best_cluster == 5),1), data_points(find(best_cluster == 5),2), 'x')
scatter(best_center(:,1), best_center(:,2), 'r^');
hold off
best_cluster

