#! /bin/bash -i

source config.sh

# PREPARE POSTGRES_USER
useradd $POSTGRES_USER -m -s  /bin/bash -d /home/$POSTGRES_USER/  
su $POSTGRES_USER -l -c 'export PATH='"$CONDA_INSTALL_DIR"/bin:$PATH'; conda init'
cp test_rdkit_cartridge.sh /home/$POSTGRES_USER/
cp config.sh /home/$POSTGRES_USER/
chmod go-rwx /home/$POSTGRES_USER/test_rdkit_cartridge.sh
chmod u+rwx /home/$POSTGRES_USER/test_rdkit_cartridge.sh
chown $POSTGRES_USER /home/$POSTGRES_USER/test_rdkit_cartridge.sh
chgrp $POSTGRES_USER /home/$POSTGRES_USER/test_rdkit_cartridge.sh
chmod go-rwx /home/$POSTGRES_USER/config.sh
chmod u+rwx /home/$POSTGRES_USER/config.sh
chown $POSTGRES_USER /home/$POSTGRES_USER/config.sh
chgrp $POSTGRES_USER /home/$POSTGRES_USER/config.sh

# PREPARE RDKIT TESTING
# RUN chown $POSTGRES_USER "$RDBASE"/build/Code/PgSQL/"$RDBASE"/regression*
# RUN chown $POSTGRES_USER "$RDBASE"/build/Code/PgSQL/"$RDBASE"/results
chown $POSTGRES_USER "$RDBASE"/build/Testing/Temporary/
# RUN chgrp $POSTGRES_USER "$RDBASE"/build/Code/RDGeneral; chmod g+w "$RDBASE"/build/Code/RDGeneral
touch "$RDBASE"/build/Code/RDGeneral/error_log.txt; chown $POSTGRES_USER "$RDBASE"/build/Code/RDGeneral/error_log.txt
chgrp $POSTGRES_USER "$RDBASE"/Code/ForceField/MMFF/test_data/; chmod g+w "$RDBASE"/Code/ForceField/MMFF/test_data/
chgrp $POSTGRES_USER "$RDBASE"/Code/GraphMol/FileParsers/test_data/; chmod g+w "$RDBASE"/Code/GraphMol/FileParsers/test_data/
chgrp $POSTGRES_USER "$RDBASE"/Code/GraphMol/Depictor/test_data/; chmod g+w "$RDBASE"/Code/GraphMol/Depictor/test_data/
# RUN chgrp $POSTGRES_USER "$RDBASE"/build/Code/GraphMol/Depictor; chmod g+w "$RDBASE"/build/Code/GraphMol/Depictor
touch "$RDBASE"/build/Code/GraphMol/Depictor/junk.mol; chown $POSTGRES_USER "$RDBASE"/build/Code/GraphMol/Depictor/junk.mol
chgrp $POSTGRES_USER "$RDBASE"/Code/GraphMol/FileParsers/; chmod g+w "$RDBASE"/Code/GraphMol/FileParsers/

pushd "$RDBASE"
find . -type d -exec chgrp $POSTGRES_USER {} +
find . -type d -exec chmod g+w {} +


su $POSTGRES_SUPERUSER -l -c "createuser -sE $POSTGRES_USER"
su $POSTGRES_SUPERUSER -l -c "createdb $POSTGRES_USER"

# Only works for postgresql 15+ . Not tested.
# RDKIT_TEST_DATABASE="regression"
# su $POSTGRES_SUPERUSER -l -c "psql -c 'ALTER USER \"$POSTGRES_USER\" CREATEDB;'"
# su $POSTGRES_SUPERUSER -l -c "psql -c 'GRANT SET ON PARAMETER lc_messages TO \"$POSTGRES_USER\";'"

popd
