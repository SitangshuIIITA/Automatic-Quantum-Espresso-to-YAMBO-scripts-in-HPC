

	mkdir BSE_Tempreature_diago

	PATH14=$DIR/BSE_Tempreature_diago

	cd $DIR/graph_data/

		mkdir BSE_Tempreature_data_diago
	 
	cd $PATH14

		for line in $temp_value
                        do
                                mkdir "BSE-${line}$Kelvin"


#       # 1. BSE spectra using diagonalization solver is computed at different temperatures. 

	#-----------------------------------------------BSE + GW + phonon Calculation: diago solver------------------------------#


						scp -r $DIR/database/SAVE ./BSE-${line}$Kelvin/.

						#scp -r $PATH7/Report/r-output_rim_cut_optics_dipoles_bss_bse_em1s ./BSE-${line}$Kelvin/.

 
                                       cd BSE-${line}$Kelvin
                                               cd SAVE
                                               rm -rf ndb.QP
                                               cd ..
		
		#----------------------------GW + temperature ELPH data merging-----------------------------------------------------#

                                                ypp -qpdb -m -F merge.in
                                                sed '19d' merge.in > 1
                                                mv 1 merge.in
                                                rm -rf 1
                                                sed -i '19i "E" |"+" |"1" |"../../GW_folder/output/ndb.QP" |' merge.in

                                                sed -i '20i "E W" |"+" |"1" |"'"../../ELPH/QP-${line}$Kelvin/qp-${line}$Kelvin/ndb.QP"'" |' merge.in

                                                ypp -F merge.in



                                               yambo
                                               yambo -r -X s -optics b -kernel sex -Ksolver d -V all -F $prefix.BSE-${line}$Kelvin.diago.in
		
				
               #------------------------------COULOMB cut-off & RIM------------------------------#


                                                awk '/Alat factors/ {print $6-1}' r_setup > 1
                                                sed 's/$/|/' 1 > 2
                                                sed '1 s/./0.000000|0.000000|&/' 2 > 3
                                                sed '55s/.*//' $prefix.BSE-${line}$Kelvin.diago.in > 4
                                                sed '55 r 3' 4 > 5
                                                sed '55d' 5 > 6
                                                mv 6 $prefix.BSE-${line}$Kelvin.diago.in
                                                rm -rf 1 2 3 4 5

                                                sed -i 's/RandQpts=0/RandQpts=1000000/g'                                $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i 's/RandGvec= 1/RandGvec= 100/g'                                  $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i 's/CUTGeo= "none"/CUTGeo= "box z"/g'                             $prefix.BSE-${line}$Kelvin.diago.in

                                                sed -i 's/DBsIOoff= "none"/DBsIOoff= "BS"/g'                            $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i 's/DBsFRAGpm= "none"/DBsFRAGpm= "+BS"/g'                         $prefix.BSE-${line}$Kelvin.diago.in



                #------------------------------CPU parallel structure-----------------------------#


                                                sed -i 's/X_and_IO_CPU= ""/X_and_IO_CPU="'"$x_and_io"'"/g'              $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i 's/X_and_IO_ROLEs= ""/X_and_IO_ROLEs= "q g k c v"/g'             $prefix.BSE-${line}$Kelvin.diago.in

                                                sed -i 's/DIP_CPU= ""/DIP_CPU="'"$dip_cpu"'"/g'                         $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i 's/DIP_ROLEs= ""/DIP_ROLEs= "k c v"/g'                           $prefix.BSE-${line}$Kelvin.diago.in

                                                sed -i 's/BS_CPU= ""/BS_CPU= "'"$bs_cpu"'"/g'                           $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i 's/BS_ROLEs= ""/BS_ROLEs= "k eh t"/g'                            $prefix.BSE-${line}$Kelvin.diago.in

               #---------------------------FFT-GVecs and other Response size block---------------#

                                                sed -i.bak -e '30d'                                                     $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i.bak "30i FFTGvecs= $fftgvecs"                                    $prefix.BSE-${line}$Kelvin.diago.in
                                                
                                                sed -i.bak -e '164d'                                                    $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i.bak "164i NGsBlkXs= $ngsblks"                                    $prefix.BSE-${line}$Kelvin.diago.in

                                                sed -i.bak -e '81d'                                                     $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i.bak "81i BSENGBlk= $bsengblk"                                    $prefix.BSE-${line}$Kelvin.diago.in

                                                sed -i.bak -e '79d'                                                     $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i.bak "79i BSENGexx= $bsengexx"                                    $prefix.BSE-${line}$Kelvin.diago.in



                #----------------------------In-plane electric field directions-------------------#             

                                                sed -i '136s/ 1.000000 | 0.000000 | 0.000000 |/ 1.000000 | 1.000000 | 0.000000 |/g'     $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i '174s/ 1.000000 | 0.000000 | 0.000000 |/ 1.000000 | 1.000000 | 0.000000 |/g'     $prefix.BSE-${line}$Kelvin.diago.in

                #----------------------------Includes el-hole coupling----------------------------#

                                                sed -i 's/BSEmod= "resonant"/BSEmod= "coupling"/g'                      $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i 's/#WehCpl/WehCpl/g'                                             $prefix.BSE-${line}$Kelvin.diago.in

		#----------------------------Include Bose Temperature-----------------------------#


						sed -i 's/BoseTemp=-1.000000         eV/BoseTemp='${line}'     K/g' $prefix.BSE-${line}$Kelvin.diago.in							
						sed -i.bak -e '131d'                                                $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i.bak "131i 0.0100000 | 0.0100000 |         eV"                $prefix.BSE-${line}$Kelvin.diago.in

		#---------------------Includes GW + temperature dependent band gap energies--------#

                                                sed -i 's/KfnQPdb= "none"/KfnQPdb= "E W < SAVE\/ndb.QP_merged_1_gw_ppa_el_ph"/g'       $prefix.BSE-${line}$Kelvin.diago.in

               	#------------------------Reading the k point limits, max valence band, min conduction band from r_setup file-------------#

                                                awk '/Filled Bands/ {print $5}' r_setup > 5
                                                awk -v v=$nv '{print $1 - v, $2}' 5 > 6


                                                awk '/Empty Bands/ {print $5}' r_setup > 7
                                                awk -v v=$nc '{print $1 + v, $2}' 7 > 8
                                                paste --delimiter='|' 6 8 > 9
                                                sed -i 's/$/|/' 9
                                                sed -i.bak '116s/.*//' $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i.bak '116 r 9' $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i.bak '116d' $prefix.BSE-${line}$Kelvin.diago.in
                                                rm -rf 1 2 3 4 5 6 7 8 9  new_file.txt 1new_file.txt *.bak

                #----------------------Includes photon energy range, W screening bands, writes exciton wavefunctions--------------------#

                                                sed -i '128s/0.00000 | 10.00000 |/0.00000 | 7.00000 |/g'                $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i 's/BEnSteps= 100/BEnSteps= 500/g'                                $prefix.BSE-${line}$Kelvin.diago.in
                                                sed -i 's/#WRbsWF/WRbsWF/g'                                             $prefix.BSE-${line}$Kelvin.diago.in



                                                $MPIRUN_YAMBO yambo -F $prefix.BSE-${line}$Kelvin.diago.in -J output -C Report


                              	cd Report

                                               mv o-output.alpha_q1_diago_bse $prefix.${line}$Kelvin.o-output.alpha_q1_diago_bse
                                               mv o-output.eps_q1_diago_bse $prefix.${line}$Kelvin.o-output.eps_q1_diago_bse
                                               mv o-output.jdos_q1_diago_bse $prefix.${line}$Kelvin.o-output.jdos_q1_diago_bse



			      	cd $DIR/graph_data/BSE_Tempreature_data_diago

                                                    mkdir BSE-${line}$Kelvin-data

				cd $PATH14/BSE-${line}$Kelvin/Report	
  						    scp -r $prefix.${line}$Kelvin.o-output.alpha_q1_diago_bse $DIR/graph_data/BSE_Tempreature_data_diago/BSE-${line}$Kelvin-data/.	

       				cd ..

						ypp -J output -e s 1

               					mv o-output.exc_qpt1_I_sorted $prefix.${line}$Kelvin.BSE_GW.diago.o-output.exc_qpt1_I_sorted
               					mv o-output.exc_qpt1_E_sorted $prefix.${line}$Kelvin.BSE_GW.diago.o-output.exc_qpt1_E_sorted
						scp -r $prefix.${line}$Kelvin.BSE_GW.diago.o-output.exc_qpt1_E_sorted $DIR/graph_data/BSE_Tempreature_data_diago/BSE-${line}$Kelvin-data/.
						scp -r $prefix.${line}$Kelvin.BSE_GW.diago.o-output.exc_qpt1_I_sorted $DIR/graph_data/BSE_Tempreature_data_diago/BSE-${line}$Kelvin-data/.

						scp -r $DIR/ELPH/QP-${line}$Kelvin/qp-${line}$Kelvin/ndb.elph_gFsq* ./output/.



				cd ..
                        done


exit;
