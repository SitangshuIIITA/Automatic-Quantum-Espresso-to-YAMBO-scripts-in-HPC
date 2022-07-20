
 
      	mkdir database database_double nscf-dg	
		


       PATH2=$DIR/scf_soc
       PATH3=$DIR/nscf
       PATH8=$DIR/nscf-dg
	
			#-------------------------------nscf-doublegrid calculation-----------------------------------#

				cd $PATH2
        					cp -r * $PATH8
				cd $PATH8
      						rm -rf scf.out
      						mv $prefix.scf.in $prefix.nscf_dg.in
      						sed -i 's/scf/nscf/g' $prefix.nscf_dg.in
						head -n -2 $prefix.nscf_dg.in > 1
						sed -i.bak "\$a $dgkpoint" 1

						awk -v var="$NBND" '/ntyp/{print;print var;next}1' 1 > 2
                                        	mv 2 $prefix.nscf_dg.in
                                        	rm -rf 1 2 *.bak

						$MPIRUN_nscf $prefix.nscf_dg.in > $prefix.nscf_dg.out

			#-------------------------------------Making double grid--------------------------------------#

      				cd $PATH8/$prefix.save
					      	p2y
				      		scp -r SAVE $DIR/database_double/.
					      	yambo
	
				cd $PATH3/$prefix.save
						p2y
						scp -r SAVE $DIR/database/.
           					rm -rf SAVE

				cd $DIR/database	
					      	yambo
				      		ypp -m -F ypp_dg.in
					      	sed -i 's/#SkipCheck/SkipCheck/g' ypp_dg.in
					      	sed -i '22s/"none" |/"..\/database_double" |/g' ypp_dg.in
						ypp -F ypp_dg.in
						yambo

exit
