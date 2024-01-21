import tensorflow as tf
import numpy as np
import random, sys
sys.path.insert(0, "./code/py")
from get_change_point.get_change_point_v1 import get_change_point

cifar10 = tf.keras.datasets.cifar10

(x_train, y_train), (x_test, y_test) = cifar10.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

ind_3 = y_train == 3
ind_8 = y_train == 5
seq_ = np.arange(x_train.shape[0])
i3 = random.sample(list(seq_[ind_3[:, 0]]), 500)
i8 = random.sample(list(seq_[ind_8[:, 0]]), 500)

x = x_train[i3 + i8]
# y = np.concatenate((np.zeros(500), np.ones(500)), axis=0)

# print(x.shape)
output = get_change_point(x, classifier="vgg16")
print(output)