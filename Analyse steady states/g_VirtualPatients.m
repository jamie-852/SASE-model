%% Script to generate numbered virtual skin sites 
% Assign ID to each virtual skin sites with stable states
% _______________________________________________________________________
%AllSteadyStates = readmatrix('AllSteadyStates.csv');

% remove first row with only zeros
AllSteadyStates(~any(AllSteadyStates,2), : ) = [];

% isolate steady states which are stable
AllStableStates = [];
parfor i = 1:length(AllSteadyStates)
    if (AllSteadyStates(i, 21) < 0 && AllSteadyStates(i, 22) < 0 && ...
            AllSteadyStates(i, 23) < 0)
        AllStableStates = [AllStableStates; AllSteadyStates(i, :)];
    end
end

% count the number of unique parameter sets
ParamSet = AllStableStates(:, 1:17);

% find unique rows, retaining order using 'stable'
[C, ia, ic] = unique(ParamSet, 'rows', 'stable'); 

% count occurances
count = accumarray(ic, 1);

% map occurances to 'ic' values
map = count(ic);

% numbered virtual patients
numVirtualPatients = [ic, map, ParamSet];

AllVirtualPatients = [numVirtualPatients, AllStableStates(:, 18:23)];

writematrix(AllVirtualPatients,'AllVirtualPatients.csv');



