models
sqrt(729)

tmp = fits;
to_fit = reshape(fits, 54, 54);
tmp(models.out_of_roi)=0;
sum(models.out_of_roi)
rem(12, 2)

progress_incr = 10;
for idx = 1:30000
    percent = idx/length(roi);
    if percent > progress_incr/100
        fprintf('%s% done...\n', num2str(percent*100));
        progress_incr = progress_incr + 10;
    end
end

