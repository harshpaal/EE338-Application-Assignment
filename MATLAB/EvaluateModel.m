%% EvaluateModel Class
% Evaluate and visualise ClassifyModel's performance.
%
%% Syntax
% EvaluateModel(acc,TP, FP, TN, FN, channelName)
% h = EvaluateModel(...)
%
% EvaluateModel.map(data,norm);
% EvaluateModel.maprank(data,rank,norm);
%% Description
% An EvaluateModel object is a part of the EEG classification framework which
% acts as a container for the evaluation results of the classification model
% trained and tested in the ClassifyModel class as well as providing a
% visualisation utility for the results and other parameters as well.
%
% There are 2 visualisation method available in this class, map and
% maprank. The map function would plot and interpolate the values while
% maprank would map the rank of each electrode position instead. For both
% mapping functions, the user must specify whether to normalise the values
% or not in the form of integers. 0 option (no normalisation) are not used but are the legacy
% of the original code. These are:
% - 0 for no normalisation (use the values directly in the grayscale plot; maximum value capped at 1)
% - 1 for relative normalisation (normalised among the given array of values)
% - 2 for percentage values and no normalisation
% For option 2: input values are in percentage format (max at 100 and no negative values)
% no normalisation will be done to allow the absolute value to be observed
% and compared across different plots while the usual cap at 1 being moved
% to 100 instead.
%
% The visualisation method was developed by incoporating the modified eegplot
% function (eegplot.m and eegplotdat.mat) whose original code is the propriety of Ikaro
% Silva (c) 2008. The visualisation method is specially tailored for the 23
% channels used in this study, other electrode positions would required the
% direct manipulation of the coordinates in the source code below.
%
% Required input arguments for constructors.
% acc : Accuracy from ClassifyModel object
% TP : True Positive from ClassifyModel object
% FP : False Negative from ClassifyModel object
% TN : True Positive from ClassifyModel object
% FN : False Negative from ClassifyModel object
% channelName : LoadFile object produced from the LoadFile class of the framework
%
% Required input arguments for map function.
% data : 23 x 1 array of any values to be plotted (accuracy, magnitude,
%           etc.) which corresponds to values at the electrode position
%           used in this study.
% norm : A single integer (0,1, or 2) specifying the normalisation details
%           as described above.
%
% Required input arguments for maprank function.
% data : 23 x 1 array of any values to be plotted (accuracy, magnitude,
%           etc.) which corresponds to values at the electrode position
%           used in this study.
% rank : A single integer specifying the top-x channels to be plotted.
% norm : A single integer (0,1, or 2) specifying the normalisation details
%           as described above.

%% Copyright (C) 2018-2019 Pholpat Durongbhan. All rights reserved.
% This file is subject to the terms and conditions defined in
% file 'LICENSE.txt', which is part of this source code package.
% *************************************************************************
classdef EvaluateModel
    properties (SetAccess = private)
        channelName                         % resulting accuracy
        classificationAcc                   % resulting accuracy
        confusionMatrix
        sensitivity
        specificity
        positivePredictiveValue
        negativePredictiveValue
        AUC
    end
    
    methods
        function obj = EvaluateModel(acc,TP, FP, TN, FN, channelName)
            obj.classificationAcc = mean(acc,2);
            obj.channelName = channelName;
            [numberOfChannel,numberOfIteration] = size(TP);
            obj.confusionMatrix = zeros(numberOfChannel,4);
            sensitivity = zeros(numberOfChannel,1);
            specificity = zeros(numberOfChannel,1);
            positivePredictiveValue = zeros(numberOfChannel,numberOfIteration);
            negativePredictiveValue = zeros(numberOfChannel,numberOfIteration);
            
            %average the values from the confusion matrix in the
            %ClassifyModel class and keept as class objects
            obj.confusionMatrix(:,1) = mean(TP,2);
            obj.confusionMatrix(:,2) = mean(FP,2);
            obj.confusionMatrix(:,3) = mean(TN,2);
            obj.confusionMatrix(:,4) = mean(FN,2);
            
            %calculaet sensitivity, specificity, etc.
            for i = 1:numberOfIteration
                for j = 1:numberOfChannel
                    sensitivity(j,i) = TP(j,i)/(TP(j,i)+FN(j,i))*100;
                    specificity(j,i) = TN(j,i)/(TN(j,i)+FP(j,i))*100;
                    positivePredictiveValue(j,i) = TP(j,i)/(TP(j,i)+FP(j,i))*100;
                    negativePredictiveValue(j,i) = TN(j,i)/(TN(j,i)+FN(j,i))*100;
                end
            end
            %average those values
            obj.sensitivity = mean(sensitivity,2);
            obj.specificity = mean(specificity,2);
            obj.positivePredictiveValue = mean(positivePredictiveValue,2);
            obj.negativePredictiveValue = mean(negativePredictiveValue,2);
            
            %calculate AUC
            obj.AUC = zeros(numberOfChannel,1);
            for i = 1:numberOfChannel
                Y = [0 obj.sensitivity(i)/100 1];
                X = [0 (100-obj.specificity(i))/100 1];
                Q = trapz(X,Y);
                obj.AUC(i) = Q;
            end
        end
    end
    methods(Static)
        function [z,map] = map(data,norm)
            if(~(norm == 0 || norm == 1 || norm == 2))
                error('Incorrect norm parameters: 0: for no norm, 1: normalised, 2: norm to 100%');
                return
            end
            %23 coordinates for the channel list used in this dataset starting
            %from 'F8-F4' to 'O1-O2'
            x = [119,116,160,161,126,124,162,200,197,198,197,239,241,238,248,248,271,271,319,320,312,310,340];
            y = [284,98,260,124,222,162,191,298,85,226,153,188,257,122,323,56,220,158,273,104,244,134,189];
            %reformat the coordinated to be compatible with the eegplot
            %method
            x = transpose(x);
            y = transpose(y);
            ch = [x y];
            
            % modified eegplot method based on original by Ikaro Silva (c) 2008
            [z,map] = eegplot(data,ch,norm,1,'cubic',[]);
        end
        function [z,map] = mapRank(data,rank,norm)
            if(~(norm == 0 || norm == 1 || norm == 2))
                error('Incorrect norm parameters: 0: for no norm, 1: normalised, 2: norm to 100%');
                return
            end
            %23 coordinates for the channel list used in this dataset starting
            %from 'F8-F4' to 'O1-O2'
            x = [119,116,160,161,126,124,162,200,197,198,197,239,241,238,248,248,271,271,319,320,312,310,340];
            y = [284,98,260,124,222,162,191,298,85,226,153,188,257,122,323,56,220,158,273,104,244,134,189];
            %reformat the coordinated to be compatible with the eegplot
            %method
            x = transpose(x);
            y = transpose(y);
            ch = [x y];
            
            %sort data according to the desired number of top ranks
            [~,index]=ismember(data,sort(data,'ascend'));
            [length,~] = size(data);
            for i = 1:length
                if(index(i) > length - rank)
                    data(i) = index(i)*(10/rank);
                else
                    data(i) = 10/rank;
                end
            end
            % modified eegplot method based on original by Ikaro Silva (c) 2008
            [z,map] = eegplot(data,ch,norm,1,'nearest',[]);
        end
    end
end