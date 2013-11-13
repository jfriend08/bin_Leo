: << 'END'
for i in $(ls -d Sample_Naoki*)
do
	gunzip $i/R1.fastq.gz &
	gunzip $i/R2.fastq.gz &
	
done
wait


for i in $(ls -d Sample_Naoki*)
do
	nohup bwa aln /aslab_scratch001/asboner_dat/zebrafish/artificialIndex_zv9/artificial_zv9.fa $i/R1.fastq.gz 1> $i/R1.sai 2> $i/R1.error &
	nohup bwa aln /aslab_scratch001/asboner_dat/zebrafish/artificialIndex_zv9/artificial_zv9.fa $i/R2.fastq.gz 1> $i/R2.sai 2> $i/R2.error &

done
wait

for i in $(ls -d Sample_Naoki*)
do
	nohup bwa sampe /aslab_scratch001/asboner_dat/zebrafish/artificialIndex_zv9/artificial_zv9.fa $i/R1.sai $i/R2.sai $i/R1.fastq.gz $i/R2.fastq.gz 1> $i/10.sam 2> $i/sampe.err &

done
wait

for i in $(ls -d Sample_Naoki*)
do

	samtools view -Sh -F 4 $i/10.sam | samtools view -Sh -F 8 $i/10.sam 1> $i/10_filtered.sam 2> sam.err
done
wait

for i in $(ls -d Sample_Naoki*)
do
	sort -k1,1 $i/10_filtered.sam | sam2mrf 1> $i/10.mrf &
done
wait
END

for i in $(ls -d Sample_Naoki*)
do

	samtools view -Sh -b $i/10_filtered.sam | samtools sort - $i/10
done
wait

for i in $(ls -d Sample_Naoki*)
do

	samtools index $i/10.bam

done
wait

