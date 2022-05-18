#! /bin/csh
#
#PBS -N DAM2D_MOM6 
#PBS -j oe
#PBS -o dam_layer.log
#PBS -W umask=027
#PBS -l application=mom6
#       10*1
#PBS -l select=1:ncpus=128:mpiprocs=10
#PBS -l place=scatter:excl
#PBS -l walltime=00:10:00
#PBS -A ONRDC10855122
#PBS -q debug

set echo
set time = 1
set timestamp
setenv R dambreak_2d
setenv S /p/work1/abozec/MOM6-examples/
mkdir -p ${S}

## get all input files in scratch
cd /p/home/abozec/MOM6-examples_202203/ocean_only/${R}/
setenv DIR layerfile_f0_kv_drag2e-4
mkdir -p ${S}/${R}/${DIR}
mkdir -p ${S}/${R}/${DIR}/INPUT
mkdir -p ${S}/${R}/${DIR}/RESTART

/bin/cp common/* ${S}/${R}/${DIR}
/bin/cp layerfile/MOM_input ${S}/${R}/${DIR}/MOM_input
/bin/cp layerfile/MOM_override ${S}/${R}/${DIR}/MOM_override
/bin/cp layerfile/MOM_memory.h ${S}/${R}/${DIR}/
/bin/cp layerfile/mom6_vgrid.nc ${S}/${R}/${DIR}/INPUT/

/bin/cp layerfile/depth_dambreak_2d_01.nc ${S}/${R}/${DIR}/INPUT/
/bin/cp layerfile/intdepth_dambreak_2d.nc ${S}/${R}/${DIR}/INPUT/

# go to the scratch
cd ${S}/${R}/${DIR}/

## get executables
cp ~/MOM6-examples_202203/build/intel/ocean_hyb_sym/repro/MOM6 ${S}/${R}/${DIR}/
#cp ~/MOM6-examples_202201/MOM6_KH_ETA_DAM ${S}/${R}/${DIR}/MOM6

unset echo
  module restore PrgEnv-intel
  module use --append /p/app/modulefiles
  module load bct-env
  module load cray-pals
#     cray-mpich/8.1.[12] do not work
  module swap cray-mpich/8.1.4
  module load python/3
  module list
  set echo
  lfs setstripe    $S -S 1048576 -i -1 -c  8
set echo
setenv NOMP 0
setenv NMPI 10

if ($NOMP == 0) then
  setenv NOMP 1
endif
setenv OMP_NUM_THREADS           $NOMP
setenv LD_LIBRARY_PATH           /opt/intel/oneapi_2021.1.0.2659/mkl/2021.1.1//lib/intel64/:${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
setenv MPICH_VERSION_DISPLAY     1
setenv MPICH_ENV_DISPLAY         1
setenv MPICH_ABORT_ON_ERROR      1
setenv ATP_ENABLED               1
setenv NO_STOP_MESSAGE           1
setenv OMP_NUM_THREADS 1
#  128 cores per dual-socket node, 16 cores per NUMA node
setenv CPU_NUMA "112-127:48-63:96-111:32-47:80-95:16-31:64-79:0-15"
time mpiexec --mem-bind local --cpu-bind list:$CPU_NUMA -n $NMPI ./MOM6

