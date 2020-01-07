function [memberships, orders] = sim_showSortedCC_LT(cc, methodFlag, maxClusters, saveDir, kMetric, k_input)
% show a sorted corrcoef matrix
% tkonkle@gmail.com
% 5 june 2013

% Revised by LT 1/2017 to include flag to flip between sorting by PC1 and
% by angle between PC1/2

% inputs:
% - cc: input for a PCA (if methodFlag = 1 or 2, should be a square distance
% or similarity matrix; if methodFlag = 3, should be a raw items-by-voxels 
% matrix)

% - methodFlag: 1 for sorting by 1st PC from PCA done on RDM or RSM; 2 for 
% sorting by angle between 1st and 2nd PC's from PCA done on RDM or RSM; 3
% for sorting by the 1st PC from PCA done on raw/rectangular matrix; 4 for 
% sorting by membership in k-means clustering clusters (I *think* you can 
% do this with either an RDM or a raw input matrix -- but probably better 
% to default to using the raw input matrix when possible).

% - maxClusters: only need if methodFlag == 4; max. number of clusters you
% think is reasonable to look for using k-means

% - saveDir: directory to save the k-means summary figure (only made if not
% specifying a k value, but should still include this in the input if
% that's the case so that the code based on # of inputs doesn't get messed
% up).

% - k_input: optional argument: input a specified k-value rather than using
% the k within the range of maxClusters that has the lowest silhouette
% distance.

% - kMetric: distance metric used for doing k-means, if that's your sorting
% method. Options are 'sqEuclidean' and 'correlation'

% outputs:
% - memberships: only output if used the k-means method. This will allow
% you to label the clusters however you like. Vector of length = # of
% items, with a number between 1 and k for each item (which cluster does it
% belong to?)

% - orders: only output if used the k-means method. Vector of length = # of
% items, referring to position in the list that's been ordered by cluster
% membership. Use this to sort the labels on the matrix visualization
% appropriately.


%--------------------------------------------------------------------------

% % ORIGINAL SORT
% subplot(1,3,1)
% imagesc(cc); axis('square'); title('orig')


if methodFlag == 1 || methodFlag == 2 
    % make sure cc is a square matrix:
    assert(size(cc, 1) == size(cc, 2), 'For this method you must input a square matrix.')
elseif methodFlag == 3
    assert(size(cc, 1) ~= size(cc, 2), 'Make sure youre not inputting an RDM!')
end

% do the PCA:
% if methodFlag = 1 or 2, do PCA on the correlation matrix
% coeff = each column is has the coeffs for each eigenvector
% score = rows are items, each column is the score along that principle
% component

% if methodFlag = 3, do the PCA on the items-by-voxels matrix
% [coeff,score, pcvars,tsquare] = princomp(cc);
[pcs, pc_representations, variance_explained] = pca(cc);
% theoretically princomp() should just be calling pca(), but definitely
% getting different dimensions for score matrix using princomp and pca --
% so for now, just leaving with princomp...
compVariance = variance_explained./sum(variance_explained).*100;
totalVariance = cumsum(compVariance);


if methodFlag == 1
    % SORT BY PC1
    % sort by contribution of first component
    [s si] = sort(pc_representations(:,1));
    % subplot(1,3,2)
    imagesc(cc(si,si)); axis('square'); title('pc1 sort')
    
elseif methodFlag == 2
    % SORT BY PC2/1 angle
    % compute angular order of eigenvector for each item
    eig1 = pcs(:,1);
    eig2 = pcs(:,2);
    ang = atan(eig2./eig1) + pi.*(eig1<=0);
    
    % haven't unfolded yet but check this order:
    % original sort
    [s si] = sort(ang);
    % subplot(1,3,3)
    imagesc(cc(si,si)); axis('square'); title('pc2/1 sort')
    
elseif methodFlag == 3 % method 3
    % sort by PC1 after PCA has been done on the raw/rectangular data:
    [s si] = sort(pc_representations(:,1));
        
    % make an RDM and plot with this sorting:
    dist = squareform(pdist(cc, 'correlation'));
    imagesc(dist(si, si)); axis('square'); title('non-RDM pc1 sort')
    
else % method 4
    if nargin < 6 % didn't specify a k-value
        % do k-means with the lowest k-value from the silhouette helper
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
        
        % save and close it:
        saveFigureHelper(1, saveDir, 'kMeansResults.png');
        close

        % get the cluster memberships for each item:
        memberships = idx{lowK};
        
        disp(['Clustering done with k = ' num2str(lowK) ' based on lowest silhouette distance.']);

    else % specified a k-value
        % run k-means with the specified value
        [idx c] = kmeans(cc, k_input, 'Distance', kMetric, 'display',...
                'final', 'Replicates', 20, 'MaxIter', 500); % using the specific distance metric
        memberships = idx; 

        disp(['Clustering done with k = ' num2str(k_input) ' based on user input.']);
        
    end

    % sort by cluster memberships:
    [s si] = sort(memberships);
    
    % make an RDM and plot with this sorting:
    dist = squareform(pdist(cc, 'correlation'));
    imagesc(dist(si, si)); axis('square'); title('K-means Clustering')
    
    title('sort by k-means clustering')
    orders = si;    
    
end
