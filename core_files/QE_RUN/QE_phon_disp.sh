

      mkdir phonon_disp

       PATH2=$DIR/scf_nonsoc
      PATH12=$DIR/phonon_disp
	


	cd $PATH12
                cat > $prefix.phonon.in << EOF
&inputph
                                verbosity  = 'high'
                                    tr2_ph = $TRN_PH
                                 alpha_mix = $alpha_mx
                                    prefix = '$prefix'
                                    fildyn = '$prefix.dyn'
                                     ldisp = .true.
				nq1=$NQ1, nq2=$NQ2, nq3=$NQ3,
/
EOF


				scp -r $PATH2/$prefix.save ./.
				echo "Running PHONON ... "
				$PH_DISP_RUN -inp $prefix.phonon.in > output_phonon


				 cat > $prefix.q2r.in << EOF
&input
                                                zasr='crystal',
                                                flfrc='$prefix.fc',
                                                fildyn='$prefix.dyn',
                                                loto_2d = .true.,
/
EOF
                                 $Q2R_DISP_RUN -inp $prefix.q2r.in > q2r.out


				 scp -r $DIR/bands/bands.out ./.

				 awk '/cryst. coord./,/Dense/' bands.out | awk 'NR > 2 { print }' | awk 'NR>2 {print last} {last=$0}' > 1

				 awk '/cryst. coord./,/Dense/' 1 | awk 'NR > 1 { print }' | awk 'NR>1 {print last} {last=$0}' > 2

				 awk '//{printf "%10s %15s %15s\n",$5,$6,$7 }' 2 > 3
				 sed -e "s/),//" 3 > 4


				 cat 4 | wc -l > 5

				 cat 4 >> 5
                                 rm -rf 1 2 3 4	bands.out


                                 cat > $prefix.matdyn.in << EOF
&input
                                                asr='crystal',
                                                flfrc='$prefix.fc',
                                                flfrq='$prefix.freq',
                                 		q_in_cryst_coord = .true.,
						loto_2d = .true.,
/
EOF

				 cat 5 >> $prefix.matdyn.in


				 $MATDYN_DISP_RUN -inp $prefix.matdyn.in > output_matdyn

				 cat > $prefix.dos.matdyn.in << EOF
&input

						asr='crystal',
              					dos=.true.,
                                                loto_2d = .true.,
                                                fldos='$prefix.dos',
						flfrc='$prefix.fc',
						q_in_cryst_coord = .true.,
                                                deltaE=1.d0,
						flfrq='$prefix.dos.freq',	
                                                nk1=128, nk2=128, nk3=1
/
EOF

                                 $MATDYN_DISP_RUN -inp $prefix.dos.matdyn.in > output_dos_matdyn

				 rm -rf 5

exit;	
