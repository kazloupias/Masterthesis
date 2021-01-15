DATA=data

TRAIN_PAIRS=(
    "de en"
    "en de"
    "it en"
    "en it"
    "nl en"
    "en nl"
)

TRAIN_SOURCES=(
    "de"
    "it"
    "nl"
)

TEST_PAIRS=(
    "de it"
    "de nl"
    "de en"
    "it de"
    "it nl"
    "it en"
    "nl de"
    "nl it"
    "nl en"
    "en de"
    "en it"
    "en nl"
)


for TEST_PAIR in "${TEST_PAIRS[@]}"; do
    TEST_PAIR=($TEST_PAIR)
    SRC=${TEST_PAIR[0]}
    TGT=${TEST_PAIR[1]}

    echo "translations/test.${SRC}-${TGT}.${TGT}"
    cat ../kazloupias/translations/test.${SRC}-${TGT}.${TGT} | sacrebleu ../kazloupias/$DATA/test.${SRC}-${TGT}.${TGT}
done