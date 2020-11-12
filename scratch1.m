
pamap = niftiread(sprintf('%s%s', data_dir, pa_map_outname));
eccmap = niftiread(sprintf('%s%s', data_dir, ecc_map_outname));

figure
count = 0;
for slice_idx = 9:9+48-1% size(map,1)
    count = count + 1;
    % subplot(ceil(sqrt(size(map,1))), ceil(sqrt(size(map,1))), slice_idx)
    subplot(4,12,count)
    imagesc(rot90(squeeze(pamap(slice_idx,1:30,10:60))))
    axis image
    caxis([min(pamap(:)), max(pamap(:))])
end

figure
count = 0;
for slice_idx = 19:19+40-1 %size(eccmap,3)
    count = count + 1;
    % subplot(ceil(sqrt(size(eccmap,3))), ceil(sqrt(size(eccmap,3))), slice_idx)
    subplot(6,7,count)
    imagesc(rot90(squeeze(eccmap(:,1:30,slice_idx))))
    axis image
    caxis([0 140])
end

i=2
idx = 3082
