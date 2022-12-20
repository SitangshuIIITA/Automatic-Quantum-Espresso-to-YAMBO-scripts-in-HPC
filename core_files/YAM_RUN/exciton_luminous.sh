 

      	PATH5=$DIR/band_structure
      	PATH7=$DIR/BSE_GW
     	PATH15=$DIR/exc_disp	
      
	cd $DIR/graph_data/
		mkdir exciton_luminious


	# Note: Run the BSE for excitons with q/=0 ible-grid.ndb is inside the SAVE folder. But this is ineffective in BSE SlepC/diagonalization computation. However, do not delete this.


      		cd $PATH15
 
                                       	ypp -e i -F $prefix.ypp_exciton_disp.in

       						       sed -i '18s/INTERP_mode= "NN"/INTERP_mode= "BOLTZ"/g'			$prefix.ypp_exciton_disp.in
                                                       sed -i '19s/INTERP_Shell_Fac= 20.00000 /INTERP_Shell_Fac= 50.00000 /g'  	$prefix.ypp_exciton_disp.in
                                                       sed -i '21s/BANDS_steps= 10/BANDS_steps= 100/g'                         	$prefix.ypp_exciton_disp.in
                                                       sed -i 's/States= "0 - 0"/States="'"$exciton_states"'"/g'               	$prefix.ypp_exciton_disp.in

                                                       awk '/Grid dimensions/ {print $4*3}' r_setup > 1
                                                       kcountvar=$(cat 1)
                       #--The following 2 lines are showing interpolation error in ypp calculation.-------------#
#                                                       sed -i '26s/-1 |-1 |-1 |/'$kcountvar' |'$kcountvar' |1 |/g'             $prefix.ypp_exciton_disp.in
#                                                       sed -i '28s/#PrtDOS/PrtDOS/g'                                           $prefix.ypp_exciton_disp.in
                        
       		                                scp -r $DIR/$prefix.band_route /.

                                                       sed -i.bak '35s/.*//'                                                   	$prefix.ypp_exciton_disp.in
                                                       cat $prefix.band_route >> $prefix.ypp_exciton_disp.in
                                                       sed -i.bak '35d'                                                        	$prefix.ypp_exciton_disp.in
                                                       sed -i.bak -e '$a%'                                                     	$prefix.ypp_exciton_disp.in
       						rm -rf 1 *.bak


                                       ypp -F $prefix.ypp_exciton_disp.in -J output

       						mv o-output.excitons_interpolated $prefix.o-output.excitons_interpolated

       						scp -r $prefix.o-output.excitons_interpolated $DIR/graph_data/exciton_disp_data/.





exit;
