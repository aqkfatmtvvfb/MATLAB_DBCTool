clc
clear

files = dir(fullfile('.', '*.dbc'));
fileNames = {files.name}';

MergeSheet1=[];
MergeSheet2=[];
MergeInitialFlag=0;
for i=1:length(fileNames)
    dbcName=fileNames{i};
    if contains(dbcName,'autogen')
        continue;
    end
    excelName=[dbcName(1:end-4) '_autogen.xlsx'];
    genDbcName=[excelName(1:end-5) '_autogen.dbc'];
    if exist(excelName,'file')
        delete(excelName);
    end
    if exist(genDbcName,'file')
        delete(genDbcName);
    end
    DBC2Excel(dbcName);
    [~,~,Sheet1]= xlsread(excelName,1);
    [~,~,Sheet2]= xlsread(excelName,2);
    if MergeInitialFlag==0
        MergeInitialFlag=1;
        MergeSheet1=Sheet1;
        MergeSheet2=Sheet2;
    else
        MergeSheet1=[MergeSheet1;Sheet1(2:end,:)];
        MergeSheet2=[MergeSheet2;Sheet2(2:end,:)];
    end
%     Excel2DBC(excelName);
end

xlswrite('Merge.xlsx',MergeSheet1,1);
xlswrite('Merge.xlsx',MergeSheet2,2);