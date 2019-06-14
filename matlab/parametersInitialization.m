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

function params = parametersInitialization(frameRate)
    
    % Growing Neural Gas parametarization    
    params.GNG.epsilon_b = 0.8; 
    params.GNG.epsilon_n = 0.01; 
    params.GNG.alpha = 0.5;    % default
    params.GNG.delta = 0.995; % default
    params.GNG.T = 10; % Removing edges, not used
    params.GNG.a = 300; % Maximum generated visual words per place    
    params.GNG.f = 25; % Visual words’ generation frequency
    params.GNG.epsilon = 1; % Growing Neural Gas iterations
    
    % Method's general parameters
    params.xi = 5; % Minimum detected local features per image
    params.v = 300; % Maximum prominent local features per image
    params.timeConstant = 40 * frameRate; % Search area time constant   
    params.verificationInliers = 12; % Geometrical verification inliers 
    params.temporalConsistency = 2; % Images’ temporal consistency    
    params.probabilityThreshold = 1e-12; % Probability score threshold 

    params.myData.load = true;
    params.myData.save = true;
    
    params.VWtoPlaces.load = true;
    params.VWtoPlaces.save = true;
    
    params.placeMatches.load = true;
    params.placeMatches.save = true;    

end