%% ClassifyModel Class
% Train classification model using features in the Features group of classes
% and keep their results for further evaluation
%
%% Syntax
% ClassifyModel(numberOfIteration, features, channelName, channelNo)
% h = ClassifyModel(...)
%
%% Description
% A ClassifyModel object is a part of the EEG classification framework which
% acts as a container for classification results obtained from training and
% validating classification models with features given from Features group of classes.
% The class train and validate the model a number of times (user specified)
% and keep the resulting output so that each iterations' result can be inspected
% and will be averaged later in the EvaluateModel Class for a more consistent
% results. Higher number of iterations can take a long time to complete.
%
% If other classification methods were to be used, the KNN method can be 
% removed and other methods can be used. See the comment in the code below.
%
% Required input arguments.
% numberOfIteration : Number of iterations the user want the program to perform
% features : Features object obtained from any derived classes of the Features base class
% channelName : Sampling rate of the signal in Hz (int)
% channelNo : Number of electrode channels in the data (int)
%
%% Copyright (C) 2018-2019 Pholpat Durongbhan. All rights reserved.
% This file is subject to the terms and conditions defined in
% file 'LICENSE.txt', which is part of this source code package.
% *************************************************************************

classdef ClassifyModel
    properties (SetAccess = private)
        channelName
        numberOfIteration                   % Mx1 channel name, can pass LoadFile.channelName for this parameter
        resultAcc                           % resulting accuracy
        resultTP                            % resulting True Positive
        resultFP                            % resulting False Negative
        resultTN                            % resulting True Positive
        resultFN                            % resulting False Negative
    end
    
    methods
        function obj = ClassifyModel(numberOfIteration, features, channelName, channelNo)
            predictedTP = zeros(channelNo,1);
            predictedFP = zeros(channelNo,1);
            predictedTN = zeros(channelNo,1);
            predictedFN = zeros(channelNo,1);
            
            obj.channelName = channelName;
            obj.numberOfIteration = numberOfIteration;
            obj.resultAcc = zeros(channelNo,numberOfIteration);
            obj.resultTP = zeros(channelNo,numberOfIteration);
            obj.resultFP = zeros(channelNo,numberOfIteration);
            obj.resultTN = zeros(channelNo,numberOfIteration);
            obj.resultFN = zeros(channelNo,numberOfIteration);
            
            for i = 1:obj.numberOfIteration
                channelPerformance = zeros(channelNo,1);
                for n = 0:channelNo-1
                    %train model
                    %if other classification methods were to be used,
                    %modify the line below
                    Mdl = fitcknn(features.featuresData.featuresData(:,(((n*features.featuresPerChannel)+1):(n*features.featuresPerChannel)+features.featuresPerChannel)),features.featuresData.featuresLabel,'NumNeighbors',1,'CrossVal','on');
                    %use the model to predict label for each sample
                    [elabel, escore] = kfoldPredict(Mdl);
                    %create confusion matrix based on real and predicted label
                    C = confusionmat(features.featuresData.featuresLabel,elabel,'Order',unique(features.featuresData.featuresLabel)');
                    %assigned the confusion matrix values in the prepared
                    %vector so that they can be averaged afterwards in
                    %the next class
                    predictedTP(n+1) = C(1,1);
                    predictedFP(n+1) = C(1,2);
                    predictedFN(n+1) = C(2,1);
                    predictedTN(n+1) = C(2,2);
                    channelPerformance(n+1) = (1-kfoldLoss(Mdl))*100;
                end
                obj.resultAcc(:,i) = channelPerformance;
                obj.resultTP(:,i) = predictedTP;
                obj.resultFP(:,i) = predictedFP;
                obj.resultTN(:,i) = predictedTN;
                obj.resultFN(:,i) = predictedFN;
            end
        end
    end
end