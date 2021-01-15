#final script

## This script is based on the tutorial for multilingual translation provided by the Sockeye 2 toolkit (Hieber, Domhan, and Denkowski, 2020), and contains other parts of code from the Fairseq prepare-multilingual-iwslt17 script, as well as using Moses Scripts for pre and post processing. The code is adapted to fit the needs of my experiment set up, which includes preparing the virtual machine on Google Cloud.


#Setting up the virtual machine, 
sudo apt update
sudo apt upgrade
sudo apt install python3-pip
sudo apt install git virtualenv wget unzip -y

#Assign bucket as local directory
BUCKET=gs://kzl-thesis-project
#Retrieving the sockeye toolkit
gsutil cp $BUCKET/sockeye.zip sockeye.zip
unzip sockeye.zip

#Setting up a virtual environment 
virtualenv -p python3 sockeye3
source sockeye3/bin/activate

#Installing packages, and storing tools to relevant user directory
pip install sockeye mxnet sacrebleu matplotlib mxboard subword-nmt crcmod httplib2
mkdir -p tools
git clone https://github.com/bricksdont/moses-scripts tools/moses-scripts

#Retrieve tag and detagging code posed by Johnson et al. (2017)from sockeye 2
wget https://raw.githubusercontent.com/awslabs/sockeye/sockeye_2/docs/tutorials/multilingual/add_tag_to_lines.py -P tools
wget https://raw.githubusercontent.com/awslabs/sockeye/sockeye_2/docs/tutorials/multilingual/remove_tag_from_translations.py -P tools


## set up GPU ----------------------------------------------------------------------------------------------------------------------

## Installing CUDA

#verify gpu is CUDA capable 
sudo apt-get install pciutils
lspci | grep -i nvidia

#verify supported version of Linux
uname -m && cat /etc/*release

#verify gcc is installed
gcc --version

#Update kernels
#check current version of kernel
uname -r
#update kernels 
sudo apt-get install linux-headers-$(uname -r)

#installing cuda 10.2
#download dependencies
sudo apt-get install software-properties-common

sudo apt-get install build-essential dkms
sudo apt-get install freeglut3 freeglut3-dev libxi-dev libxmu-dev

#cuda installation
wget https://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_440.33.01_linux.run
sudo sh cuda_10.2.89_440.33.01_linux.run
#check installation
nvidia-smi
#setting up cuda path
export PATH=/usr/local/cuda-10.2/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-10.2/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
#check if driver version is loaded
cat /proc/driver/nvidia/version
#final check if cuda is correctly installed
nvcc -V


##setting up CudNN library required for CUDA


#retrieve CuDNN files from bucket (cuDNN files not included in github due to size, publically available to download from https://developer.nvidia.com/rdp/cudnn-archive)
gsutil cp $BUCKET/libcudnn8-samples_8.0.5.39-1+cuda10.2_amd64.deb libcudnn8-samples_8.0.5.39-1+cuda10.2_amd64.deb
gsutil cp $BUCKET/libcudnn8-dev_8.0.5.39-1+cuda10.2_amd64.deb libcudnn8-dev_8.0.5.39-1+cuda10.2_amd64.deb
gsutil cp $BUCKET/libcudnn8_8.0.5.39-1+cuda10.2_amd64.deb libcudnn8_8.0.5.39-1+cuda10.2_amd64.deb

#install cudnn files
sudo dpkg -i libcudnn8_8.0.5.39-1+cuda10.2_amd64.deb
sudo dpkg -i libcudnn8-dev_8.0.5.39-1+cuda10.2_amd64.deb
sudo dpkg -i libcudnn8-samples_8.0.5.39-1+cuda10.2_amd64.deb

#check if CuDNN is properly installed
#copy Cudnn samples to writable path
cp -r /usr/src/cudnn_samples_v8/ $HOME
#go to writable path
cd  $HOME/cudnn_samples_v8/mnistCUDNN
#compile mnistCudnn sample
make clean && make
#run the sample, if properly installed should "test passed"
 ./mnistCUDNN

## final GPU sockeye addtion
gsutil cp $BUCKET/requirements.txt requirements.txt
pip install sockeye --no-deps -r requirements.txt
rm requirements.txt

## GPU Set up completed-------------------------------------------------------------------------------------------------------------------

##data preperation and preprocessing
#downloading and running the script necessary to load in the dataset, and generate the relevant train, valid and test pairs. Dataset not included in github repository because of the size, publicly available to download from https://wit3.fbk.eu/2017-01, dataset was modified to create low-resource context.
gsutil cp $BUCKET/prepare-iwslt17-4.sh tools/prepare-iwslt17-4.sh
bash tools/prepare-iwslt17-4
gsutil cp $BUCKET/run-preproc-4.sh tools/run-preproc-4.sh
bash tools/run-preproc-4.sh

## Training and evaluation
#retrieve different model variants
gsutil cp $BUCKET/trainscriptfinal1.sh tools/trainscriptfinal1.sh
gsutil cp $BUCKET/trainscriptfinal2.sh tools/trainscriptfinal2.sh
gsutil cp $BUCKET/trainscriptfinal3.sh tools/trainscriptfinal3.sh

## run different trainscripts
bash tools/trainscriptfinal1.sh
bash tools/trainscriptfinal2.sh
bash tools/trainscriptfinal3.sh

#The following code translates and evaluates the translations, should be run for every model variant.
#Averaging the best parameters observed during training time
gsutil cp $BUCKET/getbestmodel.sh tools/getbestmodel.sh
bash tools/getbestmodel.sh

#translating the testdata by using the trained model, followed by postprocessing which reverses the preprocessing steps.
gsutil cp $BUCKET/translate-postprocess.sh.sh tools/translate.sh
#setting the detokenizer.perl script as executionable
chmod +x tools/detokenizer.perl
bash tools/translate-postprocess.sh



bash tools/postprocess.sh

#Lastly, the BLEU scores are computed between the translated test data and the original file
gsutil cp $BUCKET/getscoresfinal.sh tools/getscoresfinal.sh
bash tools/getscoresfinal.sh