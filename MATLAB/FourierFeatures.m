%% FourierFeatures Class
% Extract and organise FFT-based features.
%
%% Syntax
% FourierFeatures(DataProcessing,detail,fband1,fband2)
% h = FourierFeatures(...)
%
%% Description
% A FourierFeatures object is a part of the EEG classification framework which
% acts as a container and processor for FFT-based features and details to be used in the
% ClassifyModel class. The data must be given in the form of a single DataProcessing object 
% along with the detail of how the features are to be extracted. The
% features in this study is defined as the average magnitude of FFT
% coefficients in a given frequency band.
%
% The class can handle 4 different types of FFT-based features and organisation.
% These options can be selected by using inserting these options into the detail
% parameters:
% - 'general' : 5 frequency bands, 1 feature/band
% - '1fBand' : 1 frequency band, 1 feature/band
% - '2fBand' : 2 frequency bands, 1 feature/band
% - '1fBand5features' : 1 frequency band, 5 features/band
%
% Apart from the 'general' opotion, users have to specify which frequency
% band are of interest by pass their names: 'delta', 'theta', 'alpha',
% 'beta', 'gamma' into fband parameters.
%
% Required input arguments.
% DataProcessing : DataProcessing object produced from the DataProcessing
%                   class of the framework containing the preprocessed signal
%                   data whose features are to be extracted in this class.
% detail : Detail specifying how to organise the features, see details in
%           the description above. (char)
% fband1 : Sampling rate of the signal in Hz (char)
% fband2 : Signal length of the pre-segmented signal in seconds, can be decimal (char)
%
%% Copyright (C) 2018-2019 Pholpat Durongbhan. All rights reserved.
% This file is subject to the terms and conditions defined in
% file 'LICENSE.txt', which is part of this source code package.
% *************************************************************************
classdef FourierFeatures < Features
    properties
        featuresPerChannel int16            % number of features per channel
        featuresPerSample int16             % number of features per sample
        featuresData                        % extracted features and their details
        freqArray                           % array containing frequency values for each FFT value
    end
    methods
        function obj = FourierFeatures(DataProcessing,detail,fband1,fband2)
            %=================================================================================================
            if(strcmp(detail,'general'))
                obj.freqArray = double(DataProcessing.signalFrequency)*(0:double(DataProcessing.segmentLengthN))/double(DataProcessing.segmentLengthN);
                obj.featuresPerChannel = 5;
                obj.featuresPerSample = obj.featuresPerChannel * DataProcessing.channelNo;
                featuresData = zeros(DataProcessing.sampleNo, obj.featuresPerSample);
                
                for i = 1:DataProcessing.sampleNo
                    %perform FFT
                    fourierTF = fft(DataProcessing.processedData{i,1});
                    %extract the magnitude of coefficients for each
                    %frequenecy band
                    delta = fourierTF((find(abs(obj.freqArray-2)<0.3,1):find(abs(obj.freqArray-4)<0.3,1)),:);
                    theta = fourierTF((find(abs(obj.freqArray-4)<0.3,1)+1:find(abs(obj.freqArray-8)<0.3,1)),:);
                    alpha = fourierTF((find(abs(obj.freqArray-8)<0.3,1)+1:find(abs(obj.freqArray-12)<0.3,1)),:);
                    beta = fourierTF((find(abs(obj.freqArray-12)<0.3,1)+1:find(abs(obj.freqArray-30)<0.3,1)),:);
                    gamma = fourierTF((find(abs(obj.freqArray-30)<0.3,1)+1:find(abs(obj.freqArray-50)<0.3,1)),:);
                    %average the magnitude for each frequency band and keep
                    %them as features
                    for n = 0:(DataProcessing.channelNo)-1
                        featuresData(i,(n*obj.featuresPerChannel)+1) = mean2(abs(delta(:,n+1)));
                        featuresData(i,(n*obj.featuresPerChannel)+2) = mean2(abs(theta(:,n+1)));
                        featuresData(i,(n*obj.featuresPerChannel)+3) = mean2(abs(alpha(:,n+1)));
                        featuresData(i,(n*obj.featuresPerChannel)+4) = mean2(abs(beta(:,n+1)));
                        featuresData(i,(n*obj.featuresPerChannel)+5) = mean2(abs(gamma(:,n+1)));
                    end
                end
                featuresLabel = DataProcessing.processedData(:,3);
                featuresID = DataProcessing.processedData(:,2);
                obj.featuresData = table(featuresID,featuresLabel,featuresData);
                %=================================================================================================
            elseif(strcmp(detail,'1fBand'))
                %check freq band names whether they are valid
                validBand = 0;
                if(strcmp(fband1,'delta') || strcmp(fband1,'theta') || strcmp(fband1,'alpha') || strcmp(fband1,'beta') || strcmp(fband1,'gamma'))
                    validBand = 1;
                else
                    disp('Invalid frequency band selection.')
                end
                
                if(validBand == 1)
                    obj.freqArray = double(DataProcessing.signalFrequency)*(0:double(DataProcessing.segmentLengthN))/double(DataProcessing.segmentLengthN);
                    obj.featuresPerChannel = 1;
                    obj.featuresPerSample = obj.featuresPerChannel * DataProcessing.channelNo;
                    featuresData = zeros(DataProcessing.sampleNo, obj.featuresPerSample);
                    
                    for i = 1:DataProcessing.sampleNo
                        %perform FFT
                        fourierTF = fft(DataProcessing.processedData{i,1});
                        %extract features, in this case, only 1 freq band
                        %is extracted
                        if(strcmp(fband1,'delta'))
                            features = fourierTF((find(abs(obj.freqArray-2)<0.3,1):find(abs(obj.freqArray-4)<0.3,1)),:);
                            freq = obj.freqArray(find(abs(obj.freqArray-2)<0.3,1):find(abs(obj.freqArray-4)<0.3,1),1);
                        elseif(strcmp(fband1,'theta'))
                            features = fourierTF((find(abs(obj.freqArray-4)<0.3,1)+1:find(abs(obj.freqArray-8)<0.3,1)),:);
                            freq = obj.freqArray(find(abs(obj.freqArray-4)<0.3,1)+1:find(abs(obj.freqArray-8)<0.3,1),1);
                        elseif(strcmp(fband1,'alpha'))
                            features = fourierTF((find(abs(obj.freqArray-8)<0.3,1)+1:find(abs(obj.freqArray-12)<0.3,1)),:);
                            freq = obj.freqArray(find(abs(obj.freqArray-8)<0.3,1)+1:find(abs(obj.freqArray-12)<0.3,1),1);
                        elseif(strcmp(fband1,'beta'))
                            features = fourierTF((find(abs(obj.freqArray-12)<0.3,1)+1:find(abs(obj.freqArray-30)<0.3,1)),:);
                            freq = obj.freqArray(find(abs(obj.freqArray-12)<0.3,1)+1:find(abs(obj.freqArray-30)<0.3,1),1);
                        else
                            features = fourierTF((find(abs(obj.freqArray-30)<0.3,1)+1:find(abs(obj.freqArray-50)<0.3,1)),:);
                            freq = obj.freqArray(find(abs(obj.freqArray-30)<0.3,1)+1:find(abs(obj.freqArray-50)<0.3,1),1);
                        end
                        %average the magnitude for and keep them as features
                        for n = 0:(DataProcessing.channelNo)-1
                            featuresData(i,(n*obj.featuresPerChannel)+1) = mean2(abs(features(:,n+1)));
                        end
                    end
                    featuresLabel = DataProcessing.processedData(:,3);
                    featuresID = DataProcessing.processedData(:,2);
                    obj.freqArray = freq;
                    obj.featuresData = table(featuresID,featuresLabel,featuresData);
                end
                %=================================================================================================
            elseif(strcmp(detail,'1fBand5features'))
                %check freq band names whether they are valid
                validBand = 0;
                if(strcmp(fband1,'delta') || strcmp(fband1,'theta') || strcmp(fband1,'alpha') || strcmp(fband1,'beta') || strcmp(fband1,'gamma'))
                    validBand = 1;
                else
                    disp('Invalid frequency band selection.')
                end
                
                if(validBand == 1)
                    obj.freqArray = double(DataProcessing.signalFrequency)*(0:double(DataProcessing.segmentLengthN))/double(DataProcessing.segmentLengthN);
                    obj.featuresPerChannel = 5;
                    obj.featuresPerSample = obj.featuresPerChannel * DataProcessing.channelNo;
                    featuresData = zeros(DataProcessing.sampleNo, obj.featuresPerSample);
                    
                    for i = 1:DataProcessing.sampleNo
                        %perform FFT
                        fourierTF = fft(DataProcessing.processedData{i,1});
                        %extract features, in this case, only 1 freq band
                        %is extracted
                        if(strcmp(fband1,'delta'))
                            features = fourierTF((find(abs(obj.freqArray-2)<0.3,1):find(abs(obj.freqArray-4)<0.3,1)),:);
                            freq = obj.freqArray(find(abs(obj.freqArray-2)<0.3,1):find(abs(obj.freqArray-4)<0.3,1),1);
                        elseif(strcmp(fband1,'theta'))
                            features = fourierTF((find(abs(obj.freqArray-4)<0.3,1)+1:find(abs(obj.freqArray-8)<0.3,1)),:);
                            freq = obj.freqArray(find(abs(obj.freqArray-4)<0.3,1)+1:find(abs(obj.freqArray-8)<0.3,1),1);
                        elseif(strcmp(fband1,'alpha'))
                            features = fourierTF((find(abs(obj.freqArray-8)<0.3,1)+1:find(abs(obj.freqArray-12)<0.3,1)),:);
                            freq = obj.freqArray(find(abs(obj.freqArray-8)<0.3,1)+1:find(abs(obj.freqArray-12)<0.3,1),1);
                        elseif(strcmp(fband1,'beta'))
                            features = fourierTF((find(abs(obj.freqArray-12)<0.3,1)+1:find(abs(obj.freqArray-30)<0.3,1)),:);
                            freq = obj.freqArray(find(abs(obj.freqArray-12)<0.3,1)+1:find(abs(obj.freqArray-30)<0.3,1),1);
                        else
                            features = fourierTF((find(abs(obj.freqArray-30)<0.3,1)+1:find(abs(obj.freqArray-50)<0.3,1)),:);
                            freq = obj.freqArray(find(abs(obj.freqArray-30)<0.3,1)+1:find(abs(obj.freqArray-50)<0.3,1),1);
                        end
                        %divide into smaller features
                        [row,~] = size(features);
                        features1 = features((1:floor(row/obj.featuresPerChannel)),:);
                        features2 = features((floor(row/obj.featuresPerChannel)+1:(2*floor(row/obj.featuresPerChannel))),:);
                        features3 = features(((2*floor(row/obj.featuresPerChannel))+1:3*floor(row/obj.featuresPerChannel)),:);
                        features4 = features(((3*floor(row/obj.featuresPerChannel))+1:4*floor(row/obj.featuresPerChannel)),:);
                        features5 = features(((4*floor(row/obj.featuresPerChannel))+1:row),:);
                        for n = 0:(DataProcessing.channelNo)-1
                            featuresData(i,(n*obj.featuresPerChannel)+1) = mean2(abs(features1(:,n+1)));
                            featuresData(i,(n*obj.featuresPerChannel)+2) = mean2(abs(features2(:,n+1)));
                            featuresData(i,(n*obj.featuresPerChannel)+3) = mean2(abs(features3(:,n+1)));
                            featuresData(i,(n*obj.featuresPerChannel)+4) = mean2(abs(features4(:,n+1)));
                            featuresData(i,(n*obj.featuresPerChannel)+5) = mean2(abs(features5(:,n+1)));
                        end
                    end
                    featuresLabel = DataProcessing.processedData(:,3);
                    featuresID = DataProcessing.processedData(:,2);
                    obj.featuresData = table(featuresID,featuresLabel,featuresData);
                end
                %=================================================================================================
            elseif(strcmp(detail,'2fBand'))
                %check valid freq band names for first band
                validBand = 0;
                if(strcmp(fband1,'delta') || strcmp(fband1,'theta') || strcmp(fband1,'alpha') || strcmp(fband1,'beta') || strcmp(fband1,'gamma'))
                    validBand = 1;
                else
                    disp('Invalid first frequency band selection.')
                end
                %check valid freq band names for second band
                validBand2 = 0;
                if(strcmp(fband1,'delta') || strcmp(fband1,'theta') || strcmp(fband1,'alpha') || strcmp(fband1,'beta') || strcmp(fband1,'gamma'))
                    validBand2 = 1;
                else
                    disp('Invalid second frequency band selection.')
                end
                if(strcmp(fband1,fband2))
                    disp('2 bands are identical, please use 1 band instead.')
                    validBand2 = 0;
                end
                if(validBand == 1 && validBand2 == 1)
                    obj.freqArray = double(DataProcessing.signalFrequency)*(0:double(DataProcessing.segmentLengthN))/double(DataProcessing.segmentLengthN);
                    obj.featuresPerChannel = 2;
                    obj.featuresPerSample = obj.featuresPerChannel * DataProcessing.channelNo;
                    featuresData = zeros(DataProcessing.sampleNo, obj.featuresPerSample);
                    
                    for i = 1:DataProcessing.sampleNo
                        %perform FFT
                        fourierTF = fft(DataProcessing.processedData{i,1});
                        %extract features for first band
                        if(strcmp(fband1,'delta'))
                            featuresData1 = fourierTF((find(abs(obj.freqArray-2)<0.3,1):find(abs(obj.freqArray-4)<0.3,1)),:);
                        elseif(strcmp(fband1,'theta'))
                            featuresData1 = fourierTF((find(abs(obj.freqArray-4)<0.3,1)+1:find(abs(obj.freqArray-8)<0.3,1)),:);
                        elseif(strcmp(fband1,'alpha'))
                            featuresData1 = fourierTF((find(abs(obj.freqArray-8)<0.3,1)+1:find(abs(obj.freqArray-12)<0.3,1)),:);
                        elseif(strcmp(fband1,'beta'))
                            featuresData1 = fourierTF((find(abs(obj.freqArray-12)<0.3,1)+1:find(abs(obj.freqArray-30)<0.3,1)),:);
                        else
                            featuresData1 = fourierTF((find(abs(obj.freqArray-30)<0.3,1)+1:find(abs(obj.freqArray-50)<0.3,1)),:);
                        end
                        %extract features for second band
                        if(strcmp(fband2,'delta'))
                            featuresData2 = fourierTF((find(abs(obj.freqArray-2)<0.3,1):find(abs(obj.freqArray-4)<0.3,1)),:);
                        elseif(strcmp(fband2,'theta'))
                            featuresData2 = fourierTF((find(abs(obj.freqArray-4)<0.3,1)+1:find(abs(obj.freqArray-8)<0.3,1)),:);
                        elseif(strcmp(fband2,'alpha'))
                            featuresData2 = fourierTF((find(abs(obj.freqArray-8)<0.3,1)+1:find(abs(obj.freqArray-12)<0.3,1)),:);
                        elseif(strcmp(fband2,'beta'))
                            featuresData2 = fourierTF((find(abs(obj.freqArray-12)<0.3,1)+1:find(abs(obj.freqArray-30)<0.3,1)),:);
                        else
                            featuresData2 = fourierTF((find(abs(obj.freqArray-30)<0.3,1)+1:find(abs(obj.freqArray-50)<0.3,1)),:);
                        end
                        %average magnitudes and keep them as features
                        for n = 0:(DataProcessing.channelNo)-1
                            featuresData(i,(n*obj.featuresPerChannel)+1) = mean2(abs(featuresData1(:,n+1)));
                            featuresData(i,(n*obj.featuresPerChannel)+2) = mean2(abs(featuresData2(:,n+1)));
                        end
                    end
                    featuresLabel = DataProcessing.processedData(:,3);
                    featuresID = DataProcessing.processedData(:,2);
                    obj.featuresData = table(featuresID,featuresLabel,featuresData);
                end
                %=================================================================================================
            else
                disp('Unknown detail parameter.')
            end
        end
    end
end