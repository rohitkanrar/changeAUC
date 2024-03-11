library(reticulate)
pd <- import("pandas")
heatmaps_array <- pd$read_pickle("data/fhv_nyc/heatmaps_color_numeric.pkl")

heatmaps_mat <- apply(heatmaps_array, 1, as.vector)
heatmaps_mat <- t(heatmaps_mat)
saveRDS(heatmaps_mat, "data/fhv_nyc/heatmaps_color_vectorized.RData")
