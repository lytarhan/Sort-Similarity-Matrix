function lowK = findBestK(maxClusters, cc, kMetric)
% Use this function to find the best k-value for use in k-means clustering
% (based on the lowest silhouette distance).

% inputs:
    % - maxClusters: the max # of cluster you want to consider
    % - cc: your data matrix (should be items x features or voxels)
    % - kMetric: distance metric to use with k-means (default =
    % correlation)
    
%--------------------------------------------------------------------------

for k = 1:maxClusters
    % run k-means with this many clusters:
    [idx{k} c{k}] = kmeans(cc, k, 'Distance', kMetric, 'display',...
        'final', 'Replicates', 20, 'MaxIter', 500); % using the specific distance metric
    % distance = default, could also use correlation
    
    % get silhouette distance (separation between clusters):
    [silh{k}] = silhouette(cc, idx{k}, kMetric);
    silhouetteVector(k) = mean(silh{k});
end

% k-value with lowest silhouette distance:
lowK = find(silhouetteVector == min(silhouetteVector));
idxK = idx;
clustersK = c;

% Make silhouette plot visualization?:
figure('Position', [560   530   857   420])
subplot(121)
plot(silhouetteVector, 'k-', 'LineWidth', 3)
xlabel('number of clusters (k)'), ylabel('mean silhouette distance')
title('kmeans - silhouette function')
hold on
plot(lowK, silhouetteVector(lowK), 'r*', 'MarkerSize', 15)

subplot(122)
[silh{lowK},h] = silhouette(cc,idx{lowK}, kMetric);
set(get(gca,'Children'),'FaceColor',[.5 .5 .5])
xlabel('Silhouette Value')
ylabel('Cluster')
title(['kmeans - silouette at k=' num2str(lowK)])
end