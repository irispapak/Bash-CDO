#!/bin/bash/

# This program does the following:

# 1. Selects the period 1990-2008 from the EOBs dataset (0.1) 
# 2. Remaps the EOBs' grid  (0.1) to WRF's grid (0.11)
# 3. Corrects the temperature of EOBs considering height differences 
# 4. Calculate mean monthly values

path=/mnt/meteo/groups/postproc/hindcast_WRF381c_VERGINA/

# loads module Climate Data Operators (CDO)
module load meteo cdo 

cd $path

# mean temperature, maximum temperature, minimum temperature
t_wrf=('T2MEAN' 'T2MAX' 'T2MIN')
temp=('tg' 'tx' 'tn')

######################################################################

# select dates 1990-2008 from EOBS 0.1 regular grid
# --------1--------

for i in 0 1 2 
do

cdo seldate,1990-01-01T00:00,1994-12-31T00:00 eobs_0.1_regular/${temp[$i]}_ens_mean_0.1deg_reg_1980-1994_v19.0e.nc eobs_0.1_regular/eobs_${temp[$i]}_1990-1994.nc
cdo seldate,1995-01-01T00:00,2008-12-31T00:00 eobs_0.1_regular/${temp[$i]}_ens_mean_0.1deg_reg_1995-2010_v19.0e.nc eobs_0.1_regular/eobs_${temp[$i]}_1995-2008.nc
cdo mergetime eobs_0.1_regular/eobs_${temp[$i]}_1990-1994.nc eobs_0.1_regular/eobs_${temp[$i]}_1995-2008.nc eobs_0.1_regular/eobs_${temp[$i]}_1990-2008.nc

done

echo "*************************************************"
echo "Selecting dates 1990-2008 from EOBS 0.1 completed"
echo "*************************************************"    


cd from_wrfxtrm_d02_TEMP/eobs0.1_to_wrf0.11/
mkdir corr_file

export REMAP_EXTRAPOLATE='off'


# Orography Correction File
# --------2--------

# change name of variable HGT to elevation
cdo chvar,HGT,elevation corr_file/orog_WRF_VERGINA_d02.nc corr_file/elev_WRF_d02.nc

# put the grid's information into file
cdo griddes corr_file/elev_ens_0.1deg_reg_v19.0e.nc > corr_file/eobs0.1_reg_grid.txt
cdo griddes corr_file/orog_WRF_VERGINA_d02.nc > corr_file/wrf0.11_rot_grid.txt

# apply landmask
cdo setgrid,corr_file/wrf0.11_rot_grid.txt ../../d02.LANDMASK.nc ../../d02.LANDMASK_grid.nc
cdo ifthen ../../d02.LANDMASK_grid.nc corr_file/elev_WRF_d02.nc corr_file/elev_WRF_d02_mask.nc

# remap EOBs to WRF
cdo remapnn,corr_file/wrf0.11_rot_grid.txt corr_file/elev_ens_0.1deg_reg_v19.0e.nc corr_file/elev_EOBS_0.11_rot_remap.nc

# substract heights (EOBs-WRF)
cdo sub corr_file/elev_EOBS_0.11_rot_remap.nc corr_file/elev_WRF_d02_mask.nc corr_file/diff_elev.nc

# multiply with lapse rate
cdo mulc,0.0065 corr_file/diff_elev.nc corr_file/correction_file.nc

echo "**************************"    
echo "Correction file created" 
echo "**************************"    


cd ..

# WRF
# --------3--------

# merge into one file
cdo mergetime 199*.nc 2*.nc wrf_d02_1990-2008.nc

echo "**************************"
echo "WRF merge complete"
echo "**************************"

cd eobs0.1_to_wrf0.11/

mkdir wrf_d02
mkdir eobs_remap_0.11

# apply landmask
cdo ifthen ../../d02.LANDMASK_grid.nc ../wrf_d02_1990-2008.nc ../wrf_d02_1990-2008_mask.nc


for i in 0 1 2 
do

# select variable
cdo selname,${t_wrf[$i]} ../wrf_d02_1990-2008_mask.nc wrf_d02/wrf_${t_wrf[$i]}.nc
# change name of variable
cdo chvar,${t_wrf[$i]},${temp[$i]} wrf_d02/wrf_${t_wrf[$i]}.nc wrf_d02/wrf_${temp[$i]}_1990-2008.nc
# turn Kelvin to Celcius
cdo subc,273.15 wrf_d02/wrf_${temp[$i]}_1990-2008.nc wrf_d02/wrf_${temp[$i]}_1990-2008_cel.nc       

# remap eobs to wrf
cdo remapnn,corr_file/wrf_0.11_rot_grid.txt ../../eobs_0.1_regular/eobs_${temp[$i]}_1990-2008.nc eobs_remap_0.11/eobs_${temp[$i]}_1990-2008_remap.nc
# add temperature correction 
cdo add corr_file/correction_file.nc eobs_remap_0.11/eobs_${temp[$i]}_1990-2008_remap.nc eobs_remap_0.11/eobs_${temp[$i]}_1990-2008_remap_corr.nc

done

echo "**************************************"
echo "Remapping EOBS into WRF grid complete"
echo "**************************************"

echo "**************************************"
echo "Correcting EOBS file complete"
echo "**************************************"


# Statistics
# --------4--------

mkdir eobs_mean
mkdir wrf_mean

file=('eobs_remap_0.11' 'wrf_d02')
name=('eobs' 'wrf')
extra=('_remap_corr' '_cel')


for k in 0 1
do
for i in 0 1 2
do 

# mean monthly values
cdo monmean ${file[$k]}/${name[$k]}_${temp[$i]}_1990-2008${extra[$k]}.nc ${name[$k]}_mean/${name[$k]}_mon${temp[$i]}_d02.nc
# standard deviation 
cdo monstd1 ${file[$k]}/${name[$k]}_${temp[$i]}_1990-2008${extra[$k]}.nc ${name[$k]}_mean/${name[$k]}_mon${temp[$i]}_std_d02.nc

done
done

echo "**************************"
echo "Monthly values calculated"
echo "**************************"

