% Leyla Tarhan
% MATLAB R2017b
% 1/2020

% demo for sorting similarity matrices to reveal visible structure. 

% This method could be used to investigate neural, behavioral,
% or observational data. In most cases, you should have access to the raw 
% data matrix (items x observations), then ultimately analyze the 
% similarity or distance matrix calculated over that raw data matrix 
% (referred to here as an 'RDM'). 

% method: 
    % - do k-means clustering on the raw data (not the RDM)
        % - choose a k based on the value that gives you the lowest
        % silhouette distance
    % - make the RDM
    % - sort the RDM by each item's cluster membership (so, all items in
    % cluster 1 come first, then all in cluster 2, etc.). Order within
    % those clusters is just alphabetical.
    
%% Clean up

clear all
close all
clc

%% Set up file structure

addpath('helpers')
saveDir = 'figures';
if ~exist(saveDir, 'dir'); mkdir(saveDir); end

%% Get the raw data

% in this example, the data are in a 120-by-20 matrix, containing ratings 
% along 20 feature dimensions for 120 items.
data = load(fullfile('data', 'exampleData.mat'));
data = data.bp;
size(data)

% how many items should you have?
numItems = 120; 
assert(size(data, 1) == numItems, 'Unexpected data size.')

%% Do k-means to get cluster memberships

% (1) To figure out how many clusters to group the data into (k), run
% k-means at a range of values, then select the k-value with the lowest
% silhouette distance or the value that seems most interpretable:
fprintf('Step1: determine the best k value.\n')
fprintf('..................................\n\n')
maxClusters = 10; % max. # of clusters you want to try using k-means
k_Metric = 'correlation'; % distance metric used by the clustering algorithm
bestK = findBestK(maxClusters, data, k_Metric);
% also outputs a summary figure to visualize these results -- the k with
% the lowest silhouette distance is starred.

% (2) Select a K
% specify the k-value you want:
clc
fprintf('Step2: cluster with the best k value.\n')
fprintf('..................................\n\n')

k = 3; % more interpretable than k = 6, and also associated with a low silhouette distance.
fprintf('Clustering items into %d groups...\n', k);
[memberships, clusterCenters] = kmeans(data, k, 'Distance', k_Metric, 'display', 'final', ...
    'Replicates', 20, 'MaxIter', 500); 
% memberships: which cluster each of the 120 items belongs to
% clusterCenters: profile of feature ratings associated with the items in 
% each cluster

% get the items' original indices in the order of their cluster memberships
[s, order] = sort(memberships); 
% s: cluster for each item, after sorting the items by cluster
% order: order of the items, corresponding to the order in s


%% Make and sort RDM

clc
fprintf('Step3: make and sort the RDM.\n')
fprintf('..................................\n\n')

% make it:
rdm = squareform(pdist(data, 'correlation'));
assert(all(size(rdm) == numItems), 'rdm is the wrong size.')
disp(['Finished making RDM with dimensions = ' num2str(size(rdm, 1)), ' x ', num2str(size(rdm, 2))])

% display it, unsorted and sorted:
figure('Position', [10, 60, 1400, 800], 'Color', [1 1 1]);
colormap('jet');
subplot(1, 2, 1)
imagesc(rdm);
axis square tight off
title('Unsorted RDM')

subplot(1, 2, 2)
imagesc(rdm(order, order));
axis square tight off
title(['RDM sorted by k-means cluster (k = ', num2str(k), ')'])

%% Alternatively, use this helper (more automatic):

figure()
colormap('jet');
clusterMethod = 4; % use k-means rather than the first PC, etc. to sort the RDM
maxClusters = 10; % max. # of clusters you want to try using k-means
k_Metric = 'correlation'; % distance metric used by the clustering algorithm
k_input = 3; % specify a k-value (see alternative way to call this function
% if don't know the ideal k a priori)
[members, order] = sim_showSortedCC_LT(data, clusterMethod, maxClusters, saveDir, k_Metric, k_input);

% to automatically use the k-value with the min. silhouette distance:
% close all
% sim_showSortedCC_LT(data, clusterMethod, maxClusters, saveDir, k_Metric)
% figure()
% imshow(fullfile(saveDir, 'kMeansResults.png'))