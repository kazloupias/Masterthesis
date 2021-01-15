## Code taken from Sockeye 2 tutorial on multilingual translation, modified to fit the needs of this research
mkdir -p translations
DATA=data
TEST_PAIRS=(
    "de en"
    "de nl"
    "de it"
    "en de"
    "en nl"
    "en it"
    "it en"
    "it de"
    "it nl"
    "nl en"
    "nl de"
    "nl it"
    
)

TRAIN_SOURCES=(
    "de"
    "it"
    "nl"
)

for TEST_PAIR in "${TEST_PAIRS[@]}"; do
    TEST_PAIR=($TEST_PAIR)
    SRC=${TEST_PAIR[0]}
    TGT=${TEST_PAIR[1]}

    python -m sockeye.translate \
                            -i $DATA/test.${SRC}-${TGT}.tag.${SRC} \
                            -o translations/test.${SRC}-${TGT}.tag.${TGT} \
                            -m iwslt_model \
                            --beam-size 10 \
                            --length-penalty-alpha 1.0 \
                            --device-ids 0 \
                            --batch-size 64
                            --disable-device-locking \

done

echo "Done translating data, onto preprocessing"


for TEST_PAIR in "${TEST_PAIRS[@]}"; do
    TEST_PAIR=($TEST_PAIR)
    SRC=${TEST_PAIR[0]}
    TGT=${TEST_PAIR[1]}

    # remove target language tag

    cat translations/test.${SRC}-${TGT}.tag.${TGT} | \
        python tools/remove_tag_from_translations.py --verbose \
        > translations/test.${SRC}-${TGT}.bpe.${TGT}

    # remove BPE encoding

    cat translations/test.${SRC}-${TGT}.bpe.${TGT} | sed -r 's/@@( |$)//g' > translations/test.${SRC}-${TGT}.tok.${TGT}
    
    echo "done removing bpe encoding"

    # remove tokenization

    cat translations/test.${SRC}-${TGT}.tok.${TGT} | tools/detokenizer.perl -l "${TGT}" > translations/test.${SRC}-${TGT}.${TGT}
    echo "done removing tokenization"
done