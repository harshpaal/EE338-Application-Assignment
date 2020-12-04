%% LoadFile Class
% Load all .csv file in the folder and organised them into a LoadFile object.
%
%% Syntax
% LoadFile(path, label1, label2)
% h = LoadFile(...)
%
%% Description
% A LoadFile object is a part of the EEG classification framework which
% acts as a container for data and details to be used in the preprocessing
% process in the DataProcessing class. It reads all .csv file in the folder
% and automatically assign label to the data for the classification process.
%
% The label could be anything as they are simply texts. In this study, only
% Alzheimer's (AD) and healthy controls (HC) are of interest. If the aim is
% to classify other label, simply change the text of the label. IE: If data
% for vascular dementia (VaD) and AD is available, the labels could be 'VaD'
% and 'AD' instead. If multi-label classification is desired, simply add
% another label parameter then copy and slightly modify the else-if statement
% accordingly.
%
% Required input arguments.
% path : Path to the directory which contains the data files (char)
% label1 : First classification of the file to be read, ie: 'AD' (char)
% label2 : Second classification of the file to be read, ie: 'HC' (char)
%
%% **IMPORTANT** About File Format:
% Make sure that the labels are contained in the file name, and separated
% from other words with spaces otherwise the framework won't be able to detect
% it, ie: [AD R5.csv], [R10 HC] etc. Also, make sure that the column header
% is the same throughout the all files and the first column of each file is the time
% information while the rest of the columns are the magnitudes for each
% channel. Lastly, ensure that all signals are of the same length.
%
%% Copyright (C) 2018-2019 Pholpat Durongbhan. All rights reserved.
% This file is subject to the terms and conditions defined in
% file 'LICENSE.txt', which is part of this source code package.
% *************************************************************************
classdef LoadFile
    properties
        filePath char                       % input path to directory
        fileType@char = '*.csv'             % file type to be read
        delimiterIn@char = ',';             % file delimiter type
        headerlinesIn@int16 = int16(1);     % number of header lines in  file
        classifierLabel1 char               % first input classifier label
        classifierLabel2 char               % second input classifier label
    end
    properties (SetAccess = private)
        % if there are N files in the folder and M EEG channels for each file
        data                                % Nx3 raw data, file name, label
        channelName                         % Mx1 channel name
        fileNo int16                        % number of file in the object      
    end
    
    methods
        function obj = LoadFile(path, label1, label2)
            obj.classifierLabel1 = label1;
            obj.classifierLabel2 = label2;
            obj.filePath = uigetdir(pwd, path);
            fullFile = dir(fullfile(obj.filePath, obj.fileType));
            fileList = {fullFile.name};            
            [~,obj.fileNo] = size(fileList);
            obj.data = cell(obj.fileNo,3);
            %read csv file
            for i = 1:obj.fileNo
                if(strfind(fileList{i},obj.classifierLabel1))
                    importedData = importdata(strcat(obj.filePath,'\',fileList{i}),obj.delimiterIn,obj.headerlinesIn);
                    obj.data{i,1} = importedData.data;
                    obj.data{i,2} = extractAfter(fileList{i},obj.classifierLabel1);
                    obj.data{i,3} = obj.classifierLabel1;
                    if i == 1
                        obj.channelName = transpose(importedData.colheaders(1,(2:end)));
                    end
                elseif(strfind(fileList{i},obj.classifierLabel2))
                    importedData = importdata(strcat(obj.filePath,'\',fileList{i}),obj.delimiterIn,obj.headerlinesIn);
                    obj.data{i,1} = importedData.data;
                    obj.data{i,2} = extractAfter(fileList{i},obj.classifierLabel2);
                    obj.data{i,3} = obj.classifierLabel2;
                    if i == 1
                        obj.channelName = transpose(importedData.colheaders(1,(2:end)));
                    end
                else
                end
            end
        end
    end
end