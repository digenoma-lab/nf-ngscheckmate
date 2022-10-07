# nf-NGSCheckMate
Nextflow workflow running NGSCheckMate

NGSCheckMate is a software package for identifying next generation sequencing (NGS)
data files from the same individual.
More details can be found [on its official repository](https://github.com/parklab/NGSCheckMate).

## Input Data

### Sample Sheet CSV

This workflow is designed to analyze WGS data provided as paired-end FASTQ files,
with one pair per sample.

The inputs files should be specified with a sample sheet CSV with the format:

```
sample,fastq_1,fastq_2
sampleA,/path/to/sampleA.R1.fastq.gz,/path/to/sampleA.R2.fastq.gz
sampleB,/path/to/sampleB.R1.fastq.gz,/path/to/sampleB.R2.fastq.gz
sampleC,/path/to/sampleC.R1.fastq.gz,/path/to/sampleC.R2.fastq.gz
```

The location of the sample sheet should be supplied with the parameter `paired_fastq_samplesheet`.

### Wildcard Pattern

An alternate approach for specifying input files is with a wildcard pattern
which indicates the pairs of files which belong to the same sample.
The parameter for that pattern is `paired_fastq_path`.

For example, the files listed in the sample sheet CSV shown above could be
captured with the pattern `/path/to/*.R{1,2}.fastq.gz`.
The two elements of the wildcard pattern which should be used are `*`, which
represents the variable part of the filename that matches the sample ID,
and `{1,2}`, which indicates the position which contains `1` in the read 1
file name and `2` in the read 2 file name.

## Parameters

- `paired_fastq_samplesheet`:   Sample sheet CSV indicating the location of all input files (cannot use with --paired_fastq_path)
- `paired_fastq_path`:          Sample sheet CSV indicating the location of all input files (cannot use with --paired_fastq_samplesheet)
- `outdir`:                     Location for output file (`NGSCheckMate.results.csv`) to be written
- `ref`:                        Binary pattern file used as a reference (default: https://github.com/parklab/NGSCheckMate/raw/master/SNP/SNP.pt)
