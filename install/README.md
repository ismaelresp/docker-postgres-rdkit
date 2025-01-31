# Requeriments:

## Operative system
- Ubuntu OS x86-64 (tested only in Bionic 18.04)
- Internet access

## Configuration assumptions
The installation scripts assume:
### a. PostgreSQL is already installed with peer authentication enabled. 
So, the following line in *pg_hba.conf* is present and uncommented:

    local	all      all          peer

PostgreSQL might require to be updated to the lastest minor version in the Ubuntu repository to match the version of the package *postgresql-server-dev-$PG_MAJOR* . Minor version updates hardly ever require to migrate the database data or configuration files.

### b. There is a PostgreSQL superuser that is also an Operative System user.
PostgreSQL superuser must be able to open a linux shell. 
By default, that user is *postgres*.

### c. You have access to *root* as a sudoer user. 
If not, follow the instructions removing `'sudo'` from the commands and run them after login in a terminal as *root*, e.g with `su root`.

### d. You must use a previously installed *conda* or install a brand new one.
If you choose not to follow the steps that begin with ***If you do not want to use a previously installed conda***, change *CONDA_INSTALL_DIR* variable in `config.sh` to the value of your environment variable *CONDA_PREFIX* after running in a terminal `conda activate base`.
You can get that value with: `echo $CONDA_PREFIX`.

In this case, a *conda* environment called *rdkit_built_dep* will be created in the *conda* installation in *$CONDA_INSTALL_DIR*. That environment contains libraries required by the RDKit Cartridge to run properly.

# Installation
To install the RDKit Cartridge:

 1. Copy the files in this folder to a local folder in your home directory.

 2. Open a new terminal and change the working directory to the folder mentioned in the previous step with the copied files.

 3. Check the variables in `config.sh` and change accordingly to your computer system. Do not forget to save the changes.

 4. Make a backup of *~/.bashrc* at the home of the user running the *step 6* (appart from the automatically created one by the scripts). (If it is root, usually is */root/.bashrc* . If the user is a sudoer, it is usually the home directory of the user and not */root*).

 5. **If you do not want to use a previously installed conda**, remove all *conda* activation and initialisation code from the *.bashrc* file mentioned in the previous step.

 6. **If you do not want to use a previously installed conda**, run in the terminal `sudo bash install_conda_rdkit_cartridge.sh`.
    **IMPORTANT:** If *install_conda_rdkit_cartridge.sh* fails, restore the *~/.bashrc* file as explained at the end of this README file before repeating this step or running again *install_conda_rdkit_cartridge.sh*.
 
 7. If you ran the command in the previous step, run 'bash' in the terminal or repeat step 2.

**CAUTION:** Next step **ERASES** the folder, subfolders and its contents or the file in the path *$RDBASE*, a variable set up in `config.sh`, */rdkit* by default.

**CAUTION:** Next step **ERASES** the folder, subfolders and its contents or the file in the path *rdkit-*${*RDKIT_VERSION*}*.tar.gz* in the current working directory. ${*RDKIT_VERSION*} is a variable set up in `config.sh`, and its value follows by default the pattern  *Release_yyyy_mm_n* , where *y*, *m* and *n* are numbers.

**CAUTION:** Next step **ERASES** the file ${*RDKIT_VERSION*}*.tar.gz* in the current working directory. ${*RDKIT_VERSION*} is a variable set up in `config.sh`, and its value follows by default the pattern  *Release_yyyy_mm_n* , where *y*, *m* and *n* are numbers.

 8. Run in the terminal `sudo bash -i install_rdkit_cartridge.sh`.

 9. Restart postgresql or reboot the machine. Repeat *step 2*.

10. Run in the terminal `sudo bash create_rdkit_extension.sh`.

# Testing installation (RECOMMENDED)

12. Run in the terminal `sudo bash -i config_test_rdkit_cartridge.sh` to prepare the testing environment to check if the cartridge has been built correctly.

13. Run in a terminal `sudo su [rdkit-test-user]` replacing `[rdkit-test-user]` by the value of the *POSTGRES_USER* variable in `config.sh`. Default *rdkit-test*.

**DANGER!!!:** **THE FOLLOWING COMMANDS WILL WRITE IN DATABASES**. THEY ARE SUPPOSED TO ONLY CREATE DATABASES CALLED *regression* AND *rdkit-test* AND DROP THEM. HOWEVER, **BACKUP OF ALL THE DATABASES** IS HIGHLY RECOMMENDED BEFORE PROCEEDING.

14. Run in the terminal `bash -i test_rdkit_cartridge.sh` to start the test.

15. If a test step does not progress for more than 5 min, take a note of the name and number of the lastest step. 
    Then, try to stop the script by pressing *CONTROL+C* in the terminal. 
    If it does not respond, kill the python process from another terminal or close the terminal. 
    Repeat *step 13* and jump to *step 16*.

16. Run in the terminal `bash -i test_rdkit_cartridge.sh -I [number]` to resume the tests. `[number]` is the ID number of the test.

17. If you get an error while running test_rdkit_cartridge.sh or a test fails, your build or installation has errors. For help, send an issue with the output of `bash -i test_rdkit_cartridge.sh -VV -R [name_of_the_step_failed]`.  `[name_of_the_step_failed]` is a regular expression matching the name of the step failed.

# Restoring *~/.bashrc*
Once you have a working installation of the RDKit Cartridge if you have installed *conda*, you might want to restore and *~/.bashrc* files.
You can do this with:
```bash
mv ~/.bashrc.rdkit_cartridge_bkp ~/.bashrc
```
