
#---------------1. HPC bash headers: Add yours------------#
cat > hpc_header.txt << EOF
#!/bin/bash
#PBS -u sitangshu
#PBS -N sitangshu
#PBS -q core160
#PBS -o out.log
#PBS -l nodes=4:ppn=40
#PBS -j oe
#PBS -V
     cd \$PBS_O_WORKDIR
        module load compilers/intel/parallel_studio_xe_2018_update3_cluster_edition
        module load compilers/gcc-7.5.0
     cat \$PBS_NODEFILE |uniq > nodes
EOF
#--------------------------------------------------------------------------------#
# note: To create a file with special characters (not declared as global variables) like "$" above, use "\" in front of them.



 
