library("ape")

Site.list <- c("Coweeta", "Havard", "Mountain_Lake", "Ordway", "Talladega", "White_Mountain")
Sum <- read.csv("Summary_USA_Sites.csv", stringsAsFactors=FALSE, header = TRUE)
colnames(Sum) <- c("Site", "Org_query", "Syn_tip", "BR_tip", "No_Match", "Upt_query", "Dupl_name", "Dupl_ott", "Upt_Syn_tip", "Upt_BR_tip", "NO_Qmatch", "miss_mapBack", "good")
Sum <- as.data.frame(Sum)
Sum <- Sum[-1,]
 for (i in 1:length(Site.list)) {
   Tree_BR <- read.tree(paste0(Site.list[i], "/tree/", Site.list[i], "_speciesname_BR_0607.tre", sep=""))
   Tree_BR <- ladderize(Tree_BR)
   
   Tree_Syn <- read.tree(paste0(Site.list[i], "/tree/", Site.list[i], "_speciesname_0607.tre", sep=""))
   Tree_Syn <- ladderize(Tree_Syn)
   pdf(paste0("Comparision_syn_Tree_and_BR_Tree_for_", Site.list[i], ".pdf", sep=""))
   
   par(mfrow=c(1,2))
   plot.phylo(Tree_Syn, edge.color="red", show.tip.label = FALSE, main=paste0(Site.list[i], "_Syn", sep=""))
   mtext(paste0("Total=", Sum$Org_query[i], "\nSyn_Tips=", Sum$Upt_Syn_tip[i],"\nNo_Map=", Sum$No_Match[i]), side=1, cex=0.5)
   plot.phylo(Tree_BR, edge.color="blue", show.tip.label = FALSE, main=paste0(Site.list[i], "_BR", sep=""))
   mtext(paste0("BR_Tips=", Sum$Upt_BR_tip[i], "\nMiss_MapBack=", Sum$miss_mapBack[i],"\nNo_Map=", Sum$No_Match[i], "\nDuplicates=", Sum$Dupl_name[i], "+", Sum$Dupl_ott[i]), side=1, cex=0.5)
   
   dev.off()
 }

