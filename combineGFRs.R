## Combining the GFRs:
## USE: R CMD BATCH --no-save --no-restore '--args sample="RCS-15" gfrDir="GFR.1" metaDir="." minNum=4' ~/bin/combineGFRs.R combineGFR.Rout

combineGFRs <- function( gfr1, gfr2) {
  gfr1$id2 = paste( gfr1$nameTranscript1, gfr1$nameTranscript2, sep="-@-" )
  gfr2$id2 = paste( gfr2$nameTranscript1, gfr2$nameTranscript2, sep="-@-" )
  idx = match( gfr1$id2, gfr2$id2 );
  if( !all( gfr1$id2[ !is.na(idx)] == gfr2$id2[ idx[!is.na(idx)]]) ) stop("IDs do not correspond")
  print("Combining matching fusions")
  ## combining the matched ones
  gfr = gfr1
  
  ## numInter
  gfr$numInter  [ !is.na(idx) ] = gfr$numInter[ !is.na(idx) ] + gfr2$numInter[ idx[!is.na(idx)] ]
  
  ## interMeans : TO DO
  
  ## pvalues 
  idx.diff = (gfr$pValueAB[ !is.na(idx) ] < gfr2$pValueAB[ idx[!is.na(idx)] ]);idx.diff
  if( !all( gfr$id2 [     !is.na(idx)  ] [ idx.diff ] == gfr2$id2[ idx[!is.na(idx)] ] [ idx.diff ]) )  stop("IDs do not match: PVALUES AB") ## MUST BE TRUE
  #gfr$pValueAB [     !is.na(idx)  ] [ idx.diff ] ## checking
  #gfr2$pValueAB[ idx[!is.na(idx)] ] [ idx.diff ] ## checking
  if( length(idx.diff)>0 ) gfr$pValueAB[ !is.na(idx) ][ idx.diff ] = gfr2$pValueAB[ idx[!is.na(idx)] ] [ idx.diff ]
  
  idx.diff = (gfr$pValueBA[ !is.na(idx) ] < gfr2$pValueBA[ idx[!is.na(idx)] ]);idx.diff
  if( ! all( gfr$id2 [     !is.na(idx)  ] [ idx.diff ] == gfr2$id2[ idx[!is.na(idx)] ] [ idx.diff ])) stop("IDs do not match: PVALUES BA") ## MUST BE TRUE
  #gfr$pValueBA [     !is.na(idx)  ] [ idx.diff ] ## checking
  #gfr2$pValueBA[ idx[!is.na(idx)] ] [ idx.diff ] ## checking
  if( length(idx.diff)>0 ) gfr$pValueBA[ !is.na(idx) ][ idx.diff ] = gfr2$pValueBA[ idx[!is.na(idx)] ] [ idx.diff ]
  
  ## numIntras
  gfr$numIntra1 [ !is.na(idx) ] = gfr$numIntra1[ !is.na(idx) ] + gfr2$numIntra1[ idx[!is.na(idx)] ]
  gfr$numIntra2 [ !is.na(idx) ] = gfr$numIntra2[ !is.na(idx) ] + gfr2$numIntra2[ idx[!is.na(idx)] ]
  
  ## interReads
  gfr$interReads = as.character(gfr$interReads)
  gfr$interReads[ !is.na(idx) ] = paste( as.character(gfr$interReads[ !is.na(idx) ]), as.character(gfr2$interReads[ idx[!is.na(idx)] ]), sep="|") 
  
  ##reads
  gfr$readsTranscript1 = as.character( gfr$readsTranscript1 )
  gfr$readsTranscript2 = as.character( gfr$readsTranscript2 )
  gfr$readsTranscript1[ !is.na(idx) ] = paste( as.character(gfr$readsTranscript1[ !is.na(idx) ]), as.character(gfr2$readsTranscript1[ idx[!is.na(idx)] ]), sep="|") 
  gfr$readsTranscript2[ !is.na(idx) ] = paste( as.character(gfr$readsTranscript2[ !is.na(idx) ]), as.character(gfr2$readsTranscript2[ idx[!is.na(idx)] ]), sep="|") 
  
  ## adding the remaining gfr2, if any
  idx2.notInGfr1 = !(gfr2$id2 %in% gfr1$id2);idx2.notInGfr1
  if( length(which( idx2.notInGfr1))>0 ) {
    print("adding singletons")
    gfr = rbind( gfr, gfr2[ idx2.notInGfr1, ])
  }
  return( gfr )
}


args= (commandArgs(TRUE) )
if( length(args)<3 ) stop("Arguments required: %s", args)


for( i in 1:length(args))
  eval(parse(text=args[[i]]))

if ( file.exists( sprintf("%s.1.gfr.gz", sample) ) ) stop("File 1.gfr exists")
print(sprintf("%s*.1.gfr.gz", sample))
files = list.files(gfrDir, pattern=sprintf("%s_[0-9]*.1.gfr.gz", sample),full.names=T);files
if( !file.exists( files[1] ) ) stop ("No GFR file: ", files[1] );
print(files[1])
print(getwd())
GFR = read.delim(files[1], header=TRUE) ;print(dim(GFR))
for( f in files[-1] ) {
  if( !file.exists( f ) ) stop ("No GFR file: ", f );
  currGFR = read.delim( f, header=T);print(sprintf("current GFR (%s): %s", f, nrow(currGFR)))
  GFR = combineGFRs( GFR, currGFR );print(sprintf("added %s for a total %s", f, nrow(GFR) ))
}
print(minNum)
GFR = GFR[ GFR$numInter > minNum, ] ## selecting only those with more than minNum reads 
GFR = GFR[ sort.list(GFR$numInter, decr=TRUE), -(grep("id2",colnames(GFR))) ] ## sorting and formatting
GFR$id = sprintf("%s_%05d", sample, 1:nrow(GFR))
fileName = sprintf("%s/%s.1.gfr", gfrDir, sample);print(fileName)
write.table( GFR, file=fileName, row.names=F, sep="\t", quote=F)
system2(command="gzip", args=c("--force", fileName ), stdout=TRUE)

## META files
files = list.files(metaDir, pattern=sprintf("%s\\_[0-9]*\\.meta", sample), full.names=T);files
if( !( length(files) > 1) ) stop("Not enough files")
if( !file.exists( files[1] ) ) stop ("File does not exist", files[1])
meta = read.delim(files[1], header=F, colClasses=c("factor","integer"))
#IDX.total  = (meta[,1] =="Total_number_reads")
IDX.mapped = (meta[,1] =="Mapped_reads")
if( length(which(IDX.mapped))!=1 ) stop("Can't find meta information")
for( f in files[-1] ) {
  if( !file.exists( f ) ) stop ("File does not exist", f)

  currMeta = read.delim( f, header=F, colClasses=c("factor","integer") )
#  idx.total  = (currMeta[,1] == "Total_number_reads")
  idx.mapped = (currMeta[,1] == "Mapped_reads")
  #if( length(which(idx.total))!=1 | length(which(idx.mapped))!=1 ) stop("Can't find meta information")
  #meta[ IDX.total,  2] = meta[ IDX.total,  2] + currMeta[ idx.total,  2]
  meta[ IDX.mapped, 2] = meta[ IDX.mapped, 2] + currMeta[ idx.mapped, 2]
}
write.table( meta, file=sprintf("%s/%s.meta", metaDir, sample), col.names=F, row.names=F, sep="\t", quote=F)

