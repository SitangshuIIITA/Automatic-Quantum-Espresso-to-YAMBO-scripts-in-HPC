	

	mkdir HF_folder
		
       	PATH3=$DIR/nscf
       	PATH5=$DIR/band_structure
       	PATH1=$DIR/HF_folder
	PATH2=$DIR/database
	
	# Note: double-grid.ndb is inside the SAVE folder. But this is ineffective in HF computation. However, do not delete this.


			#------------------------------HF Calculation-----------------------------#

		cd $DIR/graph_data
			mkdir HF_band_structure

		cd $PATH2

			scp -r SAVE $PATH1

		cd $PATH1
				yambo	
				yambo -r -x -V par -F $hf_filename

			#----------------------------- COULOMB cut-off & RIM-----------------------#


					awk '/Alat factors/ {print $6-1}' r_setup > 1
					sed 's/$/|/' 1 > 2 
					sed '1 s/./0.000000|0.000000|&/' 2 > 3
					sed '27s/.*//' $hf_filename > 4
					sed '27 r 3' 4 > 5
					sed '27d' 5 > 6
					mv 6 $hf_filename
					rm -rf 1 2 3 4 5
		
					#sed -i.bak '15d'                                                                       	$hf_filename
                                        #sed -i.bak "15i RandGvecW= 1 RL"                                                       	$hf_filename

					#sed -i.bak '14d'                                                       			$hf_filename
                                        #sed -i.bak "14i RIM_W"                                                 			$hf_filename
                                        sed -i 's/RandQpts=0/RandQpts=1000000/g'                              			$hf_filename
                                        sed -i 's/RandGvec= 1/RandGvec= 100/g'                                 			$hf_filename
                                        sed -i 's/CUTGeo= "none"/CUTGeo= "'"$slab"'"/g'                       			$hf_filename


			#-------------------------CPU parallel structure---------------------------#


					sed -i 's/SE_CPU= ""/SE_CPU="'"$se_cpu"'"/g'   						$hf_filename
					sed -i 's/SE_ROLEs= ""/SE_ROLEs= "q qp b"/g'   						$hf_filename

			#-------------------------------HF cut-offs--------------------------------#
					sed -i.bak -e '32d' 									$hf_filename 
					sed -i.bak -e '32d'                                                                     $hf_filename
					
					sed -i.bak "32i EXXRLvcs= $exxrlvecs"							$hf_filename
					sed -i.bak "32i VXCRLvcs= $vxcrlvecs"							$hf_filename


	#-----------Reading the k point limits, max valence band, min conduction band from r_setup file---------------#

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
					sed '35s/.*//' $hf_filename > new_file.txt
					sed '35 r 10' new_file.txt > 1new_file.txt 
					sed '35d' 1new_file.txt > $hf_filename
					rm -rf 1 2 3 4 5 6 7 8 9 10  new_file.txt 1new_file.txt *.bak

					$MPIRUN_YAMBO yambo -F $hf_filename -J output -C Report


			#---------------Hartree-Fock  Band Structure Interpolation Calculations----#

		cd $PATH5/work/FixSymm
					scp -r  $prefix.DFT_bands.in $hf_ypp_bands
					sed -i 's/GfnQPdb= "none"/GfnQPdb= "E < SAVE\/ndb.HF_and_locXC"/g' $PATH5/work/FixSymm/$hf_ypp_bands
		cd $PATH1/output
					scp -r ndb.HF_and_locXC $PATH5/work/FixSymm/SAVE/.
		cd $PATH5/work/FixSymm
					ypp -F $hf_ypp_bands
				        mv o.bands_interpolated $prefix.hf.o.bands_interpolated
				        scp -r $prefix.hf.o.bands_interpolated $DIR/graph_data/HF_band_structure/.
		cd $PATH1/Report
					scp -r o-output.hf r-output_HF_and_locXC_rim_cut $DIR/graph_data/HF_band_structure/.

		cd $DIR/graph_data/HF_band_structure/

					mv o-output.hf $prefix.o-ouput.hf
					mv r-output_HF_and_locXC_rim_cut $prefix.r-output_HF_and_locXC_rim_cut

		cd $PATH5/work/FixSymm/SAVE/
					rm -rf ndb.HF_and_locXC

exit;
