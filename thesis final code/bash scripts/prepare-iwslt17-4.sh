#! /bin/bash
# Code taken from (modified):
#https://github.com/pytorch/fairseq/blob/master/examples/translation/prepare-iwslt17-multilingual.sh
# MIT licensed. "Copyright (c) Facebook, Inc. and its affiliates. All rights reserved." 
# This script, edited by Sockeye 2 is further modified to fit the needs of my research.
MOSES=tools/moses-scripts/scripts
DATA=data
SRCS=(
    "de"
    "it"
    "nl"
)
TGT=en
ROOT=$(dirname "$0")/..
ORIG=$ROOT/iwslt17_orig
DATA=$ROOT/data
mkdir -p "$ORIG" "$DATA"
# https://wit3.fbk.eu/archive/2017-01/texts/DeEnItNlRo/DeEnItNlRo/DeEnItNlRo-DeEnItNlRo.tgz
URLS=(
    "gs://kzl-thesis-project/DeEnItNlRo-DeEnItNlRo-4.tar.gz"
)
ARCHIVES=(
    "DeEnItNlRo-DeEnItNlR-4.tgz"
)
UNARCHIVED_NAME="DeEnItNlRo-DeEnItNlRo-4"
VALID_SETS=(
    "IWSLT17.TED.dev2010.de-en"
    "IWSLT17.TED.dev2010.it-en"
	"IWSLT17.TED.dev2010.nl-en"
)

TEST_FILE="IWSLT17.TED.tst2010"

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
# download and extract data
# gdown https://drive.google.com/uc?id=1GGbs1IKDf5HC6-7CQKK6C-zFKDAqhxLH -O $ARCHIVE
 #download and extract data
# gdown https://drive.google.com/uc?id=1GGbs1IKDf5HC6-7CQKK6C-zFKDAqhxLH -O $ARCHIVE

for ((i=0;i<${#URLS[@]};++i)); do
    ARCHIVE=$ORIG/${ARCHIVES[i]}
    if [ -f "$ARCHIVE" ]; then
        echo "$ARCHIVE already exists, skipping download"
    else
        URL=${URLS[i]}
        gsutil cp "gs://kzl-thesis-project/DeEnItNlRo-DeEnItNlRo-4.tar.gz" $ARCHIVE
        if [ -f "$ARCHIVE" ]; then
            echo "$URL successfully downloaded."
        else
            echo "$URL not successfully downloaded."
            exit 1
        fi
    fi
    FILE=${ARCHIVE: -4}
    if [ -e "$FILE" ]; then
        echo "$FILE already exists, skipping extraction"
    else
        tar -C "$ORIG" -xzvf "$ARCHIVE"
    fi
done
echo "--------------------------------"

echo "--------------------------------"

echo "--------------------------------"

echo "--------------------------------"
echo "--------------------------------"

echo "--------------------------------"

echo "--------------------------------"

echo "--------------------------------"
echo "--------------------------------"

echo "--------------------------------"

echo "--------------------------------"

echo "--------------------------------"
echo "pre-processing train data..."
for SRC in "${SRCS[@]}"; do
    for LANG in "${SRC}" "${TGT}"; do
        cat "$ORIG/$UNARCHIVED_NAME/train.tags.${SRC}-${TGT}.${LANG}" \
            | grep -v '<url>' \
            | grep -v '<talkid>' \
            | grep -v '<keywords>' \
            | grep -v '<speaker>' \
            | grep -v '<reviewer' \
            | grep -v '<translator' \
            | grep -v '<doc' \
            | grep -v '</doc>' \
            | sed -e 's/<title>//g' \
            | sed -e 's/<\/title>//g' \
            | sed -e 's/<description>//g' \
            | sed -e 's/<\/description>//g' \
            | sed 's/^\s*//g' \
            | sed 's/\s*$//g' \
            > "$DATA/train.${SRC}-${TGT}.${LANG}"
    done
done

echo "pre-processing valid data..."



echo "pre-processing valid data..."
for ((i=0;i<${#SRCS[@]};++i)); do
    SRC=${SRCS[i]}
    VALID_SET=${VALID_SETS[i]}
    for FILE in ${VALID_SET[@]}; do
        for LANG in "$SRC" "$TGT"; do
            grep '<seg id' "$ORIG/$UNARCHIVED_NAME/${FILE}.${LANG}.xml" \
                | sed -e 's/<seg id="[0-9]*">\s*//g' \
                | sed -e 's/\s*<\/seg>\s*//g' \
                | sed -e "s/\Ã¢â‚¬â„¢/\'/g" \
                >> "$DATA/valid.${SRC}-${TGT}.${LANG}"
            echo ""$DATA/valid.${SRC}-${TGT}.${LANG}""
        done
    done
done

echo "pre-processing test data..."

for TEST_PAIR in "${TEST_PAIRS[@]}"; do
    TEST_PAIR=($TEST_PAIR)
    SRC=${TEST_PAIR[0]}
    TGT=${TEST_PAIR[1]}
    for LANG in "$SRC" "$TGT"; do
        echo "$DATA/test.${SRC}-${TGT}.${LANG}"
    done
done

for TEST_PAIR in "${TEST_PAIRS[@]}"; do
    TEST_PAIR=($TEST_PAIR)
    SRC=${TEST_PAIR[0]}
    TGT=${TEST_PAIR[1]}
    for LANG in "$SRC" "$TGT"; do
        grep '<seg id' "$ORIG/$UNARCHIVED_NAME/${TEST_FILE}.${SRC}-${TGT}.${LANG}.xml" \
            | sed -e 's/<seg id="[0-9]*">\s*//g' \
            | sed -e 's/\s*<\/seg>\s*//g' \
            | sed -e "s/\ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢/\'/g" \
            > "$DATA/test.${SRC}-${TGT}.${LANG}"
    done
done