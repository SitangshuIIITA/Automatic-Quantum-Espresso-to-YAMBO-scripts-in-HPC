
#---------------1. HPC bash headers: Add yours------------#
cat > hpc_header.txt << EOF
#!/bin/bash
#PBS -u sitangshu
#PBS -N sitangshu
#PBS -q core160
#PBS -o out.log
#PBS -l nodes=4:ppn=40
#PBS -j oe
#PBS -V
     cd \$PBS_O_WORKDIR
        module load compilers/intel/parallel_studio_xe_2018_update3_cluster_edition
        module load compilers/gcc-7.5.0
     cat \$PBS_NODEFILE |uniq > nodes
EOF
#--------------------------------------------------------------------------------#
# note: To create a file with special characters (not declared as global variables) like "$" above, use "\" in front of them.


#------------------------------2. DFT QE input-----------------------------------#
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
                                           ecutwfc = 90
                                       occupations = 'fixed'
                                         celldm(1) = 4.716
                                             ibrav = 4
                                         celldm(3) = 7
                                               nat = 2
                                              ntyp = 2

/&end
/

&ELECTRONS
                                   diagonalization = 'cg'
                                          conv_thr = 1e-10
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
   B   10.811         B.pz-vbc.UPF
   N  14.0067         N.pz-vbc.UPF

ATOMIC_POSITIONS (alat)
   B   0.5000000000   0.2886751346   0.0000000000
   N  -0.5000000000  -0.2886751346   0.0000000000

K_POINTS {automatic}
 $kgrid $shifted_grid

EOF
#---------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------#


#------3. Choice of BZ route for band diagram: Change as per requirement----------------------#

#------------------------Do not change the format below---------------------------------------#
#----Change the BZ route name order (example: G M K G) in the QE_variables.sh file------------#
cat > $prefix.band_route << EOF
0.00000 | 0.00000 | 0.00000 |
0.50000 | 0.00000 | 0.00000 |
0.33333 | 0.33333 | 0.00000 |
0.00000 | 0.00000 | 0.00000 |
EOF
#---------------------------------------------------------------------------------------------#



