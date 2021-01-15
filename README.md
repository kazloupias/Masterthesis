# Masterthesis
The bash script, dataset and modules needed to run for the analysis of my master thesis. Code adopted and modified from the Sockey 2 Multilingual Translation tutorial (Hieber, Domhan, and Denkowski, 2020)

In order to run the experiment, run the finalscriptthesis.sh bash script, which will set up the virtual environment and install the necessary packages, dependencies and drivers for this script to function. This script is written for a virtual machine, pulling files from a bucket on Google Cloud Platform, but can be altered easily to fit a local directory. The bash script is built for Ubuntu 18.04, and assumes a CUDA capable NVIDIA GPU is available to use for training and translating.

