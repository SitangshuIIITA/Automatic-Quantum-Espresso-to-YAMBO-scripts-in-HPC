
  
       mkdir electronic_stability

       PATH1=$DIR/relax	
       PATH2=$DIR/electronic_stability

		cd $PATH2

			for line in $atoms
	                     do
                                mkdir "${line}_stability"
				
			cd ${line}_stability
				
cat > ${line}.relax << EOF
&CONTROL
	 			calculation  = 'scf',
  				     prefix  = '$prefix',
  				pseudo_dir   = '$PSEUDO_DIR',
  			 	   verbosity = 'high',
                                  wf_collect = .true.
                               forc_conv_thr = 1e-05
                               etot_conv_thr = 1e-05


/
&SYSTEM 
  				   ibrav     = 1,
  				   celldm(1) = 30.0, 
  				   nat       = 1, 
  				   ntyp      = 1,
  				   ecutwfc   = '$ecutwfc',
  				 occupations ='smearing', 
				    smearing ='gauss', 
				      degauss=0.02,
/

&ELECTRONS
  				conv_thr    = 1e-10,
/
/
ATOMIC_SPECIES
${line} 1.0 ${line}.upf

ATOMIC_POSITIONS (angstrom) 
${line}  0.000000000000 0.000000000000 0.000000000000

K_POINTS {automatic}
1 1 1 0 0 0
EOF	

				$MPIRUN_PW ${line}.relax > ${line}.relax.out
				grep 'Final enthalpy' ${line}.relax.out > ${line}.enthalpy
				scp -r ${line}.enthalpy $PATH2

		
			 done
			
			 	scp -r $PATH1/relax.out ./.
				grep 'Final enthalpy' relax.out > $prefix.enthalpy	

exit;


