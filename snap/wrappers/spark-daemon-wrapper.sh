#!/bin/bash

###############################################################################
# Wrapper for spark daemons
###############################################################################

# Verify args
if [ $# -lt 2 ]; then
  echo "ERROR: Missing required arguments:"
  echo "$0 <start|stop> <master|worker|history-server> <args...>"
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

# Daemon uses nohup; set path to prefer the bins packed into the snap
export PATH=${SNAP}/usr/bin:$PATH

# All spark daemons require config; check for that.
SPARK_CONF_DIR=${SNAP_DATA}/etc/spark/conf
if [ ! -e ${SPARK_CONF_DIR} ]; then
  echo "WARN: Expected Spark configuration not found:"
  echo "${SPARK_CONF_DIR}"
  echo "Daemon cannot be started until config is present."
  exit 0
else
  # Run the daemon script, adapted from ./bigtop-packages/src/common/spark/*.svc
  . ${SPARK_CONF_DIR}/spark-env.sh
  DAEMON_LOG=${SNAP_DATA}/var/log/spark/spark-$COMMAND.out
  DAEMON_PID=${SNAP_DATA}/var/run/spark/spark-$COMMAND.pid
  case $COMMAND in
    history-server)
      exec nohup ${SNAP/wrappers/spark-class org.apache.spark.deploy.history.HistoryServer \
        "$@" > $DAEMON_LOG 2>&1 &
      echo $! > $DAEMON_PID
    master)
      if [ "$SPARK_MASTER_IP" = "" ]; then
        SPARK_MASTER_IP=`hostname`
      fi
      exec nohup ${SNAP/wrappers/spark-class org.apache.spark.deploy.master.Master \
        --ip $SPARK_MASTER_IP "$@" > $DAEMON_LOG 2>&1 &
      echo $! > $DAEMON_PID
      ;;
    worker)
      exec nohup ${SNAP/wrappers/spark-class org.apache.spark.deploy.worker.Worker \
        $SPARK_MASTER_URL "$@" > $DAEMON_LOG 2>&1 &
      echo $! > $DAEMON_PID
    *)
      echo "ERROR: $COMMAND is not recognized"
      exit 1
  esac
fi
