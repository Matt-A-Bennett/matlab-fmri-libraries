addpath '/home/umutc/Music/scripts/matlab/matlab'
image_dirs = {'/home/mattb/projects/uclouvain/jolien_proj/exported_pa_ecc/',
'/home/mattb/projects/uclouvain/jolien_proj/exported_bars/',
'/home/mattb/projects/uclouvain/jolien_proj/exported_bars/'};

% data_dir = '/home/mattb/projects/uclouvain/jolien_proj/';
data_dir = '/home/joliens/Documents/02_recurrentSF_3T/data-bids/derivatives/fmriprep/';
fake_tstat_dir = '/home/joliens/Documents/02_recurrentSF_3T/data-bids/derivatives/analysis-eva/';

out_dir = '/home/umutc/Music/analysis-eva/';

func_names = {'_ses-01_task-paEcc_space-T1w_desc-preproc_bold.nii.gz',
'_ses-01_task-prfBars_run-1_space-T1w_desc-preproc_bold.nii.gz',
'_ses-01_task-prfBars_run-2_space-T1w_desc-preproc_bold.nii.gz'};

subs = {'01' '02' '03' '04' '09' '11' '12' '17' '18'}
subs = {'19', '20', '21', '22'}

nsubs = length(subs)

stat_map_name = 'tstat1.nii.gz';
% stat_map_name = '_fake_tstat_map_retino.nii.gz';

pa_map_outname = 'pa_from_pRF_paecc_bars_bars_detrend';
ecc_map_outname = 'ecc_from_pRF_paecc_bars_bars_detrend';
prf_size_map_outname = 'prf_size_from_pRF_paecc_bars_bars_detrend';
rsq_map_outname = 'rsq_from_pRF_paecc_bars_bars_detrend';

screen_height_pix = 1080;
screen_height_cm = 39;
screen_distance_cm = 200;

%% parameters
% if we pretend the screen was lower resolution, all the computations are less
% expensive and we don't lose much precision (it's no as if we can reliably
% estimate the pRF location down to the pixel level)
down_sample_model_space_factor = 4;

% number of pixels (in downsized space) bewteen neighbouring pRF models
grid_density = 5;
% might mix the upper and lower visual fields for V1 (calcerine sulcus)
do_spatial_smoothing = 1;
thresh = 0.1

% sigmas in visual degrees to try as models
% I think a logarithmic scaling could be better here...
sigmas = [0.05 : 0.3 : 1];

% specifc to pa-ecc run and the 2 bar runs
time_steps = [1000/(((6*42667)-450)/842),...
    1000/(((16*20000)-450)/1044),...
    1000/(((16*20000)-450)/1044)];

%% start
pixperVA = pixperVisAng(screen_height_pix, screen_height_cm, screen_distance_cm);
sigmas = (sigmas * pixperVA)/down_sample_model_space_factor;

nruns = size(func_names,1);
identity_nruns = eye(nruns);
nvols = zeros(nruns,1);
for sub_idx = 1:nsubs
    multi_func_ni = [];
    combined_models.models = [];
    multi_run_dm = [];
    sub = subs{sub_idx};
    sub_data_dir = sprintf('%ssub-%s/ses-01/func/', data_dir, sub);
    sub_out_dir = sprintf('%ssub-%s/', out_dir, sub);
    fprintf('processing sub %s...\n', sub);
    for run_idx = 1:nruns
        fprintf('processing run %d...\n', run_idx);
        time_step = time_steps(run_idx);
        image_dir = image_dirs{run_idx};

        % load functional data and concaternate in along time dimension
        functional_ni = niftiread(sprintf('%ssub-%s%s', sub_data_dir, sub, func_names{run_idx}));

        % spatial smoothing
        if do_spatial_smoothing
            for vol_idx = 1:size(functional_ni,4)
                smoothed = smooth3(functional_ni(:,:,:,vol_idx), 'gaussian', 3);
                functional_ni(:,:,:,vol_idx) = smoothed;
            end
        end

        multi_func_ni = cat(4, multi_func_ni, functional_ni);
        nvols(run_idx) = size(functional_ni,4);

        % build up the global run confounds design matrix
        multi_run_dm = [multi_run_dm;...
            kron(identity_nruns(run_idx,:), ones(nvols(run_idx,1),1))];

        % check for duplicate directories to avoid doing work multiple times
        if run_idx > 1 && strcmp(image_dir, image_dirs{run_idx-1}) &&...
                nvols(run_idx) == nvols(run_idx-1)
            combined_models.models = cat(1, combined_models.models, models.models);
            continue
        end

        % convert the .png screenshots to a 3D binary mask matrix
        clear retstim2mask_params
        retstim2mask_params.resize = screen_height_pix/down_sample_model_space_factor;
        stimMasks = retstim2mask(image_dir, retstim2mask_params);

        % create model timecourse and pad to make the baseline
        models = makePRFmodels(stimMasks, grid_density, sigmas);
        pad = zeros(size(models.models,1), round(12*time_step));
        models.models = [pad, models.models, pad];

        % convolve the model timecourses with HRF function
        clear dm_conv_params
        dm_conv_params.time_res = 'ms';
        dm_conv_params.time_step = time_step;
        dm_conv = hrf_conv(models.models', dm_conv_params);

        % down sample dm_conv to the TR resolution
        idxq = linspace(1, size(dm_conv,1), size(dm_conv,1)/(time_step*2));
        dm_conv = interp1(dm_conv, idxq, 'linear');
        dm_conv = [dm_conv; zeros(nvols(run_idx)-size(dm_conv,1), size(dm_conv,2))];
        models.models = dm_conv;

        % concaternate models so far
        combined_models.models = cat(1, combined_models.models, models.models);
        combined_models.params = models.params;
    end

    % for testing
    func_mean = squeeze(mean(functional_ni,4));
    map_size = size(functional_ni);
    map_size = map_size(1:3);
    mask = zeros(map_size);
    mask(:, 1:18, :) = 1;
    mask(func_mean<-20000) = 0;

    % fit_pRFs_params.mask = mask;
    % fitted_models = fit_pRFs(functional_ni, models, fit_pRFs_params)

    % % convert X and Y coords to polar and eccentricity coords
    % [theta, rho] = cart2pol(fitted_models.X, fitted_models.Y);

    % %% write to nifti
    % % load map info
    % tstat_info_ni = niftiinfo(sprintf('%s%s', data_dir, stat_name));

    % % change name and
    % tstat_info_ni.Filename = [data_dir, pa_map_outname, '.nii'];
    % niftiwrite(single(theta), [data_dir, pa_map_outname], tstat_info_ni);

    % tstat_info_ni.Filename = [data_dir, ecc_map_outname, '.nii'];
    % niftiwrite(single(rho), [data_dir, ecc_map_outname], tstat_info_ni);

    % figure
    % for im_slice = 1:30
    %     subplot(5,6,im_slice)
    %     % imagesc(rot90(squeeze(func_mean(:, im_slice, :)))), axis image, colormap gray
    %     % imagesc(rot90(squeeze(fitted_models.Y(:, im_slice, :)))), axis image
    %     % imagesc(rot90(squeeze(rho(:, im_slice, :)))), axis image, caxis([min(rho(:)), max(rho(:))])
    %     imagesc(rot90(squeeze(theta(:, im_slice, :)))), axis image, caxis([min(theta(:)), max(theta(:))])
    %     % imagesc(rot90(squeeze(mask(:, im_slice, :)))), axis image, colormap gray
    % end

    % mask(:, 1:20, :) = 1;
    % mask(func_mean<-20000) = 0;

    % remove global run confounds using glm
    % put the data into a volumes x voxels matrix
    multi_func_ni = permute(multi_func_ni, [4, 1, 2 3]);
    multi_func_ni = reshape(multi_func_ni, size(multi_func_ni,1), []);
    % estimate the voxel run means, make the model, subract it off
    run_counfounds = multi_run_dm \ double(multi_func_ni);
    confound_model = multi_run_dm * run_counfounds;
    resid = double(multi_func_ni) - confound_model;

    % remove slow drifts
    % assuming 16 mins of functional data, to get 8th degree polynomial:
    % Kay, K., Rokem, A., Winawer, J., Dougherty, R., & Wandell, B. (2013).
    % GLMdenoise: a fast, automated technique for denoising task-based fMRI
    % data. Frontiers in neuroscience, 247.

    % "The number of polynomial regressors included in The model is set by a
    % simple heuristic: for each run, we include polynomials of degrees 0
    % through round(L/2) where L is the duration in minutes outputf the run
    % (thus, higher degree polynomials are used for longer runs)."
    resid = detrend(resid, 8);

    % put the data back into it's original 4D shape
    multi_func_ni = reshape(resid, [sum(nvols), map_size]);
    multi_func_ni = permute(multi_func_ni, [2, 3, 4 1]);

    %% fit models
    fprintf('fitting pRFs...\n');
    clear fit_pRFs_params
    fit_pRFs_params.mask = mask;
    fitted_models = fit_pRFs(multi_func_ni, combined_models, fit_pRFs_params);

    % convert X and Y coords to polar and eccentricity coords
    [theta, rho] = cart2pol(fitted_models.X-retstim2mask_params.resize/2,...
        fitted_models.Y-retstim2mask_params.resize/2);

    % convert theta into degrees (1-180 from upper to lower visual field)
    theta = rad2deg(theta)+180;
    theta = changem(round(theta), [91:180, fliplr(1:180), 1:90], [1:360]);

    fprintf('writing nifti maps...\n\n');
    for i = 1:2
        if i == 1
            thresh_name = '';
        else
            thresh_name = ['_', num2str(thresh)];
            % threshold maps
            theta(fitted_models.r_squared<thresh) = NaN;
            rho(fitted_models.r_squared<thresh) = NaN;
            fitted_models.sigma(fitted_models.sigma<thresh) = NaN;
        end
        %% write to nifti
        % load map info as template
        tstat_info_ni = niftiinfo(sprintf('%ssub-%s/fake_stat_map.feat/stats/%s', fake_tstat_dir, sub, stat_map_name));
        tstat_info_ni.ImageSize = map_size;
        % write polar angle map
        tstat_info_ni.Filename = [out_dir, 'sub-', sub, '/SUMA/', pa_map_outname, '_thr', thresh_name, '.nii'];
        niftiwrite(single(theta), [out_dir, 'sub-', sub, '/SUMA/', pa_map_outname, '_thr', thresh_name, '.nii'], tstat_info_ni);
        % write eccentricity map
        tstat_info_ni.Filename = [out_dir, 'sub-', sub, '/SUMA/', ecc_map_outname, '_thr', thresh_name, '.nii'];
        niftiwrite(single(rho), [out_dir, 'sub-', sub, '/SUMA/', ecc_map_outname, '_thr', thresh_name, '.nii'], tstat_info_ni);
        % write prf_size map
        tstat_info_ni.Filename = [out_dir, 'sub-', sub, '/SUMA/', prf_size_map_outname, '_thr', thresh_name, '.nii'];
        niftiwrite(single(fitted_models.sigma), [out_dir, 'sub-', sub, '/SUMA/', prf_size_map_outname, '_thr', thresh_name, '.nii'], tstat_info_ni);
        % write r_squared map
        tstat_info_ni.Filename = [out_dir, 'sub-', sub, '/SUMA/', rsq_map_outname, '_thr', thresh_name, '.nii'];
        niftiwrite(single(fitted_models.r_squared), [out_dir, 'sub-', sub, '/SUMA/', rsq_map_outname, '_thr', thresh_name, '.nii'], tstat_info_ni);
    end
end
