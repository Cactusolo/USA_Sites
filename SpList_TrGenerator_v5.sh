#! /bin/bash
# this version is used to update the resultant opnetree with branches
#based on an updated species list (ott and TPLquery)
#loading models
ml phyx R newickutils

#inpute a site name
Site=$1

rm -fr ${Site}/Opentree_0607

#put all the data for match Opentree under one directory--""
mkdir ${Site}/Opentree_0607
cd ${Site}/Opentree_0607
##########################################################################################
echo -e "\n Step1: staring from species list, then format it as query to Opentree...\n"

cut -f1 -d ',' ../species_list/${Site}_update.csv|sort|uniq|sed 's/_/ /g' >${Site}_query_ottid
Query_number=$(wc -l ../species_list/${Site}_update.csv|cut -f1 -d' ')
Dupl_name=$(cut -f1 -d ',' ../species_list/${Site}_update.csv|sort|uniq -d|wc -l)
cut -f1 -d ',' ../species_list/${Site}_update.csv|sort|uniq -d >${Site}_duplicate_aft_ott.txt
List_number=$(wc -l ${Site}_query_ottid|cut -f1 -d' ')
########################
echo -e "\n\n "$Query_number" species in the query, "$Dupl_name" duplicated names will be removed, \n "$List_number" species remained in the query list for "$Site" site\n"

#using Opentree_pytoy to get ottids
##########################
echo -e "\n using Opentree_pytoy to get ottids\n"

python /ufrc/soltis/cactus/Dimension/Community_Opentree/opentree_pytoys/src/get_ottids_for_taxa.py ${Site}_query_ottid >${Site}_species_names_ottids

cut -f2 ${Site}_species_names_ottids|sort|uniq -d|sed 's/^/ott/g' >${Site}_duplicate_ottids.txt
Dupl_ott=$(wc -l ${Site}_duplicate_ottids.txt|cut -f1 -d' ')

#prepare a file just containing ottids for subsestting from the Opentree

awk -F '\t' '{print "ott"$2}' ${Site}_species_names_ottids >${Site}_justids.ottids

######################################OTT_Tree################################################
echo -e "\n Step2: query opentree based on ottids using vas_opentree_9.1.tre \n"

pxtrt -t /ufrc/soltis/cactus/Dimension/Community_Opentree/Stephen_Brown_tree/vas_opentree_9.1.tre -f ${Site}_justids.ottids >${Site}_ottid_0607.tre 2>${Site}_miss_match_back_0607.txt

sed -i 's/ not in tree//g' ${Site}_miss_match_back_0607.txt

pxcltr -t ${Site}_ottid_0607.tre >${Site}_ottid_clean_0607.tre

Tip_num=$(nw_labels -I ${Site}_ottid_clean_0607.tre|wc -l|cut -f1 -d' ')

######################
echo -e "\n There are "$Dupl_ott" duplicate ottids, "$Tip_num" ottids mapped to the "${Site}_ottid_clean.tre"\n"

#giving a summary how many names missed
echo -e "\n giving a summary how many names missed ...\n"
echo `wc -l *miss_match_back_0607.txt`|sed -e 's/txt/txt\n/g'
echo `wc -l *.nomatch.txt`|sed -e 's/txt/txt\n/g'

###############################OTT_BR_Tree###################################################
echo -e "\n Step3: query opentree based on ottids using ALLOTB_ottid.tre \n"
#Step3: query opentree based on ottids using 

# all vascular plants on OTL: vas_opentree_9.1.tre
# ALLOTB_ottid.tre
# ALLOTB_sp_name.tre
# GBOTB_sp_name.tre
# GBOTB_ottid.tre

echo -e "\n query opentree based on ottids...\n"
pxtrt -t /ufrc/soltis/cactus/Dimension/Community_Opentree/Stephen_Brown_tree/ALLOTB_ottid.tre -f ${Site}_justids.ottids >${Site}_BR_ottid_0607.tre 2>${Site}_BR_miss_match_back_0607.txt

sed -i 's/ not in tree//g' ${Site}_BR_miss_match_back_0607.txt

pxcltr -t ${Site}_BR_ottid_0607.tre >${Site}_BR_ottid_clean_0607.tre

Tip_num_BR=$(nw_labels -I ${Site}_BR_ottid_clean_0607.tre|wc -l|cut -f1 -d' ')

echo -e "\n There are "$Tip_num_BR" ottids mapped to the "${Site}_BR_ottid_clean_0607.tre"\n"

##########################################################################################
echo -e "\n\n Step4:converting ottids to species names for subtree..."

#considering convert_ottids_names.py is not working properly, renaming tree using newickutils

# ott_tree
nw_labels -I ${Site}_ottid_clean_0607.tre >ott_tips
awk -F '\t' '{print "ott"$2","$1}' ${Site}_species_names_ottids|sed 's/ /_/g;s/,/ /g' >${Site}_species_names_ottids.tmp

grep -f ott_tips ${Site}_species_names_ottids.tmp >ott_tips_rename.map

grep -f ${Site}_duplicate_ottids.txt ott_tips_rename.map >${Site}_duplicate_ottid_name.txt

nw_rename ${Site}_ottid_clean_0607.tre ott_tips_rename.map| pxcltr >../tree/${Site}_speciesname_0607.tre

# ott_BR_tree
nw_labels -I ${Site}_BR_ottid_clean_0607.tre >ott_BR_tips

grep -f ott_BR_tips ${Site}_species_names_ottids.tmp >ott_BR_tips_rename.map

nw_rename ${Site}_BR_ottid_clean_0607.tre ott_BR_tips_rename.map| pxcltr >../tree/${Site}_speciesname_BR_0607.tre

##########################################################################################
echo -e "\n\n Step5: Generateing a summary table ...\n\n"
#echo "Site,Org_query,Syn_tip,No_Match,BR_tip,Upt_query,Dupl_name,Dupl_ott,Upt_Syn_tip,NO_Qmatch,Upt_BR_tip,miss_mapBack,good,Syn_NoBr,Br_NoSyn" >../../OTL_update_summary_0607.csv

Org_query=$(wc -l ../species_list/${Site}.csv|cut -f1 -d' ')

nw_labels -I ../tree/${Site}_speciesname_0607.tre|sort|uniq >${Site}_speciesname_0607.txt
nw_labels -I ../tree/${Site}_speciesname_BR_0607.tre|sort|uniq >${Site}_speciesname_BR_0607.txt

Syn_tip=$(wc -l ${Site}_speciesname_0607.txt|cut -f1 -d' ')
BR_tip=$(wc -l ${Site}_speciesname_BR_0607.txt|cut -f1 -d' ')

sort ${Site}_speciesname_0607.txt ${Site}_speciesname_BR_0607.txt|uniq -d >${Site}_good_list.txt
good=$(wc -l ${Site}_good_list.txt|cut -f1 -d' ')

sort ${Site}_speciesname_0607.txt ${Site}_good_list.txt|uniq -u >${Site}_Syn_NoBr_upt.txt
Syn_NoBr=$(wc -l ${Site}_Syn_NoBr_upt.txt|cut -f1 -d' ')
grep -f ${Site}_Syn_NoBr_upt.txt ${Site}_species_names_ottids.tmp >${Site}_Syn_NoBr_upt_ott.txt

sort ${Site}_speciesname_BR_0607.txt ${Site}_good_list.txt|uniq -u >${Site}_Br_NoSyn_upt.txt
Br_NoSyn=$(wc -l ${Site}_Br_NoSyn_upt.txt|cut -f1 -d' ')

grep -f ${Site}_Br_NoSyn_upt.txt ${Site}_species_names_ottids.tmp >${Site}_Br_NoSyn_upt_ott.txt
No_Match=$(cat ../species_list/${Site}_NO-match.csv|sed '1d'|wc -l)
No_Qmatch=$(cat ${Site}_query_ottid.nomatch.txt|wc -l)
mis_mthbck=$(cat ${Site}_BR_miss_match_back_0607.txt|wc -l)
echo -e "${Site},${Org_query},${Syn_tip},${No_Match},${BR_tip},${Query_number},${Dupl_name},${Dupl_ott},${Tip_num},${No_Qmatch},${Tip_num_BR},${mis_mthbck},$good,${Syn_NoBr},${Br_NoSyn}" >>../../OTL_update_summary_0607.csv

rm *.tmp
cd ../..

exit 0