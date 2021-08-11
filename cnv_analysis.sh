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
samtools view -bSq 30 $line.sam > $line.bam

echo "          Sort the bam file "
samtools sort $line.bam  $line.sorted.bam
81)
echo "          Remove reads likely to be PCR duplicates "
samtools rmdup -s $line.sorted.bam  $line.rmdup.bam
82)
echo "          Create a bam file index "
samtools index $line.rmdup.bam

echo "          bam to bed conversion "
# bam to bed conversion  
bamToBed -i $line.rmdup.bam | cut -f 1,2,3,4,5,6 | sort -T . -k1,1 -k2,2n -S 5G > $line.bed

echo "          bed line number calculate "
# bed line number calculate  
x=`wc -l $line.bed | cut -d' ' -f 1`

echo "          generate coverage on genomic windows"
# generate coverage on genomic windows  
bedtools intersect -sorted -c -b $line.bed -a /home/chenjiale/project/cnv/dm6_windows_50k.bed |awk -vx=$x '{print $1,$2,$3,$4*1e+06/x}' OFS='\t' > $line.bg


echo End time: `date`

