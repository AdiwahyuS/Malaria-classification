seg_folder = 'blood_smear';
image_folder = dir(seg_folder);
cd(seg_folder);
num = length(image_folder);
train_features_glcm1 = zeros(1,16);
train_labels = zeros(1,1);
label = 1;
for folders = 3:num
    images = dir(image_folder(folders).name);
    num_images = length(images);
    cd(image_folder(folders).name);
    fprintf('Evaluating features for %s\n' ,  image_folder(folders).name);
    for idx = 3:num_images
        seg_img = imread(images(idx).name);
        I = imresize(seg_img,[50,50]);
        if ndims(I) == 3
            img = rgb2gray(I);
        end
        offsets = [0 1;-1 1;-1 0;-1 -1];
        [GLCM,SI] = graycomatrix(img,'Of',offsets);
        %GLCM = graycomatrix(img);
        stats = graycoprops(GLCM, 'all');
        features = struct2array(stats);
        train_features_glcm1 = [train_features_glcm1; features];
        train_labels = [train_labels; label];
    end
    cd ../;
    label = label + 1;
end
train_features_glcm1(1,:) = [];
glcm = train_features_glcm1;
train_labels(1,:) = [];

train_glcm = [train_labels glcm];
save ../glcm_data4.mat glcm train_glcm train_labels;