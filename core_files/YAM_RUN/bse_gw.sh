	

 	mkdir BSE_GW


       	PATH3=$DIR/nscf
       	PATH5=$DIR/band_structure
       	PATH6=$DIR/GW_folder
       	PATH7=$DIR/BSE_GW
       	PATH8=$DIR/nscf-dg


	   cd $DIR/graph_data
		mkdir BSE_GW_SLEPC

	# Note: double-grid.ndb is inside the SAVE folder. But this is ineffective in BSE SlepC/diagonalization computation. However, do not delete this.

			#-------------------------------BSE (+GW) Calculation: slepC solver-----------------------------------#
				
				cd $PATH6
						scp -r SAVE output $PATH7	

				#cd $PATH7/output
			
				#		rm -rf ndb.QP ndb.HF_and_locXC	

    				cd $PATH7
              					yambo   
		              			yambo -r -X s -optics b -kernel sex -Ksolver s -V all -F $bse_filename



			#------------------------------COULOMB cut-off & RIM------------------------------#


                                        	awk '/Alat factors/ {print $6-1}' r_setup > 1
                                        	sed 's/$/|/' 1 > 2
                                        	sed '1 s/./0.000000|0.000000|&/' 2 > 3
                                        	sed '55s/.*//' $bse_filename > 4
                                        	sed '55 r 3' 4 > 5
                                        	sed '55d' 5 > 6
                                        	mv 6 $bse_filename
                                        	rm -rf 1 2 3 4 5

                                        	sed -i 's/RandQpts=0/RandQpts=1000000/g'                       		$bse_filename
                                        	sed -i 's/RandGvec= 1/RandGvec= 100/g'                         		$bse_filename
                                        	sed -i 's/CUTGeo= "none"/CUTGeo= "box z"/g'                    		$bse_filename

       						sed -i 's/DBsIOoff= "none"/DBsIOoff= "BS"/g' 				$bse_filename	
       						sed -i 's/DBsFRAGpm= "none"/DBsFRAGpm= "+BS"/g' 			$bse_filename
	             			


			#------------------------------CPU parallel structure-----------------------------#


                                        	sed -i 's/X_and_IO_CPU= ""/X_and_IO_CPU="'"$x_and_io"'"/g'              $bse_filename
                                        	sed -i 's/X_and_IO_ROLEs= ""/X_and_IO_ROLEs= "q g k c v"/g'             $bse_filename

                                        	sed -i 's/DIP_CPU= ""/DIP_CPU="'"$dip_cpu"'"/g'                         $bse_filename
                                        	sed -i 's/DIP_ROLEs= ""/DIP_ROLEs= "k c v"/g'                           $bse_filename

					  	sed -i 's/BS_CPU= ""/BS_CPU= "'"$bs_cpu"'"/g'                           $bse_filename
                                                sed -i 's/BS_ROLEs= ""/BS_ROLEs= "k eh t"/g'                            $bse_filename	


			#---------------------------FFT-GVecs and other Response size block---------------#

						sed -i.bak -e '30d'                                                     $bse_filename
                                        	sed -i.bak "30i FFTGvecs= $fftgvecs"                                   	$bse_filename

						sed -i.bak -e '173d'                                                    $bse_filename
                                        	sed -i.bak "173i NGsBlkXs= $ngsblks"                                    $bse_filename

						sed -i.bak -e '81d'                                                    	$bse_filename
                                                sed -i.bak "81i BSENGBlk= $bsengblk"                                    $bse_filename

						sed -i.bak -e '79d'                                                     $bse_filename
                                                sed -i.bak "79i BSENGexx= $bsengexx"                                    $bse_filename


			#----------------------------In-plane electric field directions-------------------#		
	
	       					sed -i '136s/ 1.000000 | 0.000000 | 0.000000 |/ 1.000000 | 1.000000 | 0.000000 |/g' 	$bse_filename
		       				sed -i '183s/ 1.000000 | 0.000000 | 0.000000 |/ 1.000000 | 1.000000 | 0.000000 |/g' 	$bse_filename

       			#----------------------------Includes el-hole coupling----------------------------#

       						sed -i 's/BSEmod= "resonant"/BSEmod= "coupling"/g' 			$bse_filename
		       				sed -i 's/#WehCpl/WehCpl/g' 						$bse_filename

       			#---------------------Includes GW band gap energies and polarization bands--------#

       						sed -i 's/KfnQPdb= "none"/KfnQPdb= "E < ..\/GW_folder\/output\/ndb.QP"/g'	$bse_filename


		        #------------------------Reading the k point limits, max valence band, min conduction band from r_setup file-------------#

        
						awk '/Filled Bands/ {print $5}' r_setup > 5
                                        	awk -v v=$nv '{print $1 - v, $2}' 5 > 6


                                        	awk '/Empty Bands/ {print $5}' r_setup > 7
                                        	awk -v v=$nc '{print $1 + v, $2}' 7 > 8
                                        	paste --delimiter='|' 6 8 > 9
                                        	sed -i 's/$/|/' 9
                                        	sed -i.bak '116s/.*//' $bse_filename
                                        	sed -i.bak '116 r 9' $bse_filename
                                        	sed -i.bak '116d' $bse_filename
                                        	rm -rf 1 2 3 4 5 6 7 8 9  new_file.txt 1new_file.txt *.bak


       			#----------------------Includes photon energy range, W screening bands, writes exciton wavefunctions--------------------#

       						sed -i '128s/0.00000 | 10.00000 |/0.00000 | 7.00000 |/g' 		$bse_filename
       						sed -i 's/BEnSteps= 100/BEnSteps= 1000/g' 				$bse_filename
		       				sed -i 's/#WRbsWF/WRbsWF/g' 						$bse_filename
                                                sed -i.bak -e '131d'                                                	$bse_filename
                                                sed -i.bak "131i 0.0800000 | 0.0800000 |         eV"                	$bse_filename



       			#-------------------------SLEPC solver: first 15 excitons----------------------------------------------------------------#

						sed -i 's/BSSNEig=0/BSSNEig=15/g' 					$bse_filename
		       				sed -i 's/BSSEnTarget= 0.000000/BSSEnTarget= 2.00/g' 			$bse_filename

		       				$MPIRUN_YAMBO yambo -F $bse_filename -J output -C Report

       			cd $PATH7/Report
       	
       						mv o-output.alpha_q1_slepc_bse $prefix.BSE_GW.o-output.alpha_q1_slepc_bse
       						mv o-output.jdos_q1_slepc_bse $prefix.BSE_GW.o-output.jdos_q1_slepc_bse
       						scp -r $prefix.BSE_GW.o-output.alpha_q1_slepc_bse $prefix.BSE_GW.o-output.jdos_q1_slepc_bse $DIR/graph_data/BSE_GW_SLEPC

       			cd ..
              				    	ypp -J output -e s 1

               					mv o-output.exc_qpt1_I_sorted $prefix.BSE_GW.o-output.exc_qpt1_I_sorted
               					mv o-output.exc_qpt1_E_sorted $prefix.BSE_GW.o-output.exc_qpt1_E_sorted
						scp -r $prefix.BSE_GW.o-output.exc_qpt1_E_sorted $DIR/graph_data/BSE_GW_SLEPC
						scp -r $prefix.BSE_GW.o-output.exc_qpt1_I_sorted $DIR/graph_data/BSE_GW_SLEPC

exit;
