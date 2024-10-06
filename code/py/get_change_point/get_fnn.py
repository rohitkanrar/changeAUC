import tensorflow as tf
from math import ceil


def get_fnn_model(p, regul_=0.001, hidden_=0.5):
    """
    Input:
    - p: dimension of input sample; int
    - hyper_param: dictionary containing the hyper-parameters of ANN.
                    e.g. {"regularization": 0.001,
                            "no_of_hidden_layer_multiplier": 5}
    Output:
    - compiled model object ready to train.

    Details:
    This is a basic wrapper which returns model.compile object created using tensorflow.

    """
    model = tf.keras.models.Sequential()
    model.add(tf.keras.Input(shape=(p,)))
    model.add(tf.keras.layers.Dense(units=p, activation='relu',
                                    kernel_regularizer=tf.keras.regularizers.L1(regul_)))
    model.add(tf.keras.layers.Dense(units=(ceil(hidden_ * p)), activation='relu',
                                    kernel_regularizer=tf.keras.regularizers.L1(regul_)))
    model.add(tf.keras.layers.Dense(units=(ceil(pow(hidden_, 2) * p)), activation='relu',
                                    kernel_regularizer=tf.keras.regularizers.L1L2(regul_)))
    model.add(tf.keras.layers.Dense(1, activation='sigmoid'))

    # Change from SGD to Adam since the latter trains faster with adaptive learning rate.
    # my_optimizer = tf.keras.optimizers.SGD(learning_rate=0.1)
    # model.compile(optimizer=my_optimizer, loss='binary_crossentropy', metrics=[tf.keras.metrics.AUC()])
    model.compile(optimizer="adam", loss='binary_crossentropy', metrics=[tf.keras.metrics.AUC()])
    return model
