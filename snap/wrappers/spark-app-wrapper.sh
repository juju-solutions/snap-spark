#!/bin/bash

###############################################################################
# Wrapper for spark-related applications
###############################################################################

# Setup config/env
if [ -e ${SNAP}/wrappers/spark-common-wrapper.sh ]; then
  . ${SNAP}/wrappers/spark-common-wrapper.sh
else
  echo "ERROR: Could not find 'spark-common-wrapper.sh':"
  echo "${SNAP}/wrappers/spark-common-wrapper.sh"
  exit 1
fi

# All spark apps require config; check for that.
SPARK_CONF_DIR=${SNAP_DATA}/etc/spark/conf
if [ ! -e ${SPARK_CONF_DIR} ]; then
  echo "ERROR: Expected Spark configuration not found:"
  echo "${SPARK_CONF_DIR}"
  exit 1
else
  . ${SPARK_CONF_DIR}/spark-env.sh

  # Run the application
  COMMAND=`basename $0`
  case $COMMAND in
    spark-class|spark-shell|spark-sql|spark-submit|find-spark-home|pyspark|run-example)
      exec ${SPARK_HOME}/bin/$COMMAND "$@"
      ;;
    *)
      echo "ERROR: $0 is not recognized"
      exit 1
  esac
fi
