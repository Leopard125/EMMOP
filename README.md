# EMMOP

------

The code is built upon PlatEMO: A MATLAB platform for evolutionary multi-objective optimization [educational forum], thanks to Ye Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin. Note that we use a previous version of PlatEMO v2.7.

How to use the code:

1 Setup running environment: 

- Put the folder 'EMMOP' under PlatEMO folder 'Algorithm'. 
- Put the folder 'MOMUPP' under PlatEMO folder 'Problems'.
- Put 'main.m' and 'runme.m' in folder 'PlatEMO', cover previous files if necessary.
- Put 'GLOBAL.m' and 'myDraw.m' under PlatEMO folder 'Public', cover previous files if necessary.
- Run the code via 'runme.m'.

 You may output different kinds of result from 'runme.m':

- The Pareto front of our algorithm.
- The least distance, balanced, and least threatened path planning figure.
- The best, average and standard deviation of HV/PD values.

2 You may change evaluation times and size of population in 'runme.m', while other algorithm parameters in 'EMMOP.m'.

3 You may change the problem scale in 'MOMUPP.m'.
