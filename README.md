This repository contains all the codes used in the following paper titled 
- Kanrar, R., Jiang, F., Cai, Z. (2024+). Model-free Change-point Detection Using Modern Classifiers. 



## Contents

- /code: This folder contains all the R and Python code used in the paper.
- /output: This folder contains the output saved in various steps.
- /data: This folder contains data used in the paper. Data sets are already stored and it can be processed with reproducible code available in the folder. 


## Initial Setups:

- Clone Github Repository:
git clone git@github.com:rohitkanrar/changeAUC.git
cd changeAUC

- Install all required R packages:
source("code/r/requirements.R")

- Create Python Environment
conda create -n "hd_cpd" python=3.7.13
pip install code/py/requirements.txt

