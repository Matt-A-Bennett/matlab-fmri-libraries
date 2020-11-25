function embedded = embed(background, foreground, postition, varargin)
    %% documentation:
    % Takes two matrices <background> and <foreground> and embeds <foreground>
    % into <background> (overwriting <background> values). The <foreground>
    % matrix is centered on the coords in <position>. If part of the
    % <foreground> matrix exceeds the size of the <background> matrix, then the
    % <foreground> matrix is clipped by default (the part that exceeds is
    % thrown away). Setting <clip> to zero will instead pad <background> with
    % nans to allow the whole of <foreground> to be embedded.
    %
    % mandory arguments:
    % background : the matrix into which <foreground> will be embedded
    %
    % foreground : the matrix which will be embedded into <background>
    %
    % position : a vector specifying the row and column of <background> where
    % the center of the <foreground> matrix will be placed. In the case that
    % <foreground> has an even number of rows/columns (so there is no true
    % centre coord) the row and/or column of <foreground> the center coord will
    % be taken to be one row above and/or one column left of the theortical
    % center.
    %
    % Example:
    % for the <foreground> described by the numbers below, the 'center'
    % would be 'cell 2', as it's in the true center columnwise, but the
    % theoretical center rowwise would be 1.5, so we go one row up into row 1.
    % So r=1, c=2, gives cell 2.
    %
    % **********
    % **********
    % **123*****
    % **456*****
    % **********
    % **********
    %
    % optional arguments (passed as structure - see usage example below):
    % clip = 1 : (default = 1) if clip=1, any part of the <foreground> matrix
    % exceeding the size of the <background> matrix is deleted from
    % <foreground>. If clip=0, then the <background> matrix is padded with NaNs
    % to accommodate the <foreground> matrix.
    %
    % function usage example:
    % clear embed_params
    % embed_params.clip = 1;
    % embedded = embed(background, foreground, position, embed_params);

    %% set default values for optional variables
    % clip = 1;

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
    fg_size = size(foreground)

    % compute embedded coordinates
    r1 = postition(1)-ceil(fg_size(1)/2)+1;
    r2 = postition(1)+floor(fg_size(1)/2);
    c1 = postition(2)-ceil(fg_size(2)/2)+1;
    c2 = postition(2)+floor(fg_size(2)/2);

    % adjust matrix sizes
    if r1 < 1
        difference = abs(r1)+1;
        if clip
            foreground(1:difference,:)=[];
        else
            background = [nan(difference, size(background,1)); background];
            r2 = r2 + difference;
        end
        r1 = 1;
    end

    if r2 > size(background,1)
        difference = abs(size(background,1) - r2);
        if clip
            foreground(end-difference+1:end,:)=[];
            r2 = r2 - difference;
        else
            background = [background; nan(difference, size(background,1))];
        end
    end

    if c1 < 1
        difference = abs(c1)+1;
        if clip
            foreground(:,1:difference)=[];
        else
            background = [nan(size(background,1),difference), background];
            c2 = c2 + difference;
        end
        c1 = 1;
    end

    if c2 > size(background,2)
        difference = abs(size(background,2) - c2);
        if clip
            foreground(:,end-difference+1:end)=[];
            c2 = c2 - difference;
        else
            background = [background, nan(size(background,1), difference)];
        end
    end

    background(r1:r2, c1:c2) = foreground;
