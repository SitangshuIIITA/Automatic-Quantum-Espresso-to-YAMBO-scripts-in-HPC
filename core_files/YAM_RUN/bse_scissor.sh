 

	mkdir BSE_scissor	
		

       	PATH3=$DIR/nscf
       	PATH5=$DIR/band_structure
       	PATH6=$DIR/GW_folder
       	PATH7=$DIR/BSE_GW
       	PATH8=$DIR/nscf-dg
      	PATH14=$DIR/BSE_scissor

	cd $DIR/graph_data/
		mkdir BSE_scissor_data


	# 1. BSE spectra using inversion solver is computed using the double-grid k points. 
	# 2. Run the double nscf and gw script before this.

		 #-------------------------------BSE + scissor Calculation: Inversion solver--------#

				cd $DIR/database

        					scp -r SAVE $PATH14

				cd $PATH7/Report

        					scp -r r-output_rim_cut_optics_dipoles_bss_bse_em1s $PATH14


				cd $PATH6/Report
						scp -r slope_c.txt slope_v.txt $PATH14


       				cd $PATH14
       						cd SAVE
       						rm -rf ndb.QP
       				cd ..

              					yambo
           					yambo -r -X s -optics b -kernel sex -Ksolver i -V all -F $sci_filename


		#------------------------------COULOMB cut-off & RIM------------------------------#


                                                awk '/Alat factors/ {print $6-1}' r_setup > 1
                                                sed 's/$/|/' 1 > 2
                                                sed '1 s/./0.000000|0.000000|&/' 2 > 3
                                                sed '55s/.*//' $sci_filename > 4
                                                sed '55 r 3' 4 > 5
                                                sed '55d' 5 > 6
                                                mv 6 $sci_filename
                                                rm -rf 1 2 3 4 5

                                                sed -i 's/RandQpts=0/RandQpts=1000000/g'                                $sci_filename
                                                sed -i 's/RandGvec= 1/RandGvec= 100/g'                                  $sci_filename
                                                sed -i 's/CUTGeo= "none"/CUTGeo= "box z"/g'                             $sci_filename

                                                sed -i 's/DBsIOoff= "none"/DBsIOoff= "BS"/g'                            $sci_filename
                                                sed -i 's/DBsFRAGpm= "none"/DBsFRAGpm= "+BS"/g'                         $sci_filename



                #------------------------------CPU parallel structure-----------------------------#


                                                sed -i 's/X_and_IO_CPU= ""/X_and_IO_CPU="'"$x_and_io"'"/g'              $sci_filename
                                                sed -i 's/X_and_IO_ROLEs= ""/X_and_IO_ROLEs= "q g k c v"/g'             $sci_filename

                                                sed -i 's/DIP_CPU= ""/DIP_CPU="'"$dip_cpu"'"/g'                         $sci_filename
                                                sed -i 's/DIP_ROLEs= ""/DIP_ROLEs= "k c v"/g'                           $sci_filename

                                                sed -i 's/BS_CPU= ""/BS_CPU= "'"$bs_cpu"'"/g'                           $sci_filename
                                                sed -i 's/BS_ROLEs= ""/BS_ROLEs= "k eh t"/g'                            $sci_filename

		#---------------------------FFT-GVecs and other Response size block---------------#

                                                sed -i.bak -e '30d'                                                     $sci_filename
                                                sed -i.bak "30i FFTGvecs= $fftgvecs"                                    $sci_filename
                                                
                                                sed -i.bak -e '167d'                                                    $sci_filename
                                                sed -i.bak "167i NGsBlkXs= $ngsblks"                                    $sci_filename

                                                sed -i.bak -e '81d'                                                     $sci_filename
                                                sed -i.bak "81i BSENGBlk= $bsengblk"                                    $sci_filename

                                                sed -i.bak -e '79d'                                                     $sci_filename
                                                sed -i.bak "79i BSENGexx= $bsengexx"                                    $sci_filename


                #----------------------------In-plane electric field directions-------------------#             

                                                sed -i '136s/ 1.000000 | 0.000000 | 0.000000 |/ 1.000000 | 1.000000 | 0.000000 |/g'     $sci_filename
                                                sed -i '177s/ 1.000000 | 0.000000 | 0.000000 |/ 1.000000 | 1.000000 | 0.000000 |/g'     $sci_filename

                #----------------------------Includes el-hole coupling----------------------------#

                                                #sed -i 's/BSEmod= "resonant"/BSEmod= "coupling"/g'                      $sci_filename
                                                #sed -i 's/#WehCpl/WehCpl/g'                                             $sci_filename

		#------------------------Reading the k point limits, max valence band, min conduction band from r_setup file-------------#

						awk '/Filled Bands/ {print $5}' r_setup > 5
                                                awk -v v=$nv '{print $1 - v, $2}' 5 > 6


                                                awk '/Empty Bands/ {print $5}' r_setup > 7
                                                awk -v v=$nc '{print $1 + v, $2}' 7 > 8
                                                paste --delimiter='|' 6 8 > 9
                                                sed -i 's/$/|/' 9
                                                sed -i.bak '116s/.*//' 							$sci_filename
                                                sed -i.bak '116 r 9' 							$sci_filename
                                                sed -i.bak '116d' 							$sci_filename
                                                rm -rf 1 2 3 4 5 6 7 8 9  new_file.txt 1new_file.txt *.bak

                #----------------------Includes photon energy range, W screening bands, writes exciton wavefunctions--------------------#

                                                sed -i '128s/0.00000 | 10.00000 |/0.00000 | 7.00000 |/g'                $sci_filename
                                                sed -i 's/BEnSteps= 100/BEnSteps= 500/g'                                $sci_filename
                                                sed -i 's/#WRbsWF/WRbsWF/g'                                             $sci_filename


		#--------------------Following lines are for scissor input--------------------------------------------------------------#

                                        	awk '/coarse-grid/ {print $6}' r-output_rim_cut_optics_dipoles_bss_bse_em1s > 1
                                        	sed '1d' 1 > 2
                                        
						paste --delimiter='|' slope_c.txt slope_v.txt > 3
						sed -i 's/$/|/' 3		
						paste --delimiter='|' 2 3 > 4

                                                sed '89d' $sci_filename > 5
                                                sed '88 r 4' 5 > 6
						mv 6 $sci_filename
						mv 4 scissor_correction	
						rm -rf 1 2 3 5 


       						$MPIRUN_YAMBO yambo -F $sci_filename -J output -C Report


       		        cd $PATH14/Report

       			                mv o-output.eps_q1_inv_bse $prefix.scissor.o-output.eps_q1_inv_bse
       			                mv o-output.alpha_q1_inv_bse $prefix.scissor.o-output.alpha_q1_inv_bse
       			                mv o-output.jdos_q1_inv_bse $prefix.scissor.o-output.jdos_q1_inv_bse

       				        scp -r $prefix.scissor.o-output.alpha_q1_inv_bse $DIR/graph_data/BSE_scissor_data

exit;
