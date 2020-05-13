#!/usr/bin/env bash

set -e

directory=$1
shift;

mkdir -p $directory
cd $directory

# samtools
SAMTOOLS_VERSION=$1
wget https://github.com/samtools/samtools/archive/${SAMTOOLS_VERSION}.zip 
unzip ${SAMTOOLS_VERSION}.zip 
rm ${SAMTOOLS_VERSION}.zip 
cd samtools-${SAMTOOLS_VERSION} 
sed -i 's!\#-m64\s\#-arch\sppc!-m64 -fPIC!' Makefile 
sed -i 's!^\(CFLAGS=.*\)$!\1 -fPIC!g' Makefile 
sed -i 's!^\(DFLAGS=.*\)$!\1 -fPIC!g' Makefile 
make
cd ..

# tabix
TABIX_VERSION=$2
wget -q https://sourceforge.net/projects/samtools/files/tabix/tabix-${TABIX_VERSION}.tar.bz2/download -O tabix-${TABIX_VERSION}.tar.bz2
tar jxf tabix-${TABIX_VERSION}.tar.bz2
rm tabix-${TABIX_VERSION}.tar.bz2
cd tabix-${TABIX_VERSION} 
sed -ir 's/-lz -L. -ltabix/-L. -ltabix -lz/g' Makefile 
make 
chmod -R 755 .
cd ..

# subread
SUBREAD_VERSION=$3
wget -q "https://sourceforge.net/projects/subread/files/subread-${SUBREAD_VERSION}/subread-${SUBREAD_VERSION}-Linux-x86_64.tar.gz/download" -O - | tar zxf -

cd ..
