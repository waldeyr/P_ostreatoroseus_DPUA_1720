### This script takes the annotation results files i) Unifire_annotations.out and ii) CAZy_results.txt and merge them according certain selection criteria
### Waldeyr Mendes Cordeiro da Silva, Nov. 2020
library(readr)
library(dplyr)
library(tidyr)

## UNIFIRE RESULTS
Unifire_annotations <- read_delim("Unifire_annotations.out", 
                                  "\t", escape_double = FALSE, locale = locale(), 
                                  trim_ws = TRUE)
colnames(Unifire_annotations)
Unifire_annotations <- Unifire_annotations %>% select(c('ProteinId','AnnotationType','Value'))
unique(Unifire_annotations$AnnotationType)

## Obatin fullname + similarity
df_fullname <- Unifire_annotations %>% filter(AnnotationType == 'protein.recommendedName.fullName') 
df_similarity <- Unifire_annotations %>% filter(AnnotationType == 'comment.similarity')
df_fullname_similarity <- merge(df_fullname, df_similarity, by="ProteinId", all = TRUE)
colnames(df_fullname_similarity) <- c("ProteinId", "AnnotationTypeFullName", "FullName", "AnnotationTypeSimilarity", "Similariry")
df_fullname_similarity <- within(df_fullname_similarity, rm("AnnotationTypeFullName", "AnnotationTypeSimilarity"))
# dim(df_fullname_similarity)
# head(df_fullname_similarity)


## Obtain fullname + similarity + EC
df_ecnumber <- Unifire_annotations %>% filter(AnnotationType == 'protein.recommendedName.ecNumber')
df_fullname_similarity_ec <- merge(df_fullname_similarity, df_ecnumber, by="ProteinId", all = TRUE)
colnames(df_fullname_similarity_ec) <- c("ProteinId", "FullName", "Similariry", "toRemove", "EC")
df_fullname_similarity_ec <- within(df_fullname_similarity_ec, rm("toRemove"))
# dim(df_fullname_similarity)
# head(df_fullname_similarity_ec)


## CAZY RESULTS
CAZy_annotations <- read_delim("CAZy_results.txt", 
                           "\t", escape_double = FALSE, comment = "#", 
                           trim_ws = TRUE)
colnames(CAZy_annotations)
CAZy_annotations <- separate(data = CAZy_annotations, col = `Gene ID`, into = c("ProteinId", "toRemove"), sep = "\\|")
CAZy_annotations <- within(CAZy_annotations, rm("toRemove"))
# dim(CAZy_annotations)
# head(CAZy_annotations)


## Obtain fullname + similarity + EC + Cazy
df_fullname_similarity_ec_cazy <- merge(df_fullname_similarity_ec, CAZy_annotations, by="ProteinId", all = TRUE)
head(df_fullname_similarity_ec_cazy)
colnames(df_fullname_similarity_ec_cazy) <- c('ProteinId', 'FullName', 'Similariry', 'EC', 'CAZy_HMMER', 'CAZy_Hotpep', 'CAZy_DIAMOND', 'Signalp')
# dim(df_fullname_similarity_ec_cazy)
# head(df_fullname_similarity_ec_cazy)

# Remove duplicated lines
df_fullname_similarity_ec_cazy <- df_fullname_similarity_ec_cazy %>% distinct()
df_fullname_similarity_ec_cazy <- df_fullname_similarity_ec_cazy[!duplicated(df_fullname_similarity_ec_cazy$ProteinId), ]
# dim(df_fullname_similarity_ec_cazy)
# head(df_fullname_similarity_ec_cazy)

# Write the fina result in a tsv file
write.table(df_fullname_similarity_ec_cazy, file = "P_ostreatoroseus_fullname_similarity_ec_CAZy.tsv", row.names=FALSE, sep="\t")