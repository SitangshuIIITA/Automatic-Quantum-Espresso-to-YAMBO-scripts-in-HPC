

       mkdir bands

       PATH3=$DIR/nscf
       PATH4=$DIR/bands	
	


			#---------------------------DFT nscf calculations--------------------------------------------#

		       	cd $PATH3
			       		rm -rf scf.out

			       		mv $prefix.scf.in $prefix.nscf.in
			       		sed -i 's/scf/nscf/g' $prefix.nscf.in
					awk -v var="$NBND" '/ntyp/{print;print var;next}1' $prefix.nscf.in > 1
					mv 1 $prefix.nscf.in
					rm -rf 1
					
			       		sed -i.bak '/K_POINTS/q' $prefix.nscf.in
                                        sed -i.bak "\$a $kgrid $shifted_grid" $prefix.nscf.in
                                        rm -rf *.bak
	
			$MPIRUN_nscf $prefix.nscf.in > nscf.out
					scp -r * $PATH4

exit;
 
