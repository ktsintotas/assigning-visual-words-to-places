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

function VWtoPlaces = VisualWordsToPlaces(myData, params)
    
    if params.VWtoPlaces.load == true && exist('results/VWtoPlaces.mat', 'file')    
        load('results/VWtoPlaces.mat');
    else
        imageCounter = 0; % number of images belonging in a sequence
        sequenceCounter = 1; % initialization of sequence counter
        imageToSequence = [];
        featuresCollection = [];
        featuresDatabaseTemp = [];
        featuresIndex = [];
        databaseIndexing = [];
        featuresCommon = {};
        commonSize = 100;
        j = 0;
        imagesInPlace = [];
        placeDescriptors = [];
        imagesNumber = 0;
        VWdatabaseIndexing = [];
        placeVWsNumber =[];
        placeVWsCounterTemp = 0;
        vwToPlaces = {};
        visualWordsCollection = [];
        
        for i = 1: myData.imagesLoaded
            % imageCounter calculates the number of images inside a place
            imageCounter = imageCounter + 1;
            % check incoming information
            if size(myData.features{i}, 1) > params.xi
                indexTemp = i;
                index(i, sequenceCounter) = indexTemp;
            else
                index(i, sequenceCounter) = indexTemp;
                imageToSequence(i) = sequenceCounter;
                continue
            end
            % features which are meant to clustered and used as database
            featuresCollection = [ featuresCollection ; myData.features{i} ]; 
            % features indexing
            featuresIndex = ones(size(myData.features{i}, 1), 1, 'single') * imageCounter; 
            % descriptors database indexing
            databaseIndexing = [databaseIndexing; featuresIndex];
            % image to sequence association
            imageToSequence(i) = sequenceCounter;

            % A. PLACES FORMULATION
            if imageCounter == 2 && sequenceCounter > 2 && index(i-1, sequenceCounter) ...
                    == index(i-2, sequenceCounter-1)
                continue
            end
            if imageCounter == 2
                indexPairs = matchFeatures(myData.features{i}, myData.features{index(i-1, sequenceCounter)});
                if size(myData.features{index(i-1, sequenceCounter)}, 1) > size(myData.features{i}, 1)
                    featuresCommon{i} = myData.features{index(i-1, sequenceCounter)}(indexPairs(:, 1), :);
                else
                    featuresCommon{i} = myData.features{i}(indexPairs(:, 2), :);
                end
                commonSize = length(indexPairs);
            end
            if imageCounter > 2
                try
                    indexPairs2 = matchFeatures(myData.features{i}, featuresCommon{index(i-1, sequenceCounter)});
                    if size(featuresCommon{index(i-1, sequenceCounter)}, 1) > size(myData.features{i}, 1)
                        featuresCommon{i} = myData.features{index(i-1, sequenceCounter)}(indexPairs2(:, 1), :);
                    else
                        featuresCommon{i} = myData.features{i}(indexPairs2(:, 2), :);
                    end
                    commonSize = length(indexPairs2);
                catch
                    indexPairs = matchFeatures(myData.features{i}, myData.features{index(i-1, sequenceCounter)});
                    if size(myData.features{index(i-1, sequenceCounter)}, 1) > size(myData.features{i}, 1)
                        featuresCommon{i} = myData.features{index(i-1, sequenceCounter)}(indexPairs(:, 1), :);
                    else
                        featuresCommon{i} = myData.features{i}(indexPairs(:, 2), :);
                    end
                    commonSize = length(indexPairs);
                end
            end
            % B. REPRESENTATION OF PLACES BY VISUAL WORDS
            if commonSize < 1
                j  = j + 1;
                placeSize(j) = imageCounter; % defining place's size
                imagesNumber = imagesNumber + placeSize(j);
                imagesInPlace(j) = imagesNumber;
                placeDescriptors{j} = featuresCollection;
                placeVisualWords{j} = GrowingNeuralGasNetwork(double(placeDescriptors{j}), params); % visual words generation

                % visual words indexing
                visualWordsIndex = ones(size(placeVisualWords{j}.w, 1), 1, 'single') * j;
                % visual words database indexing
                VWdatabaseIndexing = [VWdatabaseIndexing; visualWordsIndex];
                vwToPlaces{j} = VWdatabaseIndexing; %fts

                placeVWsNumber(j) = size((placeVisualWords{j}.w), 1); % how many visual words are generated
                placeVWsCounterTemp = placeVWsCounterTemp + placeVWsNumber(j);
                placeVWsCounter{j} = placeVWsCounterTemp;

                visualWordsCollection = [visualWordsCollection ; placeVisualWords{j}.w];
                searchingAreaDatabaseSize{j} = size(visualWordsCollection, 1);

                featuresDatabaseIndexing{j} = databaseIndexing;
                databaseIndexing = [];

                sequenceCounter = sequenceCounter + 1;
                commonSize = 100; % initialize the commonSize
                imageCounter = 0; % initialize sequence's image counter
                featuresCollection = [];                      
            end
        end
        
        VWtoPlaces.imageToSequence = imageToSequence;
        VWtoPlaces.visualWordsCollection = visualWordsCollection;
        VWtoPlaces.searchingAreaDatabaseSize = searchingAreaDatabaseSize;
        VWtoPlaces.vwToPlaces = vwToPlaces;
        VWtoPlaces.placeVWsCounter = placeVWsCounter;
        VWtoPlaces.placeVWsNumber = placeVWsNumber;
        VWtoPlaces.placeDescriptors = placeDescriptors;
        VWtoPlaces.placeSize = placeSize;
        VWtoPlaces.featuresDatabaseIndexing = featuresDatabaseIndexing;
        VWtoPlaces.imagesInPlace = imagesInPlace;
    
        if params.VWtoPlaces.save
            save('results/VWtoPlaces', 'VWtoPlaces');
        end
    end
end




 