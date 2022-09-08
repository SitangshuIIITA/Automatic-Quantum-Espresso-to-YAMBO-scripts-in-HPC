## Automatic-Quantum-Espresso-to-YAMBO-scripts
### These are automatic set of scripts that does all the exciton-phonon driven optical absorption computations at one shot in a high performance cluster :)
- Use this for only Yambo version 5.1.0, 5.1.1., as of now.
- Right now this works only with 2D single layers. I will update for bulk also.
- You should be fully aware of recent QE and Yambo variables. 
- Requires the use of SlepC module in Yambo. Install this if you don't have. 

<p style='text-align: justify;'>This is my automatic version 1.0 running script for YAMBO v5.1. I have tried to write the flow in a super easy to understand format, so that anyone can run these lengthy and cascaded consecutive flows without losing much time in between. The folder names are compatible also to the yambopy process-flow. The script "get_qlist.py" and "elph.sh" are from Yambo tutorials, with additional modifications from my side.</p>

<p style='text-align: justify;'>There are mainly two directories: core_files & work_dir , and one file: initialize.sh. The "work_dir" is your current working directory and is the place where all your files and folders will get generated. This is named as $DIR. Do not change this anywhere in the script. Core_files contains the various run and variable declaration scripts. 

Note: There are large number of file exchanges that is going to take place once you run the script. So, carefully read the following working procedures:</p>  

1. Open the initialize.sh script and change lines 2-12 as per you declare your HPC headers. Note that this step is not equivalent of yambo initialization. Dont worry though, yambo initializations are taken care of. Also don't forget to load compiler modules here.
2. Now copy these lines and open QE_input_file.sh inside \core_files directory. Delete lines 5-15 and paste the headers here also.

Save the file and close it.

#### Quantum Espresso DFT input script generation: 
This section will take care of "relax", "scf" (both with and without spin-orbit calculation), "nscf (by default (both with spin-orbit calculation)" and "bands (with orbitals)" calculations automatically.

1. In the QE_input_file.sh file, change only lines 35-67 as per your input. You may add other QE flags also. 
2. Scroll down and change line 82-85. Dont delete "|". Maintain the format.


#### Assigning variables for HPC processors & Quantum Espresso:

1. Open QE_variables.sh file inside /core_files/QE_VAR directory.
2. Modify line 11 by setting QE path.
3. Modify line 13 by replacing "mpiexec.hydra -ppn 40 -f $DIR/nodes". Note that in most HPC jobs, node file is generated.
4. Modify the number of processors in line 15-19.
5. Modify similarly lines 22-25.
6. The QE variables can now be easliy set in lines 29-47. Do not modify the space in line 41. 

Save the file and close it.

#### Assigning variables for parallel cpus & YAMBO v5.1:

1. Open yambo_variables.sh file inside /core_files/YAM_VAR directory.
2. Modify lines 6-7 & 14-17 without modifying/renaming the arguements.
3. Modify the subsequent list of yambo variables. Do not change the arguement names.

#### ----------------------------------------- Done ------------------------------------------------

#### Now run the files:

1. Run the script initialize.sh only once from your HPC. This will add the headers in all of your input *.sh scripts located inside QE_RUN and YAM_RUN. For example, check now the /core_files/QE_RUN/QE_relax.sh file. Your HPC headers should exactly appear here.
2. The directory "work_dir" is the place where all your files and folders will get generated.
3. Put your pseudopotentials inside "/pseudo" directory.
4. Go to the work_dir. In the run.sh script, the chronological process flow is written. Run the run.sh script in your HPC by uncommenting the QE shell script lines like QE_relax.sh, etc., either in one shot or one by one. You will see the QE DFT results have generated. Maintain the sequentiality of the jobs. Do not play randomly.
5. Similarly, to get the GW, BSE, temperature dependent BSE, exciton dispersion, etc., uncomment the yambo shell script lines like yambo_dft_band_struc.sh, etc. either at one shot or one by one. Maintain the sequentiality of the jobs. Do not play randomly.
6. The python script "lin_reg.py" inside "/work_dir" is used during GW calculations to perform regression on GW data. Look into the GW_folder (after running gw.sh) and you will find slopes for conduction and valence data sets.
6. All the resulted data files will be located inside the "\work_dir\graph_data\" folder. Use them for a nice plot! :) 



Do let me know, if there is any query, I am at: 
  Department of Electronics and Communication Engineering
  Indian Institute of Information Technology-Allahabad
  Uttar Pradesh 211015
  India
  Email: sitangshu@iiita.ac.in 
  Webpage: https://profile.iiita.ac.in/sitangshu/


#### ------------------------------ That's all folks Enjoy! ------------------------------------------
