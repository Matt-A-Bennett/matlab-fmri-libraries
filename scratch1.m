data_dir = '~/projects/uclouvain/jolien_proj/';
pa_map_outname = 'pa_from_pRF_paecc_bars_bars_new_owngauss.nii';
ecc_map_outname = 'ecc_from_pRF_paecc_bars_bars_new_owngauss.nii';
prf_size_map_outname = 'prf_size_from_pRF_paecc_bars_bars_new_owngauss.nii';

pamap = niftiread(sprintf('%s%s', data_dir, pa_map_outname));
eccmap = niftiread(sprintf('%s%s', data_dir, ecc_map_outname));
prf_size_map = niftiread(sprintf('%s%s', data_dir, prf_size_map_outname));

figure
count = 0;
for slice_idx = 9:9+48-1% size(map,1)
    count = count + 1;
    % subplot(ceil(sqrt(size(map,1))), ceil(sqrt(size(map,1))), slice_idx)
    subplot(4,12,count)
    imagesc(rot90(squeeze(pamap(slice_idx,1:30,10:60))))
    axis image
    caxis([min(pamap(:)), max(pamap(:))+.001])
end

figure
count = 0;
for slice_idx = 19:19+40-1 %size(eccmap,3)
    count = count + 1;
    % subplot(ceil(sqrt(size(eccmap,3))), ceil(sqrt(size(eccmap,3))), slice_idx)
    subplot(6,7,count)
    imagesc(rot90(squeeze(eccmap(:,1:30,slice_idx))))
    axis image
    % caxis([min(eccmap(:)), max(eccmap(:))+.001])
    % caxis([0, 900])
end
figure, hist(eccmap(:),100)

figure
count = 0;
for slice_idx = 19:19+40-1 %size(prf_size_map,3)
    count = count + 1;
    % subplot(ceil(sqrt(size(prf_size_map,3))), ceil(sqrt(size(prf_size_map,3))), slice_idx)
    subplot(6,7,count)
    imagesc(rot90(squeeze(prf_size_map(:,1:30,slice_idx))))
    axis image
    caxis([min(prf_size_map(:)), max(prf_size_map(:))+.001])
end
figure, hist(prf_size_map(:),100)

