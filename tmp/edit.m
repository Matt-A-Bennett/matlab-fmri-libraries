oris = {'sag', 'axial', 'cor'}
filt = fspecial('gaussian', [7, 7], 2);

for ori = 1:3
    for i = 1:256
        if exist([oris{ori}, '_', num2str(i), '.png'])
            [im, ~, alpha] = imread([oris{ori}, '_', num2str(i), '.png']);
            alpha = double(im~=0);
            alpha = logical(imfilter(alpha, filt));
            binaryImage = double(~bwareaopen(~alpha, 400));
            alpha = imfilter(alpha);
            imwrite(im, [oris{ori}, '_', num2str(i), '_transparent.png'], 'alpha', alpha)
        end
    end
end
