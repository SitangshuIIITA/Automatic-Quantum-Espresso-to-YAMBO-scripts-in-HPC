#!/bin/bash
#PBS -u sitangshu
#PBS -N sitangshu
#PBS -q core160
#PBS -o out.log
#PBS -l nodes=4:ppn=40
#PBS -j oe
#PBS -V
     cd $PBS_O_WORKDIR
        module load compilers/intel/parallel_studio_xe_2018_update3_cluster_edition
        module load compilers/gcc-7.5.0
     cat $PBS_NODEFILE |uniq > nodes

cd core_files/QE_VAR
set -a
source ./QE_variables.sh
set +a

cd ../YAM_VAR
set -a
source ./yambo_variables.sh
set +a

cd ..
		sh header_input.sh

cd ./QE_RUN	
		sed -i '1i\\' *.sh
cd ..
 
cd ./YAM_RUN
		sed -i '1i\\' *.sh
cd ..

		sed -n '$=' hpc_header.txt > count
		countvar=$(cat count)

		sed  -i '1 r hpc_header.txt' ./QE_RUN/*.sh
			sed -i -e "1d" ./QE_RUN/*.sh

		sed  -i '1 r hpc_header.txt' ./YAM_RUN/*.sh
                        sed -i -e "1d" ./YAM_RUN/*.sh

		sed  -i '1 r hpc_header.txt' ../work_dir/run.sh
                        sed -i -e "1d" ../work_dir/run.sh
		
		sed  -i '1 r hpc_header.txt' ../work_dir/input_relax.sh
                        sed -i -e "1d" ../work_dir/input_relax.sh

		scp -r $prefix.band_route $prefix.relax ../work_dir/.
		rm -rf scp -r $prefix.band_route $prefix.relax 
cd ..
		rm -rf count

exit;
