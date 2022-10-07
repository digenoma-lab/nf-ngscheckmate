#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

// All of the default parameters are being set in `nextflow.config`

// Import the process
include { check; join } from './processes'


// Function which prints help message text
def helpMessage() {
    log.info"""
Usage:

nextflow run FredHutch/nf-ngscheckmate <ARGUMENTS>

Arguments:

  Input Data:
  --paired_fastq_samplesheet   Sample sheet CSV indicating the location of all input files (cannot use with --paired_fastq_path)
  or
  --paired_fastq_path          Sample sheet CSV indicating the location of all input files (cannot use with --paired_fastq_samplesheet)

  Reference Database
  --ref                        Binary pattern file used as a reference (default: https://github.com/parklab/NGSCheckMate/raw/master/SNP/SNP.pt)

  Output Location:
  --outdir                     Location for output file (`NGSCheckMate.results.csv`) to be written

    """.stripIndent()
}


// Main workflow
workflow {

    // Show help message if the user specifies the --help flag at runtime
    // or if any required params are not provided
    if ( params.help || params.outdir == false || params.ref == false ){
        // Invoke the function above which prints the help message
        helpMessage()
        // Exit out and do not run anything else
        exit 1
    }

    // Raise an error if neither input type is specified
    if ( params.paired_fastq_samplesheet == false && params.paired_fastq_path == false ){
        // Invoke the function above which prints the help message
        helpMessage()
        // Exit out and do not run anything else
        exit 1
    }

    // Raise an error if BOTH input types are specified
    if ( params.paired_fastq_samplesheet && params.paired_fastq_path ){
        log.info"""
        You may only specify one input type -- paired_fastq_samplesheet OR paired_fastq_path
        """.stripIndent()
        exit 1
    }

    // If the samplesheet input was specified
    if ( params.paired_fastq_samplesheet ){
        Channel
            .fromPath(
                "${params.paired_fastq_samplesheet}",
                checkIfExists: true,
                glob: false
            )
            .splitCsv(
                header: true
            )
            .map {
                row -> [
                    row.sample,
                    file(row.fastq_1, checkIfExists: true),
                    file(row.fastq_2, checkIfExists: true)
                ]
            }
            .set { input_ch }
    } else {

        // Make a channel with all of the files from the --input_folder
        Channel
            .fromFilePairs([
                "${params.paired_fastq_path}"
            ])
            .ifEmpty { error "No file pairs found at ${params.paired_fastq_path}" }
            .map {it -> [it[0], it[1][0], it[1][1]]}
            .set { input_ch }

    }

    // Get the reference file
    ref = file("${params.ref}", checkIfExists: true, glob: false)

    // Run NGSCheckmate on each pair of inputs
    check(input_ch, ref)

    // Combine the results
    join(
        check
            .out
            .toSortedList()
    )

}