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


	mkdir GW_folder

      	PATH3=$DIR/nscf
       	PATH5=$DIR/band_structure
       	PATH6=$DIR/GW_folder
	

			#-------------------------------GW Calculation-----------------------------------#
	cd $DIR/graph_data
                        mkdir GW_band_structure

	cd $PATH3/$prefix.save
				scp -r SAVE $PATH6

      	cd $PATH6
				yambo	
				yambo -r -x -d -k hartree -p p -g n -V all -F $gw_filename
					
				
			#------------------------------COULOMB cut-off & RIM------------------------------#

	
                                        awk '/Alat factors/ {print $6-1}' r_setup > 1
                                        sed 's/$/|/' 1 > 2
                                        sed '1 s/./0.000000|0.000000|&/' 2 > 3
                                        sed '49s/.*//' $gw_filename > 4
                                        sed '49 r 3' 4 > 5
                                        sed '49d' 5 > 6
                                        mv 6 $gw_filename
                                        rm -rf 1 2 3 4 5

					#sed -i.bak '15d'                                                       $gw_filename
					#sed -i.bak "15i RIM_W"						       $gw_filename
                                        sed -i 's/RandQpts=0/RandQpts=1000000/g'                               $gw_filename
                                        sed -i 's/RandGvec= 1/RandGvec= 100/g'                                 $gw_filename
					#sed -i 's/CUTwsGvec= 0.700000/CUTwsGvec= 20 RL/g'                      $gw_filename
                                        sed -i 's/CUTGeo= "none"/CUTGeo= "box z"/g'                           $gw_filename

			#------------------------------2D Material anisotropy-----------------------------#

					sed -i '91s/ 1.000000 | 0.000000 | 0.000000 |/ -99.000000 | -99.000000 | 0.000000 |/g'  $gw_filename

			#------------------------------Self Consistent GW iteration-----------------------#
	
					sed -i '126s/GWIter=0/GWIter=4/g'  					$gw_filename
	
			#------------------------------HF and respnse size block cut-offs-----------------#
					
					sed -i.bak -e '30d'							$gw_filename
					sed -i.bak "30i FFTGvecs= $fftgvecs"                                    $gw_filename

                                        sed -i.bak -e '55d'                                                     $gw_filename
                                        sed -i.bak -e '55d'                                                     $gw_filename

                                        sed -i.bak "55i EXXRLvcs= $exxrlvecs"                                   $gw_filename
                                        sed -i.bak "55i VXCRLvcs= $vxcrlvecs"                                   $gw_filename

	                                sed -i.bak -e '85d'                                                     $gw_filename
                                        sed -i.bak "85i NGsBlkXp= $ngsblkp"                                     $gw_filename

					sed -i.bak -e '83d' 							$gw_filename
					sed -i.bak "83i 1| $bndsrnxp|" 						$gw_filename	

				 	sed -i.bak -e '118d'                                                    $gw_filename
                                        sed -i.bak "118i 1| $gbndrnge|"                                         $gw_filename


			#------------------------------CPU parallel structure-----------------------------#
					
					sed -i 's/SE_CPU= ""/SE_CPU="'"$se_cpu"'"/g'                            $gw_filename
                                        sed -i 's/SE_ROLEs= ""/SE_ROLEs= "q qp b"/g'                            $gw_filename

					sed -i 's/X_and_IO_CPU= ""/X_and_IO_CPU="'"$x_and_io"'"/g'		$gw_filename
					sed -i 's/X_and_IO_ROLEs= ""/X_and_IO_ROLEs= "q g k c v"/g'   		$gw_filename

					sed -i 's/DIP_CPU= ""/DIP_CPU="'"$dip_cpu"'"/g'				$gw_filename
					sed -i 's/DIP_ROLEs= ""/DIP_ROLEs= "k c v"/g'   			$gw_filename

			
			#------------------------------GW cut-offs----------------------------------------#
					sed -i '94s/XTermKind= "none"/XTermKind= "BG"/g' 			$gw_filename
					sed -i '94s/GTermKind= "none"/GTermKind= "BG"/g' 			$gw_filename
					sed -i '129s/#ExtendOut/ExtendOut/g' 					$gw_filename

	#------------------------Reading the k point limits, max valence band, min conduction band from r_setup file-------------#

					awk '/K-points/ {print $4}' r_setup > 1
                                        sed '1d' 1 > 2
                                        sed '2d' 2 > 3
                                        sed -e 's/^/1|/' 3 > 4
                                        awk '/Filled Bands/ {print $5}' r_setup > 5
                                        awk -v v=$nv '{print $1 - v, $2}' 5 > 6


                                        awk '/Empty Bands/ {print $5}' r_setup > 7
                                        awk -v v=$nc '{print $1 + v, $2}' 7 > 8
                                        paste --delimiter='|' 4 6 8 > 9
                                        sed -i 's/$/|/' 9
                                        sed '/^$/d' 9 > 10 
                                        sed '133s/.*//' $gw_filename > new_file.txt
                                        sed '133 r 10' new_file.txt > 1new_file.txt
                                        sed '133d' 1new_file.txt > $gw_filename
                                        rm -rf 1 2 3 4 5 6 7 8 9 10  new_file.txt 1new_file.txt *.bak

					$MPIRUN_YAMBO yambo -F $gw_filename -J output -C Report
					

			cd Report					 

					sed '/#/d' o-output.qp > 1
					awk '{print $3 "\t \t" $4}' 1 > 2
					sort -n 2 >3 
					awk '$2 !~ /^-/{print $0}' 3 > GW_positiveE.txt
					awk '$2  ~ /^-/{print $0}' 3 > 4
					sort -n 4 > GW_negativeE.txt
					rm -rf 1 2 3 4
					
			cd $DIR
					scp -r lin_reg.py $PATH6/Report
					
			cd $PATH6/Report

					python lin_reg.py					




			#-------------------------GW Band Structure Interpolation Calculations--------------#

		cd $PATH5/work/FixSymm
					scp -r  $prefix.DFT_bands.in $gw_ypp_bands
					sed -i 's/GfnQPdb= "none"/GfnQPdb= "E < SAVE\/ndb.QP"/g' $PATH5/work/FixSymm/$gw_ypp_bands
		cd $PATH6/output
					scp -r ndb.QP $PATH5/work/FixSymm/SAVE/.
		cd $PATH5/work/FixSymm
					ypp -F $gw_ypp_bands
				        mv o.bands_interpolated $prefix.GW.o.bands_interpolated
				        scp -r $prefix.GW.o.bands_interpolated $DIR/graph_data/GW_band_structure/.
		cd $PATH6/Report
					scp -r o-output.qp r-output_HF_and_locXC_gw0_dyson_rim_cut_em1d_ppa $DIR/graph_data/GW_band_structure/.

		cd $DIR/graph_data/GW_band_structure/
					mv o-output.qp $prefix.GW.o-output.qp
					mv r-output_HF_and_locXC_gw0_dyson_rim_cut_em1d_ppa $prefix.r-output_HF_and_locXC_gw0_dyson_rim_cut_em1d_ppa

		cd $PATH5/work/FixSymm/SAVE/
					rm -rf ndb.QP









exit;
