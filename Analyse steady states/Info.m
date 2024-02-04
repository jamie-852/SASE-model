% Instructions for analysing steady states as shown in Figure 2 and
% Figure S1

%% f_.m scripts define functions which are used in either g_.m or a_.m scripts. 

%% g_samples.m 
% generates 1 million parameter sets where each column represents a 
% particular parameter in Table S1.

%% a_SampledParameters.m
% analyses all the steady states for each parameter set where the first 17
% columns represent the model parameters, columns 18 - 20 represent the
% steady states A*, E* and B*, respectively, and columns 21 - 23 represent
% the eigenvalues for stability. See supplementary note 3 for more details.

%% g_VirtualPatients.m
% numbers each virtual skin site depending on a unique parameter set in
% column 1. 
% the number of stable states present for a particular virtual skin site is
% labeled in column 2. 

%% a_PatientGroups.m
% assigns a number based on the nine possible characteristic population
% densities of SA and SE leading to a healthy or damaged state as outlined
% in supplementary note 3. 