# SpliceAI
### requirement
```
- pip install spliceai
- pip install tensorflow
- wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz
- wget http://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz

- gcloud auth login
- gsutil cp gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf .

```

### Useage
spliceai -R hg19.fa -I test/Homo_sapiens_assembly38.dbsnp138_info.vcf -O test/Homo.vcf -A grch37

# Pangolin
### requirement
```
# download annotation file
wget https://www.dropbox.com/sh/6zo0aegoalvgd9f/AAA9Q90Pi1UqSzX99R_NM803a/gencode.v38lift37.annotation.db
wget https://www.dropbox.com/sh/6zo0aegoalvgd9f/AADOhGYJo8tbUhpscp3wSFj6a/gencode.v38.annotation.db

# download reference file
cd chromFa
wget ftp://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/chromFa.tar.gz
tar -zxvf chromFa.tar.gz
cat chr*.fa > GRCh37.primary_assembly.genome.fa
samtools faidx GRCh37.primary_assembly.genome.fa
```

### Useage
pangolin test/Homo.vcf chromFa/GRCh37.primary_assembly.genome.fa gencode.v38.annotation.db brca_pangolin