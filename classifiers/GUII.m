function varargout = GUII(varargin)
% GUII MATLAB code for GUII.fig
%      GUII, by itself, creates a new GUII or raises the existing
%      singleton*.
%
%      H = GUII returns the handle to a new GUII or the handle to
%      the existing singleton*.
%
%      GUII('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUII.M with the given input arguments.
%
%      GUII('Property','Value',...) creates a new GUII or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUII_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUII_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUII

% Last Modified by GUIDE v2.5 29-Aug-2019 16:45:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUII_OpeningFcn, ...
                   'gui_OutputFcn',  @GUII_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUII is made visible.
function GUII_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUII (see VARARGIN)

% Choose default command line output for GUII
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUII wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUII_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
global I
[filename, pathname] = uigetfile({'*.*';'*.bmp';'*.jpg';'*.gif'}, 'Pick a Image File');
I = imread([pathname,filename]);
axes(handles.axes1);
imshow(I);
title('Sel Darah Merah');
handles.imageData = I;
guidata(hObject,handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I
I2 = imresize(I,[50,50]);
seg_img = SegmentImage(I2,10);
if ndims(seg_img) == 3
   I3 = rgb2gray(seg_img);
end
axes(handles.axes2);
imshow(I3);title('Segmented Image');
handles.I3 = I3;
guidata(hObject,handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I3
offsets = [0 1;-1 1;-1 0;-1 -1];
[GLCM,SI] = graycomatrix(I3,'Of',offsets);
%GLCM = graycomatrix(img);
stats = graycoprops([GLCM,SI], 'all');
features = struct2array(stats);

result1 = [1,features];
result2 = [2,features];
mat(1,:) = result1;
mat(2,:) = result2;

%%%%%%%%%%% Load training dataset
train_data=importdata('train_glcm2.mat');
T=train_data(:,1)';
P=train_data(:,2:size(train_data,2))';
clear train_data;                                   %   Release raw training data array

TV.T= mat(:,1)';
TV.P= mat(:,2:size(mat,2))';

NumberofTrainingData = size(P,2);
NumberofTestingData = size(TV.P,2);
%NumberofInputNeurons = size(P,1);
%NumberofHiddenNeurons = 3000;

%%%%%%%%%%% Preprocessing the data of classification
    sorted_target=sort(cat(2,T,TV.T),2);
    label=zeros(1,1);                               %   Find and save in 'label' class label from training and testing data sets
    label(1,1)=sorted_target(1,1);
    j=1;
    for i = 2:(NumberofTrainingData+NumberofTestingData)
        if sorted_target(1,i) ~= label(1,j)
            j=j+1;
            label(1,j) = sorted_target(1,i);
        end
    end
    number_class=j;
    NumberofOutputNeurons=number_class;
       
    %%%%%%%%%% Processing the targets of training
    temp_T=zeros(NumberofOutputNeurons, NumberofTrainingData);
    for i = 1:NumberofTrainingData
        for j = 1:number_class
            if label(1,j) == T(1,i)
                break; 
            end
        end
        temp_T(j,i)=1;
    end
    T=temp_T*2-1;

    %%%%%%%%%% Processing the targets of testing
    temp_TV_T=zeros(NumberofOutputNeurons, NumberofTestingData);
    for i = 1:NumberofTestingData
        for j = 1:number_class
            if label(1,j) == TV.T(1,i)
                break; 
            end
        end
        temp_TV_T(j,i)=1;
    end
    TV.T=temp_TV_T*2-1;
    

%%%%%%%%%%% Calculate weights & biases

%%%%%%%%%%% Random generate input weights InputWeight (w_i) and biases BiasofHiddenNeurons (b_i) of hidden neurons
%InputWeight=rand(NumberofHiddenNeurons,NumberofInputNeurons)*2-1;
InputWeight = importdata('bobot300016.mat');
%BiasofHiddenNeurons=rand(NumberofHiddenNeurons,1);
BiasofHiddenNeurons = importdata('bias3000.mat');
tempH=InputWeight*P;
ind=ones(1,NumberofTrainingData);
BiasMatrix=BiasofHiddenNeurons(:,ind);              %   Extend the bias matrix BiasofHiddenNeurons to match the demention of H
tempH=tempH+BiasMatrix;

%%%%%%%% Triangular basis function
H = tribas(tempH);

%%%%%%%%%%% Calculate output weights OutputWeight (beta_i)
OutputWeight=pinv(H') * T';                       

tempH_test=InputWeight*TV.P;
clear TV.P;             %   Release input of testing data             
ind=ones(1,NumberofTestingData);
BiasMatrix=BiasofHiddenNeurons(:,ind);              %   Extend the bias matrix BiasofHiddenNeurons to match the demention of H
tempH_test=tempH_test + BiasMatrix;

H_test = tribas(tempH_test); 

TY=(H_test' * OutputWeight)';

for i = 1 : size(TV.T, 2)
        [x, label_index_expected]=max(TV.T(:,i));
        [x, label_index_actual]=max(TY(:,i));
        expected(:,i) = label_index_expected;
        actual(:,i)   = label_index_actual;
end
    confusionTesting = confusionmat(expected,actual);
    TestingAccuracy   = sum(diag(confusionTesting)) / sum(sum(confusionTesting));
    
    TP = confusionTesting(1,1); % TP
    TN = confusionTesting(2,2); % TN
    Sensitivity = TP / sum(confusionTesting(:,1));
    Specificity = TN / sum(confusionTesting(:,2));
    
output= label_index_expected;

if output == 1
   kelas = 'Infected';title('Infected');
elseif output == 2
   kelas = 'Uninfected';title('Uninfected');
end
pause(.5);

set(handles.Pred,'String',kelas)
set(handles.sens,'String',Sensitivity)
set(handles.spec,'String',Specificity)
clear;
