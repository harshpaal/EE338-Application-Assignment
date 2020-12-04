%==========================================================================
% %Fourier Features Study Example Code
%==========================================================================
%rerun everytime a new dataset is used
load = LoadFile('..\EEGData\','AD','HC');
proc = DataProcessing(23,3,2000,double(12.00),load);

features = FourierFeatures(proc,'general',[],[]);
model = ClassifyModel(1,features,load.channelName,proc.channelNo);
EvaluationResult = EvaluateModel(model.resultAcc,model.resultTP,model.resultFP,model.resultTN,model.resultFN,model.channelName);
%Visualise the result------------------------------------------------------
EvaluateModel.map(EvaluationResult.classificationAcc(:),2);
%==========================================================================
% %1 Frequency Band FFT Study Example Code
%==========================================================================
%rerun everytime a new dataset is used
load = LoadFile('..\Data\EC Below70\','AD','HC');
proc = DataProcessing(23,3,2000,double(12.00),load);

delta = FourierFeatures(proc,'1fBand','delta',[]);
deltaModel = ClassifyModel(1,delta,load.channelName,proc.channelNo);
deltaResult = EvaluateModel(deltaModel.resultAcc,deltaModel.resultTP,deltaModel.resultFP,deltaModel.resultTN,deltaModel.resultFN,deltaModel.channelName);
% %Visualise the result----------------------------------------------------
EvaluateModel.map(deltaResult.classificationAcc(:),2);