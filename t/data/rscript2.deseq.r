#!/usr/bin/env Rscript
library(DESeq)
thisCountTable = read.table( "t/data/deseq_test_count_table", header=TRUE, row.names=1 )
thisDesign = data.frame(
row.names = colnames(thisCountTable),
condition = c( "treated","treated","treated","untreated","untreated" ),
libType = c( "paired-end","paired-end","paired-end","paired-end","paired-end" ))
pairedSamples = thisDesign$libType == "paired-end"
countTable = thisCountTable[, pairedSamples]
condition = thisDesign$condition[ pairedSamples ]
cds = newCountDataSet( countTable, condition )
cds = estimateSizeFactors( cds )
cds = estimateDispersions(cds, fitType="local")
res = nbinomTest( cds, "untreated", "treated" )
write.csv( res, file="./new_deseq_test_result_table.csv")
