# Running from Tarball

This is a small tool to privately generate events for Moriond17 analyses.

## Installation

1. Put your tarball (containing a `runcmsgrid.sh`) into the `inputs/` folder together with an appropriate hadronizer.
2. Modify `njobs` in submit.py, determining how many chunks of 1k events you wanna generate.  

## Run

```bash
sh buildInputs.sh EWKZ2Jets_ZToLL_M-50_13TeV-madgraph-pythia8
python submit.py work_EWKZ2Jets_ZToLL_M-50_13TeV-madgraph-pythia8
```

