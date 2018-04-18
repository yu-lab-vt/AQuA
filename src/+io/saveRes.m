function saveRes( expFile,m,opts )
%SAVERES save experiment results

if exist('opts','var')
    save(expFile,'m','opts','expFile');
else
    save(expFile,'m','expFile');
end

end

