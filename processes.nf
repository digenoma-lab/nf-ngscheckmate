#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

process check {
    container "${params.container__ngscheckmate}"
    cpus "${params.cpus}"
    memory "${params.memory_gb}.GB"
    
    input:
    // FASTQ Pair per Sample
    tuple val(sample_name), path(R1), path(R2)
    // Reference Database
    path "ref.pt"

    output:
    // Capture all output files
    path "${sample_name}.vaf"

"""#!/bin/bash

set -e

echo Processing sample : '${sample_name}'

/usr/local/NGSCheckMate/ngscheckmate_fastq \
    -1 "${R1}" \
    -2 "${R2}" \
    ref.pt \
    --maxthread ${task.cpus} \
    > "${sample_name}.vaf"
"""

}

process join {
    container "${params.container__ngscheckmate}"
    publishDir "${params.outdir}", mode: "copy", overwrite: true
    
    input:
    path "inputs/"

    output:
    path "*"

"""#!/bin/bash

set -e

python /usr/local/NGSCheckMate/vaf_ncm.py -f -I inputs -O output -N NGSCheckMate.results
mv output/* ./
"""

}
