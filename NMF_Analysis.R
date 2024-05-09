####  1.NMF analysis  
library(Seurat)
library(RcppML)
library(ggplot2)
#### prepare data ####
seurat_spatialObj <- readRDS("seurat_spatialObj.rds")
sce <- as.SingleCellExperiment(seurat_spatialObj)
data <- assay(sce, "logcounts")

#### choose appropriate k ####
# cv_mse <- crossValidate(data, method = "predict", k = 1:10, seed = 123)
# cv_robust <- crossValidate(data, method = "robust", k = 1:10, seed = 123)
# pdf("figures/NMF/NMF_CV.pdf", width = 10, height = 7)
# P1 <-plot(cv_mse) 
# P2 <-plot(cv_robust)
# print(P1+P2)
# dev.off()

#### run NMF ####
model <- RcppML::nmf(data, k = k, L1 = c(0.1,0.1))
w_matrix <- model$w
h_matrix <- model$h
rownames(w_matrix) <- rownames(data)
colnames(h_matrix) <- colnames(data)
write.table(w_matrix, "nmf_w_matrix.xls", sep = "\t", row.names = TRUE, col.names = NA)
write.table(h_matrix, "nmf_h_matrix.xls", sep = "\t", row.names = TRUE, col.names = NA)

####  2.NMF correlation
library(plyr)
library(corrplot)
library(stats)
#### combine NMF modules from all samples ####
all <- join_all(list(sample_list),type='full')

#### each NMF module keeps top n genes ####
top_n_row_names <- apply(all[, -1], 2, function(col) {
  top_indices <- order(col, decreasing = TRUE)[1:n]  
  rownames(all[top_indices, ]) 
})
all_top_n <- all[which(rownames(all) %in% top_n_row_names),]

#### correlation ####
cor_mat = cor(all_top_n, method = "pearson")
p <- corrplot(cor_mat, type = "full", col = rev(COL2('RdBu', 200)), tl.pos = "l",tl.col = "black", tl.srt = 45, order = "hclust", method = "color"
              #,addCoef.col='black'
              )

#### dendrogram ####
corr <- p$corr
method = 'complete'
tree = hclust(as.dist(1 - corr), method = method)
test <- as.dendrogram(tree)
plot(test)
