#!/bin/bash
#START=$(date +%s)
START=$(date +%s.%N)
eval $1
# your logic ends here
#END=$(date +%s)
END=$(date +%s.%N)
DIFF=$(echo "$END - $START"|bc)
echo "It took $DIFF seconds"