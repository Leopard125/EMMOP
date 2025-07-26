# EMMOP
This is the MATLAB implementation of article "Multiobjective multi-UAV path planning via evolutionary multitasking optimization with adaptive operator selection and knowledge fusion" by Kai Meng, Binghong Wu, Bin Xin, Fang Deng and Chen Chen. Coded by Binghong Wu.

For any question, please contact 3120240820@bit.edu.cn (Binghong Wu)

------

The code is built above PlatEMO: A MATLAB platform for evolutionary multi-objective optimization [educational forum], thanks to Ye Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin. Note that we use a previous version of PlatEMO v2.7.

How to use the code:

1 Setup running environment: 

- Put the folder 'EMMOP' under PlatEMO folder 'Algorithm'. 
- Put the folder 'MOMUPP' under PlatEMO folder 'Problems'.
- Put 'main.m' and 'runme.m' in folder 'PlatEMO', cover previous files if necessary.
- Run the code via 'runme.m'.

 You may output different kinds of result from 'runme.m':

- The Pareto front of our algorithm.
- The least distance, balanced, and least threatened path planning figure.
- The best, average and standard deviation of HV/PD values.

2 You may change evaluation times and size of population in 'runme.m', while other algorithm parameters in 'EMMOP.m'.

3 You may change the problem scale in 'MOMUPP.m'.
