The installation scripts assume:

a. PostgreSQL is already installed with peer authentication is enabled. 
So, the following line in pg_hba.conf is present and uncommented:
local  all      all          peer

PostgreSQL might require to be updated to the lastest minor version in the Ubuntu repository to match
the version of the package postgresql-server-dev-$PG_MAJOR . Minor version updates hardly ever require
to migrate the database data or configuration files.

b. There is a PostgreSQL superuser that is also an Operative System user that can open a linux shell.
By default, that user is 'postgres'.

c. You have access as a sudoer user. 
If not, follow the instructions removing 'sudo ' from the commands and run them after login in a terminal as 'root'.

d. If you choose not to follow the steps that begin with 'If you do not want to use a previously installed conda',
change CONDA_INSTALL_DIR variable in config.sh to the value of your environmental variable CONDA_PREFIX after 
running in a terminal 'conda activate base'. You can get that value with: 'echo $CONDA_PREFIX'.
In this case, a conda enviroment called 'rdkit_built_dep', will be created in the conda installation in 
$CONDA_INSTALL_DIR. That environment contains libraries required by the RDKIT cartridge to run
properly.

To install the RDKIT cartridge:

 1. Copy the files in this folder to a local folder in your home directory.

 2. Open a new terminal and change the working directory to the folder mentioned in the previous step with the copied files.

 3. Check the variables in config.sh and change accordingly to your computer system. Do not forget to save the changes.

 4. Make a backup of ~/.bashrc at the home of the user running the step 6.
    (If it is root, usually is /root/.bashrc . If the user is a sudoer, it is usually the home directory of the user and not
    /root).

 5. If you do not want to use a previously installed conda, remove all conda activation and initialization code from the
    .bashrc file mentioned in the previous step.

 6. If you do not want to use a previously installed conda, run in the terminal 'sudo bash install_conda_rdkit_cartridge.sh'.
 IMPORTANT: If install_conda_rdkit_cartridge.sh fails, restore the ~/.bashrc file as explained at the end of this 
 README.txt file before repeating this step or running again install_conda_rdkit_cartridge.sh.

 7. If you ran the command in the previous step, run 'bash' in the terminal or repeat step 2.

 8. Run in the terminal 'sudo bash -i install_rdkit_cartridge.sh'.

 9. Restart postgresql or reboot the machine. Repeat step 2.

11. Run in the terminal 'sudo create_rdkit_extension.sh'.

To test the installation (RECOMMENDED):

12. Run in the terminal 'sudo bash -i config_test_rdkit_cartridge.sh' to prepare the testing environment to check if the
    cartridge has been built correctly.

13. Run in a terminal 'sudo su [rdkit-test-user]' replacing [rdkit-test-user] by the value of the POSTGRES_USER variable
    in config_test_rdkit_cartridge.sh. Default 'rdkit-test'.

DANGER!!!: THE FOLLOWING COMMANDS WILL WRITE IN DATABASES. THEY ARE SUPPOSED TO ONLY CREATE DATABASES CALLED
'regression' AND 'rdkit-test' AND DROP THEM. HOWEVER, BACKUP OF ALL THE DATABASES IS HIGHLY RECOMMENDED BEFORE PROCEEDING.

14. Run in the terminal 'cd; bash -i test_rdkit_cartridge.sh' to start the test.

15. If a test step does not progress for more than 5 min, take a note of the name and number of the last step. 
    Then, try to stop the script with pressing CONTROL+C in terminal. 
    If it does not respond, kill the python process from another terminal or close the terminal. 
    Repeat step 13 and jump to step 16.

16. Run in the terminal 'cd; bash -i test_rdkit_cartridge.sh -I [number]' to resume the tests. [number] is the ID number of
    the test.

17. If you get an error while running test_rdkit_cartridge.sh or a test fails, your build or installation has errors.
    Send to Ismael the output of 'cd; bash -i test_rdkit_cartridge.sh -VV -R [name_of_the_step_failed]'.
    [name_of_the_step_failed] is a regular expression matching the name of the step failed. 

Once you have a working installation of the RDKIT cartridge if you have installed conda, you might want to restore 
/etc/profile.d/conda.sh and ~/.bashrc files.
You can do this with:
mv ~/.bashrc.rdkit_cartridge_bkp /etc/profile.d/conda.sh

