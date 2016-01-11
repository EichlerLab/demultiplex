# demultiplex

Demultiplex Illumina runs by barcode

## Configuration

Create a tab-delimited file with the barcodes used for the Illumina run using
the following format.

```
Well    i5       i7
A1      TATAGCCT ATTACTCG
```

Edit the `input_barcodes` path in `config.json` to refer to this
file. Additionally, edit the `basecalls_dir` path to refer to the root directory
of the Illumina run which should contain the machine name and run barcode in its
name (e.g., "/path/to/basecalls/151230_M01123_0212_000000000-AJP1Y").

Specify the read structure of the run as defined in the [Picard documentation
for the ExtractIlluminaBarcodes
command](http://broadinstitute.github.io/picard/command-line-overview.html#ExtractIlluminaBarcodes). For
instance, paired-end 151 bp reads with two 8 bp barcodes would have a read
structure of "151T8B8B151T".

Finally, specify the desired output directory for the demultiplexed FASTQs in
the `fastq_dir` path of the config file.

## Usage

Load the software required for demultiplexing including Snakemake and Picard.

```
. config.sh
```

Run the demultiplexing pipeline.

```
snakemake
```

Output will be in the directory specified by `fastq_dir` in `config.json` in
compress FASTQ format with one set of files per well. Reads for which the
sequenced barcode could not be matched to an input barcode are placed in files
with the prefix "unmatched".
