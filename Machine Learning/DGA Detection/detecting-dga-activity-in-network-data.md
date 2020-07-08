# Supplementary materials for "Machine learning in cybersecurity: Detecting DGA activity in network data"

This folder contains the supplementary materials for the blogpost "Machine learning in cybersecurity: Detecting DGA activity in network data"

## Painless Script for Extracting Unigrams, Bigrams and Trigrams from Packetbeat data

Because our model was trained on unigrams, bigrams and trigrams, we have to extract these same features from any new domains we wish to score using the model. Hence, before passing the domains from packetbeat DNS requests into the inference processor, we first have to pass them through a Painless script processor that invokes the stored script below.

```

```