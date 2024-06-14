fp = '/Users/jim/Library/CloudStorage/Box-Box/__non_shared/sensitive/LURN/fitbit_results/OneDrive_1_2-28-2024/m_a_calories.sas7bdat';

fp = sas.utils.getExampleFilePath('fts0003.sas7bdat');

fp = sas.utils.getExampleFilePath('numeric_1000000_2.sas7bdat');

parser = 'parso';
parser = 'pandas';
parser = 'matlab';

%feature('DefaultCharacterSet')
%https://stackoverflow.com/questions/14942097/accessing-matlabs-unicode-strings-from-c




profile on
n = 1;
tic
for i = 1:n
[s,f] = sas.readFile(fp,'parser',parser);
%toc
end
toc/n
profile off
profile viewer

tic; [s,f] = sas.readFile(fp,'parser',parser); toc;