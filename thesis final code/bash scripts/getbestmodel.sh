#Code taken from the Sockey 2 tutorial WMT German to English news translation
cp -r iwslt_model iwslt_model_avg
python -m sockeye.average -o iwslt_model_avg/param.best iwslt_model