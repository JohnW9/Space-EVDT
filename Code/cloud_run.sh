#!/bin/bash

#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --partition=xeon-p8

# Run the script
cd /home/gridsan/jsmith/Repos/Space-EVDT/Code
matlab -nodisplay -singleCompThread -r "Cloud_computing2; exit"
