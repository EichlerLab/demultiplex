configfile: "config.json"

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

# BARCODE_FILE
# i7 is barcode 1 and i5 is barcode 2
rule prepare_barcodes_for_picard:
    input: "TruSeq_HT_kit_dual_index_sequences.tsv"
    output: "TruSeq_HT_kit_dual_index_sequences.tab"
    params: sge_opts=""
    shell: """awk 'OFS="\\t" {{ if (NR == 1) {{ print "barcode_sequence_1","barcode_sequence_2","barcode_name","library_name" }} else {{ print $3,$2,$1,$1 }} }}' {input} > {output}"""
