import tensorflow as tf
from tensorflow.keras.layers import Input, Conv2D, Dense, Flatten, Dropout
from keras.applications.vgg16 import VGG16
from keras.applications.vgg19 import VGG19
from tensorflow.keras.models import Model, Sequential

callback = tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=3, restore_best_weights=True)


def get_vgg16_model(shape=(32, 32, 3), pre_trained='imagenet', n_layers_dense=128):
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
    model_vgg16 = VGG16(weights=pre_trained, include_top=False, input_shape=shape)
    # mark loaded layers as not trainable
    for layer in model_vgg16.layers:
        layer.trainable = False
    # add new classifier layers
    model = Sequential()
    model.add(model_vgg16)
    model.add(Flatten(name='flatten'))
    model.add(Dense(units=n_layers_dense, activation='relu', kernel_initializer='he_uniform', name='dense'))
    model.add(Dense(units=1, activation='sigmoid', name='output'))
    # Change from SGD to Adam since the latter trains faster with adaptive learning rate.
    my_optimizer = tf.keras.optimizers.SGD(learning_rate=0.001, momentum=0.9)
    model.compile(optimizer=my_optimizer, loss='binary_crossentropy')
    # model.compile(optimizer="adam", loss='binary_crossentropy')
    return model


def get_vgg19_model(shape=(32, 32, 3), pre_trained='imagenet', n_layers_dense=128):
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
    model_vgg19 = VGG19(weights=pre_trained, include_top=False, input_shape=shape)
    # mark loaded layers as not trainable
    for layer in model_vgg19.layers:
        layer.trainable = False
    # add new classifier layers
    model = Sequential()
    model.add(model_vgg19)
    model.add(Flatten(name='flatten'))
    model.add(Dense(units=n_layers_dense, activation='relu', kernel_initializer='he_uniform', name='dense'))
    model.add(Dense(units=1, activation='sigmoid', name='output'))

    # Change from SGD to Adam since the latter trains faster with adaptive learning rate.
    my_optimizer = tf.keras.optimizers.SGD(learning_rate=0.001, momentum=0.9)
    model.compile(optimizer=my_optimizer, loss='binary_crossentropy')
    return model