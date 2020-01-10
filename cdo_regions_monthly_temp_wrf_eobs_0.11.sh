#!/bin/bash/

# This program:

# 1. splits Europe into 8 regions
# 2. calculates mean monthly values for each region
# 3. seperates seasons for each region

path=/mnt/meteo/groups/postproc/hindcast_WRF381c_VERGINA/from_wrfxtrm_d02_TEMP

module load meteo cdo 

cd $path/eobs0.1_to_wrf0.11/

# mean temperature, max temperature, minimum temperature
t_wrf=('T2MEAN' 'T2MAX' 'T2MIN')
temp=('tg' 'tx' 'tn')


# Cut regions for EOBS and WRF
# --------1--------

mkdir regions 
mkdir regions/eobs
mkdir regions/wrf

file=('eobs_remap_0.11' 'wrf_d02')
name=('eobs' 'wrf')
extra=('_remap_corr' '_cel')
reg=('BI' 'IP' 'FR' 'ME' 'SC' 'AL' 'MD' 'EA')


for i in 0 1 
do
for j in 0 1 2 
do

# select and cut regions giving latitude-longitude
cdo sellonlatbox,-10,2,50,59 ${file[$i]}/${name[$i]}_${temp[$j]}_1990-2008${extra[$i]}.nc regions/${name[$i]}/BI_${temp[$j]}_${name[$i]}.nc
cdo sellonlatbox,-10,3,36,44 ${file[$i]}/${name[$i]}_${temp[$j]}_1990-2008${extra[$i]}.nc regions/${name[$i]}/IP_${temp[$j]}_${name[$i]}.nc
cdo sellonlatbox,-5,5,44,50 ${file[$i]}/${name[$i]}_${temp[$j]}_1990-2008${extra[$i]}.nc regions/${name[$i]}/FR_${temp[$j]}_${name[$i]}.nc
cdo sellonlatbox,2,16,48,55 ${file[$i]}/${name[$i]}_${temp[$j]}_1990-2008${extra[$i]}.nc regions/${name[$i]}/ME_${temp[$j]}_${name[$i]}.nc
cdo sellonlatbox,5,30,55,70 ${file[$i]}/${name[$i]}_${temp[$j]}_1990-2008${extra[$i]}.nc regions/${name[$i]}/SC_${temp[$j]}_${name[$i]}.nc
cdo sellonlatbox,5,15,44,48 ${file[$i]}/${name[$i]}_${temp[$j]}_1990-2008${extra[$i]}.nc regions/${name[$i]}/AL_${temp[$j]}_${name[$i]}.nc
cdo sellonlatbox,3,25,36,44 ${file[$i]}/${name[$i]}_${temp[$j]}_1990-2008${extra[$i]}.nc regions/${name[$i]}/MD_${temp[$j]}_${name[$i]}.nc
cdo sellonlatbox,16,30,44,55 ${file[$i]}/${name[$i]}_${temp[$j]}_1990-2008${extra[$i]}.nc regions/${name[$i]}/EA_${temp[$j]}_${name[$i]}.nc

done
done

echo "**************************"      
echo "Cutting regions completed"
echo "**************************"      
   

# Statistics
# --------2--------

for i in 0 1 
do

mkdir regions/${name[$i]}_mean

for j in 0 1 2 3 4 5 6 7 
do
for k in 0 1 2
do

# calculate mean monthly values for each region
cdo monmean regions/${name[$i]}/${reg[$j]}_${temp[$k]}_${name[$i]}.nc regions/${name[$i]}_mean/${reg[$j]}_mon${temp[$k]}_${name[$i]}_d02.nc
# seperate seasons for each region
cdo seasmean regions/${name[$i]}_mean/${reg[$j]}_mon${temp[$k]}_${name[$i]}_d02.nc regions/${name[$i]}_mean/${reg[$j]}_seas${temp[$k]}_${name[$i]}_d02.nc

done
done

done

echo "*************************************"
echo "Statistics for each region calculated"
echo "*************************************"
