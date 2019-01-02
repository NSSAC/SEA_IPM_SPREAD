# Clustering ranked cells based on ...
# AA: 2018-12-24
library(Rankcluster)
library(optparse)

startTime=proc.time()
# options
option_list = list(
  make_option(c("-i", "--input_ranked_data"), type="character", default=NULL, 
              help="<instance,<comma separated ranked cells>"),
  make_option(c("-o", "--out"), type="character", default="cluster_out.csv", 
              help="output file <instance,cluster>"),
  make_option(c("-k", "--number_of_clusters"), type="integer", default=2, 
              help="")
)

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# Read data
print(opt$input_ranked_data)
cellRankList=read.csv(opt$input_ranked_data, row.names = 1, header= TRUE, sep=",")

# convert cellRankList (typeof(cellRankList)=list) to matrix
# unlist breaks it down to components
cellRanks=matrix(unlist(cellRankList,use.names=FALSE),ncol=ncol(cellRankList),nrow=nrow(cellRankList),byrow=FALSE) 
typeof(cellRanks[1:50])

# convert to 1 to ncol(cellRanks)
## factor(vector,distinct_values,corresponding_labels) does the substitution.
## But, factor converts (i) labels to strings; and (ii) matrix to vector.
## strtoi() converts back strings to integers.
## matrix() reshapes the vector.
cellRanksStandardized=matrix(strtoi(factor(cellRanks,sort(cellRanks[1,]),seq(1,ncol(cellRankList)))),nrow=nrow(cellRanks),byrow=FALSE)

# Cluster
cellRanksStandardized=cellRanksStandardized[1:10,]
dim(cellRanksStandardized)
res=rankclust(cellRanksStandardized,m=ncol(cellRanksStandardized),K=2:opt$number_of_clusters,Qsem=100,Bsem=10,Ql=50,Bl=5, maxTry=10,run=10)

proc.time()-startTime
