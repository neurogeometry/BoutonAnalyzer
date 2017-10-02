function [outputpath] = isunixispc(inputpath)
%input: unix or pc format of path address string
%output: correct unix or pc path address string
inputpath(inputpath=='/' | inputpath=='\')=filesep;
outputpath=inputpath;
end

