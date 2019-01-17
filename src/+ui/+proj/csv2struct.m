function Out = csv2struct(filename)
%CSV2STRUCT reads Excel's files stored in .xls or .csv file formats and 
% stores results as a struct with field names based on the header row.
%
% DESCRIPTION
% The Excel file is assumed to have a single header row. The output struct
% will have a field for each column and the field name will be based on the
% column name stored in the header.
%
% Unlike csvread, csv2struct is able to read files with both text and
% number fields and store data as fields of a struct. Likely works on
% Windows machines only.
% 
% See also:
%   MATLAB's csvread and xlsread functions
%   xml_read from my xml_io_tools which creates struct out of xml files
%
% Test:
% 			file_str = ['Name,City,Age\n', ...
% 			'A. Cox,San Francisco,66\n', ...
% 			'A. Ramos,London,47\n', ...
% 			'A. Satou,Tokyo,33\n', ...
% 			'C. Marshall,San Francisco,36\n'];
% 			fileID = fopen('test.csv','w');
% 			fwrite(fileID,sprintf(file_str),'char');
% 			fclose(fileID);
% 			X =  csv2struct('test.csv')
%
% Written by Jarek Tuszynski, Leidos, jaroslaw.w.tuszynski_at_leidos.com
% Code covered by BSD License
%% read xls file with a single header row
[~, ~, raw] = xlsread(filename);
nRow = size(raw,1);
nCol = size(raw,2);
header = raw(1,:);   % Store header information
raw(1,:) = [];       % Remove headed from the data
%% Split data into txt & num parts
num = [];
txt = [];
ColNumeric = true(1,nCol);
for c = 1:nCol
  col = raw(:,c);
  for r = 1:nRow-1
    if(~isnumeric(col{r}) || isnan(col{r})), 
        ColNumeric(c) = false; 
        break; 
    end
  end
  if (ColNumeric(c)), 
    num = [num cell2mat(col)]; %#ok<*AGROW>
  else
    txt = [txt col];
  end
end
clear raw
%% Create struct with fields derived from column names from header
iNum = 1;
iTxt = 1;
Out = struct();
for c=1:nCol
  if ischar(header{c})
    name = strtrim(header{c});
    name(name==' ') = '_';
    name = matlab.lang.makeValidName(name);
  end
  
  if (ColNumeric(c))
      if ~isfield(Out,(name))
          Out.(name) = num(:,iNum);
      else
        Out.(name) = [Out.(name),num(:,iNum)];
      end
    iNum = iNum+1;
  else
    Out.(name) = char(txt(:,iTxt));
    iTxt = iTxt+1;
  end
end
end