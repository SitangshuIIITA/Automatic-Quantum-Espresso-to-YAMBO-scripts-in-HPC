

#------------------------------1. DFT QE input-----------------------------------#
#--------------------------------------------------------------------------------#
cat > $prefix.relax << EOF

&CONTROL
                                        wf_collect = .true.
                                       calculation = 'vc-relax'
                                         verbosity = 'high'
                                        pseudo_dir = '$PSEUDO_DIR'
                                     forc_conv_thr = 1e-05
                                            prefix = '$prefix'
                                     etot_conv_thr = 1e-05
/&end

&SYSTEM
                                           ecutwfc = $ecutwfc
                                       occupations = 'fixed'
                                         celldm(1) = 5.9722904441
                                             ibrav = 4
                                         celldm(3) = 6.6135615745
                                               nat = 3
                                              ntyp = 2
/&end
/

&ELECTRONS
                                   diagonalization = 'david'
                                          conv_thr = 1e-10
				  electron_maxstep = 200
/&end
/ 
 
&ions
                                      ion_dynamics = 'bfgs'
/&end
&cell
                                       cell_dofree = '2Dxy'
                                     cell_dynamics = 'bfgs'
/&end


ATOMIC_SPECIES
  Mo 95.940000  Mo-sp_r_r.oncvpsp.upf
  S 32.065000   S_r_r.oncvpsp.upf

ATOMIC_POSITIONS {alat}

 Mo    0.5000000000   0.2886751346   0.9725825845
  S    0.5000000000  -0.2886751346   0.4707299709
  S    0.5000000000  -0.2886751346   1.4744351981

K_POINTS {automatic}
 $kgrid_nonsoc $shifted_grid

EOF
#---------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------#


#------2. Choice of BZ route for band diagram: Change as per requirement----------------------#

#------------------------Do not change the format below---------------------------------------#
#----Change the BZ route name order (example: G M K G) in the QE_variables.sh file------------#
cat > $prefix.band_route << EOF
0.00000 | 0.00000 | 0.00000 |
0.50000 | 0.00000 | 0.00000 |
0.33333 | 0.33333 | 0.00000 |
0.00000 | 0.00000 | 0.00000 |
EOF
#---------------------------------------------------------------------------------------------#
