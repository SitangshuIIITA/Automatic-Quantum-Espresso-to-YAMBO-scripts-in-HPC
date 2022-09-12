
 
	mkdir exc_disp 

      	PATH5=$DIR/band_structure
      	PATH7=$DIR/BSE_GW
     	PATH15=$DIR/exc_disp	
      
	cd $DIR/graph_data/
		mkdir exciton_disp_data



                     	#-------------------------------Exciton dispersion using BSE (+GW) Calculation: slepC solver-----------------------------------#

                                cd $DIR/database
                                                scp -r SAVE $PATH15

                                cd $PATH7/Report

                                                scp -r r-output_rim_cut_optics_dipoles_bss_bse_em1s $PATH15


                              	cd $PATH15

                                                yambo
                                                yambo -r -X s -optics b -kernel sex -Ksolver s -V all -F $exc_disp_filename


		  	#------------------------------COULOMB cut-off & RIM------------------------------#


                                                awk '/Alat factors/ {print $6-1}' r_setup > 1
                                                sed 's/$/|/' 1 > 2
                                                sed '1 s/./0.000000|0.000000|&/' 2 > 3
                                                sed '55s/.*//' $exc_disp_filename > 4
                                                sed '55 r 3' 4 > 5
                                                sed '55d' 5 > 6
                                                mv 6 $exc_disp_filename
                                                rm -rf 1 2 3 4 5

                                                sed -i 's/RandQpts=0/RandQpts=1000000/g'                                $exc_disp_filename
                                                sed -i 's/RandGvec= 1/RandGvec= 100/g'                                  $exc_disp_filename
                                                sed -i 's/CUTGeo= "none"/CUTGeo= "box z"/g'                             $exc_disp_filename

                                                sed -i 's/DBsIOoff= "none"/DBsIOoff= "BS"/g'                            $exc_disp_filename
                                                sed -i 's/DBsFRAGpm= "none"/DBsFRAGpm= "+BS"/g'                         $exc_disp_filename

                        #------------------------------CPU parallel structure-----------------------------#


                                                sed -i 's/X_and_IO_CPU= ""/X_and_IO_CPU="'"$x_and_io"'"/g'              $exc_disp_filename
                                                sed -i 's/X_and_IO_ROLEs= ""/X_and_IO_ROLEs= "q g k c v"/g'             $exc_disp_filename

                                                sed -i 's/DIP_CPU= ""/DIP_CPU="'"$dip_cpu"'"/g'                         $exc_disp_filename
                                                sed -i 's/DIP_ROLEs= ""/DIP_ROLEs= "k c v"/g'                           $exc_disp_filename

                                                sed -i 's/BS_CPU= ""/BS_CPU= "'"$bs_cpu"'"/g'                           $exc_disp_filename
                                                sed -i 's/BS_ROLEs= ""/BS_ROLEs= "k eh t"/g'                            $exc_disp_filename


			#---------------------------FFT-GVecs and other Response size block---------------#

                                                sed -i.bak -e '30d'                                                     $exc_disp_filename
                                                sed -i.bak "30i FFTGvecs= $fftgvecs"                                    $exc_disp_filename

                                                sed -i.bak -e '173d'                                                    $exc_disp_filename
                                                sed -i.bak "173i NGsBlkXs= $ngsblks"                                    $exc_disp_filename

                                                sed -i.bak -e '81d'                                                     $exc_disp_filename
                                                sed -i.bak "81i BSENGBlk= $bsengblk"                                    $exc_disp_filename

                                                sed -i.bak -e '79d'                                                    	$exc_disp_filename
                                                sed -i.bak "79i BSENGexx= $bsengexx"                                    $exc_disp_filename


                        #-------------------------Excitonic disperison correction-------------------------#


			                        awk '/IBZ Q-points/ {print $4}' r_setup > 1
                                                echo '1' >> 2
                                                paste --delimiter='|' 2 1 > 3
						sed -i 's/$/|/' 3
                                                sed '113s/.*//' $exc_disp_filename > new_file.txt
                                                sed '113 r 3' new_file.txt > 1new_file.txt
                                                sed '113d' 1new_file.txt > $exc_disp_filename
                                                rm -rf 1 2 3 4 new_file.txt 1new_file.txt


			#----------------------------In-plane electric field directions-------------------#             

                                                sed -i '136s/ 1.000000 | 0.000000 | 0.000000 |/ 1.000000 | 1.000000 | 0.000000 |/g'     $exc_disp_filename
                                                sed -i '183s/ 1.000000 | 0.000000 | 0.000000 |/ 1.000000 | 1.000000 | 0.000000 |/g'     $exc_disp_filename	
			

			#---------------------Includes GW band gap energies and polarization bands--------#

                                                sed -i 's/KfnQPdb= "none"/KfnQPdb= "E < ..\/GW_folder\/output\/ndb.QP"/g'   		$exc_disp_filename


                        #---------------------Includes el-hole coupling-----------------------------------#

                                                sed -i 's/BSEmod= "resonant"/BSEmod= "coupling"/g'                                     $exc_disp_filename
                                                sed -i 's/#WehCpl/WehCpl/g'                                                            $exc_disp_filename



			#------------------------Reading the k point limits, max valence band, min conduction band from r_setup file-------------#


						awk '/Filled Bands/ {print $5}' r_setup > 5
                                                awk -v v=$nv '{print $1 - v, $2}' 5 > 6


                                                awk '/Empty Bands/ {print $5}' r_setup > 7
                                                awk -v v=$nc '{print $1 + v, $2}' 7 > 8
                                                paste --delimiter='|' 6 8 > 9
                                                sed -i 's/$/|/' 9
                                                sed -i.bak '116s/.*//' $exc_disp_filename
                                                sed -i.bak '116 r 9' $exc_disp_filename
                                                sed -i.bak '116d' $exc_disp_filename
                                                rm -rf 1 2 3 4 5 6 7 8 9  new_file.txt 1new_file.txt *.bak


			#----------------------Includes photon energy range, W screening bands, writes exciton wavefunctions--------------------#

                                                sed -i '128s/0.00000 | 10.00000 |/0.00000 | 7.00000 |/g'                $exc_disp_filename
                                                sed -i 's/BEnSteps= 100/BEnSteps= 500/g'                                $exc_disp_filename
                                                sed -i 's/#WRbsWF/WRbsWF/g'                                             $exc_disp_filename

			#-------------------------SLEPC solver: first 5 excitons----------------------------------------------------------------#

                                                sed -i 's/BSSNEig=0/BSSNEig=5/g'                                        $exc_disp_filename
                                                sed -i 's/BSSEnTarget= 0.000000/BSSEnTarget= 2.00/g'                    $exc_disp_filename

						
					$MPIRUN_YAMBO yambo -F $exc_disp_filename -J output -C Report
       					
			cd $DIR/graph_data/

						mkdir exciton_disp_data

       		cd $PATH15/Report
       					scp -r o-output.alpha* $DIR/graph_data/exciton_disp_data/

       		#-------------------------Excitonic dispersion-------------------------------#

       		cd $PATH15

                                       ypp -e i -F $prefix.ypp_exciton_disp.in

       						sed -i '18s/INTERP_mode= "NN"/INTERP_mode= "BOLTZ"/g'                          $prefix.ypp_exciton_disp.in
                                                       sed -i '19s/INTERP_Shell_Fac= 20.00000 /INTERP_Shell_Fac= 50.00000 /g'  $prefix.ypp_exciton_disp.in
                                                       sed -i '21s/BANDS_steps= 10/BANDS_steps= 100/g'                         $prefix.ypp_exciton_disp.in
                                                       sed -i 's/States= "0 - 0"/States="'"$exciton_states"'"/g'               $prefix.ypp_exciton_disp.in

                                                       awk '/Grid dimensions/ {print $4*3}' r_setup > 1
                                                       kcountvar=$(cat 1)
                       #--The following 2 lines are showing interpolation error in ypp calculation.-------------#
                                                       sed -i '26s/-1 |-1 |-1 |/'$kcountvar' |'$kcountvar' |1 |/g'             $prefix.ypp_exciton_disp.in
                                                       sed -i '28s/#PrtDOS/PrtDOS/g'                                           $prefix.ypp_exciton_disp.in
                        
       		                                scp -r $DIR/$prefix.band_route /.

                                                       sed -i.bak '35s/.*//'                                                   $prefix.ypp_exciton_disp.in
                                                       cat $prefix.band_route >> $prefix.ypp_exciton_disp.in
                                                       sed -i.bak '35d'                                                        $prefix.ypp_exciton_disp.in
                                                       sed -i.bak -e '$a%'                                                     $prefix.ypp_exciton_disp.in
       						rm -rf 1 *.bak


                                       ypp -F $prefix.ypp_exciton_disp.in -J output

       						mv o-output.excitons_interpolated $prefix.o-output.excitons_interpolated

       						scp -r $prefix.o-output.excitons_interpolated $DIR/graph_data/exciton_disp_data/.





xit;
