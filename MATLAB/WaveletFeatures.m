%% WaveletFeatures Class
% Extract and organise CWT-based features.
%
%% Syntax
% WaveletFeatures(DataProcessing,detail,fband1,method)
% h = WaveletFeatures(...)
%
%% Description
% A WaveletFeatures object is a part of the EEG classification framework which
% acts as a container and processor for wavelet-based features and details to be used in the
% ClassifyModel class. The data must be given in the form of a single DataProcessing object 
% along with the detail of how the features are to be extracted. The
% features in this study is defined as the average magnitude of wavelet
% coefficients (CWT or CWFT) in a given frequency band.
%
% The class can handle 4 different types of wavelet-based features and organisation.
% These options can be selected by using inserting these options into the detail
% parameters:
% - 'general' : 5 frequency bands, 1 feature/band
% - '1fBand' : 1 frequency band, 1 feature/band
%
% Apart from the 'general' opotion, users have to specify which frequency
% band are of interest by pass their names: 'delta', 'theta', 'alpha',
% 'beta', 'gamma' into fband parameter.
%
% Since MATLAB offers 2 approach - CWT/CWFT - the user have to specify
% which method is required with 'CWT' or 'CWFT' for the method parameter.
%
% Required input arguments.
% DataProcessing : DataProcessing object produced from the DataProcessing
%                   class of the framework containing the preprocessed signal
%                   data whose features are to be extracted in this class.
% detail : Detail specifying how to organise the features, see details in
%           the description above. (char)
% fband1 : Sampling rate of the signal in Hz (char)
% method : Specify which method in MATLAB to use 'CWT' or 'CWFT' (char)
%
%% Copyright (C) 2018-2019 Pholpat Durongbhan. All rights reserved.
% This file is subject to the terms and conditions defined in
% file 'LICENSE.txt', which is part of this source code package.
% *************************************************************************
classdef WaveletFeatures < Features
    properties
        featuresPerChannel int16            % number of features per channel
        featuresPerSample int16             % number of features per sample
        featuresData                        % extracted features and their details
        freqArray                           % array containing frequency values for each FFT value
    end
    methods
        function obj = WaveletFeatures(DataProcessing,detail,fband1,method)
            if(strcmp(detail,'general'))
                if(strcmp(method,'CWT'))
                    obj.featuresPerChannel = 5;
                    obj.featuresPerSample = obj.featuresPerChannel * DataProcessing.channelNo;
                    featuresData = zeros(DataProcessing.sampleNo, obj.featuresPerSample);
                    
                    for i = 1:DataProcessing.sampleNo
                        for j = 1:DataProcessing.channelNo
                            %perform CWT
                            %change mother wavelet type here as desired
                            [cfs,obj.freqArray] = cwt(DataProcessing.processedData{i,1}(:,j),'bump',2000);
                            
                            cfs = flipud(abs(cfs));
                            obj.freqArray = flipud(obj.freqArray);
                            
                            %extract the magnitude of coefficients for each
                            %frequenecy band
                            delta = cfs((1:find(abs(obj.freqArray-4)<0.7,1)),:);
                            theta = cfs((find(abs(obj.freqArray-4)<0.7,1)+1:find(abs(obj.freqArray-8)<0.4,1)),:);
                            alpha = cfs((find(abs(obj.freqArray-8)<0.4,1)+1:find(abs(obj.freqArray-12)<0.4,1)),:);
                            beta = cfs((find(abs(obj.freqArray-12)<0.4,1)+1:find(abs(obj.freqArray-30)<1,1)),:);
                            gamma = cfs((find(abs(obj.freqArray-30)<1,1)+1:find(abs(obj.freqArray-50)<1,1)),:);
                            %average the magnitude for each frequency band and keep
                            %them as features
                            
                            n = j-1;                          
                            featuresData(i,(n*obj.featuresPerChannel)+1) = mean2(delta);
                            featuresData(i,(n*obj.featuresPerChannel)+2) = mean2(theta);
                            featuresData(i,(n*obj.featuresPerChannel)+3) = mean2(alpha);
                            featuresData(i,(n*obj.featuresPerChannel)+4) = mean2(beta);
                            featuresData(i,(n*obj.featuresPerChannel)+5) = mean2(gamma);
                        end
                    end
                    featuresLabel = DataProcessing.processedData(:,3);
                    featuresID = DataProcessing.processedData(:,2);
                    obj.featuresData = table(featuresID,featuresLabel,featuresData);
                    
                elseif (strcmp(method,'CWFT'))
                    obj.featuresPerChannel = 5;
                    obj.featuresPerSample = obj.featuresPerChannel * DataProcessing.channelNo;
                    featuresData = zeros(DataProcessing.sampleNo, obj.featuresPerSample);
                    
                    for i = 1:DataProcessing.sampleNo
                        for j = 1:DataProcessing.channelNo
                            %perform CWT
                            sig = {DataProcessing.processedData{i,1}(:,j),1/2000};
                            %change mother wavelet type here as desired
                            cwtstruct = cwtft(sig,'wavelet','paul');
                            
                            cfs = flipud(abs(cwtstruct.cfs));
                            obj.freqArray = flipud(cwtstruct.frequencies');
                            
                            %extract the magnitude of coefficients for each
                            %frequenecy band
                            delta = cfs((1:find(abs(obj.freqArray-4)<0.6,1)),:);
                            theta = cfs((find(abs(obj.freqArray-4)<0.6,1)+1:find(abs(obj.freqArray-8)<0.9,1)),:);
                            alpha = cfs((find(abs(obj.freqArray-8)<0.9,1)+1:find(abs(obj.freqArray-12)<0.6,1)),:);
                            beta = cfs((find(abs(obj.freqArray-12)<0.6,1)+1:find(abs(obj.freqArray-30)<4.5,1)),:);
                            gamma = cfs((find(abs(obj.freqArray-30)<4.5,1)+1:find(abs(obj.freqArray-50)<5.7,1)),:);
                            %average the magnitude for each frequency band and keep
                            %them as features
                            
                            n = j-1;
                            
                            featuresData(i,(n*obj.featuresPerChannel)+1) = mean2(delta);
                            featuresData(i,(n*obj.featuresPerChannel)+2) = mean2(theta);
                            featuresData(i,(n*obj.featuresPerChannel)+3) = mean2(alpha);
                            featuresData(i,(n*obj.featuresPerChannel)+4) = mean2(beta);
                            featuresData(i,(n*obj.featuresPerChannel)+5) = mean2(gamma);
                        end
                    end
                    featuresLabel = DataProcessing.processedData(:,3);
                    featuresID = DataProcessing.processedData(:,2);
                    obj.featuresData = table(featuresID,featuresLabel,featuresData);
                end
            elseif(strcmp(detail,'1fBand'))
                %check freq band names whether they are valid
                validBand = 0;
                if(strcmp(fband1,'delta') || strcmp(fband1,'theta') || strcmp(fband1,'alpha') || strcmp(fband1,'beta') || strcmp(fband1,'gamma'))
                    validBand = 1;
                else
                    disp('Invalid frequency band selection.')
                end
                if(strcmp(method,'CWT') && validBand)
                    obj.featuresPerChannel = 1;
                    obj.featuresPerSample = obj.featuresPerChannel * DataProcessing.channelNo;
                    featuresData = zeros(DataProcessing.sampleNo, obj.featuresPerSample);
                    
                    for i = 1:DataProcessing.sampleNo
                        for j = 1:DataProcessing.channelNo
                            %perform CWT
                            %change mother wavelet type here as desired
                            [cfs,obj.freqArray] = cwt(DataProcessing.processedData{i,1}(:,j),'bump',2000);
                            
                            cfs = flipud(abs(cfs));
                            obj.freqArray = flipud(obj.freqArray);
                            
                            %extract the magnitude of coefficients for each
                            %frequenecy band
                            if(strcmp(fband1,'delta'))
                                features = cfs((1:find(abs(obj.freqArray-4)<0.7,1)),:);
                                freq = obj.freqArray(1:find(abs(obj.freqArray-4)<0.7,1),1);
                            elseif(strcmp(fband1,'theta'))
                                features = cfs((find(abs(obj.freqArray-4)<0.7,1)+1:find(abs(obj.freqArray-8)<0.4,1)),:);
                                freq = obj.freqArray(find(abs(obj.freqArray-4)<0.7,1)+1:find(abs(obj.freqArray-8)<0.4,1),1);
                            elseif(strcmp(fband1,'alpha'))
                                features = cfs((find(abs(obj.freqArray-8)<0.4,1)+1:find(abs(obj.freqArray-12)<0.4,1)),:);
                                freq = obj.freqArray(find(abs(obj.freqArray-8)<0.4,1)+1:find(abs(obj.freqArray-12)<0.4,1),1);
                            elseif(strcmp(fband1,'beta'))
                                features = cfs((find(abs(obj.freqArray-12)<0.4,1)+1:find(abs(obj.freqArray-30)<1,1)),:);
                                freq = obj.freqArray(find(abs(obj.freqArray-12)<0.4,1)+1:find(abs(obj.freqArray-30)<1,1),1);
                            else
                                features = cfs((find(abs(obj.freqArray-30)<1,1)+1:find(abs(obj.freqArray-50)<1,1)),:);
                                freq = obj.freqArray(find(abs(obj.freqArray-30)<1,1)+1:find(abs(obj.freqArray-50)<1,1));
                            end
                            %average the magnitude for each frequency band and keep
                            %them as features
                            n = j-1;
                            featuresData(i,(n*obj.featuresPerChannel)+1) = mean2(abs(features));
                        end
                    end
                    featuresLabel = DataProcessing.processedData(:,3);
                    featuresID = DataProcessing.processedData(:,2);
                    obj.freqArray = freq;
                    obj.featuresData = table(featuresID,featuresLabel,featuresData);
                elseif (strcmp(method,'CWFT') && validBand)
                    obj.featuresPerChannel = 5;
                    obj.featuresPerSample = obj.featuresPerChannel * DataProcessing.channelNo;
                    featuresData = zeros(DataProcessing.sampleNo, obj.featuresPerSample);
                    
                    for i = 1:DataProcessing.sampleNo
                        for j = 1:DataProcessing.channelNo
                            %perform CWT
                            sig = {DataProcessing.processedData{i,1}(:,j),1/2000};
                            %change mother wavelet type here as desired
                            cwtstruct = cwtft(sig,'wavelet','paul');
                            
                            cfs = flipud(abs(cwtstruct.cfs));
                            obj.freqArray = flipud(cwtstruct.frequencies');
                            
                            %extract the magnitude of coefficients for each
                            %frequenecy band
                            if(strcmp(fband1,'delta'))
                                features = cfs((1:find(abs(obj.freqArray-4)<0.7,1)),:);
                                freq = obj.freqArray(1:find(abs(obj.freqArray-4)<0.7,1),1);
                            elseif(strcmp(fband1,'theta'))
                                features = cfs((find(abs(obj.freqArray-4)<0.7,1)+1:find(abs(obj.freqArray-8)<0.4,1)),:);
                                freq = obj.freqArray(find(abs(obj.freqArray-4)<0.7,1)+1:find(abs(obj.freqArray-8)<0.4,1),1);
                            elseif(strcmp(fband1,'alpha'))
                                features = cfs((find(abs(obj.freqArray-8)<0.4,1)+1:find(abs(obj.freqArray-12)<0.4,1)),:);
                                freq = obj.freqArray(find(abs(obj.freqArray-8)<0.4,1)+1:find(abs(obj.freqArray-12)<0.4,1),1);
                            elseif(strcmp(fband1,'beta'))
                                features = cfs((find(abs(obj.freqArray-12)<0.4,1)+1:find(abs(obj.freqArray-30)<1,1)),:);
                                freq = obj.freqArray(find(abs(obj.freqArray-12)<0.4,1)+1:find(abs(obj.freqArray-30)<1,1),1);
                            else
                                features = cfs((find(abs(obj.freqArray-30)<1,1)+1:find(abs(obj.freqArray-50)<1,1)),:);
                                freq = obj.freqArray(find(abs(obj.freqArray-30)<1,1)+1:find(abs(obj.freqArray-50)<1,1));
                            end
                            %average the magnitude for each frequency band and keep
                            %them as features
                            n = j-1;
                            featuresData(i,(n*obj.featuresPerChannel)+1) = mean2(abs(features));
                        end
                    end
                    featuresLabel = DataProcessing.processedData(:,3);
                    featuresID = DataProcessing.processedData(:,2);
                    obj.freqArray = freq;
                    obj.featuresData = table(featuresID,featuresLabel,featuresData);
                end
            else
                disp('Unknown detail parameter.')
            end
        end
    end
end