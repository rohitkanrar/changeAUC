This repository contains all the codes used in the following paper titled 
- Kanrar, R., Jiang, F., Cai, Z. (2024+). Model-free Change-point Detection Using Modern Classifiers. 



## Contents

- /code: This folder contains all the R and Python code used in the paper.
- /output: This folder contains the output saved in various steps.
- /data: This folder contains data used in the paper. Data sets are already stored and it can be processed with reproducible code available in the folder. 

The following paragraphs outline an overall description of the main sub folders in this repository.

## Contents of /code/r/:

- /generate_data: contains R scripts to simulate high dimensional euclidean data as described in Section 4.1
- /get_change_point: contains R scripts for the main functions to detect single and multiple change points.
- /get_null_quantiles: generate and combine null quantiles for the proposed test statistic. See Table 1 for more details.
- /misc: contains some additional functions, such as calculation of Adjusted Rand Index (ARI), etc.
- /other_methods: contains R implementation of the other methods compared.
- /real_data: contains R scripts to access and process the real data sets used in Section 5.
- /simulation_scripts: contains R scripts used to conduct simulation experiments and Section 4 and to produce visualizations and tables. 
- requirements.R: contains R packages required to install first.

## Contents of /code/py/:

- /generate_data: contains Python scripts to simulate high dimensional euclidean data as described in Section 4.1
- /get_change_point: contains Python scripts for the main functions to detect single and multiple change points.
- /misc: contains some additional functions, such as calculation of Adjusted Rand Index (ARI), generating heat maps for the NYC Taxi Data etc.
- /real_data: contains Python scripts to access and process the real data sets used in Section 5.
- /simulation_scripts: contains Python scripts used to conduct simulation experiments and Section 4 and to produce visualizations and tables. 

## Contents of /data:
- This folder contains processed data sets used in the paper. We also provide reproducible code to access and process the data sets in the /code/real_data folder.

## Contents of /output:
- This folder contains outputs created in the simulation experiemnts and real data analysis. 


## Initial Setups:

- Clone Github Repository:

git clone git@github.com:rohitkanrar/changeAUC.git
cd changeAUC

- Install all required R packages:

source("code/r/requirements.R")

- Create Python Environment:

conda create -n "hd_cpd" python=3.7.13
pip install code/py/requirements.txt

