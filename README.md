# Sort-Similarity-Matrix
Code to sort a similarity matrix to make the structure of the data more visible.

When doing analyses over square similarity or distance matrices (e.g., Representational Similarity Analyses in psychology), it's often helpful to visualize the matrix, to get a sense of the structure in the data. For example, visualizing the matrix could reveal whether there seem to be 3 natural clusters or none. However, this only works if the matrix is already sorted in a meaningful way. 

In cases where you don't already know the structure of your data, and therefore don't know the "meaningful" way to sort these matrices, you can take a data-driven approach. Here, I demonstrate how to use k-means clustering to cluster the matrix and then sort it based on those clusters.  
