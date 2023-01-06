 
#	Note: Before ruuning this, you should run the BSE finite q calculation and double-grid electron phonon coupling, i.e., the elph.sh script.
#	See the Yambo tutorials for more details.

        cd $DIR/exc_disp

        PATH1=$DIR/ELPH/phonon
        PATH5=$DIR/band_structure
        PATH16=$DIR/exc_disp

        cd $PATH16


                for line in $temp_value
                        do

                                        ypp_ph -e p -F                                                                  $prefix.ypp.Lumin-${line}$Kelvin.in

                                        sed -i 's/States= "0 - 0"/States="'"$exciton_states"'"/g'                       $prefix.ypp.Lumin-${line}$Kelvin.in
                                        sed -i 's/BoseTemp=-1.000000         eV/BoseTemp='${line}' K/g'                 $prefix.ypp.Lumin-${line}$Kelvin.in
                                        sed -i 's/PHfreqF= "none"/PHfreqF= "'"..\/ELPH\/phonon\/$prefix.freq"'"/g'      $prefix.ypp.Lumin-${line}$Kelvin.in
                                        sed -i 's/DOS_broad= 0.100000/DOS_broad= '$dos_broad_exc_phon'/g'               $prefix.ypp.Lumin-${line}$Kelvin.in
                                        sed -i 's/DOSESteps=  500/DOSESteps=  1000/g'                                   $prefix.ypp.Lumin-${line}$Kelvin.in

                                        sed -i.bak -e '23d'                                                             $prefix.ypp.Lumin-${line}$Kelvin.in
                                        sed -i.bak "23i $dos_energy_range"                                              $prefix.ypp.Lumin-${line}$Kelvin.in


                                        ypp_ph -F $prefix.ypp.Lumin-${line}$Kelvin.in -J output

                                        mv o-output.excitons_ph_dos o-output.excitons_ph_dos.${line}$Kelvin
                        done


                                        rm -rf *.bak
exit; 
