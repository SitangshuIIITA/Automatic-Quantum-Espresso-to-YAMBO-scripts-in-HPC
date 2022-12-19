

       mkdir band_structure graph_data

       PATH3=$DIR/nscf
       PATH4=$DIR/bands
       PATH5=$DIR/band_structure
	


			#--------------YAMBO interpolater: DFT  Band Structure Calculations-------------------------#
		
			cd $DIR/graph_data

					mkdir DFT_band_structure

			cd $PATH5

			       		mkdir work
	       		cd $PATH3/$prefix.save
					p2y
			       		scp -r SAVE $PATH5/work

			cd $PATH5/work
				 	yambo
				 	ypp -y -F rmv_symm.in
				 	sed -i 's/#RmAllSymm/RmAllSymm/g' $PATH5/work/rmv_symm.in
				 	ypp -F rmv_symm.in

			cd $PATH5/work/FixSymm
				 	yambo
				 	ypp -s b -V qp -F $prefix.DFT_bands.in

			 #------------------------Reading the k point limits, max valence band, min conduction band from r_setup file-------------#

                                        awk '/Filled Bands/ {print $5}' r_setup > 5
                                        awk -v v=$nv '{print $1 - v, $2}' 5 > 6


                                        awk '/Empty Bands/ {print $5}' r_setup > 7
                                        awk -v v=$nc '{print $1 + v, $2}' 7 > 8
                                        paste --delimiter='|' 6 8 > 9
                                        sed -i 's/$/|/' 9
					sed -i.bak '27s/.*//' $prefix.DFT_bands.in
                                        sed -i.bak '27 r 9' $prefix.DFT_bands.in
                                        sed -i.bak '27d' $prefix.DFT_bands.in
                                        rm -rf 1 2 3 4 5 6 7 8 9  new_file.txt 1new_file.txt *.bak

			#--------------------------Choice of BZ route for DFT band diagram---------------------------------------------#

				 	sed -i 's/NN/BOLTZ/g' 					$prefix.DFT_bands.in
				 	sed -i 's/BANDS_steps= 10/BANDS_steps= 30/g' 		$prefix.DFT_bands.in
			
					sed -i 's/BANDS_path= ""/BANDS_path="'"$bands_path"'"/g'	$prefix.DFT_bands.in
					
			cd $DIR 
					scp -r $prefix.band_route $PATH5/work/FixSymm
			cd $PATH5/work/FixSymm

					sed -i.bak '52s/.*//' $prefix.DFT_bands.in
					cat $prefix.band_route >> $prefix.DFT_bands.in
                                        sed -i.bak '52d' $prefix.DFT_bands.in
					sed -i.bak -e '$a%' $prefix.DFT_bands.in
			
					ypp -F $prefix.DFT_bands.in
				 	rm -rf l_electrons_bnds l_setup

        			 	ypp -F $prefix.DFT_bands.in

				 	mv o.bands_interpolated $prefix.DFT.o.bands_interpolated

				 	scp -r $prefix.DFT.o.bands_interpolated $DIR/graph_data/DFT_band_structure/.
				 	rm -rf  *.bak
	


 #-------------This following lines converts rows with line break ups into multiple columns. Very essential for band structure from QE output-----------#
 #-----------------------------------However it takes a lot of time to convert. Use this if it is strongly required-------------------------------------#

                       	cd $PATH4
				scp -r Bandx.dat.gnu $PATH5/work/FixSymm

			cd $PATH5/work/FixSymm

				mv Bandx.dat.gnu $prefix.Bandx.dat.gnu

			        sed -i 's/^ *//' $prefix.Bandx.dat.gnu

                                sed -i '$ d' $prefix.Bandx.dat.gnu

                                sed -E '/\S/!d;H;g;s/((\n\S+)(\s+)[^\n]*)(.*)\2\3(.*)$/\1\3\5\4/;h;$!d;x;s/.//' $prefix.Bandx.dat.gnu > 1

                                mv 1 $prefix.Bandx.dat.gnu

				scp -r $prefix.Bandx.dat.gnu $DIR/graph_data/DFT_band_structure/.
				
				rm -rf $prefix.Bandx.dat.gnu


exit;
