#!/bin/sh

CURRENT_DIR=`dirname "$0"`

. $CURRENT_DIR/_common.sh

exe $CURRENT_DIR/../server stop

exe $CURRENT_DIR/setup.sh "$@"

exe $CURRENT_DIR/../server start
