library("rotl")
library("Taxonstand")
nomatch.list <- list.files("./Opentree_query", pattern="_query_ottid.nomatch.txt", full.names=TRUE)
path.name <- "./Opentree_query/"

parts <- unlist(strsplit(basename(nomatch.list), split="_"))
Sitename <- paste0(parts[1], sep="_", parts[2])

query <- read.csv(nomatch.list, header=FALSE, stringsAsFactors=FALSE)

resolved_names <- tnrs_match_names(query$V1, context_name = "Land plants")
write.csv(resolved_names, paste0(path.name, Sitename, "_query_ottid.nomatch_OttQery.csv", sep=""))

#TPL
TPL_results <- TPL(query$V1, infra = TRUE, diffchar=2, max.distance=1, corr=TRUE, encoding = "UTF-8")
write.csv(TPL_results, paste0(path.name, Sitename, "_query_ottid.nomatch_TPLQery.csv", sep=""))
