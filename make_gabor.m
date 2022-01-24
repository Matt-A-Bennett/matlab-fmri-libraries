function gabor_filter = make_gabor(filter_size, cycles_per_im, orientation, pix_gauss_std, varargin)
    %% documentation:
    % describe what the function does
    %
    % mandory arguments:
    % filter_size :
    %
    % cycles_per_im :
    %
    % orientation :
    %
    % pix_gauss_std :
    %
    % optional arguments (passed as structure - see usage example below):
    % optional_arg1 :  (default = True)
    % optional_arg2 :  (default = False)
    %
    % function usage example:
    % clear make_gabor_params
    % make_gabor_params.optional_arg1 = <value1>;
    % make_gabor_params.optional_arg2 = <value2>;
    % gabor_filter = make_gabor(filter_size, pix_wavelength, orientation, pix_gauss_std, arg, make_gabor_params);

    % %% set default values for optional variables
    % optional_arg1 = True;
    % optional_arg2 = False;

    %% override optional arguments
    % if varagin variables have been provided, overwrite the above default
    % values with provided values
    if ~isempty(varargin)
        if size(fieldnames(varargin{1}), 1) ~= 0
            vars_in_fields = fieldnames(varargin{1});
            % check variable names in varargin are expected by this function
            for i = 1:numel(vars_in_fields)
                if ~exist(vars_in_fields{i}, 'var')
                    error(sprintf([['variable <%s> does not correspond ',...
                        'exactly to any variable name used in the function',...
                        '\n\nvalid variable names are as follows:',...
                        '\n'],...


                        ], vars_in_fields{i}))
                end
            end
            additional_params = varargin{1};
            for additional_params_index = 1:size(fieldnames(varargin{1}), 1)
                eval([vars_in_fields{additional_params_index},...
                    ' = additional_params.',...
                    vars_in_fields{additional_params_index}, ';'])
            end
        end
    end

    %% start the actual fuction

    k = cycles_per_im;
    x = 1:filter_size;
    y = 1:filter_size ;
    [X,Y] = meshgrid(x,y) ;
    I = 1/2*(1+sin(2*pi/filter_size*k*X)) ;
    I = I - 0.5;
    I = imrotate(I, orientation, 'bilinear', 'crop');

    gauss = fspecial('gaussian', [filter_size, filter_size], pix_gauss_std);

    tmp = I.*gauss;
    tmp = rescale(tmp);
    tmp = tmp-mode(tmp(:));

    clip = zeros(size(gauss));
    clip(gauss<0.0000001)=1;
    tmp(logical(clip)) = mode(tmp(:));

    gabor_filter = tmp;



