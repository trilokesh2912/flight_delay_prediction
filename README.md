objective

Most flight-delay tools tell you a flight was late after the fact. This project answers two questions an airline or airport operations team has to act on:

Will this flight be delayed, and how confident is the model? Predict, ahead of departure, the probability that a flight arrives more than 15 minutes late, with calibrated probabilities rather than a bare yes/no.
How long will the delay be, and where should operations focus? Estimate delay minutes per flight and aggregate them by route, carrier, and airport, so crews, gates, and rebooking capacity go where they are needed most, given that [X]% of flights run on time and the delayed minority drives most of the cost.

It does this on the [US DOT Bureau of Transportation Statistics On-Time Performance dataset], joined with [weather / airport / aircraft tables]. Two models are built and validated against baselines (such as “always predict on time” and a carrier/route historical average) on a time-based holdout, so there is no leakage from future flights. An interactive dashboard replays the held-out period as if flights were arriving live.

Delay data has real quirks, and the pipeline handles them explicitly: severe class imbalance, cancelled and diverted flights, cascading delays from late inbound aircraft, and seasonal and weather effects.

The full workflow (ingest, clean, feature engineering, model, evaluate, simulate, export, visualize) is a single reproducible pipeline [{targets} in an R package / Python with DVC / Make], with dependencies locked by [renv / poetry / requirements.txt].
