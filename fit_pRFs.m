function fitted_models = fit_pRFs(functional, models, varargin)
    % documentation:
    % Takes in a nifti (<functional>), <models>, and an optional <mask> and
    % and outputs a structure <fitted_models> which contains 3 fields each the
    % same size as <functional>. The 3 fields contain the X, Y, sigma, and r
    % squared paratmeters of the fitted models.

    % mandory arguments:
    % functional : a nifti timeseries

    % models :  output of the makePRFmodels.m once the data in the
    %           models.models function has been convolved with an HRF function
    %           (e.g. using the function hrf_conv.m)

    % default values for vars not set in varargin:
    mask = ones(size(functional)); %    logical where ones specify which voxles
    %                                   to fit

    % if varagin variables have been provided, overwrite the above default
    % values with provided values
    if ~isempty(varargin)
        if size(fieldnames(varargin{1}), 1) ~= 0

            vars_in_fields = fieldnames(varargin{1});
            for i = 1:numel(vars_in_fields)
                if ~exist(vars_in_fields{i}, 'var')
                    error('one or more of varargins does not correspond exactly to any variable name used in the function')
                end
            end
            additional_params = varargin{1};

            for additional_params_index = 1:size(fieldnames(varargin{1}), 1)
                eval([vars_in_fields{additional_params_index}, ' = additional_params.', vars_in_fields{additional_params_index}, ';'])
            end
        end
    end

    %% start the actual fuction
    map_size = size(functional);
    map_size = map_size(1:3);

    % preallocate for memory
    X = nan(map_size);
    Y = nan(map_size);
    sigma = nan(map_size);
    r_squared = nan(map_size);

    % keyboard

    roi = find(mask(:));
    for idx = 1:length(roi)
        vox = roi(idx);
        [x,y,z] = ind2sub(map_size,vox);
        fits = corr(double(squeeze(functional(x,y,z,:))), models.models);
        [r, i] = max(fits);
        % if r > 0.03
        %     break
        % end
        best_model = models.params(i,:);
        X(vox) = best_model(1);
        Y(vox) = best_model(2);
        sigma(vox) = best_model(3);
        r_squared(vox) = r*r;
    end

    % models.params(1344,:)

    % scatter(models.params(:,1), models.params(:,2), 50, fits, 'filled', 'sq')

    % models.params(1400,:)

    % subplot(1,3,1)
    % imagesc(reshape(models.models(200, 1:1344), 54, 54))
    % subplot(1,3,2)
    % imagesc(reshape(models.models(200, 2917:5832), 54, 54))
    % subplot(1,3,3)
    % imagesc(reshape(models.models(200, 5833:8748), 54, 54))

    % thing = reshape(fits(1:2916), 54, 54);
    % imagesc(thing),
    % caxis([0, 0.4])

    % size(models.models)
    % subplot(4,1,1)
    % plot(double(squeeze(functional(x,y,z,:))))
    % subplot(4,1,2)
    % plot(models.models(:,1))
    % subplot(4,1,3)
    % plot(models.models(:,3000))
    % subplot(4,1,4)
    % plot(models.models(:,8000))

    fitted_models.X = X;
    fitted_models.Y = Y;
    fitted_models.sigma = sigma;
    fitted_models.r_squared = r_squared;

    %% how can we improve the fits?
    % fit_mat = nan(270);
    % for idx = 386*2+1:386*3 %size(models.params,1)/3
    % fit_mat(models.params(idx, 1), models.params(idx, 2)) = fits(idx);
    % end
    % gauss = fspecial('gaussian', [10, 10], 3);
    % fit_mat = nanconv(fit_mat, gauss);
    % figure, surf(fit_mat),% axis image



