#!/bin/bash

echo "          Info of this Script:   Designed by Jiale Chen"
echo "          Attention:             If you have some problems, Please contact chenjiale@sklmg.edu.cn"

echo "          Generate sample file "

cd Rawdata/
ls *gz |sed 's/_[12].fastq.gz//'|sort -u > ../sample.txt
cd ..

if [ ! -d bam ];then
    echo "mkdir bam"
    mkdir -p bam
fi 

echo "          Mapping to reference genome "
# Mapping 
cat sample.txt|while read line ;do bowtie2 -x /home/reference/Dmelanogaster/UCSC/dm6/Sequence/Bowtie2Index/dm6 -p 20 -1 Rawdata/$line'_1.fastq.gz' -2 Rawdata/$line'_2.fastq.gz' -S $line.sam ;done

echo "          Convert sam to bam "
# sam to bam conversion  
cat sample.txt|while read line ;do samtools view -bSq 30 $line.sam > $line.bam ;done

echo "          Sort the bam file "
cat sample.txt|while read line ;do samtools sort $line.bam  $line.sorted.bam;done

echo "          Remove reads likely to be PCR duplicates "
cat sample.txt|while read line ;do samtools rmdup -s $line.sorted.bam  $line.rmdup.bam;done

echo "          Create a bam file index "
cat sample.txt|while read line ;do samtools index $line.rmdup.bam;done

echo "          bam to bed conversion "
# bam to bed conversion  
cat sample.txt|while read line ;do bamToBed -i $line.rmdup.bam | cut -f 1,2,3,4,5,6 | sort -T . -k1,1 -k2,2n -S 5G > $line.bed;done

echo "          bed line number calculate "
# bed line number calculate  
x=`wc -l $line.bed | cut -d' ' -f 1`

echo "          generate coverage on genomic windows"
# generate coverage on genomic windows  
cat sample.txt|while read line ;do bedtools intersect -sorted -c -b $line.bed -a /home/chenjiale/project/cnv/dm6_windows_50k.bed |awk -vx=$x '{print $1,$2,$3,$4*1e+06/x}' OFS='\t' > $line.bg;done


echo End time: `date`

