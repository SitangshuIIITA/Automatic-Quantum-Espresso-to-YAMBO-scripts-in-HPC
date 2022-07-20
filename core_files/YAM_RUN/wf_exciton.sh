

       	PATH7=$DIR/BSE_GW
	PATH5=$DIR/graph_data/BSE_GW_SLEPC/
	
#			1. Run first the BSE-GW script: bse-gw.sh			


       			cd $PATH7

  				#-------------Excitonic Oscillator Strength & Amplitude Calculation--------------------------#

               					ypp -F $prefix.ypp_AMPL.in -J output -e a 1
               					sed -i 's/States= "0 - 0"/States= "'"$exciton_states"'"/g' $prefix.ypp_AMPL.in
						sed -i 's/Degen_Step= 0.010000/Degen_Step= 0.00000/g' $prefix.ypp_AMPL.in


               					mpiexec.hydra -ppn 32 -f $DIR/nodes -np 128 ypp -F $prefix.ypp_AMPL.in -J output
						mv o-output.exc_qpt1_amplitude* o-output.exc_qpt1_weights* $PATH5/.	

				#-----------------------------------Excitonic distribution plot------------------------------#

       						ypp -F $prefix.ypp_WF.in -J output  -e w  1
               					sed -i 's/Format= "g"/Format= "x"/g' $prefix.ypp_WF.in
               					sed -i 's/Direction= "1"/Direction= "3"/g' $prefix.ypp_WF.in
               					sed -i '26s/1 | 1 | 1 |/11 | 11 | 1 |/g' $prefix.ypp_WF.in
               					sed -i '29s/0.000000 | 0.000000 | 0.000000 |/0.000000 | 0.000000 | 0.000000 |/g' $prefix.ypp_WF.in
               					sed -i 's/States= "0 - 0"/States= "'"$exciton_states"'"/g' $prefix.ypp_WF.in
               					sed -i 's/Degen_Step= 0.010000/Degen_Step= 0.00000/g' $prefix.ypp_WF.in

               					#mpiexec.hydra -ppn 32 -f $DIR/nodes -np 128 ypp -F $prefix.ypp_WF.in -J output


exit;
