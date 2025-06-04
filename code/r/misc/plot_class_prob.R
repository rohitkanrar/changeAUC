library(ggplot2)

file_ <- "output/cifar/3-5/vgg16/cifar_3-5_n_1000_rep_500.pkl"
out <- pd$read_pickle(file_)

dat <-  data.frame(
  x = c(1:350, 1:350),
  y = c(rep(0, 350), rep(1, 350)),
  value = out$pred[1, ]
)
  
a <- ggplot(dat, aes(x = value, y = y, color = factor(y))) +
  geom_point(size = 0.01) +
  scale_color_manual(values = c("#0072B2", "#D55E00"),
                     labels = c("Cat", "Dog")) +
  labs(x = "Estimated Classification Probability", 
       y = "True Classification Probability", 
       title = "Cat vs. Dog", 
       color = "Image") + guides(color = "none") +
  theme(axis.text.x = element_text(size = 10, angle = 0, hjust = 1),
        strip.text = element_text(size = 10))


file_ <- "output/cifar/4-5/vgg16/cifar_4-5_n_1000_rep_500.pkl"
out <- pd$read_pickle(file_)

dat <-  data.frame(
  x = c(1:350, 1:350),
  y = c(rep(0, 350), rep(1, 350)),
  value = out$pred[1, ]
)

b <- ggplot(dat, aes(x = value, y = y, color = factor(y))) +
  geom_point(size = 0.01) +
  scale_color_manual(values = c("#CC79A7", "#D55E00"),
                     labels = c("Deer", "Dog")) +
  labs(x = "Estimated Classification Probability", 
       y = "True Classification Probability", 
       title = "Deer vs. Dog", 
       color = "Image") + guides(color = "none") +
  theme(axis.text.x = element_text(size = 10, angle = 0, hjust = 1),
        strip.text = element_text(size = 10))


file_ <- "output/cifar/4-7/vgg16/cifar_4-7_n_1000_rep_500.pkl"
out <- pd$read_pickle(file_)

dat <-  data.frame(
  x = c(1:350, 1:350),
  y = c(rep(0, 350), rep(1, 350)),
  value = out$pred[1, ]
)

c <- ggplot(dat, aes(x = value, y = y, color = factor(y))) +
  geom_point(size = 0.01) +
  scale_color_manual(values = c("#CC79A7", "#7CAE00"),
                     labels = c("Deer", "Horse")) +
  labs(x = "Estimated Classification Probability", 
       y = "True Classification Probability", 
       title = "Deer vs. Horse", 
       color = "Image") + guides(color = "none") +
  theme(axis.text.x = element_text(size = 10, angle = 0, hjust = 1),
        strip.text = element_text(size = 10))

library(patchwork)

d <- a + b + c + plot_layout(ncol = 3) + theme(axis.title.y = element_blank())
ggsave("output/plots/class_prob_ex.jpg", height = 3, width = 12, units = "in")
