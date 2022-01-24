function sub_matrix = submatrix(original, position, subwidth, subheight, varargin)
    %% documentation:
    % Extracts a sub matrix from <original> centred at the coordinates in
    % <position> and with <subwidth> columns and <subheight> rows. If a part of the
    % speicified % submatrix exceeds the bounds of <original>, then the
    % submatrix is clipped by default. If <clip> is set to zero in the optional
    % arguments (see below) then the that part of the submatrix that exceeds
    % <original> is padded with NaNs.
    %
    % mandory arguments:
    % original : a 2D matrix
    %
    % position : a vector containing the row and column where the submatrix
    %            will be centred
    %
    % subwidth :    the number of columns in submatrix
    %
    % subheight :   the number of rows in submatrix
    %
    % optional arguments (passed as structure - see usage example below):
    % clip : (default = 1) if set to zero in the optional arguments (see below)
    % then the that part of the submatrix that exceeds <original> is padded
    % with NaNs.
    %
    % function usage example:
    % clear submatrix_params
    % submatrix_params.clip = <value1>;
    % sub_matrix = submatrix(original, position, subwidth, subheight, submatrix_params);

    %% set default values for optional variables
    clip = 1;

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
                        ['\n% clip'],...
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
    r1 = position(1) - floor(subheight/2);
    r2 = r1 + subheight;
    c1 = position(2) - floor(subwidth/2);
    c2 = c1 + subwidth;

    if mod(subheight,2)==0
        r1 = r1 + 1;
    end
    if mod(subwidth,2)==0
        c1 = c1 + 1;
    end

    r1_pad = 0;
    if r1 < 1
        if ~clip
            r1_pad = abs(r1);
        end
        r1 = 1;
    end

    c1_pad = 0;
    if c1 < 1
        if ~clip
            c1_pad = abs(c1);
        end
        c1 = 1;
    end

    r2_pad = 0;
    if r2 > size(original,1)
        if ~clip
            r2_pad = abs(r2-size(original,1)-1);
        end
        r2 = size(original,1);
    end

    c2_pad = 0;
    if c2 > size(original,1)
        if ~clip
            c2_pad = abs(c2-size(original,1)-1);
        end
        c2 = size(original,1);
    end

    sub_matrix = original(r1:r2, c1:c2);

    if r1_pad
        sub_matrix = padarray(sub_matrix, r1_pad, NaN, 'pre')
    end
    if r2_pad
        sub_matrix = padarray(sub_matrix, r2_pad, NaN, 'post')
    end
    if c1_pad
        sub_matrix = padarray(sub_matrix, c1_pad, NaN, 'pre')
    end
    if c2_pad
        sub_matrix = padarray(sub_matrix, c2_pad, NaN, 'post')
    end

