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
% Assigning Visual Words to Places pipeline is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% MIT License for more details. <https://opensource.org/licenses/MIT>

function placeMatches = queryingPlaces(temporalConstant, frameRate, myData, VWtoPlaces, params)

    if params.placeMatches.load == true && exist('results/placeMatches.mat', 'file')    
        load('results/placeMatches.mat');
    else

        searchDatabaseDefinition = 0;
        binomialMatrix = zeros(myData.imagesLoaded, size(VWtoPlaces.vwToPlaces, 2));
        loopClosureMatrixImageToImage = false(myData.imagesLoaded, myData.imagesLoaded);
        matches = zeros(myData.imagesLoaded, 1, 'single');

        % how many images to ingore
        temporalRestriction = temporalConstant * frameRate; 
        startImage = temporalRestriction + 1;
        for i = startImage : myData.imagesLoaded
            disp(i)
            searchDatabaseDefinition = VWtoPlaces.imageToSequence(i - temporalRestriction); % searching area definition, until which place to look
            mdl = ExhaustiveSearcher(VWtoPlaces.visualWordsCollection(1: VWtoPlaces.searchingAreaDatabaseSize{searchDatabaseDefinition}, :));
            IdxNN = knnsearch(mdl, double(myData.features{i}) , 'K', 1); % k Nearest Neighbor search
            % QUERY TO PLACE ASSIGNMENT
            % vote agregation
            placeScore = zeros(searchDatabaseDefinition, 1);
            for j = 1 : length(IdxNN)
                placeScore(VWtoPlaces.vwToPlaces{searchDatabaseDefinition}(IdxNN(j))) = placeScore(VWtoPlaces.vwToPlaces{searchDatabaseDefinition}(IdxNN(j))) + 1;  
            end
            % binomial distribution density function
            LAMDA = sum(VWtoPlaces.placeVWsCounter{searchDatabaseDefinition}); % is the sum of VWs within the searching area
            N = size(myData.features{i}, 1); % number of descriptors in query image i
            E_x = zeros(1, searchDatabaseDefinition);
            for k = 1 : searchDatabaseDefinition
                lamda = VWtoPlaces.placeVWsNumber(k); % lamda corresponds to place’s i VWs
                placeVotes = placeScore(k); % number of votes for place k
                p = lamda/LAMDA;
                E_x(k) = N * p; 
                probability = binopdf(placeVotes, N, p);
                binomialMatrix(i, k) = probability;
            end
            % find the minimum probability score
            [minProbability, minIndex] = min(binomialMatrix(i, 1 : searchDatabaseDefinition));
            % check if the candidate place is under the pre-defined threshold
            if minProbability <= params.probabilityThreshold && placeScore(minIndex) > E_x(minIndex)
                % IMAGE TO IMAGE ASSOCIATION 
                mdl2 = ExhaustiveSearcher(VWtoPlaces.placeDescriptors{minIndex});
                IdxNN2 = knnsearch(mdl2,  myData.features{i}, 'K', 1);
                imageScore = zeros(VWtoPlaces.placeSize(minIndex), 1);
                for h = 1 : length(IdxNN2)
                    imageScore(VWtoPlaces.featuresDatabaseIndexing{minIndex}(IdxNN2(h))) = imageScore(VWtoPlaces.featuresDatabaseIndexing{minIndex}(IdxNN2(h))) + 1;
                end
                % the image which gathers the most matches is considered as loop closure candidate
                [~, maxVotedImage] = max(imageScore);
                if minIndex ~= 1 
                    candidateImage = VWtoPlaces.imagesInPlace(minIndex-1) + maxVotedImage; % edited 9.6.2020
                else 
                    candidateImage = maxVotedImage; %%% % edited 9.6.2020
                end 

                % verification step
                indexPairs = matchFeatures(myData.features{i}, myData.features{candidateImage}, 'Unique', true);
                matchedPoints1 = myData.points{i}(indexPairs(:, 1), :);
                matchedPoints2 = myData.points{candidateImage}(indexPairs(:, 2), :);
                try
                    [~, inliersIndex, ~] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, 'Method', 'RANSAC', 'DistanceThreshold', 1);
                    numInliers = sum(inliersIndex);
                    if numInliers >= 12                        
                        loopClosureMatrixImageToImage(i, candidateImage) = true; 
                        matches(i) =  candidateImage;
                    end
                catch
                    continue
                end            
            end
        end
        placeMatches.binomialMatrix = binomialMatrix;        
        placeMatches.loopClosureMatrixImageToImage = loopClosureMatrixImageToImage;
        placeMatches.matches = matches;
        
        if params.placeMatches.save
            save('results/placeMatches', 'placeMatches');
        end     
        
    end
end
