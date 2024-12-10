import os, random
import numpy as np
from tensorflow.keras.applications.vgg16 import preprocess_input
from tensorflow.keras.preprocessing.image import load_img, img_to_array

def get_file_counts(parent_directory):
  folder_file_counts = {}

  for folder_name in os.listdir(parent_directory):
      folder_path = os.path.join(parent_directory, folder_name)
      
      # Check if it is a directory
      if os.path.isdir(folder_path):
          # Count the number of files in the folder
          file_count = len([f for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f))])
          # Add the count to the dictionary
          folder_file_counts[folder_name] = file_count

  # Print the resulting dictionary
  return folder_file_counts

def get_file_names(label0, label1, file_counts, tau=0.5, fps=12, img_per_sec=2, duration=120, 
                   dir_path='code/py/real_data/monkey_data'):
  dir_0 = dir_path + "/n" + str(label0)
  dir_1 = dir_path + "/n" + str(label1)
  n = fps * duration
  t0 = np.floor(n*tau)
  reps = int(np.ceil(fps / img_per_sec))
  n_unq_img = int(np.ceil(duration * tau * img_per_sec))
  label0_ind = random.choices(np.arange(file_counts['n'+str(label0)]), k = n_unq_img)
  label1_ind = random.choices(np.arange(file_counts['n'+str(label1)]), k = n_unq_img)
  label0_ind = np.repeat(label0_ind, reps)
  label1_ind = np.repeat(label1_ind, reps)
  
  label0_file = os.listdir(dir_0)
  label1_file = os.listdir(dir_1)

  final_file_names = [dir_0 + '/' + label0_file[ii] for ii in label0_ind]
  final_file_names += [dir_1 + '/' + label1_file[ii] for ii in label1_ind]

  return final_file_names

def get_img_array(file_names, target_size=(224, 224, 3)):
  images_array = []

  for file_ in file_names:
    image = load_img(file_, target_size=target_size)
    image_array = img_to_array(image).astype(np.uint8)
    images_array.append(image_array)
  
  images_array = np.array(images_array)
  dataset_array = preprocess_input(images_array)

  return dataset_array