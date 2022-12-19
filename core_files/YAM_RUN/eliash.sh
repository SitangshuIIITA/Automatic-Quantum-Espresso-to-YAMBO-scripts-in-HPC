

      	PATH1=$DIR/ELPH
	
	cd $DIR/graph_data/
	mkdir Eliash_data QP_Temperature_data

	cd $PATH1


		for line in $temp_value
			do
   				mkdir "QP-${line}$Kelvin"
				scp -r SAVE ./QP-${line}$Kelvin
				cp -r r_setup ./QP-${line}$Kelvin
   				cd QP-${line}$Kelvin
				
		#------------------------------------------Quasi-particle energies calculation-----------------------------------------------------------------#		


					yambo_ph -r -g n -p fan -c ep -V gen -F qp-${line}$Kelvin.in




					#------------------------------COULOMB cut-off & RIM------------------------------#


                                        awk '/Alat factors/ {print $6-1}' r_setup > 1
                                        sed 's/$/|/' 1 > 2
                                        sed '1 s/./0.000000|0.000000|&/' 2 > 3
                                        sed '28s/.*//' qp-${line}$Kelvin.in > 4
                                        sed '28 r 3' 4 > 5
                                        sed '28d' 5 > 6
                                        mv 6 qp-${line}$Kelvin.in
                                        rm -rf 1 2 3 4 5

                                        sed -i 's/RandQpts=0/RandQpts=1000000/g'                               		qp-${line}$Kelvin.in
                                        sed -i 's/RandGvec= 1/RandGvec= 100/g'                                 		qp-${line}$Kelvin.in
                                        sed -i 's/CUTGeo= "none"/CUTGeo= "box z"/g'                           		qp-${line}$Kelvin.in
				
					sed -i 's/BoseTemp=-1.000000         eV/BoseTemp='${line}'   Kn/g'		qp-${line}$Kelvin.in
					sed -i 's/GDamping= 0.100000         eV/GDamping= 0.0200000         eV/g'      	qp-${line}$Kelvin.in
					sed -i 's/   1 | 300 |/   1 | 70 |/g'       					qp-${line}$Kelvin.in
					sed -i 's/#WRgFsq/WRgFsq/g'                                             	qp-${line}$Kelvin.in
                                        sed -i '$a ExtendOut'                                                   	qp-${line}$Kelvin.in

			

					#------------------------Reading the k point limits, max valence band, min conduction band from r_setup file-------------#

                                        awk '/K-points/ {print $4}' r_setup > 1
                                        sed '1d' 1 > 2
                                        sed '2d' 2 > 3
                                        sed -e 's/^/1|/' 3 > 4
                                        awk '/Filled Bands/ {print $5}' r_setup > 5
                                        awk -v v=$nv '{print $1 - v, $2}' 5 > 6


                                        awk '/Empty Bands/ {print $5}' r_setup > 7
                                        awk -v v=$nc '{print $1 + v, $2}' 7 > 8
                                        paste --delimiter='|' 4 6 8 > 9
                                        sed -i 's/$/|/' 9
                                        sed '/^$/d' 9 > 10
                                        sed '43s/.*//' qp-${line}$Kelvin.in > new_file.txt
                                        sed '43 r 10' new_file.txt > 1new_file.txt
                                        sed '43d' 1new_file.txt > qp-${line}$Kelvin.in
                                        rm -rf 1 2 3 4 5 6 7 8 9 10  new_file.txt 1new_file.txt *.bak

					yambo_ph -F qp-${line}$Kelvin.in -J qp-${line}$Kelvin

					mv o-qp-${line}$Kelvin.qp $prefix.o-qp-${line}$Kelvin.qp

					scp -r $prefix.o-qp-${line}$Kelvin.qp $DIR/graph_data/QP_Temperature_data/.
		
		#---------------------------------------------Spectral function calculation: Indirect gap---------------------------------------------------------#



					yambo_ph -r -g g -p fan -c ep -V gen -F sf-${line}$Kelvin.ind_gap.in

					#------------------------------COULOMB cut-off & RIM------------------------------#


                                        awk '/Alat factors/ {print $6-1}' r_setup > 1
                                        sed 's/$/|/' 1 > 2
                                        sed '1 s/./0.000000|0.000000|&/' 2 > 3
                                        sed '28s/.*//' sf-${line}$Kelvin.ind_gap.in > 4
                                        sed '28 r 3' 4 > 5
                                        sed '28d' 5 > 6
                                        mv 6 sf-${line}$Kelvin.ind_gap.in
                                        rm -rf 1 2 3 4 5

                                        sed -i 's/RandQpts=0/RandQpts=1000000/g'                                sf-${line}$Kelvin.ind_gap.in
                                        sed -i 's/RandGvec= 1/RandGvec= 100/g'                                  sf-${line}$Kelvin.ind_gap.in
                                        sed -i 's/CUTGeo= "none"/CUTGeo= "box z"/g'                             sf-${line}$Kelvin.ind_gap.in

                                        sed -i 's/BoseTemp=-1.000000         eV/BoseTemp='${line}'   K/g'      	sf-${line}$Kelvin.ind_gap.in

                                        sed -i 's/GEnSteps= 100/GEnSteps= 500/g'                               	sf-${line}$Kelvin.ind_gap.in
                                        sed -i '$a ExtendOut'                                                   sf-${line}$Kelvin.ind_gap.in

					sed -i.bak -e '42d' 							sf-${line}$Kelvin.ind_gap.in
					sed -i.bak "42i -3| 3|  eV" 						sf-${line}$Kelvin.ind_gap.in

					sed -i.bak -e '45d'                                                     sf-${line}$Kelvin.ind_gap.in
                                        sed -i.bak "45i -0.2| 0.2|  eV"                                         sf-${line}$Kelvin.ind_gap.in

					sed -i 's/   1 | 300 |/   1 | 70 |/g'                                   sf-${line}$Kelvin.ind_gap.in

					#------------------------Reading the k point limits, max valence band, min conduction band from r_setup file-------------#

					awk '/Indirect Gap between kpts/ {print $7}' r_setup > 1
					awk '/Indirect Gap between kpts/ {print $8}' r_setup > 2

					awk '/Filled Bands/ {print $5}' r_setup > 3
					awk '/Empty Bands/ {print $5}' r_setup > 4
					paste --delimiter='|' 1 2 3 4 > 5
					sed -i 's/$/|/' 5

                                        sed '48s/.*//' sf-${line}$Kelvin.ind_gap.in > new_file.txt
                                        sed '48 r 5' new_file.txt > 1new_file.txt
                                        sed '48d' 1new_file.txt > sf-${line}$Kelvin.ind_gap.in
                                        rm -rf 1 2 3 4 5  new_file.txt 1new_file.txt *.bak

					yambo_ph -F sf-${line}$Kelvin.ind_gap.in -J sf-${line}$Kelvin

			

			#---------------------------------------------Spectral function calculation: direct gap-----------------------------------------------------------#

					yambo_ph -r -g g -p fan -c ep -V gen -F sf-${line}$Kelvin.dir_gap.in

                                        #------------------------------COULOMB cut-off & RIM------------------------------#

                                        awk '/Alat factors/ {print $6-1}' r_setup > 1
                                        sed 's/$/|/' 1 > 2
                                        sed '1 s/./0.000000|0.000000|&/' 2 > 3
                                        sed '28s/.*//' sf-${line}$Kelvin.dir_gap.in > 4
                                        sed '28 r 3' 4 > 5
                                        sed '28d' 5 > 6
                                        mv 6 sf-${line}$Kelvin.dir_gap.in
                                        rm -rf 1 2 3 4 5

                                        sed -i 's/RandQpts=0/RandQpts=1000000/g'                                sf-${line}$Kelvin.dir_gap.in
                                        sed -i 's/RandGvec= 1/RandGvec= 100/g'                                  sf-${line}$Kelvin.dir_gap.in
                                        sed -i 's/CUTGeo= "none"/CUTGeo= "box z"/g'                             sf-${line}$Kelvin.dir_gap.in

                                        sed -i 's/BoseTemp=-1.000000         eV/BoseTemp='${line}'   K/g'       sf-${line}$Kelvin.dir_gap.in

                                        sed -i 's/GEnSteps= 100/GEnSteps= 500/g'                                sf-${line}$Kelvin.dir_gap.in
                                        sed -i '$a ExtendOut'                                                   sf-${line}$Kelvin.dir_gap.in

                                        sed -i.bak -e '42d'                                                     sf-${line}$Kelvin.dir_gap.in
                                        sed -i.bak "42i -3| 3|  eV"                                             sf-${line}$Kelvin.dir_gap.in

                                        sed -i.bak -e '45d'                                                     sf-${line}$Kelvin.dir_gap.in
                                        sed -i.bak "45i -0.2| 0.2|  eV"                                         sf-${line}$Kelvin.dir_gap.in

                                        sed -i 's/   1 | 300 |/   1 | 70 |/g'                                   sf-${line}$Kelvin.dir_gap.in

                                        #------------------------Reading the k point limits, max valence band, min conduction band from r_setup file-------------#

                                        awk '/Direct Gap localized at k/ {print $8}' r_setup > 1
                                        awk '/Direct Gap localized at k/ {print $8}' r_setup > 2

                                        awk '/Filled Bands/ {print $5}' r_setup > 3
                                        awk '/Empty Bands/ {print $5}' r_setup > 4
                                        paste --delimiter='|' 1 2 3 4 > 5
                                        sed -i 's/$/|/' 5

                                        sed '48s/.*//' sf-${line}$Kelvin.dir_gap.in > new_file.txt
                                        sed '48 r 5' new_file.txt > 1new_file.txt
                                        sed '48d' 1new_file.txt > sf-${line}$Kelvin.dir_gap.in
                                        rm -rf 1 2 3 4 5  new_file.txt 1new_file.txt *.bak

                                        yambo_ph -F sf-${line}$Kelvin.dir_gap.in -J sf-${line}$Kelvin



					#--------------------------------------------------Eliashberg Function: Indirect gap-------------------------------------#


					ypp_ph -s e -F eliash.${line}$Kelvin.ind.in

					sed -i 's/PhBroad= 0.010000/PhBroad= 0.0010000/g'			eliash.${line}$Kelvin.ind.in
                                        sed -i 's/PhStps= 200/PhStps= 1000/g'					eliash.${line}$Kelvin.ind.in


					awk '/Indirect Gap between kpts/ {print $7}' r_setup > 1
                                        awk '/Indirect Gap between kpts/ {print $8}' r_setup > 2

                                        awk '/Filled Bands/ {print $5}' r_setup > 3
                                        awk '/Empty Bands/ {print $5}' r_setup > 4
                                        paste --delimiter='|' 1 2 3 4 > 5
                                        sed -i 's/$/|/' 5

                                        sed '21s/.*//' eliash.${line}$Kelvin.ind.in > new_file.txt
                                        sed '21 r 5' new_file.txt > 1new_file.txt
                                        sed '21d' 1new_file.txt > eliash.${line}$Kelvin.ind.in

					ypp_ph -F eliash.${line}$Kelvin.ind.in -J qp-${line}$Kelvin
				
					start_k=`cat 1`
					end_k=`cat 2`
					ind_v=`cat 3`
					ind_c=`cat 4`

					paste o-qp-${line}$Kelvin.g_sq_F_b_$ind_v\_k\_$start_k o-qp-${line}$Kelvin.g_sq_F_b_$ind_c\_k\_$end_k | awk '{print $1,$2-$10}' > $prefix.${line}$Kelvin.eliash_diff_indirect.txt

					sed -i.bak -E '/(^$|^#)/d' $prefix.${line}$Kelvin.eliash_diff_indirect.txt
					#sed -i.bak 's/  */\t/g'    $prefix.${line}$Kelvin.eliash_diff_indirect.txt 	

					rm -rf 1 2 3 4 5  new_file.txt 1new_file.txt *.bak


					#--------------------------------------------------Eliashberg Function: direct gap---------------------------------------#

					ypp_ph -s e -F eliash.${line}$Kelvin.dir.in

                                        sed -i 's/PhBroad= 0.010000/PhBroad= 0.0010000/g'                       eliash.${line}$Kelvin.dir.in
                                        sed -i 's/PhStps= 200/PhStps= 1000/g'                                   eliash.${line}$Kelvin.dir.in

					
					awk '/Direct Gap localized at k/ {print $8}' r_setup > 1
                                        awk '/Direct Gap localized at k/ {print $8}' r_setup > 2

                                        awk '/Filled Bands/ {print $5}' r_setup > 3
                                        awk '/Empty Bands/ {print $5}' r_setup > 4
                                        paste --delimiter='|' 1 2 3 4 > 5
                                        sed -i 's/$/|/' 5

                                        sed '21s/.*//' eliash.${line}$Kelvin.dir.in > new_file.txt
                                        sed '21 r 5' new_file.txt > 1new_file.txt
                                        sed '21d' 1new_file.txt > eliash.${line}$Kelvin.dir.in

                                        ypp_ph -F eliash.${line}$Kelvin.dir.in -J qp-${line}$Kelvin

                                        start_k=`cat 1`
                                        end_k=`cat 2`
                                        ind_v=`cat 3`
                                        ind_c=`cat 4`

                                        paste o-qp-${line}$Kelvin.g_sq_F_b_$ind_v\_k\_$start_k o-qp-${line}$Kelvin.g_sq_F_b_$ind_c\_k\_$end_k | awk '{print $1,$2-$10}' > $prefix.${line}$Kelvin.eliash_diff_direct.txt

                                        sed -i.bak -E '/(^$|^#)/d' $prefix.${line}$Kelvin.eliash_diff_direct.txt
                                        #sed -i.bak 's/  */\t/g'    $prefix.${line}$Kelvin.eliash_diff_direct.txt

                                        rm -rf 1 2 3 4 5  new_file.txt 1new_file.txt *.bak
		
					
					scp -r $prefix.${line}$Kelvin.eliash_diff_direct.txt $prefix.${line}$Kelvin.eliash_diff_indirect.txt $DIR/graph_data/Eliash_data/.
						
  				cd ..
			done	


exit;
