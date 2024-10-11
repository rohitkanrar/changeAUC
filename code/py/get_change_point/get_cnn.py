import tensorflow as tf
from tensorflow.keras.layers import Input, Conv2D, Dense, Flatten, Dropout
from keras.applications.vgg16 import VGG16
from keras.applications.vgg19 import VGG19
from tensorflow.keras.models import Model, Sequential

callback = tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=3, restore_best_weights=True)


def get_vgg16_model(bw=False):
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
    if bw:
        shape = (32, 32, 1)
    else:
        shape = (32, 32, 3)
    model = VGG16(include_top=False, input_shape=shape)
    # mark loaded layers as not trainable
    for layer in model.layers:
        layer.trainable = False
    # add new classifier layers
    flat1 = Flatten()(model.layers[-1].output)
    class1 = Dense(128, activation='relu', kernel_initializer='he_uniform')(flat1)
    output = Dense(1, activation='sigmoid')(class1)
    # define new model
    model = Model(inputs=model.inputs, outputs=output)

    # Change from SGD to Adam since the latter trains faster with adaptive learning rate.
    my_optimizer = tf.keras.optimizers.SGD(learning_rate=0.001, momentum=0.9)
    model.compile(optimizer=my_optimizer, loss='binary_crossentropy', metrics=[tf.keras.metrics.AUC()])
    # model.compile(optimizer="adam", loss='binary_crossentropy', metrics=[tf.keras.metrics.AUC()])
    return model


def get_vgg19_model(bw=False):
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
    if bw:
        shape = (32, 32, 1)
    else:
        shape = (32, 32, 3)
    model = VGG19(include_top=False, input_shape=shape)
    # mark loaded layers as not trainable
    for layer in model.layers:
        layer.trainable = False
    # add new classifier layers
    flat1 = Flatten()(model.layers[-1].output)
    class1 = Dense(128, activation='relu', kernel_initializer='he_uniform')(flat1)
    output = Dense(1, activation='sigmoid')(class1)
    # define new model
    model = Model(inputs=model.inputs, outputs=output)

    # Change from SGD to Adam since the latter trains faster with adaptive learning rate.
    my_optimizer = tf.keras.optimizers.SGD(learning_rate=0.001, momentum=0.9)
    model.compile(optimizer=my_optimizer, loss='binary_crossentropy', metrics=[tf.keras.metrics.AUC()])
    # model.compile(optimizer="adam", loss='binary_crossentropy', metrics=[tf.keras.metrics.AUC()])
    return model