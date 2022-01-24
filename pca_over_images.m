% images is a 3D matrix where each image is in 3rd dim
images = zeros(58, 58, 158);

disp('loading images...')
for nFile = 1:Dataset.NFiles

    % Read the image
    tIm = imread( [FileNames.FileNames{nFile}] ) ;

    % select a square region of the image
    if strcmp(Dataset.Name, 'siblings')
        tmp_imsize = size(tIm);
        tIm = tIm(:, round((tmp_imsize(2)/2)-tmp_imsize(1)/2):round((tmp_imsize(2)/2)+tmp_imsize(1)/2), :);
    end

    % Resize the image
    tIm = imresize(tIm, fliplr( Dataset.ImageSize.Pix ) ) ;

    % If the image is in colour, convert it to greyscale
    if (size(tIm,3) == 3)
        % tIm = rgb2gray(imread(tIm)) ;
        tIm = rgb2gray(tIm) ;
    end

    % Convert the image to double
    tIm = im2double (tIm) ;

    % % plot the some of the images as they will be fed into the network
    % if nFile < 29
    %     subplot(4,7,nFile)
    %     imagesc(tIm), axis image off, colormap gray
    % end

    % An optional grey-world type contrast normalisation
    sw.GreyWorldNormalisation = 1; % 0 -> No, 1 -> Yes
    if sw.GreyWorldNormalisation
        % Centring each image at zero
        tIm = tIm - mean( tIm(:) ) ;
        % Scaling such that max power in any given pixel is one
        tIm = tIm / norm( tIm(:) , 2);
    end
    images(:,:,nFile) = tIm;
end

% for i = 1:158
%     tmp = squeeze(sum(Retinotopic_RGCActivations_Thresholded(:,:,:,i),3));
%     images(:,:,i) = tmp;
% end

[h, w, n] = size(images);
d = h * w;
% vectorize images
x = reshape(images, [d n]);
x = double(x);
% subtract mean
mean_matrix = mean(x, 2);
x = bsxfun(@minus, x, mean_matrix);
% calculate covariance
s = cov(x');
% obtain eigenvalue & eigenvector
[V, D] = eig(s);
eigval = diag(D);
% sort eigenvalues in descending order
eigval = eigval(end: - 1:1);
V = fliplr(V);
% show mean and 1st through 15th principal eigenvectors
figure, subplot(4, 4, 1)
imagesc(reshape(mean_matrix, [h, w]))
colormap gray
for i = 1:15
    subplot(4, 4, i + 1)
    imagesc(reshape(V(:, i), h, w))
end

% evaluate the number of principal components needed to represent 95% Total variance.
eigsum = sum(eigval);
csum = 0;
for i = 1:d
    csum = csum + eigval(i);
    tv = csum / eigsum;
    if tv > 0.95
        k95 = i;
        fprintf('%d components are needed to capture 95%% of the variation in the dataset.\n', i);
        break
    end;
end;
