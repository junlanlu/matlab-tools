function volume2montage(varargin)
%VOLUME2MONTAGE Convert volumetric data and displays to a montage of
%its constituent slices
%   VOLUME2MONTAGE(A,FILENAME) writes the image A to the file specified by
%   FILENAME
%   
%   VOLUME2MONTAGE(...,FILENAME) writes the image to FILENAME, inferring the
%   format to use from the filename's extension. The extension must be
%   one of the legal values for FMT. 
%
%   VOLUME2MONTAGE(A,MAP,FILENAME,FMT) writes the volumetric data A and its
%   associated colormap MAP to FILENAME in the format specified by FMT.
%   MAP must be a valid MATLAB colormap.  Note that most image file formats do not
%   support colormaps with more than 256 entries.
%
%   VOLUME2MONTAGE(...,FILENAME) writes the image to FILENAME, inferring the
%   format to use from the filename's extension. The extension must be
%   one of the legal values for FMT. 
%
%   VOLUME2MONTAGE(...,PARAM1,VAL1,PARAM2,VAL2,...) specifies parameters that
%   control various characteristics of the output file. Parameters include
%   'nslices'  = number of slices in the montage (default is 10), 
%   'mask'  = If mask is given, the montage will only include slices of A that
%   are within the mask
%   'range' = A row vector describing the index of slices to be included in
%   the montage. The default is linearly spaced
%   'scaling' = The specifies the max in min values that correspond to 0.0
%   and 1.0 in the image. Default is [0 1]
%   'cbar' = Logical value that specifies whether to display the colorbar.
%   Default is 1.
%   'nrows' = Numerical value between 1 and 2 of how many rows to display montage.
%   Default is 1.
if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

[data, map, filename, format, paramPairs] = parse_inputs(varargin{:});
validateattributes(data,{'numeric','logical'},{'nonempty','nonsparse','ndims', 3},'','DATA');

if (isempty(format))

    format = get_format_from_filename(filename);
    if (isempty(format))
        error(message('MATLAB:imagesci:imwrite:fileFormat'));
    end
    
end

% Get the format details from the registry.
fmt_s = imformats(format);
nrows = 1;
num_slices = 14;
slice_index = int16(linspace(1,size(data,3),num_slices));
mask = 0;
min_value = min(data,[],'all');
max_value = max(data,[],'all');
cbar = 1;
for k = 1:length(paramPairs)
    if(contains(string(paramPairs{k}),'nslices','IgnoreCase',true))
        num_slices = int16(paramPairs{k+1});
    end
    if(contains(string(paramPairs{k}),'mask','IgnoreCase',true)&~contains(string(paramPairs{k}),'range','IgnoreCase',true))
        mask = paramPairs{k+1};
        [u, v] = find_boundary_index3(mask);
        slice_index = int16(linspace(u+4,v-2,num_slices));
    end
    if(contains(string(paramPairs{k}),'range','IgnoreCase',true))
        slice_index = int16(paramPairs{k+1});
        num_slices = length(slice_index);
    end
    if(contains(string(paramPairs{k}),'nrows','IgnoreCase',true))
        nrows = int16(paramPairs{k+1});
    end
    if(contains(string(paramPairs{k}),'scaling','IgnoreCase',true))
        V = double(paramPairs{k+1});    
        min_value = V(1);
        max_value = V(2);
        if(~length(V)==2)
            error('Need two arguments [min max] for scaling');
        end
    end
    if(contains(string(paramPairs{k}),'cbar'))
        if(paramPairs{k+1} == 0)
            cbar = 0;
        elseif(paramPairs{k+1} == 1)
            cbar = 1;
        else
            error('Input a valid number of ''cbar'' 0 or 1');
        end
    end
end
      


filenames_arr = string(zeros(length(num_slices),1));
temp_dir = get_dir_from_filename(filename);
for k = 1:num_slices
    slice_name = string(temp_dir)+'/slice'+string(k)+'.png';
    I = mat2gray(data(:,:,slice_index(k)),[min_value max_value]); 
    filenames_arr(k,1) = slice_name;
    imwrite(I*255, map, slice_name, format);
end

set(gcf,'color','w');
montage(filenames_arr(:,1),'Size', [nrows ceil(num_slices/nrows)]);
caxis([min_value max_value]);
colormap(map);
if(cbar == 1)
    c = colorbar;
    set(c,'Fontsize',30);
    ticks = [];
    set(c,'Ticks',ticks);
end
M = getframe(gcf);
imwrite(remove_whitespace(M.cdata), filename, format);
        %***Delete individual slices***
for k = 1:num_slices
    delete(filenames_arr(k,1));
end

    

%%%
%%% Function parse_inputs
%%%
function [data, map, filename, format, paramPairs] = parse_inputs(varargin)
data = [];
map = gray(255);
filename = '';
format = '';
paramPairs = {};


if (nargin < 2)
	error(message('MATLAB:imagesci:validate:wrongNumberOfInputs'));
end

firstString = [];
for k = 1:length(varargin)
    if (ischar(varargin{k}))
        firstString = k;
        break;
    end
end

if (isempty(firstString))
	error(message('MATLAB:imagesci:imwrite:missingFilename'));
end

switch firstString
case 1
	error(message('MATLAB:imagesci:imwrite:firstArgString'));
    
case 2
    % imwrite(data, filename, ...)
    data = double(varargin{1});
    filename = varargin{2};
    
case 3
    % imwrite(data, map, filename, ...)
    data = double(varargin{1});
    map = varargin{2};
    filename = varargin{3};
    if (size(map,2) ~= 3)
		error(message('MATLAB:imagesci:imwrite:invalidColormap'));
    end
    
    validateattributes(map,{'numeric'},{'>=',0,'<=',1},'','COLORMAP');

otherwise
    error(message('MATLAB:imagesci:imwrite:badFilenameArgumentPosition'));
end

if (length(varargin) > firstString)
    % There are additional arguments after the filename.
    if (~ischar(varargin{firstString + 1}))
    	error(message('MATLAB:imagesci:imwrite:invalidArguments'));
    end
    
    % Is the argument after the filename a format specifier?
    fmt_s = imformats(varargin{firstString + 1});
    
    if (~isempty(fmt_s))
        % imwrite(..., filename, fmt, ...)
        format = varargin{firstString + 1};
        paramPairs = varargin((firstString + 2):end);
        
    else
        % imwrite(..., filename, prop1, val1, prop2, val2, ...)
        paramPairs = varargin((firstString + 1):end);
    end
    
    % Do some validity checking on param-value pairs
    if (rem(length(paramPairs), 2) ~= 0)
    	error(message('MATLAB:imagesci:imwrite:invalidSyntaxOrFormat',varargin{firstString + 1}));
    end

end

for k = 1:2:length(paramPairs)
    validateattributes(paramPairs{k},{'char', 'string'},{'nonempty', 'scalartext'},'','PARAMETER NAME');
end

%%%
%%% Function get_format_from_filename
%%%
function format = get_format_from_filename(filename)

format = '';

idx = find(filename == '.');

if (~isempty(idx))
  
    ext = filename((idx(end) + 1):end);
    fmt_s = imformats(ext);
    
    if (~isempty(fmt_s))
        format = ext;
    end
    
end

function directory = get_dir_from_filename(filename)

directory = pwd;

idx = find(filename == '/',1,'last');

if (~isempty(idx))
  directory = filename(1:idx);
    
end