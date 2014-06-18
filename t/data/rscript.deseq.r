#!/usr/bin/env Rscript
library(DESeq)
thisCountTable = read.table( "./deseq_test", header=TRUE, row.names=1 )
thisDesign = data.frame(
row.names = colnames(thisCountTable),
condition = c( "treated","treated","treated","untreated","untreated" ),
libType = c( "paired-end","paired-end","paired-end","paired-end","paired-end" ))
pairedSamples = thisDesign$libType == "paired-end"
countTable = thisCountTable[, pairedSamples]
condition = thisDesign$condition[ pairedSamples ]
cds = newCountDataSet( countTable, condition )
cds = estimateSizeFactors( cds )
cds = estimateDispersions(cds)
res = nbinomTest( cds, "untreated", "treated" )
write.csv( res, file="deseq_test_result_table.csv")
