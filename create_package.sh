#!/bin/bash

cur_dir=$(realpath $(dirname $0))

version='v1.0.23'

set -x 

# clean up
rm -rf tmp

# Step 1: Create tmp directory
mkdir -p tmp 


# Step 2: Clone bts-ce repo in tmp directory
cd tmp 
git clone --recurse-submodules https://github.com/bodastage/bts-ce.git

cd bts-ce 


#Step 3: Create the cm data folders for supported vendors 

# create mediation directories 
MEDIATION_DIR=mediation/data/cm
mkdir -p $MEDIATION_DIR
mkdir -p $MEDIATION_DIR/{ericsson,huawei,nokia,zte}/{in,out,parsed,raw}

# Ericsson
mkdir -p $MEDIATION_DIR/ericsson/{raw,parsed}/{bulkcm,eaw,cnaiv2,backup}

#Huawei
mkdir -p $MEDIATION_DIR/huawei/{raw,parsed}/gexport_{gsm,wcdma,lte,cdma,sran,others}
mkdir -p $MEDIATION_DIR/huawei/{raw,parsed}/nbi_{gsm,umts,lte,sran}
mkdir -p $MEDIATION_DIR/huawei/{raw,parsed}/mml_{gsm,umts,lte}
mkdir -p $MEDIATION_DIR/huawei/{raw,parsed}/cfgsyn
mkdir -p $MEDIATION_DIR/huawei/{raw,parsed}/backup

#ZTE
mkdir -p $MEDIATION_DIR/zte/{raw,parsed}/bulkcm_{gsm,umts,lte}
mkdir -p $MEDIATION_DIR/zte/{raw,parsed}/backup

#Nokia
mkdir -p $MEDIATION_DIR/nokia/{raw,parsed}/raml2_{gsm,umts,lte}
mkdir -p $MEDIATION_DIR/nokia/{raw,parsed}/backup


# API
# ------------------------
mv bts-ce-api api

# Remove git artificats 
rm -rf api/.git
rm -rf api/.gitignore

# Database 
# ------------------------
mv bts-ce-database database 
rm -rf database/.git
rm -rf database/.gitignore
rm -rf database/.idea


# Web 
# -----------------------------
mv bts-ce-web web 
rm -rf web/.git
rm -rf web/.gitignore

# build 
cd web 
npm install
npm run build
for f in `ls -1 | grep -v dist`
do
	rm -rf $f
done 

cp -r dist/* ./ 

rm -rf dist
cd ..

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


# Update docker-compose.yml
sed -i 's/\.\/bts-ce-api/\.\/api/' docker-compose.yml
sed -i 's/\.\/bts-ce-docs/\.\/docs/' docker-compose.yml
sed -i 's/\.\/bts-ce-web\/dist/\.\/web/' docker-compose.yml
sed -i 's/\.\/bts-ce-database/\.\/database/' docker-compose.yml

cd $cur_dir/tmp 

# 
7z a -tzip bts-ce-${version}.zip ./bts-ce/*




