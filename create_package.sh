#!/bin/bash

cur_dir=$(realpath $(dirname $0))

if [ "$1" = "" ]
then
   echo "Version is needed"
   exit 1
fi

version=$1

set -x 

# clean up
rm -rf tmp

# Step 1: Create tmp directory
mkdir -p tmp 


# Step 2: Clone bts-ce repo in tmp directory
cd tmp 
git clone --recurse-submodules https://github.com/bodastage/bts-ce.git

cd bts-ce 

# fix windows newlines
dos2unix db/setup/create_bts_database.sh
dos2unix queue_scripts/queue_setup.sh

CM_DATA_DIR=mediation

# Create reports folder
mkdir -p mediation/data/reports


#Step 3: Create the cm data folders for supported vendors 
# create mediation directories 
CM_DATA_DIR=mediation/data/cm

mkdir -p $CM_DATA_DIR
mkdir -p $CM_DATA_DIR/{ericsson,huawei,nokia,zte}/{in,out,parsed,raw}

# Ericsson
mkdir -p $CM_DATA_DIR/ericsson/{raw,parsed}/{bulkcm,eaw,cnaiv2,backup}

#Huawei
mkdir -p $CM_DATA_DIR/huawei/{raw,parsed}/{gexport,nbi,mml,cfgsyn,rnp,backup}

#ZTE
mkdir -p $CM_DATA_DIR/zte/{raw,parsed}/{bulkcm,xls,backup}

#Nokia
mkdir -p $CM_DATA_DIR/nokia/{raw,parsed}/{raml2,backup}


# API Service
# ------------------------
mv bts-ce-api api

# Remove git artificats 
rm -rf api/.git
rm -rf api/.gitignore

# Database Service
# ------------------------
mv bts-ce-database database 
rm -rf database/.git
rm -rf database/.gitignore
rm -rf database/.idea


# Web Client Service
# -----------------------------
mv bts-ce-web web 
rm -rf web/.git
rm -rf web/.gitignore

# build 
#cd web 
#npm install
#npm run build
#for f in `ls -1 | grep -v dist`
#do
#	rm -rf $f
#done 
#
#cp -r dist/* ./ 
#
#rm -rf dist
#cd ..

# Docs 
# ----------------------
mv bts-ce-docs docs 
rm -rf docs/.git
rm -rf docs/.gitignore

cd docs 

mkdir -p html
sphinx-build . html 

#mkdir -p latex
#sphinx-build -b latex . latex

for f in `ls -1 | grep -v html`
do
	rm -rf $f
done 

cd ..

# Reports 
# ----------------------
mv bts-ce-reports reports 
rm -rf reports/.git
rm -rf reports/.gitignore

# Update docker-compose.yml
sed -i 's/\.\/bts-ce-api/\.\/api/' docker-compose.yml
sed -i 's/\.\/bts-ce-docs/\.\/docs/' docker-compose.yml
sed -i 's/\.\/bts-ce-web\/dist/\.\/web/' docker-compose.yml
sed -i 's/\.\/bts-ce-database/\.\/database/' docker-compose.yml
sed -i 's/\.\/bts-ce-reports/\.\/reports/' docker-compose.yml

cd $cur_dir/tmp 

# Add version to VERSION file
echo ${version} > ./bts-ce/VERSION

# 
7z a -tzip bts-ce-${version}.zip ./bts-ce/*




