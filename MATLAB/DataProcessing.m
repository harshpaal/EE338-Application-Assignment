%% DataProcessing Class
% Perform signal preprocessing on all data in the LoadFile object provided.
%
%% Syntax
% DataProcessing(channelNo, segmentNo, signalFrequency, totalSignalLength, LoadFile)
% h = DataProcessing(...)
%
%% Description
% A DataProcessing object is a part of the EEG classification framework which
% acts as a container and processor for preprocessed data and details to be used in the
% feature extraction process in the Features group of class. The data must
% be given in the form of a single LoadFile object along with the recording
% detail such as sampling frequency and signal length. It is possible to
% opt-out of the segmentation process by simply inserting segmentNo as 1.
% Preprocessing procedures performed are:
% - Signal segmentation to produce more data sample
% - Low pass filter at 50 Hz
% - High pass filter at 2 Hz
%
% Required input arguments.
% channelNo : Number of electrode channels in the data (int)
% segmentNo : Preferred number of segments to cut the signal into. 
%               To opt-out, put 1. (int)
% signalFrequency : Sampling rate of the signal in Hz (int)
% totalSignalLength : Signal length of the pre-segmented signal in seconds, can be decimal (double)
% LoadFile : LoadFile object produced from the LoadFile class of the framework
%
%% Copyright (C) 2018-2019 Pholpat Durongbhan. All rights reserved.
% This file is subject to the terms and conditions defined in
% file 'LICENSE.txt', which is part of this source code package.
% *************************************************************************
classdef DataProcessing
    properties
        channelNo int16                     % number of electrode channels
        segmentNo int16                     % number of segments to divide the signals into
        signalFrequency int16               % sampling rate of signals in Hz
        totalSignalLength double            % pre-segment signal length in seconds
    end
    properties (SetAccess = private)
        segmentLengthS double               % segmented signal length in seconds
        segmentLengthN int16                % number of element in the segmented signal
        processedData                       % data after being preprocessed
        sampleNo int16                      % number of sample after preprocessing
    end
    
    methods
        function obj = DataProcessing(channelNo, segmentNo, signalFrequency, totalSignalLength, LoadFile)
            acc = 1/signalFrequency;
            
            obj.channelNo = channelNo;
            obj.segmentNo = segmentNo;
            obj.signalFrequency = signalFrequency;
            obj.totalSignalLength = totalSignalLength;
            obj.processedData = cell(obj.segmentNo*LoadFile.fileNo,3);
            %calculate segment length from the desired number of segment
            obj.segmentLengthS = DataProcessing.customRound((obj.totalSignalLength/double(obj.segmentNo)),acc);
            %segmentation will be performed iteratively for all signal file
            for i = 1:LoadFile.fileNo
                for j = 0:(obj.segmentNo - 1)
                    %calculate the number of row to assign the current
                    %segment into.
                    rowid = ((i-1)*obj.segmentNo)+j+1;
                    %Since signal is discrete, the start and end position
                    %of the segment have to be calculated. It's impossible
                    %to find an exact match, so the program will find the
                    %closest value instead.
                    % First column is the time information so calculate
                    % segments from the columns.
                    startRow = find(abs(LoadFile.data{i,1}(:,1)-DataProcessing.customRound(double(j)*obj.segmentLengthS,acc))<0.00001);
                    endRow = find(abs(LoadFile.data{i,1}(:,1)-DataProcessing.customRound(double(j+1)*obj.segmentLengthS,acc))<0.00001);
                    %how many element in the segment
                    obj.segmentLengthN = endRow - startRow;
                    
                    %create butterworth filter with the desired
                    %specification
                    [b,a] = butter(10,0.05,'low');
                    %apply the butterworth filter to the signal
                    filteredsignal = filter(b,a,LoadFile.data{i,1}(:,(2:end)));  %skip first column cause its time information
                    
                    % In this study, 0-2 Hz has already been removed 
                    % in the raw data. However, if it has not been removed
                    % yet, uncomment the high pass filter line below to
                    % remove 0-2 Hz component from the raw signal.                    
                    % filteredsignal = highpass(filteredsignal,2,obj.signalFrequency,'Steepness',0.95);

                    
                    %assign the values into the final object
                    obj.processedData{rowid,1} = filteredsignal(startRow:endRow,:);
                    obj.processedData{rowid,2} = strcat(LoadFile.data{i,2},num2str(j));
                    obj.processedData{rowid,3} = LoadFile.data{i,3};
                end
            end
            [obj.sampleNo, col] = size(obj.processedData);
        end
    end
    
    %custom rounding function used in trimming signal lengths
    methods (Static = true, Access = private)
        function output = customRound(input,acc)
            output = floor(input/acc)*acc;
        end
    end
end