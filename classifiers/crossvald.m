JumlahFold          = 10;
data                = importdata('train_glcm2.mat');
label               = data(:,1);
indeks              = crossvalind('Kfold',label,JumlahFold);
%JumlahHiddenNeurons = 3500;
FungsiAktivasi      = 'tribas';
AkurasiTrainingPerFold   = zeros(JumlahFold,1);
AkurasiTestingPerFold    = zeros(JumlahFold,1);
SensPerFold    = zeros(JumlahFold,1);
SpecPerFold    = zeros(JumlahFold,1);
for i = 1 : JumlahFold
    fprintf('Fold ke - %d\n', i);
    test      = (indeks == i); 
    train     = ~test;
    [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy, Sensitivity, Specifity] = elm(data(train,:),data(test,:), 1, FungsiAktivasi);
    AkurasiTrainingPerFold(i,1) = TrainingAccuracy;
    AkurasiTestingPerFold(i,1)  = TestingAccuracy;
    SensPerFold(i,1)  = Sensitivity;
    SpecPerFold(i,1)  = Specifity;
end

AkurasiTrainingRataRata = mean(AkurasiTrainingPerFold)
AkurasiTestingRataRata  = mean(AkurasiTestingPerFold)
SensTestingRataRata  = mean(SensPerFold)
SpecTestingRataRata  = mean(SpecPerFold)
