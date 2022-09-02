## Automatic-Quantum-Espresso-to-YAMBO-scripts
### These are automatic set of scripts that does all the exciton-driven optical absorption computations at one shot in a high performance cluster :)
- Use this for only Yambo version 5.1.0, 5.1.1., as of now.
- Right now this works only with 2D single layers. I will update for bulk also.
- You should be fully aware of recent QE and Yambo variables. 

<p style='text-align: justify;'>This is my automatic version 1.0 running script for YAMBO v5.1. I have tried to write the flow in a super easy format, so that anyone can run these lengthy and cascaded without losing much time in between consecutive flows. The folder names are compatible also to the yambopy process-flow. The script "get_qlist.py" and "elph.sh" are from Yambo tutorials, with additional modifications from my side.</p>

<p style='text-align: justify;'>There are main two directories (core_files & work_dir) and one file (initialize.sh). The directory "work_dir" is the place where all your files and folders will get generated and is the $DIR. Core_files contains the various run and variable declaration scripts. 

Note: There are large number of file exchanges that is going to take place once you run the script. So, carefully read the following working procedures:</p>  

1. Open initialize.sh script and change lines 2-12 as per you declare your HPC headers. Dont forget to load modules here.
2. Now copy these lines and open QE_input_file.sh inside \core_files directory. Delete lines 5-15 and paste the headers here also.

Save the file and close it.

#### Quantum Espresso DFT input script generation: 
This section will take care of "relax", "scf" (both with and without spin-orbit calculation), "nscf (by default (both with spin-orbit calculation)" and "bands (with orbitals)" calculations automatically.

1. In the QE_input_file.sh file, change only lines 35-67 as per your input. Don't Change anything else.
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
2. Modify lines 6-7 & 14-17 without renaming the arguements.
3. Modify the subsequent list of yambo variables. Do not change the arguements.

#### ----------------------------------------- Done ------------------------------------------------

#### Now run the files:

1. Run the script initialize.sh only once from your HPC. This will add the headers in all of your input *.sh scripts. For example, check the /core_files/QE_RUN/QE_relax.sh file.
2. The directory "work_dir" is the place where all your files and folders will get generated.
3. Put your pseudopotentials inside "/pseudo" directory.
4. Go to the /core_files/work_dir. In the run.sh script, the chronological process flow is written. Run the run.sh script in your HPC by uncommenting lines 16-24 either in one shot or one by one. You will see the QE DFT results have generated. Maintain the sequentiality of the jobs. Do not play randomly.
5. To get GW, BSE, temperature dependent BSE, exciton dispersion, etc. uncomment lines 30-54 either at one shot or one by one. Maintain the sequentiality of the jobs. Do not play randomly.
6. All the resulted data files will be located inside the "\work_dir\graph_data\" folder. Use them for a nice plot! :) 



Do let me know, if there is any query, I am at: 
  Department of Electronics and Communication Engineering
  Indian Institute of Information Technology-Allahabad
  Uttar Pradesh 211015
  India
  Email: sitangshu@iiita.ac.in 
  Webpage: https://profile.iiita.ac.in/sitangshu/


#### ------------------------------ That's all folks Enjoy! ------------------------------------------
