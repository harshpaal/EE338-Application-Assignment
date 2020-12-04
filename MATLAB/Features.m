%% Features Class
% Base class that implement the necessary interface for the Features group of classes.
% This is to ensure that any --Features classes that are implemented as a derived
% object of this class will be compatible with the framework as a whole.
% The Features class is not meant to be implemented on directly on its own.
% The Features class is not meant to be modified by the user.
%
% To implement/experiement with new features extraction techniques,
% simply implement a derived class using Features as a base class. Any
% number of derived class can be implemented. See FourierFeatures and
% WaveletFeatures for some sample implementations.
%
%% Copyright (C) 2018-2019 Pholpat Durongbhan. All rights reserved.
% This file is subject to the terms and conditions defined in
% file 'LICENSE.txt', which is part of this source code package.
% *************************************************************************
classdef (Abstract) Features
   properties (Abstract)
        featuresPerChannel int16            % number of features per channel
        featuresPerSample int16             % number of features per sample
        featuresData                        % extracted features and their details
   end
end 