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
    gaussian_models = 0;

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
    % r_squared = nan(map_size);

    roi = find(mask(:));

    % find best model fitting the fits
    progress_incr = 1; % update at N% intervals
    progress = 0;
    for idx = 1:length(roi)
        % display progress
        percent = idx/length(roi);
        if percent >= progress/100
            fprintf('%s%% done...\n', num2str(round(percent*100)));
            progress = progress + progress_incr;
        end

        % get voxel location from mask
        vox = roi(idx);
        [x,y,z] = ind2sub(map_size,vox);

        % populate field with model fits
        field = nan(size(models(1).grids,1), size(models(1).grids,1));
        for i = 1:size(models,2)
            fits = corr(double(squeeze(functional(x,y,z,:))), models(i).models);
            field(models(i).grids) = fits;
        end

        if size(models,2) > 1
            % interpolate over the missing values
            [y,x] = ind2sub(size(field), find(~isnan(field(:))));
            v = field(~isnan(field(:)));
            [xq,yq] = meshgrid(1:size(field,1), 1:size(field,2));
            to_fit = griddata(x,y,v,xq,yq, 'linear');
        else
            to_fit = field;
        end
        % keyboard
        to_fit(isnan(to_fit))=0;

        % tmp = to_fit(:)'*gaussian_models.gaussians';
        % [r, ix] = max(tmp(:));

        % figure, scatter(to_fit(:), gaussian_models.gaussians(ix,:), '.')
        % axis([0.25 0.33 0 0.01])

        % winner = gaussian_models.gaussians(ix,:);
        % winner = reshape(winner, 270, 270);

        % to_fit_smoothed = imgaussfilt(to_fit,1);
        % [amp, ix] = max(to_fit_smoothed(:));
        % [i, j] = ind2sub(size(to_fit_smoothed),ix);

        try
            % fit a gaussian to the field map to estimate pRF location
            % out = [Amp, x_coord, x_sigma, y_coord, y_sigma, gauss_rotation]
            out = fit_gauss_2D(to_fit);
        catch
            out = nan(1,5);
        end
        X(vox) = out(2);
        Y(vox) = out(4);
        sigma(vox) = mean([out(3), out(5)]);

        % X(vox) = gaussian_models.params(ix,1);
        % Y(vox) = gaussian_models.params(ix,2);
        % sigma(vox) = gaussian_models.params(ix,3);

    end

    fitted_models.X = X;
    fitted_models.Y = Y;
    fitted_models.sigma = sigma;

