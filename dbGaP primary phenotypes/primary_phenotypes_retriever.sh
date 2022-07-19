# retrieve the list of studies that we analyzed

awk -F',' '{print $(NF-1)}' summary_fourth.csv | sed "s/\.\/data\///g;s/\./ /g" | awk '{print $1"."$2"."$5}' | sort -u > study_list.txt

# split study_list.txt into multiple files

mkdir tmp
split --number=4 study_list.txt tmp/

# curl the primary phenotypes for the studies in each file in parallel

task(){
	for i in `cat $1`; do
    	curl -s "https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=$i" | grep -i -A 2 "primary phenotype" | grep mesh | perl -ne '$_=~ s/\[uid\]\"\>/\t/g;$_=~ s/\<\/a\>//g; print $_;'  | awk -F'\t' '{printf "%s\t%s\n","'$i'",$NF}' > primary_phenotypes/"$i".txt;
    done
}

for i in `ls tmp/*`; do
	task $i;	 
done

# gather all the phenotypes

cat primary_phenotypes/* | sed 's/<[^~]*>//g;s/\t/ /g' | tr -s ' ' | sort -u | sed -r 's/\s+/\t/' > dbGaP_primary_phenotypes.tsv 

# plot using the jupyter notebook