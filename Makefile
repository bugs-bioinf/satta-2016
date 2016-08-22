STRAINS=02.113 03.013 03.313 04.018 04.211 04.503 05.094 07.116 02.292 03.039 04.011 04.194 04.493 05.046 05.177 07.118 H37Rv

CPUS=1
REF=NC_000962

## file locations
GENOMES    = genomes
ALIGNMENTS = alignments
ASSEMBLIES = assemblies
PHYLOGENY  = phylogeny
CIRCOS     = circos
DATA       = data
VCF        = vcf

## exe locations

## Workflow

indexed = $(addsuffix .bwt, $(GENOMES)/$(REF).fna )
bam     = $(addprefix $(ALIGNMENTS)/$(REF)_, $(addsuffix .bam, $(STRAINS) ) )
vcf     = $(addprefix $(VCF)/$(REF)_, $(addsuffix .vcf, $(STRAINS) ) )
sites   = $(addprefix $(VCF)/$(REF)_, $(addsuffix .all.vcf.gz, $(STRAINS) ) )
contigs = $(addprefix $(ASSEMBLIES)/, $(STRAINS) )
rings   = $(addprefix $(CIRCOS)/$(REF)_, $(addsuffix .txt, $(STRAINS) ) )

all: index alignments sites trees
index: $(indexed)
alignments: $(bam)
sites: $(sites)
snps: $(vcf)
assemblies: $(contigs)

circosrings: $(rings)

versions:
	@samtools 2>&1 | grep Version | perl -p -e 's/Version/samtools/' > versions.txt
	@bwa 2>&1 | grep Version | perl -p -e 's/Version/bwa/' >> versions.txt
	@spades.py -h 2>&1 | grep "SPAdes genome assembler" | perl -p -e 's/SPAdes genome assembler v.(\d+.\d+.\d+)/SPAdes: \1/' >> versions.txt
	@raxmlHPC-PTHREADS-SSE3 -v | grep "RAxML version" | perl -p -e 's/.+RAxML version (\d+.\d+.\d+).+/RAxML: \1/' >> versions.txt

$(GENOMES)/$(REF).fna.bwt:
	bwa index $(GENOMES)/$(REF).fna

$(VCF)/$(REF)_%.all.vcf.gz: $(ALIGNMENTS)/$(REF)_%.bam
	samtools mpileup -gf $(GENOMES)/$(REF).fna $(ALIGNMENTS)/$(REF)_$*.bam | bcftools view -cg - > $(VCF)/$(REF)_$*.all.vcf
	gzip -S .gz $(VCF)/$(REF)_$*.all.vcf

$(VCF)/$(REF)_%.vcf: $(ALIGNMENTS)/$(REF)_%.bam
	samtools mpileup -gf $(GENOMES)/$(REF).fna $(ALIGNMENTS)/$(REF)_$*.bam | bcftools view -bvcg - > $(VCF)/$*.raw.bcf && bcftools view $(VCF)/$*.raw.bcf  | vcfutils.pl varFilter -D 100 > $@
	rm $(VCF)/$*.raw.bcf

$(ALIGNMENTS)/$(REF)_%.bam: $(GENOMES)/$(REF).fna.bwt
	bwa mem -t $(CPUS) $(GENOMES)/$(REF).fna $(DATA)/$*_1.fastq.gz $(DATA)/$*_2.fastq.gz | samtools view -bS - | samtools sort -o - $(ALIGNMENTS)/temp.$* | samtools rmdup - - > $(ALIGNMENTS)/$(REF)_$*.bam
	samtools index $@

$(ASSEMBLIES)/%:
	spades.py --careful -o $(ASSEMBLIES)/$*/ -1 $(DATA)/$*_1.fastq.gz -2 $(DATA)/$*_2.fastq.gz -t $(CPUS) ;

$(PHYLOGENY)/NC_000962.inh.b1.infile:
	perl scripts/snp_caller.pl --chrom NC_000962.3 --qual 30 --dp 4 --dp4 75 --dpmax 5000 --af 1 --mq 30 --noindels --noheader \
			--vcf 02.113,vcf/NC_000962_02.113.all.vcf.gz \
	       	--vcf 02.292,vcf/NC_000962_02.292.all.vcf.gz \
			--vcf 03.013,vcf/NC_000962_03.013.all.vcf.gz \
	       	--vcf 03.039,vcf/NC_000962_03.039.all.vcf.gz \
	       	--vcf 03.313,vcf/NC_000962_03.313.all.vcf.gz \
	       	--vcf 04.018,vcf/NC_000962_04.018.all.vcf.gz \
	       	--vcf 04.194,vcf/NC_000962_04.194.all.vcf.gz \
	       	--vcf 04.211,vcf/NC_000962_04.211.all.vcf.gz \
	       	--vcf 04.493,vcf/NC_000962_04.493.all.vcf.gz \
	       	--vcf 04.503,vcf/NC_000962_04.503.all.vcf.gz \
	       	--vcf 05.046,vcf/NC_000962_05.046.all.vcf.gz \
	       	--vcf 07.116,vcf/NC_000962_07.116.all.vcf.gz \
	       	--vcf 07.118,vcf/NC_000962_07.118.all.vcf.gz \
	       	--vcf 05.177,vcf/NC_000962_05.177.all.vcf.gz \
	       	--vcf 05.094,vcf/NC_000962_05.094.all.vcf.gz \
	       	--vcf 04.011,vcf/NC_000962_04.011.all.vcf.gz \
		--dir $(PHYLOGENY)/ --phylip NC_000962.inh.b1.infile --verbose 1 -b 1 --cpus $(CPUS)

$(PHYLOGENY)/NC_000962.inh_snp_list.b1.infile:
	perl scripts/snp_caller.pl --chrom NC_000962.3 --qual 30 --dp 4 --dp4 75 --dpmax 5000 --af 1 --mq 30 --noindels --noheader \
			--vcf 05.177,vcf/NC_000962_05.177.all.vcf.gz \
			--vcf 02.292,vcf/NC_000962_02.292.all.vcf.gz \
			--vcf 03.039,vcf/NC_000962_03.039.all.vcf.gz \
			--vcf 04.018,vcf/NC_000962_04.018.all.vcf.gz \
			--vcf 04.211,vcf/NC_000962_04.211.all.vcf.gz \
			--vcf 04.503,vcf/NC_000962_04.503.all.vcf.gz \
			--vcf 07.116,vcf/NC_000962_07.116.all.vcf.gz \
			--vcf 04.493,vcf/NC_000962_04.493.all.vcf.gz \
		--dir $(PHYLOGENY)/ --phylip NC_000962.inh_snp_list.b1.infile --refilter --verbose 1 -b 1 --cpus $(CPUS)
#		--dir phylogeny/ --phylip NC_000962.b1.inh_snp_list.infile --refilter --verbose 2 -b 1 --cpus 20 \

$(PHYLOGENY)/RAxML_bipartitions.NC_000962.inh.b1: $(PHYLOGENY)/NC_000962.inh.b1.infile
	raxmlHPC-PTHREADS-SSE3 -T $(CPUS) -f a -s $(PHYLOGENY)/NC_000962.inh.b1.infile -x 12345 -p 1234 -# 1000 -m GTRGAMMA -w $(shell pwd)/$(PHYLOGENY) -n NC_000962.inh.b1 -o NC_000962.3

$(PHYLOGENY)/RAxML_bipartitions.NC_000962.inh_snp_list.b1: $(PHYLOGENY)/NC_000962.inh_snp_list.b1.infile
	raxmlHPC-PTHREADS-SSE3 -T $(CPUS) -f a -s $(PHYLOGENY)/NC_000962.inh_snp_list.b1.infile -x 12345 -p 1234 -# 1000 -m GTRGAMMA -w $(shell pwd)/$(PHYLOGENY) -n NC_000962.inh_snp_list.b1 -o NC_000962.3

trees: $(PHYLOGENY)/RAxML_bipartitions.NC_000962.inh.b1 $(PHYLOGENY)/RAxML_bipartitions.NC_000962.inh_snp_list.b1

# circos contains hard-coded paths and filenames, as the config file is currently manually generated

$(CIRCOS)/$(REF).karyotype.txt:
	perl scripts/circos_fasta_karyotype.pl --fasta  $(GENOMES)/$(REF).fna > $(CIRCOS)/$(REF).karyotype.txt

$(CIRCOS)/$(REF).genes.for.txt:
	perl scripts/circos_gbk_track.pl --gbk  $(GENOMES)/$(REF).gbk --strand for > $(CIRCOS)/$(REF).genes.for.txt
	perl -pi -e 's/NC_000962/NC_000962.3/' $(CIRCOS)/$(REF).genes.for.txt

$(CIRCOS)/$(REF).genes.rev.txt:
	perl scripts/circos_gbk_track.pl --gbk  $(GENOMES)/$(REF).gbk --strand rev > $(CIRCOS)/$(REF).genes.rev.txt
	perl -pi -e 's/NC_000962/NC_000962.3/' $(CIRCOS)/$(REF).genes.rev.txt

$(CIRCOS)/$(REF)_%.txt:
	perl scripts/circos_bam_track.pl --bam $(ALIGNMENTS)/$(REF)_$*.bam --verbose --window 100 > $@

$(CIRCOS)/$(REF).png: $(CIRCOS)/$(REF).karyotype.txt $(CIRCOS)/$(REF).genes.for.txt $(CIRCOS)/$(REF).genes.rev.txt $(rings)
	cd $(CIRCOS); ~/Tools/circos-0.62-1/bin/circos -outputfile $(REF).png --conf $(REF).conf

circos: $(CIRCOS)/$(REF).png


