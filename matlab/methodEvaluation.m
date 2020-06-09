% 

% Copyright 2019, Konstantinos Tsintotas
% ktsintot@pme.duth.gr
%
% This file is part of "Assigning Visual Words to Places for Loop Closure
% Detection" framework.
%
% Assigning Visual Words to Places framework is free software: you can 
% redistribute it and/or modify it under the terms of the MIT License as 
% published by the corresponding authors 
%  
% Bag-of-Tracked-Words pipeline is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% MIT License for more details. <https://opensource.org/licenses/MIT>

function results = methodEvaluation(params, matches, groundTruthMatrix) 

% Method Evaluation

    results = zeros(1, 6);
       
    loopClosureMatrix = matches.loopClosureMatrixImageToImage;

    figure('IntegerHandle','on','Name','Loop Closure Matrix');
    spy(loopClosureMatrix);

    figure('IntegerHandle','on','Name','Ground Truth Matrix');
    spy(groundTruthMatrix);

    % calculation the sum of true positives
    groundTruthNumber = sum(sum(groundTruthMatrix')>0);

    % calculation of True Positives
    % logical AND between ground truth and loop closure matrix for true positives
    tempTP = logical (groundTruthMatrix.*loopClosureMatrix); 
    tempSumTP = sum(tempTP, 2);
    truePositives = sum(tempSumTP, 1);

    figure('IntegerHandle','on','Name','True Positives');
    spy(tempTP);

    % calculation of False Positives
    % logical AND between opposite ground truth and loop closure matrix for false positives 
    tempFP = logical (loopClosureMatrix.* not(groundTruthMatrix)); 
    tempSumFP = sum(tempFP, 2);
    falsePositives = sum(tempSumFP, 1);
  
    figure('IntegerHandle','on','Name','False Positives');
    spy(tempFP);


    % calculation of Precision - Recall 
    precisionScore = truePositives / (truePositives + falsePositives);
    recallScore = truePositives / groundTruthNumber;

    % Results
    results(1, 1) = precisionScore;
    results(1, 2) = recallScore;   
    results(1, 3) = int16(truePositives);   
    results(1, 4) = int16(falsePositives);
    results(1, 5) = params.probabilityThreshold;    
    results(1, 6) = groundTruthNumber;
    
end