
  
       mkdir relax scf_soc scf_nonsoc

       PATH1=$DIR/relax
       PATH2=$DIR/scf_soc
       PATH6=$DIR/scf_nonsoc	

			#--------------------------- DFT Geometric relxation part-------------------------------------#


			scp -r $prefix.relax $PATH1
			#rm -rf $prefix.relax

			cd $PATH1

		$MPIRUN_PW $prefix.relax > relax.out
 

		               	awk '/Begin final coordinates/,/End final coordinates/' relax.out | awk 'NR > 3 { print }' | awk 'NR>2 {print last} {last=$0}' > 1
		               	tail -3 $prefix.relax >> 1
		               	awk '/&CONTROL/,/ATOMIC_POSITIONS/' $prefix.relax | awk 'NR>1 {print last} {last=$0}' >> 2
		               	cat 1 >> 2
		               	sed -i 's/vc-relax/scf/g' 2
		               	sed -i 's/ibrav = '$ibrav'/ibrav = 0/g' 2
				awk '/ntyp/{print;print "                                  force_symmorphic = .TRUE.";next}1' 2 > 3
				awk '/ntyp/{print;print "                                          lspinorb = .TRUE.";next}1' 3 > 4
				awk '/ntyp/{print;print "                                          noncolin = .TRUE.";next}1' 4 > 5
				rm -rf 1 2 3 4 
				mv 5 2
	        		cp -r $prefix.save $PATH2
 				cp -r $prefix.xml $PATH2
	        		cp -r 2 $PATH2
				cp -r $prefix.save $PATH6
				cp -r $prefix.xml $PATH6
 		        	rm -rf 1 2


       		cd $PATH2
	        		mv 2 $prefix.scf.in
				
					
exit;






