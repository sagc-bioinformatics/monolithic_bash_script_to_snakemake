################
# Rules Proper #
################
rule bwa_index:
	input:
		"references/reference.fasta.gz",
	output:
		"references/reference.fasta.gz.amb",
		"references/reference.fasta.gz.ann",
		"references/reference.fasta.gz.bwt",
		"references/reference.fasta.gz.pac",
		"references/reference.fasta.gz.sa",
	conda:
		"envs/bwa_index.yaml",
	shell:
		"""
		bwa index \
		  -a bwtsw \
		  {input}
		"""
