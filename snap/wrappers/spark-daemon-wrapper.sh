#!/bin/bash

###############################################################################
# Wrapper for spark daemons
###############################################################################

# Verify args
if [ $# -lt 2 ]; then
  echo "ERROR: Missing required arguments:"
  echo "$0 <start|stop> <history-server|master|worker> <args...>"
  exit 1
else
  STARTSTOP=$1
  shift
  COMMAND=$1
  shift
fi

# All Spark daemons require root
if [ $EUID -ne 0 ]; then
  echo "ERROR: $0 must be run with root authority"
  exit 1
fi

# Setup env
if [ -e ${SNAP}/wrappers/spark-common-wrapper.sh ]; then
  . ${SNAP}/wrappers/spark-common-wrapper.sh
else
  echo "ERROR: Could not find 'spark-common-wrapper.sh':"
  echo "${SNAP}/wrappers/spark-common-wrapper.sh"
  exit 1
fi

# Export daemon (root) writable locations
export SPARK_CONF_DIR=${SNAP_DATA}/etc/spark/conf
export SPARK_LOG_DIR=${SNAP_DATA}/var/log/spark
export SPARK_PID_DIR=${SNAP_COMMON}/var/run/spark

# Daemon uses chown and nohup; set path to prefer the bins packed into the snap
export PATH=${SNAP}/bin:${SNAP}/usr/bin:$PATH

# All spark daemons require config; check for that.
if [ ! -e ${SPARK_CONF_DIR} ]; then
  echo "WARN: Expected Spark configuration not found:"
  echo "${SPARK_CONF_DIR}"
  echo "Daemon cannot be started until config is present."
  exit 0
else
  . ${SPARK_CONF_DIR}/spark-env.sh

  # Run the daemon script
  case $COMMAND in
    history-server|master)
      exec ${SPARK_HOME}/sbin/${STARTSTOP}-${COMMAND}.sh
      ;;
    worker)
      exec ${SPARK_HOME}/sbin/${STARTSTOP}-slave.sh ${SPARK_MASTER_URL}
      ;;
    *)
      echo "ERROR: $COMMAND is not recognized"
      exit 1
  esac
fi
