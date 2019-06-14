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

%% Initially, load or compute the dataset

function myData = extractMyData(params, dataPath, dataFormat)
    v = params.v;
    % shall we load the dataset and its' variables?
    if params.myData.load == true && exist('results/myData.mat', 'file')    
        load('results/myData.mat');                
    else       
        % replace the '*.png' format with the correspondinf format of your dataset
        images = dir([dataPath dataFormat]  );
        % fields to be removed from images' structure
        fields = {'folder','date','bytes','isdir','datenum'};    
        images = rmfield(images, fields);
        % data load and local points extraction and description   
        imagesLoaded = size(images,1);
        indexVector = [];
        for i = 1 : imagesLoaded
            inputImage{i} = imread([dataPath images(i).name]);
            % if input data is RGB convert it to grayscale
            if size(inputImage{i}, 3) == 3
                inputImage{i} = rgb2gray(inputImage{i});
            end
            % SURF points' detection
            points{i} = detectSURFFeatures(inputImage{i});
            % Select the "v" maximum prominent local features per image
            points{i} = points{i}.selectStrongest(v); 
            % SURF points' description
            [features{i}, ~] = extractFeatures(inputImage{i}, points{i}, 'Method','SURF');
            % create indexing for each feature
            tempIndexVector = i * ones(size(features{i}, 1), 1, 'single'); 
            indexVector = [indexVector ; tempIndexVector];        
        end
        % Clear variable space
        clear vars dataPath i fields tempIndexVector
        
        myData.images = images;
        myData.inputImage = inputImage;
        myData.imagesLoaded = imagesLoaded;
        myData.features = features;
        myData.points = points;        
        myData.indexVector = indexVector;    
        
        if params.myData.save
            save('results/myData', 'myData');
        end
    end
end