

      	mkdir phonon dvscf

      PATH2=$DIR/scf_nonsoc
       PATH3=$DIR/nscf
       PATH5=$DIR/band_structure
      PATH12=$DIR/phonon
      PATH13=$DIR/dvscf
	


	cd $PATH12
                cat > $prefix.phonon.in << EOF
&inputph
                                verbosity  = 'high'
                                    tr2_ph = $TRN_PH
                                 alpha_mix = $alpha_mx
                                    prefix = '$prefix'
                                  fildvscf = '$prefix-dvscf'
                                    fildyn = '$prefix.dyn'
                           electron_phonon = 'dvscf'
                                     epsil = .true.
                                     trans = .true.
                                     ldisp = .false.
                                     qplot = .true.
/
EOF


       cd $PATH13
                cat > $prefix.dvscf.in << EOF
&inputph
                                 verbosity = 'high'
                                    tr2_ph = $TRN_PH
                                 alpha_mix = $alpha_mx
                                    prefix = '$prefix'
                                  fildvscf = '$prefix-dvscf'
                                    fildyn = '$prefix.dyn'
                           electron_phonon = 'yambo'
                                     epsil = .true.
                                     trans = .false.
                                     ldisp = .false.
                                     qplot = .true.
/
EOF

      cd $DIR


		
                                # The self-consistent file
                               # this file defines the number of k-points for the density and the plane-wave cutoff
                               SCF_FILE="$prefix.scf.in"
                               PREFIX="$prefix"
                               DYN_FILE="$prefix.dyn"

                               # The files for nscf, phonons, and dvscf without the q-points
                               # in the nscf file we define the number of bands
                               NSCF_FILE="$prefix.nscf.in"
                               PHONON_FILE="$prefix.phonon.in"
                               DVSCF_FILE="$prefix.dvscf.in"
                               DYN0_FILE="$prefix.dyn0"

        #initial folder
        STARTPWD=$DIR

                # k-grid for the NSCF calculation
                        K_GRID=$kgrid     # Q-grid use in the nscf

                # Select the q-grid 
                        Q_GRID_TYPE="automatic"  # You can specify a q-grid type (automatic | file | random )

                # if Q_GRID_TYPE='automatic' read the internal Yambo q-grid (generated from the K_GRID)

                        Q_GRID_NAME="ELPH" # Name of the folder where calculations are performed

                        Q_GRID_N_RND=200   # Number of random q-point for the random q-grid, used if Q_GRID_TYPE='random'
                        Q_GRID_FILE="$STARTPWD/my_qgrid" # User defined q-grid, used if Q_GRID_TYPE='file'

                echo 
                echo " * * * Electron-phonon calculation for Yambo * * * "
                echo

                        if [[ $Q_GRID_TYPE == 'automatic' ]]
                        then
                                echo "Automatic q-grid : $K_GRID"
                        elif [[ $Q_GRID_TYPE == 'random' ]]
                        then
                echo "Random q-grid, number of random q : $Q_GRID_N_RND"
                        elif [[ $Q_GRID_TYPE == 'file' ]]
                        then
                echo "Q-grid read from file : $STARTPWD/qpoints"
                        fi

                echo ""
                echo "  * * * Script to generate DVSCF databases * * * "
                echo ""
                echo "K-grid $K_GRID"
                echo "Q-grid folder $Q_GRID_NAME"

			# Run the scf
                                cd $PATH2
                                        echo "Running SCF ... "
                                        $PW_RUN -inp $SCF_FILE > output_scf
                                cd ..

                mkdir $Q_GRID_NAME
            	cd $Q_GRID_NAME

			# Run the nscf
                                mkdir nscf
                                cd nscf
                                cat ../../nscf/$NSCF_FILE > $NSCF_FILE
                                echo "$K_GRID 0 0 0 " >> $NSCF_FILE
                                cp -r ../../scf_nonsoc/$PREFIX.save ./
                                echo "Running NSCF ... "
                                $PW_RUN -inp $NSCF_FILE > output_nscf

				awk /parameter/ output_nscf > 1
                                #sed '2d' 1 > 2
                                awk '{print $1}' 1 > lattice
                                sed -i '/lattice/c\OutputAlat=' lattice
                                awk '{print $5}' 1 > value
                                paste lattice value > lattice_value
                                rm -rf 1 2 lattice value


		 	#Read WF
                cd $PREFIX.save
                                echo "Running P2Y ... "
                                $P2Y 2> output_p2y

                        #Yambo setup
                                echo "setup" > yambo.in_setup
                                echo "Running YAMBO setup ... "
                                        $YAMBO_PH -nompi -F yambo.in_setup 2> output_setup

			#Print the list of q-points

				if [[ $Q_GRID_TYPE == 'automatic' ]]
				then
        				echo "Automatic q-points grid ... "
        				echo "bzgrids" > ypp.in_qpoints
        				echo "Q_grid " >> ypp.in_qpoints
        				echo "NoWeights  " >> ypp.in_qpoints
        				echo "ListPts    " >> ypp.in_qpoints
        				echo "cooOut= 'alat' "  >>  ypp.in_qpoints

					cp -r ../lattice_value ./.
                                        cat  lattice_value >> ypp.in_qpoints

        				$YPP_PH -nompi -F ypp.in_qpoints 2> output_qpoints
        				python $STARTPWD/get_qlist.py > output_getlist
        				cp qpoints $STARTPWD/
				elif [[ $Q_GRID_TYPE == 'random' ]]
				then
        				echo "Random q-points grid ... "
        				echo "Not implemented yet "
        			exit

				elif [[ $Q_GRID_TYPE == 'file' ]]
				then
        				cp $Q_GRID_FILE $STARTPWD/qpoints

				fi
				cd ..
				cd ..

			# Run the phonon
       		
			mkdir phonon
      			cd phonon
				cat ../../phonon/$PHONON_FILE > $PHONON_FILE
				cat $STARTPWD/qpoints  >> $PHONON_FILE
				scp -r ../../scf_nonsoc/$PREFIX.save ./
				echo "Running PHONON ... "
				$PH_RUN_phon -inp $PHONON_FILE > output_phonon

				echo "$K_GRID" >> $DYN0_FILE
                                cat $STARTPWD/qpoints  >> $DYN0_FILE
			

				 cat > $prefix.q2r.in << EOF
&input
                                                zasr='crystal',
                                                flfrc='$prefix.fc',
                                                fildyn='$prefix.dyn',
                                                loto_2d = .true.,
/
EOF
                                               $Q2R_RUN -inp $prefix.q2r.in > q2r.out

                                 cat > $prefix.matdyn.in << EOF
&input
                                                asr='crystal',
                                                flfrc='$prefix.fc',
                                                flfrq='$prefix.freq',
                                                dos=.true.,
                                                loto_2d = .true.,
                                                fldos='$prefix.dos',
                                                deltaE=1.d0,
                                                nk1=160, nk2=160, nk3=1
/
EOF
                                                $MATDYN_RUN -inp $prefix.matdyn.in > output_matdyn

			cd ..

			# Run the dvscf
			mkdir dvscf
			cd dvscf
				cat ../../dvscf/$DVSCF_FILE > $DVSCF_FILE
				cat $STARTPWD/qpoints  >> $DVSCF_FILE
				scp -r ../nscf/$PREFIX.save ./
				scp -r ../phonon/_ph0 ./
				scp ../phonon/$DYN_FILE* ./
				echo "Running DVSCF ... "
				$PH_RUN_dvscf -inp $DVSCF_FILE > output_dvscf




#			#Read gkkp matrix elements

			cd $PREFIX.save
				echo "gkkp"> ypp.in_dbs
				echo "gkkp_db" >> ypp.in_dbs
				echo 'DBsPATH= "../elph_dir/"' >> ypp.in_dbs
				echo "Running YPP_PH gkkp ... "
				$YPP_PH -nompi -F ypp.in_dbs 2> output_dbs


	        #--------------------------Phonon double grid calculation---------------------------------#


                                cd ../../phonon

                                        scp -r $prefix.freq ../dvscf/$prefix.save/.

                                cd ../dvscf/$prefix.save

                                         cat > $prefix.ypp_ph_dg.in << EOF
&input

                                        gkkp                           
                                        gkkp_dg                        
                                        PHfreqF= "$prefix.freq"       
                                        PHmodeF= "none"               
                                        FineGd_mode= "mixed"          
                                        #SkipBorderPts                
                                        EkplusQmode= "interp"         
                                        #TestPHDGrid                  
/
EOF

                                        $YPP_PH -nompi -F $prefix.ypp_ph_dg.in
                                        scp -r SAVE r_setup ../../.

        #----------------------------------------------------------------------------------------#


			cd $STARTPWD




exit;	
