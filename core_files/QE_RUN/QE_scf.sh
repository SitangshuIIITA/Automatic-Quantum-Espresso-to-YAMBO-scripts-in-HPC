
 
       mkdir nscf 

       PATH2=$DIR/scf_soc
       PATH3=$DIR/nscf
       PATH6=$DIR/scf_nonsoc	
	



			#---------------------------DFT scf-soc calculations-----------------------------------------#

              		cd $PATH2
		        						
			$MPIRUN_PW $prefix.scf.in > scf.out

       	       				cp -r * $PATH3
					cp $prefix.scf.in $PATH6

			#---------------------------DFT scf-non-soc calculations-------------------------------------#

                        cd $PATH6
						
						sed -i '/lspinorb/d' ./$prefix.scf.in
						sed -i '/noncolin/d' ./$prefix.scf.in
						sed -i.bak '/K_POINTS/q' $prefix.scf.in
						sed -i.bak "\$a $kgrid_nonsoc $shifted_grid" $prefix.scf.in
						rm -rf *.bak

			$MPIRUN_PW $prefix.scf.in > scf.out
		
exit;






