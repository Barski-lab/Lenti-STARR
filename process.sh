#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Please, provide path to two input directories"
    exit 1
fi

if ! [ -x "$(command -v macs2)" ]; then
  echo "Error: macs2 is not installed" >&2
  exit 1
fi

if ! [ -x "$(command -v bedtools)" ]; then
  echo "Error: bedtools is not installed" >&2
  exit 1
fi

if ! [ -x "$(command -v R)" ]; then
  echo "Error: R is not installed" >&2
  exit 1
fi

R -e 'if (!"fitdistrplus" %in% installed.packages()[, "Package"]){quit(save="no", status=1, runLast=FALSE)}' > /dev/null 2>&1
if [ $? -ne 0 ] ; then
  echo "Error: fitdistrplus R package is not installed" >&2
  exit 1
fi

cat > fitdist.R <<EOF
options(error=function(){traceback(3); quit(save="no", status=1, runLast=FALSE)})
suppressMessages(library(fitdistrplus))
args = commandArgs(trailingOnly=TRUE)
data <- read.table(args[1], header=FALSE, sep="\t")
dist_data <- fitdist(data[,4], "nbinom")
cat (qnbinom(0.75, mu=dist_data[["estimate"]][["mu"]], size=dist_data[["estimate"]][["size"]]))
EOF

function preprocess {
    for FILE in $1/*.bam; do
        echo "Processing "$FILE;
        BASE=$(basename -- "$FILE")
        NOEXT="${BASE%.*}"
        echo "Converting BAM to BED keeping all reads"
        macs2 filterdup --keep-dup all -i $FILE -f BAMPE -g 2.7E9 | grep -vwE "(chrM)" > all_$NOEXT.bed
        echo "Converting BAM to BED keeping only unique reads"
        macs2 filterdup --keep-dup 1 -i $FILE -f BAMPE -g 2.7E9 | grep -vwE "(chrM)" > unique_$NOEXT.bed
        echo "Counting duplicate reads"
        bedtools intersect -c -a unique_$NOEXT.bed -b all_$NOEXT.bed > counts_$NOEXT.bed
        echo "Calculating 75th quantile of read duplication rate"
        DUPRATE=$(Rscript fitdist.R counts_$NOEXT.bed)
        echo "Converting BAM to BED keeping only ${DUPRATE} tags at the same location"
        macs2 filterdup --keep-dup $DUPRATE -i $FILE  -f BAMPE -g 2.7E9 | grep -vwE "(chrM)" > quantile_$NOEXT.bed
        echo "Removing temporary data"
        rm -f all_$NOEXT.bed unique_$NOEXT.bed counts_$NOEXT.bed
    done;
    echo "Concatenating all quantiled files"
    cat quantile_* | sort -k1,1 -k2,2n > $2_concatenated.bed
    rm quantile_*
}

#######################################################################################################################

TM_DIRECTORY=$1
CL_DIRECTORY=$2

preprocess $TM_DIRECTORY tm
preprocess $CL_DIRECTORY cl

echo "Calling peaks Enhancers ::(tx -t) STARR-Seq Reads  / (control -c) Control Plasmid Reads"
mkdir res_tm_cl && cd res_tm_cl
macs2 callpeak -f BEDPE --keep-dup all -t ../tm_concatenated.bed -c ../cl_concatenated.bed -g 2.7E9 -n res_tm_cl || true
cd ..

echo "Calling peaks NRE ::(tx -t) Control Plasmid Reads / (control -c) STARR-Seq Reads"
mkdir res_cl_tm && cd res_cl_tm
macs2 callpeak -f BEDPE --keep-dup all -t ../cl_concatenated.bed -c ../tm_concatenated.bed -g 2.7E9 -n res_cl_tm || true
cd ..