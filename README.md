# EMMOP

------
## Supplementary Material
The supplementary material includes the datasets associated with the experimental results reported in the manuscript currently under peer review.

## Code Base
The code is built upon **PlatEMO:** _A MATLAB platform for evolutionary multi-objective optimization_ [educational forum], with sincere thanks to Ye Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin. 
**Note:** This implementation uses a previous version of PlatEMO (v2.7).

## How to use the code

1 Setup running environment: 

- Put the folder 'EMMOP' under PlatEMO folder 'Algorithm'. 
- Put the folder 'MOMUPP' under PlatEMO folder 'Problems'.
- Put 'main.m' and 'runme.m' in folder 'PlatEMO', and cover previous files.
- Put 'GLOBAL.m' and 'myDraw.m' under PlatEMO folder 'Public', and cover previous files.
- Run the code via 'runme.m'.

 You may output different kinds of result from 'runme.m':

- The best, average and standard deviation of HV/PD values.
- The approximated Pareto front of our algorithm.
- The balanced path planning figure of UAVs.
- The runtime of the algorithm.

2 You can modify the number of evaluations and the population size in 'runme.m'.

3 Other algorithm-specific parameters can be configured in 'EMMOP.m'.
