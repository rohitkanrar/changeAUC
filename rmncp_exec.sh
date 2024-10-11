############# POWER SIMULATION RMNCP ############################


Rscript code/r/simulation_scripts/simulation_rmncp.R -d 2 -n 1000 -p 500 -r 500 -g "dense_mean" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 2 -n 1000 -p 500 -r 500 -g "sparse_mean" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 0.1 -n 1000 -p 500 -r 500 -g "dense_cov" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 0.8 -n 1000 -p 500 -r 500 -g "sparse_cov" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 5 -n 1000 -p 500 -r 500 -g "dense_diag_cov" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 5 -n 1000 -p 500 -r 500 -g "sparse_diag_cov" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 1 -n 1000 -p 500 -r 500 -g "dense_moment" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 1 -n 1000 -p 500 -r 500 -g "sparse_moment" -l "pronto" -s 1

Rscript code/r/simulation_scripts/simulation_rmncp.R -d 2 -n 1000 -p 1000 -r 500 -g "dense_mean" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 2 -n 1000 -p 1000 -r 500 -g "sparse_mean" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 0.1 -n 1000 -p 1000 -r 500 -g "dense_cov" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 0.8 -n 1000 -p 1000 -r 500 -g "sparse_cov" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 5 -n 1000 -p 1000 -r 500 -g "dense_diag_cov" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 5 -n 1000 -p 1000 -r 500 -g "sparse_diag_cov" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 1 -n 1000 -p 1000 -r 500 -g "dense_moment" -l "pronto" -s 1
Rscript code/r/simulation_scripts/simulation_rmncp.R -d 1 -n 1000 -p 1000 -r 500 -g "sparse_moment" -l "pronto" -s 1

