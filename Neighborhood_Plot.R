#### After running Neighborhood_Analysis.py
library(ggplot2)
library(circlize)
library(ComplexHeatmap)
library(tidyr)

#### prepare data ####
pre_distance <- read.table('coordinates_distance_w0.4.txt')
distance <- tidyr::spread(test,key = V1,value = V3)
rownames(distance) <- distance[,1]
distance <- distance[,-1]
combine <- distance + t(distance)

#### plot ####
col_fun = colorRamp2(c(min(combine),max(combine)), c("white","#CC0033"))
pdf('nmf_distance_w0.4.pdf',6,6)
Heatmap(combine,
        cluster_columns = T,cluster_rows = T,
        column_title = "NMF distance w0.4",
        row_names_gp = gpar(fontface = 'italic',fontsize = 10),
        row_names_side = 'left',
        border = T,
        rect_gp = gpar(col = "white", lwd = 1),
        column_names_side = 'top',
        column_names_rot = 45,
        col = col_fun,
        width = ncol(combine)*unit(5, "mm"),height = ncol(combine)*unit(5, "mm")
)
dev.off()
