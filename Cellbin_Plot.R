#### cellbin plot —— two gene modules ####
library(Seurat)
library(ggplot2)
#genelist example
MP10 <- list(c())
MP11 <- list(c())

sc <- readRDS('cellbin.rds')
umap <- as.data.frame(sc@reductions$umap@cell.embeddings)
umap$UMAP_1 <- sc@images$slice1@coordinates$col
umap$UMAP_2 <- sc@images$slice1@coordinates$row*(-1)
sc@reductions$umap@cell.embeddings <- as.matrix(umap)
sample <- 'sample'

#score
sc <- AddModuleScore(sc,features = MP10,name = "MP10")
colnames(sc@meta.data)[length(colnames(sc@meta.data))] <- 'MP10_AddModuleScore'
sc <- AddModuleScore(sc,features = MP11,name = "MP11")
colnames(sc@meta.data)[length(colnames(sc@meta.data))] <- 'MP11_AddModuleScore'

#### data preparation ####
data <- cbind(sc$MP10_AddModuleScore,sc$MP11_AddModuleScore)
data <- as.data.frame(data)
max_1 <- max(data$V1)
min_1 <- min(data$V1)
max_2 <- max(data$V2)
min_2 <- min(data$V2)
maxuse <- 0.6
minuse <- 0.45
#max
data[,1][data[,1] > min_1 + (max_1 - min_1) * maxuse] <- min_1 + (max_1 - min_1) * maxuse
data[,2][data[,2] > min_2 + (max_2 - min_2) * maxuse] <- min_2 + (max_2 - min_2) * maxuse
#min
data[,1][data[,1] < min_1 + (max_1 - min_1) * minuse] <- min_1
data[,2][data[,2] < min_2 + (max_2 - min_2) * minuse] <- min_2
sc$MP10_plot <- data$V1
sc$MP11_plot <- data$V2

#plot
pdf(paste0(sample,'_20X_MP10_MP11_',maxuse,'_',minuse,'.pdf'),40,10)
FeaturePlot(sc,features = c('MP10_plot','MP11_plot'),raster = F,blend = T)+coord_fixed()
dev.off()
