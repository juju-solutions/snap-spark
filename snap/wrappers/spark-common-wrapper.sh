#!/bin/bash

###############################################################################
# Wrapper for all spark-related binaries and daemons
###############################################################################

# Setup environment
# NB: all snaps that plug into hadoop are expected to have $SNAP/hadoop and
# $SNAP_DATA/etc/hadoop dirs that will be automatically mounted when connected.
if [ -e ${SNAP}/hadoop/wrappers/hadoop-common-wrapper.sh ]; then
  . ${SNAP}/hadoop/wrappers/hadoop-common-wrapper.sh

  # Update path so spark can find $SNAP/hadoop/wrappers (like 'hadoop')
  export PATH=${SNAP}/hadoop/wrappers:$PATH
else
  # Spark can run without hadoop, but warn users in case this is unexpected.
  echo "WARN: Hadoop was not found. YARN mode is unavailable."

  # Set Bigtop envars for java/jsvc (otherwise set by hadoop's common-wrapper)
  . ${SNAP}/usr/lib/bigtop-utils/bigtop-detect-javahome
  export JSVC_HOME=${SNAP}/usr/lib/bigtop-utils
fi

# Update path to find our spark wrappers
export PATH=${SNAP}/wrappers:$PATH
