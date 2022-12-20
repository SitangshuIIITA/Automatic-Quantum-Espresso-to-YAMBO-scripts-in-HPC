 

	PATH3=$DIR/nscf
       	PATH5=$DIR/band_structure
       	PATH6=$DIR/GW_folder
       	PATH7=$DIR/BSE_GW
       	PATH8=$DIR/nscf-dg
      	PATH14=$DIR/BSE_Tempreature_diago
      	PATH15=$DIR/graph_data/BSE_Tempreature_data_diago	

	

 
	cd $PATH14

		#---------Exciton Intensity sorting: all positive energies and intensities between & including 0.3 and 1 -----------------------#
	
		for line in $temp_value
                        do
				cd BSE-${line}$Kelvin
	
						awk '(NR>1) && ($1 > 0) && ($2 > 0.3 ) ' $prefix.${line}$Kelvin.BSE_GW.diago.o-output.exc_qpt1_E_sorted > 2  

		#--------------------------List of exciton states which are degenerate by 0.01 eV-----------------------------------------------#

						awk 'NR>1&&($1-prev[1])<=0.01{printf "%d - %d\n",prev[3],$3}{split($0,prev)}' 2 > 3

						    awk '                                                                                     
    							{
        							first[NR]=$1;
        							last[NR]=$NF;
        							row[NR]=$0
    							} 
    						        END{
        							for (i=1; i<=NR; i++) 
            							if (last[i] != first[i+1]) print row[i]
    							   }
 							   ' 3 > exc_states.txt
						mv 2 $prefix.${line}$Kelvin.energy_state_linewidth.txt

						sed -i.bak '1 i #    E [ev]             Strength           Index              W [meV]' $prefix.${line}$Kelvin.energy_state_linewidth.txt
						sed -i.bak '1 i # Exciton Intensity sorting: all positive energies and intensities between & including 0.3 and 1' $prefix.${line}$Kelvin.energy_state_linewidth.txt

						sed -i.bak '1 i # List of exciton states which are degenerate by 0.01 eV' exc_states.txt

						scp -r exc_states.txt exc_states_list.txt
						
						sed 1d exc_states.txt 

						rm -rf 3 *.bak


						while IFS='' read -r states; do

							ypp_ph -e -e -F  exciton_eliash.$line$Kelvin.${states}

							
							sed -i 's/States= "0 - 0"/States= "'"$states"'"/g' 		exciton_eliash.$line$Kelvin.${states}
							sed -i 's/PhStps= 200/PhStps= 1000/g'                           exciton_eliash.$line$Kelvin.${states}
                                               		sed -i 's/PhBroad= 0.010000/PhBroad= 0.0050000/g'               exciton_eliash.$line$Kelvin.${states}
		

							ypp_ph -F  exciton_eliash.$line$Kelvin.${states} -J output
	
													

						cd $PATH14/BSE-${line}$Kelvin
	
								scp -r $prefix.${line}$Kelvin.energy_state_linewidth.txt exc_states_list.txt o-output.g_sq_F* $PATH15/BSE-${line}$Kelvin-data	
				
						done < exc_states.txt



						

				cd ..
                 	done

exit;
