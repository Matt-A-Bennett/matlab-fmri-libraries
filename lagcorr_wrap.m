% paths
addpath('../matlab')
path = '/home/mattb/projects/uclouvain/jolien_proj/';
data_name = 'sub-01_ses-01_task-paEcc_space-T1w_desc-preproc_bold.nii.gz';
stat_name = 'tstat1.nii.gz';
pa_outname = 'pa_lag1-84_bh';
ecc_outname = 'ecc_lag1-102_bh';

% load nifi
pa_ecc_ni = niftiread(sprintf('%s%s', path, data_name));
tstat_ni = niftiread(sprintf('%s%s', path, stat_name));
tstat_info_ni = niftiinfo(sprintf('%s%s', path, stat_name));

pa_ecc_ni_av = mean(pa_ecc_ni,4);
pa_ecc_ni_av = uint8(255 * mat2gray(pa_ecc_ni_av));

clear params
params.time_res = 'ms';
% pa
[max_lag, max_r] = lagcorr(pa_ecc_ni, 2000, 500, 42667, 6, 42667, params);

% remap lag values
% I think this is to shift all the values by 84/4 -> by 1/4 -> from 3 O'clock
% to 12 O'clock... to make the colours make sense
max_lag = changem(max_lag, 1:84, [63:84,1:62]);
% max_lag_thresh = max_lag ;
% max_lag_thresh(max_r<0.15)=0;

tstat_info_ni.Filename = [path, pa_outname, '.nii'];
niftiwrite(single(max_lag), [path, pa_outname], tstat_info_ni);
% niftiwrite(single(max_lag_thresh), [path, pa_outname], tstat_info_ni);

% ecc
[max_lag, max_r] = lagcorr(pa_ecc_ni, 2000, 500, 51333, 5, 51333, params);
tstat_info_ni.Filename = [path, ecc_outname, '.nii'];
niftiwrite(single(max_lag), [path, ecc_outname], tstat_info_ni);
