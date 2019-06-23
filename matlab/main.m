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

clear all; close all;
dataPath = ('dataset_directory\'); % images' directory
dataFormat = '*.png'; % e.g., for png input data
dataFrameRate = 10; % dataset frame rate declaration
temporalConstant = 40; % search area time constant, 40 secs

params = parametersInitialization(dataFrameRate);

myData = extractMyData(params, dataPath, dataFormat);

VWtoPlaces = VisualWordsToPlaces(myData, params);

placeMatches = queryingPlaces(temporalConstant, dataFrameRate, myData, VWtoPlaces, params);






