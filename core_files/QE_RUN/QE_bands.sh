
 
       PATH4=$DIR/bands
	 


			#------------------------------------QE Band Structure Calculations-------------------------#

			cd $PATH4

					mv $prefix.nscf.in $prefix.bands.in
                                       	sed -i 's/nscf/bands/g' $prefix.bands.in
       					sed -i.bak '/nbnd/d' $prefix.bands.in
       					awk '/ntyp/{print;print"                                              nbnd = 100";next}1' $prefix.bands.in > 1
       					mv 1 $prefix.bands.in
				
					sed -i.bak '/K_POINTS/,$d' $prefix.bands.in
	
					#sed -i.bak '/K_POINTS/q' $prefix.bands.in
					rm -rf 1 *.bak
					scp -r $DIR/$prefix.band_route $PATH4/.


					mv $prefix.band_route $prefix.k_points
					sed -i.bak 's/|//g' $prefix.k_points
					sed -i.bak -s 's/$/50/' $prefix.k_points
					sed -n '$=' $prefix.k_points > 2
					cat $prefix.k_points >> 2
					sed -i.bak '1i\K_POINTS {crystal_b}' 2
					cat 2 >> 1

					cat 1 >> $prefix.bands.in
					rm -rf 1 2 *.bak $prefix.k_points	

			$MPIRUN_Bnds $prefix.bands.in > bands.out
			
cat > $prefix.bandx.in << EOF
&BANDS
  						prefix="$prefix"
  						outdir="."
	  					filband="Bandx.dat"
/
EOF
			$MPIRUN_Bndx $prefix.bandx.in > bandx.out				


cat > $prefix.projwfc.in << EOF
&projwfc
						prefix = '$prefix'
						ngauss=0, degauss=0.016748
						DeltaE = 0.030000
						kresolveddos=.true.
/
EOF

			$MPIRUN_proj $prefix.projwfc.in > projwfc.out

exit;
