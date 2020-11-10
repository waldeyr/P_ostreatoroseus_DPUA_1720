from Bio import SeqIO
from textwrap import wrap

'''
This scritp:
    1) reads the fasta file with hypothetical P. ostreatoroseus' proteins downloaded from NCBI just after their release
    2) Parse the fsata header to fit as input data to UniFire (https://gitlab.ebi.ac.uk/uniprot-public/unifire)
        >{id}|{name} {flags}
            {id} must be a unique string amongst the processed sequences
            {name}: can be any string starting from the previous separator, that should not contain any flag
                    might contains (Fragment) if applicable (e.g "ACN2_ACAGO Acanthoscurrin-2 (Fragment)")
            {flags} [mandatory]: to be considered a valid header, only the following flags should be provided:
                    OX={taxonomy Id} //2048520 = Pleurotus ostreatoroseus on UniProt/NCBI
            {flags} [optional]: If possible / applicable, you should also provide:
                    OS={organism name}
                    GN={recommended gene name}
                    GL={recommended ordered locus name (OLN) or Open Reading Frame (OLN) name}
                    OG={gene location(s), comma-separated if multiple} (cf. organelle ontology)
                    
How to use it:

python3  buildInputForUniFire.py > proteins.fasta     

Waldeyr Mendes Cordeiro da Silva, Nov. 2020              
'''

def formatSequence(sequence, length):
    formatedSequence = ''
    listTemp = wrap(sequence, length)
    for temp in listTemp:
        formatedSequence = formatedSequence + str(temp) + '\n'
    return formatedSequence.rstrip('\n')
for record in SeqIO.parse("P_ostreatoroseus_hypothetical_proteins.fasta", "fasta"):
    header = record.description.split(" ")
    newHeader = ">" + header[0] + "|" + header[3] + " OX=2048520 OS=Pleurotus ostreatoroseus DPUA 1720 PE=4 SV=1"
    print(newHeader)
    print(formatSequence(str(record.seq), 80))