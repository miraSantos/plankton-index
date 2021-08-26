#!/bin/bash
#SBATCH --partition=compute         # Queue selection
#SBATCH --job-name=rac_1       # Job name
#SBATCH --mail-type=END             # Mail events (BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=msantos@whoi.edu  # Where to send mail
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --mem=30gb                   # Job memory request
#SBATCH --time=24:00:00             # Time limit hrs:min:sec
#SBATCH --output=rac_1_%j.log  # Standard output/error
 
pwd; hostname; date
 
module load r/3.6.0                  # Load the python module
 
echo "running rac analysis"
 
python /vortexfs1/scratch/msantos/rac/code/plankton_rac_analysis.R
 
date
