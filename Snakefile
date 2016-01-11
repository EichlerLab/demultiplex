configfile: "config.json"

FASTQ_DIR=config["fastq_dir"]

def _get_run_barcode(wildcards):
    # input: /path/to/basecalls/151230_M01123_0212_000000000-AJP1Y
    # output: AJP1Y
    return config["basecalls_dir"].split("/")[-1].split("-")[-1]

def _get_machine_name(wildcards):
    # input: /path/to/basecalls/151230_M01123_0212_000000000-AJP1Y
    # output: M01123
    return config["basecalls_dir"].split("/")[-1].split("_")[1]

def _get_flowcell_barcode(wildcards):
    # input: /path/to/basecalls/151230_M01123_0212_000000000-AJP1Y
    # output: 000000000-AJP1Y
    return config["basecalls_dir"].split("/")[-1].split("_")[-1]

rule convert_illumina_basecalls_to_fastq:
    input: basecalls_dir="%s/Data/Intensities/BaseCalls" % config["basecalls_dir"], barcodes_dir="barcodes", multiplex_params="multiplex_params.tab"
    output: FASTQ_DIR
    params: sge_opts="", read_structure=config["read_structure"], run_barcode=_get_run_barcode, machine_name=_get_machine_name, flowcell_barcode=_get_flowcell_barcode
    shell:
        "mkdir -p {output}; "
        "java -Xmx2g -jar $PICARD_DIR/picard.jar IlluminaBasecallsToFastq "
        "BASECALLS_DIR={input.basecalls_dir} "
        "BARCODES_DIR={input.barcodes_dir} "
        "LANE=1 "
        "RUN_BARCODE={params.run_barcode} "
        "MACHINE_NAME={params.machine_name} "
        "FLOWCELL_BARCODE={params.flowcell_barcode} "
        "READ_STRUCTURE={params.read_structure} "
        "MULTIPLEX_PARAMS={input.multiplex_params} "
        "COMPRESS_OUTPUTS=true "
        "NUM_PROCESSORS=1"

rule extract_illumina_barcodes:
    input: basecalls_dir="%s/Data/Intensities/BaseCalls" % config["basecalls_dir"], barcodes_file="TruSeq_HT_kit_dual_index_sequences.tab"
    output: barcodes_dir="barcodes", metrics="metrics.txt"
    params: sge_opts="", read_structure=config["read_structure"]
    shell:
        "mkdir -p {output.barcodes_dir}; "
        "java -Xmx2g -jar $PICARD_DIR/picard.jar ExtractIlluminaBarcodes BASECALLS_DIR={input.basecalls_dir} "
        "OUTPUT_DIR={output.barcodes_dir} "
        "LANE=1 "
        "BARCODE_FILE={input.barcodes_file} "
        "READ_STRUCTURE={params.read_structure} "
        "METRICS_FILE={output.metrics} "
        "MAX_MISMATCHES=2 "
        "MIN_MISMATCH_DELTA=2 "
        "NUM_PROCESSORS=1"

# MULTIPLEX_PARAMS
rule prepare_multiplex_params_for_picard:
    input: "TruSeq_HT_kit_dual_index_sequences.tsv"
    output: "multiplex_params.tab"
    params: sge_opts="", fastq_dir=FASTQ_DIR
    shell: """awk 'OFS="\\t" {{ if (NR == 1) {{ print "OUTPUT_PREFIX","BARCODE_1","BARCODE_2"; print "{params.fastq_dir}/unmatched","N","N" }} else {{ print "{params.fastq_dir}/"$1,$2,$3 }} }}' {input} > {output}"""

# BARCODE_FILE
# i7 is barcode 1 and i5 is barcode 2
rule prepare_barcodes_for_picard:
    input: "TruSeq_HT_kit_dual_index_sequences.tsv"
    output: "TruSeq_HT_kit_dual_index_sequences.tab"
    params: sge_opts=""
    shell: """awk 'OFS="\\t" {{ if (NR == 1) {{ print "barcode_sequence_1","barcode_sequence_2","barcode_name","library_name" }} else {{ print $3,$2,$1,$1 }} }}' {input} > {output}"""
