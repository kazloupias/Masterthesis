DATA=data
python -m sockeye.prepare_data \
                        -s $DATA/train.tag.src \
                        -t $DATA/train.tag.trg \
                        -o train_data \
                        --shared-vocab \
                        --seed 2


python -m sockeye.train -d train_data \
                        -vs $DATA/valid.tag.src \
                        -vt $DATA/valid.tag.trg \
                        --shared-vocab \
                        --batch-size 512 \
                        --transformer-attention-heads 4 \
                        --weight-tying-type src_trg_softmax \
                        --max-num-checkpoint-not-improved 10 \
                        --device-ids 0 \
                        --decode-and-evaluate-device-id 0 \
                        --disable-device-locking \
                        --seed 2 \
                        -o iwslt_model
                        