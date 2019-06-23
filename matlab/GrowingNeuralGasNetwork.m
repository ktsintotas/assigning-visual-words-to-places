%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPML111
% Project Title: Growing Neural Gas Network in MATLAB
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%

function net = GrowingNeuralGasNetwork(X, params)

    if ~exist('PlotFlag', 'var')
        PlotFlag = false;
    end

    %% Load Data
    
    nData = size(X,1);
    nDim = size(X,2);

    X = X(randperm(nData), :);

    Xmin = min(X);
    Xmax = max(X);

    %% Parameters

    N = params.GNG.a;
    MaxIt = params.GNG.epsilon;
    L = params.GNG.f;
    epsilon_b = params.GNG.epsilon_b;
    epsilon_n = params.GNG.epsilon_n;
    alpha = params.GNG.alpha;
    delta = params.GNG.delta;
    T = params.GNG.T;

    %% Initialization

    Ni = 2;

    w = zeros(Ni, nDim);
    for i = 1:Ni
        w(i,:) = unifrnd(Xmin, Xmax); %original is without _kostas
    end

    E = zeros(Ni,1);

    C = zeros(Ni, Ni);
    t = zeros(Ni, Ni);

    %% Loop

    nx = 0;

    for it = 1:MaxIt
        for l = 1:nData
            % Select Input --------1
            % Generate an input signal x
            nx = nx + 1;
            x = X(l,:);

            % Competion and Ranking --------2
            % Find the nearest unit s1 and the second-nearest unit s2.
            d = pdist2(x, w);
            [~, SortOrder] = sort(d);
            s1 = SortOrder(1);
            s2 = SortOrder(2);

            % Aging --------3
            % Increment the age of all edges emanating from s1.
            t(s1, :) = t(s1, :) + 1;
            t(:, s1) = t(:, s1) + 1;

            % Add Error --------4
            % Add the squared distance between the input signal and the nearest unit in input space to a local counter variable:
            E(s1) = E(s1) + d(s1)^2;

            % Adaptation --------5
            % Move s1 and its direct topological neighbor s1 towards x by fractions epsilon_b and epsilon_n, respectively, of the total distance:
            w(s1,:) = w(s1,:) + epsilon_b*(x-w(s1,:));
            Ns1 = find(C(s1,:)==1);
            for j=Ns1
                w(j,:) = w(j,:) + epsilon_n*(x-w(j,:));
            end

            % Create Link --------6
            % If s1 and s2 are connected by an edge, set the age of this edge to zero. If such an edge does not exist, create it.
            C(s1,s2) = 1;
            C(s2,s1) = 1;
            t(s1,s2) = 0;
            t(s2,s1) = 0;

            % Remove Old Links --------7
            % Remove edges with an age larger than alpha max. If this results in points having no emanating edges, remove them as well.
            C(t>T) = 0;
            nNeighbor = sum(C);
            AloneNodes = (nNeighbor==0);
            C(AloneNodes, :) = [];
            C(:, AloneNodes) = [];
            t(AloneNodes, :) = [];
            t(:, AloneNodes) = [];
            w(AloneNodes, :) = [];
            E(AloneNodes) = [];

            % Add New Nodes --------8
            % If the number of input signals generated so far is an integer multiple of a parameter lamda, insert a new unit as follows:
            if mod(nx, L) == 0  && size(w,1) < N   %---ORIGINAL IS WITHOUT COMMENT !!!!!
                % Determine the unit q with the maximum accumulated error.
                [~, q] = max(E);
                [~, f] = max(C(:,q).*E);
                % Insert a new unit r halfway between q and its neighbor f with the largest error variable: Wr = 0.5 (wq + wf)'
                r = size(w,1) + 1;
                w(r,:) = (w(q,:) + w(f,:))/2; 
                % Insert edges connecting the new unit r with units q and f, and remove the original edge between q and f.
                C(q,f) = 0;
                C(f,q) = 0;
                C(q,r) = 1;
                C(r,q) = 1;
                C(r,f) = 1;
                C(f,r) = 1;
                t(r,:) = 0;
                t(:, r) = 0;
                % Decrease the error variables of q and f by multiplying them with a constant a.
                E(q) = alpha*E(q);
                E(f) = alpha*E(f); 
                % Initialize the error variable of r with the new value of the error variable of q. 
                E(r) = E(q);       
            end

            % Decrease Errors --------9
            % Decrease all error variables by multiplying them with a constant d.
            E = delta*E;          
        end
    end

   %% Export Results
    net.w = w;
    net.E = E;
    net.C = C;
    net.t = t;  
    
end
