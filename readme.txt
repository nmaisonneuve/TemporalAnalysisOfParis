code from Carl & 
%%% INSTALL

>cd libs/hog
>mex hog/features

>cd MinMaxSelection
>minmax_install.m

%% CONFIG

check config.m

%% RUNNING

run exp_one_vs_all.m



-------------
- time / complexity of the algo
- minimizing the numbere of detectors
- maximixing the inter class gap.

- scaling 
not multi-scaling , since it raise

frequent large visual element should emerged as an aggregation of frequent smaller parts.

related to bottom up approach like http://en.wikipedia.org/wiki/Apriori_algorithm
(see example 2)

"if an itemset is not frequent, any of its superset is never frequent?.

so by using such kind of predicate, if 2 items are frequent , a potential candidate is the union of both.

1. start by small candidates, 
2. assess  their representativeness/discriminativeness
3. filter bad ones
4. if there is remaining candidates
     generate new bigger candidates from the overlappings ones 
   else quit
5. go to .

- overlapping
not during the generation (removed according to grad/prob) 
but after the KNN process to keep the higher 
ranked candidates between a pair of overlapping patches

- overlapping when scales are different 
(purity or scale as priority to keep one of the 2 patches?)

- purity (satisfactory criteria i.e. "pure enough")
local  / not global discrimination criteria 
measure higly depending of size of the positive images + number of KNN parameters
