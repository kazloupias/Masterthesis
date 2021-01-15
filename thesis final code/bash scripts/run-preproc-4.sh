MOSES=tools/moses-scripts/scripts
DATA=data

SRCS=(
    "de"
    "it"
    "nl"
)
TGT=en

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


echo "start"

for SRC in "${TRAIN_SOURCES[@]}"; do
    for LANG in "${SRC}" "${TGT}"; do
        for corpus in train valid; do
            ln -s $corpus.${SRC}-${TGT}.${LANG} $DATA/$corpus.${TGT}-${SRC}.${LANG}
        done
    done
done

echo "done created symlinks"

for PAIR in "${TRAIN_PAIRS[@]}"; do
    PAIR=($PAIR)
    SRC=${PAIR[0]}
    TGT=${PAIR[1]}

    for LANG in "${SRC}" "${TGT}"; do
        for corpus in train valid; do
            cat "$DATA/${corpus}.${SRC}-${TGT}.${LANG}" | perl $MOSES/tokenizer/normalize-punctuation.perl | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $LANG  > "$DATA/${corpus}.${SRC}-${TGT}.tok.${LANG}"
        done
    done
done

for PAIR in "${TEST_PAIRS[@]}"; do
    PAIR=($PAIR)
    SRC=${PAIR[0]}
    TGT=${PAIR[1]}

    for LANG in "${SRC}" "${TGT}"; do
        cat "$DATA/test.${SRC}-${TGT}.${LANG}" | perl $MOSES/tokenizer/normalize-punctuation.perl | perl $MOSES/tokenizer/tokenizer.perl -a -q -l $LANG  > "$DATA/test.${SRC}-${TGT}.tok.${LANG}"
    done
done

echo "Tokenized pairs"

cat $DATA/train.*.tok.* > train.tmp

subword-nmt learn-joint-bpe-and-vocab -i train.tmp \
  --write-vocabulary bpe.vocab \
  --total-symbols --symbols 32000 -o bpe.codes

rm train.tmp


echo "Learned BPE model"

for PAIR in "${TRAIN_PAIRS[@]}"; do
    PAIR=($PAIR)
    SRC=${PAIR[0]}
    TGT=${PAIR[1]}

    for LANG in "${SRC}" "${TGT}"; do
        for corpus in train valid; do
            subword-nmt apply-bpe -c bpe.codes --vocabulary bpe.vocab --vocabulary-threshold 50 < "$DATA/${corpus}.${SRC}-${TGT}.tok.${LANG}" > "$DATA/${corpus}.${SRC}-${TGT}.bpe.${LANG}"
        done
    done
done

for PAIR in "${TEST_PAIRS[@]}"; do
    PAIR=($PAIR)
    SRC=${PAIR[0]}
    TGT=${PAIR[1]}

    for LANG in "${SRC}" "${TGT}"; do
        subword-nmt apply-bpe -c bpe.codes --vocabulary bpe.vocab --vocabulary-threshold 50 < "$DATA/test.${SRC}-${TGT}.tok.${LANG}" > "$DATA/test.${SRC}-${TGT}.bpe.${LANG}"
    done
done


echo "Done with byte-pair encoding"

for PAIR in "${TRAIN_PAIRS[@]}"; do
    PAIR=($PAIR)
    SRC=${PAIR[0]}
    TGT=${PAIR[1]}

    for corpus in train valid; do
        cat $DATA/$corpus.${SRC}-${TGT}.bpe.${SRC} | python tools/add_tag_to_lines.py --tag "<2${TGT}>" > $DATA/$corpus.${SRC}-${TGT}.tag.${SRC}
        cat $DATA/$corpus.${SRC}-${TGT}.bpe.${TGT} | python tools/add_tag_to_lines.py --tag "<2${SRC}>" > $DATA/$corpus.${SRC}-${TGT}.tag.${TGT}
    done
done

for PAIR in "${TEST_PAIRS[@]}"; do
    PAIR=($PAIR)
    SRC=${PAIR[0]}
    TGT=${PAIR[1]}

     cat $DATA/test.${SRC}-${TGT}.bpe.${SRC} | python tools/add_tag_to_lines.py --tag "<2${TGT}>" > $DATA/test.${SRC}-${TGT}.tag.${SRC}
     cat $DATA/test.${SRC}-${TGT}.bpe.${TGT} | python tools/add_tag_to_lines.py --tag "<2${SRC}>" > $DATA/test.${SRC}-${TGT}.tag.${TGT}
done

echo "Done indicating target language"

for corpus in train valid; do
    touch $DATA/$corpus.tag.src
    touch $DATA/$corpus.tag.trg

    # be specific here, to be safe

    cat $DATA/$corpus.de-en.tag.de $DATA/$corpus.en-de.tag.en $DATA/$corpus.it-en.tag.it $DATA/$corpus.en-it.tag.en $DATA/$corpus.nl-en.tag.nl $DATA/$corpus.en-nl.tag.en> $DATA/$corpus.tag.src
    cat $DATA/$corpus.de-en.tag.en $DATA/$corpus.en-de.tag.de $DATA/$corpus.it-en.tag.en $DATA/$corpus.en-it.tag.it $DATA/$corpus.nl-en.tag.en $DATA/$corpus.en-nl.tag.nl> $DATA/$corpus.tag.trg
done

echo "Concatenated individual files"

echo "Sanity check:"

wc -l $DATA/*