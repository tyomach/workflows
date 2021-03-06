cwlVersion: v1.0
class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement

'sd:metadata':
  - "https://raw.githubusercontent.com/SciDAP/workflows/master/metadata/chipseq-header.cwl"

inputs:

# MAIN
#        1       |       2       |       3       |       4
# ---------------------------------------------------------------
#|        indices_folder         |         control_file          |
# ---------------------------------------------------------------
#|          broad_peak           |                               |
# ---------------------------------------------------------------
#|                          fastq_file                           |
# ---------------------------------------------------------------

  indices_folder:
    type: Directory
    'sd:parent': "https://raw.githubusercontent.com/SciDAP/workflows/master/workflows/bowtie-index.cwl"
    label: "BOWTIE indices folder"
    doc: "Path to BOWTIE generated indices folder"

  annotation_file:
    type: File
    'sd:parent': "https://raw.githubusercontent.com/SciDAP/workflows/master/workflows/bowtie-index.cwl"
    label: "Annotation file"
    format: "http://edamontology.org/format_3475"
    doc: "Tab-separated input annotation file"

  genome_size:
    type: string
    'sd:parent': "https://raw.githubusercontent.com/SciDAP/workflows/master/workflows/bowtie-index.cwl"
    label: "Effective genome size"
    doc: "MACS2 effective genome size: hs, mm, ce, dm or number, for example 2.7e9"

  chrom_length:
    type: File
    'sd:parent': "https://raw.githubusercontent.com/SciDAP/workflows/master/workflows/bowtie-index.cwl"
    label: "Chromosome length file"
    format: "http://edamontology.org/format_2330"
    doc: "Chromosome length file"

  control_file:
    type: File?
    default: null
    'sd:parent': "https://raw.githubusercontent.com/SciDAP/workflows/master/workflows/chipseq-se.cwl"
    label: "Control BAM file"
    format: "http://edamontology.org/format_2572"
    doc: "Control BAM file file for MACS2 peak calling"

  broad_peak:
    type: boolean
    #'sd:parent': "https://raw.githubusercontent.com/SciDAP/workflows/master/tags/antibody-dummy.cwl"
    label: "Callpeak broad"
    doc: "Set to call broad peak for MACS2"

  fastq_file:
    type: File
    label: "FASTQ input file"
    format: "http://edamontology.org/format_1930"
    doc: "Reads data in a FASTQ format, received after single end sequencing"

# ADVANCED
#        1       |       2       |       3       |       4
# ---------------------------------------------------------------
#|      exp_fragment_size        |     force_fragment_size       |
# ---------------------------------------------------------------
#|          clip_3p_end          |         clip_5p_end           |
# ---------------------------------------------------------------
#|      remove_duplicates        |                               |
# ---------------------------------------------------------------

  exp_fragment_size:
    type: int?
    default: 150
    'sd:layout':
      advanced: true
    label: "Expected fragment size"
    doc: "Expected fragment size for MACS2"

  force_fragment_size:
    type: boolean?
    default: false
    'sd:layout':
      advanced: true
    label: "Force fragment size"
    doc: "Force MACS2 to use exp_fragment_size"

  clip_3p_end:
    type: int?
    default: 0
    'sd:layout':
      advanced: true
    label: "Clip from 3p end"
    doc: "Number of bases to clip from the 3p end"

  clip_5p_end:
    type: int?
    default: 0
    'sd:layout':
      advanced: true
    label: "Clip from 5p end"
    doc: "Number of bases to clip from the 5p end"

  remove_duplicates:
    type: boolean?
    default: false
    'sd:layout':
      advanced: true
    label: "Remove duplicates"
    doc: "Calls samtools rmdup to remove duplicates from sortesd BAM file"

# SYSTEM DEPENDENT

  threads:
    type: int?
    default: 2
    'sd:layout':
      advanced: true
    doc: "Number of threads for those steps that support multithreading"
    label: "Number of threads"

outputs:

  bigwig:
    type: File
    format: "http://edamontology.org/format_3006"
    label: "BigWig file"
    doc: "Generated BigWig file"
    outputSource: bam_to_bigwig/outfile

  fastx_statistics:
    type: File
    label: "FASTQ statistics"
    format: "http://edamontology.org/format_2330"
    doc: "fastx_quality_stats generated FASTQ file quality statistics file"
    outputSource: fastx_quality_stats/statistics

  bowtie_log:
    type: File
    label: "BOWTIE alignment log"
    format: "http://edamontology.org/format_2330"
    doc: "BOWTIE generated alignment log"
    outputSource: bowtie_aligner/output_bowtie_log

  iaintersect_log:
    type: File
    label: "Island intersect log"
    format: "http://edamontology.org/format_3475"
    doc: "Iaintersect generated log"
    outputSource: island_intersect/log

  iaintersect_result:
    type: File
    label: "Island intersect results"
    format: "http://edamontology.org/format_3475"
    doc: "Iaintersect generated results"
    outputSource: island_intersect/result

  atdp_log:
    type: File
    label: "ATDP log"
    format: "http://edamontology.org/format_3475"
    doc: "Average Tag Density generated log"
    outputSource: average_tag_density/log

  atdp_result:
    type: File
    label: "ATDP results"
    format: "http://edamontology.org/format_3475"
    doc: "Average Tag Density generated results"
    outputSource: average_tag_density/result

  samtools_rmdup_log:
    type: File
    label: "Remove duplicates log"
    format: "http://edamontology.org/format_2330"
    doc: "Samtools rmdup generated log"
    outputSource: samtools_rmdup/rmdup_log

  bambai_pair:
    type: File
    format: "http://edamontology.org/format_2572"
    label: "Coordinate sorted BAM alignment file (+index BAI)"
    doc: "Coordinate sorted BAM file and BAI index file"
    outputSource: samtools_sort_index_after_rmdup/bam_bai_pair

  macs2_called_peaks:
    type: File?
    label: "Called peaks"
    format: "http://edamontology.org/format_3468"
    doc: "XLS file to include information about called peaks"
    outputSource: macs2_callpeak/peak_xls_file

  macs2_narrow_peaks:
    type: File?
    label: "Narrow peaks"
    format: "http://edamontology.org/format_3613"
    doc: "Contains the peak locations together with peak summit, pvalue and qvalue"
    outputSource: macs2_callpeak/narrow_peak_file

  macs2_broad_peaks:
    type: File?
    label: "Broad peaks"
    format: "http://edamontology.org/format_3614"
    doc: "Contains the peak locations together with peak summit, pvalue and qvalue"
    outputSource: macs2_callpeak/broad_peak_file

  macs2_peak_summits:
    type: File?
    label: "Peak summits"
    format: "http://edamontology.org/format_3003"
    doc: "Contains the peak summits locations for every peaks"
    outputSource: macs2_callpeak/peak_summits_file

  macs2_moder_r:
    type: File?
    label: "MACS2 generated R script"
    format: "http://edamontology.org/format_2330"
    doc: "R script to produce a PDF image about the model based on your data"
    outputSource: macs2_callpeak/moder_r_file

  macs2_gapped_peak:
    type: File?
    label: "Gapped peak"
    format: "http://edamontology.org/format_3586"
    doc: "Contains both the broad region and narrow peaks"
    outputSource: macs2_callpeak/gapped_peak_file

  macs2_log:
    type: File?
    label: "MACS2 log"
    format: "http://edamontology.org/format_2330"
    doc: "MACS2 output log"
    outputSource: macs2_callpeak/macs_log

  get_stat_log:
    type: File?
    label: "Bowtie & Samtools Rmdup combined log"
    format: "http://edamontology.org/format_2330"
    doc: "Processed and combined Bowtie aligner and Samtools rmdup log"
    outputSource: get_stat/output

  macs2_fragment_stat:
    type: File?
    label: "FRAGMENT, FRAGMENTE, ISLANDS"
    format: "http://edamontology.org/format_2330"
    doc: "fragment, calculated fragment, islands count from MACS2 results"
    outputSource: macs2_callpeak/macs2_stat

  fastq_compressed:
    type: File
    label: "Compressed FASTQ"
    doc: "bz2 compressed FASTQ file"
    outputSource: bzip/output

steps:

  fastx_quality_stats:
    run: ../tools/fastx-quality-stats.cwl
    in:
      input_file: fastq_file
    out: [statistics]

  bzip:
    run: ../tools/bzip2.cwl
    in:
      input_file: fastq_file
    out: [output]

  bowtie_aligner:
    run: ../tools/bowtie.cwl
    in:
      filelist: fastq_file
      indices_folder: indices_folder
      clip_3p_end: clip_3p_end
      clip_5p_end: clip_5p_end
      v:
        default: 3
      m:
        default: 1
      best:
        default: true
      strata:
        default: true
      sam:
        default: true
      threads: threads
      q:
        default: true
    out: [output, output_bowtie_log]

  samtools_sort_index:
    run: ../tools/samtools-sort-index.cwl
    in:
      sort_input: bowtie_aligner/output
      threads: threads
    out: [bam_bai_pair]

  samtools_rmdup:
    run: ../tools/samtools-rmdup.cwl
    in:
      trigger: remove_duplicates
      input_file: samtools_sort_index/bam_bai_pair
      single_end:
        default: true
    out: [rmdup_output, rmdup_log]

  samtools_sort_index_after_rmdup:
    run: ../tools/samtools-sort-index.cwl
    in:
      trigger: remove_duplicates
      sort_input: samtools_rmdup/rmdup_output
      threads: threads
    out: [bam_bai_pair]

  macs2_callpeak:
    run: ../tools/macs2-callpeak-biowardrobe-only.cwl
    in:
      treatment: samtools_sort_index_after_rmdup/bam_bai_pair
      control: control_file
      nolambda:
        source: control_file
        valueFrom: |
          ${
            return !Boolean(self);
          }
      genome_size: genome_size
      mfold:
        default: "4 40"
      verbose:
        default: 3
      nomodel: force_fragment_size
      extsize: exp_fragment_size
      bw: exp_fragment_size
      broad: broad_peak
      call_summits:
        source: broad_peak
        valueFrom: $(!self)
      keep_dup:
        default: auto
      q_value:
        default: 0.05
      format_mode:
        default: BAM
      buffer_size:
        default: 10000
    out:
      - peak_xls_file
      - narrow_peak_file
      - peak_summits_file
      - broad_peak_file
      - moder_r_file
      - gapped_peak_file
      - treat_pileup_bdg_file
      - control_lambda_bdg_file
      - macs_log
      - macs2_stat
      - macs2_fragments_calculated

  bam_to_bigwig:
    run: bam-genomecov-bigwig.cwl
    in:
      input: samtools_sort_index_after_rmdup/bam_bai_pair
      genomeFile: chrom_length
      mappedreads: get_stat/mapped_reads
      fragmentsize: macs2_callpeak/macs2_fragments_calculated
    out: [outfile]

  get_stat:
      run: ../tools/python-get-stat.cwl
      in:
        bowtie_log: bowtie_aligner/output_bowtie_log
        rmdup_log: samtools_rmdup/rmdup_log
      out:
        - output
        - mapped_reads

  island_intersect:
      run: ../tools/iaintersect.cwl
      in:
        input_filename: macs2_callpeak/peak_xls_file
        annotation_filename: annotation_file
        promoter_bp:
          default: 1000
      out: [result, log]

  average_tag_density:
      run: ../tools/atdp.cwl
      in:
        input_filename: samtools_sort_index_after_rmdup/bam_bai_pair
        annotation_filename: annotation_file
        fragmentsize_bp: macs2_callpeak/macs2_fragments_calculated
        avd_window_bp:
          default: 5000
        avd_smooth_bp:
          default: 50
        ignore_chr:
          default: chrM
        double_chr:
          default: "chrX chrY"
        avd_heat_window_bp:
          default: 200
        mapped_reads: get_stat/mapped_reads
      out: [result, log]


$namespaces:
  s: http://schema.org/

$schemas:
- http://schema.org/docs/schema_org_rdfa.html

s:name: "chipseq-se"
s:downloadUrl: https://raw.githubusercontent.com/SciDAP/workflows/master/workflows/scidap/chipseq-se.cwl
s:codeRepository: https://github.com/SciDAP/workflows
s:license: http://www.apache.org/licenses/LICENSE-2.0

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "Cincinnati Children's Hospital Medical Center"
  s:location:
  - class: s:PostalAddress
    s:addressCountry: "USA"
    s:addressLocality: "Cincinnati"
    s:addressRegion: "OH"
    s:postalCode: "45229"
    s:streetAddress: "3333 Burnet Ave"
    s:telephone: "+1(513)636-4200"
  s:logo: "https://www.cincinnatichildrens.org/-/media/cincinnati%20childrens/global%20shared/childrens-logo-new.png"
  s:department:
  - class: s:Organization
    s:legalName: "Allergy and Immunology"
    s:department:
    - class: s:Organization
      s:legalName: "Barski Research Lab"
      s:member:
      - class: s:Person
        s:name: Michael Kotliar
        s:email: mailto:michael.kotliar@cchmc.org
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898

doc: >
  Runs ChIP-Seq BioWardrobe basic analysis with single-end data file.

s:about: |
  The original [BioWardrobe's](https://biowardrobe.com) [PubMed ID:26248465](https://www.ncbi.nlm.nih.gov/pubmed/26248465)
  **ChIP-Seq** basic analysis for a **single-end** experiment.
  A corresponded input [FASTQ](http://maq.sourceforge.net/fastq.shtml) file has to be provided.

  In outputs it returns coordinate sorted BAM file alongside with index BAI file, quality
  statistics of the input FASTQ file, reads coverage in a form of BigWig file, peaks calling
  data in a form of narrowPeak or broadPeak files, islands with the assigned nearest genes and
  region type, data for average tag density plot (on the base of BAM file).

  Workflow starts with step *fastx\_quality\_stats* from FASTX-Toolkit
  to calculate quality statistics for input FASTQ file.

  At the same time `bowtie` is used to align
  reads from input FASTQ file to reference genome *bowtie\_aligner*. The output of this step
  is unsorted SAM file which is being sorted and indexed by `samtools sort` and `samtools index`
  *samtools\_sort\_index*.

  Based on workflow’s input parameters indexed and sorted BAM file
  can be processed by `samtools rmdup` *samtools\_rmdup* to get rid of duplicated reads.
  If removing duplicates is not required the original input BAM and BAI
  files return. Otherwise step *samtools\_sort\_index\_after\_rmdup* repeat `samtools sort` and `samtools index` with BAM and BAI files.

  Right after that `macs2 callpeak` performs peak calling *macs2\_callpeak*. On the base of returned outputs the next step
  *macs2\_island\_count* calculates the number of islands and estimated fragment size. If the last
  one is less that 80bp (hardcoded in the workflow) `macs2 callpeak` is rerun again with forced fixed
  fragment size value (*macs2\_callpeak\_forced*). If at the very beginning it was set in workflow
  input parameters to force run peak calling with fixed fragment size, this step is skipped and the
  original peak calling results are saved.

  In the next step workflow again calculates the number of islands and estimates fragment size (*macs2\_island\_count\_forced*)
  for the data obtained from *macs2\_callpeak\_forced* step. If the last one was skipped the results from *macs2\_island\_count\_forced* step
  are equal to the ones obtained from *macs2\_island\_count* step.

  Next step (*macs2\_stat*) is used to define which of the islands and estimated fragment size should be used
  in workflow output: either from *macs2\_island\_count* step or from *macs2\_island\_count\_forced* step. If input
  trigger of this step is set to True it means that *macs2\_callpeak\_forced* step was run and it returned different
  from *macs2\_callpeak* step results, so *macs2\_stat* step should return [fragments\_new, fragments\_old, islands\_new],
  if trigger is False the step returns [fragments\_old, fragments\_old, islands\_old], where sufix "old" defines
  results obtained from *macs2\_island\_count* step and sufix "new" - from *macs2\_island\_count\_forced* step.

  The following two steps (*bamtools\_stats* and *bam\_to\_bigwig*) are used to calculate coverage on the base
  of input BAM file and save it in BigWig format. For that purpose bamtools stats returns the number of
  mapped reads number which is then used as scaling factor by bedtools genomecov when it performs coverage
  calculation and saves it in BED format. The last one is then being sorted and converted to BigWig format by
  bedGraphToBigWig tool from UCSC utilities. Step *get\_stat* is used to return a text file with statistics
  in a form of [TOTAL, ALIGNED, SUPRESSED, USED] reads count.

  Step *island\_intersect* assigns genes and regions to the islands obtained from *macs2\_callpeak\_forced*.
  Step *average\_tag\_density* is used to calculate data for average tag density plot on the base of BAM file.
