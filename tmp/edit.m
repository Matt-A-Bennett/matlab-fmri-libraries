oris = {'sag', 'axial', 'cor'}
filt = fspecial('gaussian', [7, 7], 2);

for ori = 1:3
    for i = 1:256
        if exist([oris{ori}, '_', num2str(i), '.png'])
            im = imread([oris{ori}, '_', num2str(i), '.png']);
            im = imresize(im, 2);
            alpha = double(im~=0);
            alpha = logical(imfilter(alpha, filt));
            alpha = double(~bwareaopen(~alpha, 1600));
            imwrite(im, [oris{ori}, '_', num2str(i), '_transparent_big.png'], 'alpha', alpha)
        end
    end
end

