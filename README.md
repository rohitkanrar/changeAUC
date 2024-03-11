This repository contains all the codes used in the following paper titled 
- Kanrar, R., Jiang, F., Cai, Z. (2024+). Model-free Change-point Detection Using Modern Classifiers. 



## Contents

- `/code`: This folder contains all the R and Python code used in the paper.
- `/output`: This folder contains the output saved in various steps.
- `/data`: This folder contains data used in the paper. Data sets are already stored and it can be processed with reproducible code available in the folder. 
- `.gitattributes`: This file is auto-generated by Git LFS to track large files.
- `.gitignore`: This file is auto-generated by Git to track unnecessary file not added to the repository.
- `changeAUC_exec.sh`: This is an executable file to run all the simulation experiments for euclidean data in Section 4.1 using `changeAUC` method.
- `gSeg_exec.sh`: This is an executable file to run all the simulation experiments for euclidean data in Section 4.1 using `gSeg` method.

The following paragraphs outline an overall description of the main sub folders in this repository.

## Contents of `/code/r/`:

- `/generate_data`: contains R scripts to simulate high dimensional euclidean data as described in Section 4.1
- `/get_change_point`: contains R scripts for the main functions to detect single and multiple change points.
- `/get_null_quantiles`: generate and combine null quantiles for the proposed test statistic. See Table 1 for more details.
- `/misc`: contains some additional functions, such as calculation of Adjusted Rand Index (ARI), etc.
- `/other_methods`: contains R implementation of the other methods compared.
- `/real_data`: contains R scripts to access and process the real data sets used in Section 5.
- `/simulation_scripts`: contains R scripts used to conduct simulation experiments and Section 4 and to produce visualizations and tables. 
- `requirements.R`: contains R packages required to install first.

## Contents of `/code/py/`:

- `/generate_data`: contains Python scripts to simulate high dimensional euclidean data as described in Section 4.1
- `/get_change_point`: contains Python scripts for the main functions to detect single and multiple change points.
- `/misc`: contains some additional functions, such as calculation of Adjusted Rand Index (ARI), generating heat maps for the NYC Taxi Data etc.
- `/real_data`: contains Python scripts to access and process the real data sets used in Section 5.
- `/simulation_scripts`: contains Python scripts used to conduct simulation experiments and Section 4 and to produce visualizations and tables. 

## Contents of `/data`:
- This folder contains processed data sets used in the paper. We also provide reproducible code to access and process the data sets in the `/real_data` folder inside either `/code/r/` or `/code/py/`.

## Contents of `/output`:
- This folder contains outputs created in the real data analysis. Other outputs created in the simulation experiments are omitted due to size limit in the Github repository. 


## Initial Setups:

- Clone Github Repository:

```
git clone git@github.com:rohitkanrar/changeAUC.git
cd changeAUC
```

- Install all required R packages:

```
source("code/r/requirements.R")
```
- Create Python Environment:

```
conda create -n "hd_cpd" python=3.7.13
pip install code/py/requirements.txt
```

## Test Cases:

In the following, we include three test cases to check the validity of empirical results reported in the Section 4 of the paper.

- The following command detects a change point using Random Forest with data generated by the Dense Mean setup with sample size 1000 and dimension 500 over 10 replications. The output will be created and saved in the /output/dense_mean/ folder. We set the seed to 2024 for illustrations only. 

Approximate Time (CPU): 5 seconds.

```
Rscript code/r/simulation_scripts/simulation_changeAUC.R -d 2 -n 1000 -p 500 -r 10 -g "dense_mean" -l "local" -c "RF" -s 2024
```
- The following command performs the same task above but uses a Fully connected neural network (FNN).

Approximate Time (CPU): 30 seconds.

```
python code/py/simulation_scripts/simulation_changeAUC.py -d 2 -n 1000 -p 500 -r 10 -g dense_mean -l local -c FNN -s 2024
```

- The following command detects a change point using vgg16 classifier with a data simulated from the CIFAR10 database. The data includes 500 images of dog followed by 500 images of cat. We replicate the procedure over 10 replication with seed 2024. The output will be created and saved in the /output/cifar/3-5/ folder. Here 3 and 5 refers to the dog and cat respectively as arranged in the CIFAR10 database. 

Approximate Time (CPU): 250 seconds.

```
python code/py/simulation_scripts/simulation_cifar.py -r 10 -n 1000 -g 35 -c VGG16 -l local -s 2024
```
