function Excel2DBC(Excel_file_path)
% read sheet2
[~,~,XlsContent]= xlsread(Excel_file_path,1);
[~,XlsColumn]  = size(XlsContent);
for mColumn =1:XlsColumn
    switch (XlsContent{1,mColumn})
        case 'ID'
            IDColumn = mColumn;
        case 'SendNode'
            SendNodeColumn = mColumn;
        case 'MsgName'
            MsgNameColumn = mColumn;
        case 'StartByte'
            StartByteColumn = mColumn;
        case 'StartBit'
            StartBitColumn = mColumn;
        case 'SignalLength'
            SignalLengthColumn = mColumn;
        case 'SignalName'
            SignalNameColumn = mColumn;
        case 'Unit'
            UnitColumn = mColumn;
        case 'factor'
            factorColumn = mColumn;
        case 'offset'
            offsetColumn = mColumn;
        case 'ByteOrder'
            ByteOrderColumn = mColumn;
        case 'Signed'
            SignedColumn = mColumn;
        case 'Min'
            MinColumn = mColumn;
        case 'Max'
            MaxColumn = mColumn;
        otherwise
            continue
    end
end
ID = XlsContent(2:end,IDColumn);
SendNode = XlsContent(2:end,SendNodeColumn);
MsgName= XlsContent(2:end,MsgNameColumn);
StartByte = XlsContent(2:end,StartByteColumn);
StartBit = XlsContent(2:end,StartBitColumn);
SignalLength= XlsContent(2:end,SignalLengthColumn);
SignalName = XlsContent(2:end,SignalNameColumn);
Unit= XlsContent(2:end,UnitColumn);
factor= XlsContent(2:end,factorColumn);
offset= XlsContent(2:end,offsetColumn);
ByteOrder= XlsContent(2:end,ByteOrderColumn);
Signed= XlsContent(2:end,SignedColumn);
MinValue= XlsContent(2:end,MinColumn);
MaxValue= XlsContent(2:end,MaxColumn);
N_Signal=size (SignalName,1);

[~,~,XlsContent]= xlsread(Excel_file_path,2);
[~,XlsColumn]  = size(XlsContent);
for mColumn =1:XlsColumn
    switch (XlsContent{1,mColumn})
        case 'ID'
            VAL_IDColumn = mColumn;
        case 'SignalName'
            VAL_SignalNameColumn = mColumn;
        case 'Value'
            VAL_ValueColumn = mColumn;
        case 'enum'
            VAL_enumColumn = mColumn;
        otherwise
            continue
    end
end
VAL_ID = XlsContent(2:end,VAL_IDColumn);
VAL_SignalName = XlsContent(2:end,VAL_SignalNameColumn);
VAL_Value= XlsContent(2:end,VAL_ValueColumn);
VAL_enum = XlsContent(2:end,VAL_enumColumn);

%%
DBC_file_path=[Excel_file_path(1:end-5) '_autogen.dbc'];
fid = fopen(DBC_file_path,'w');
fprintf(fid,'VERSION ""\n');
fprintf(fid,'\n\n');
fprintf(fid,'NS_ : \n');
fprintf(fid,'\tNS_DESC_\n');
fprintf(fid,'\tCM_\n');
fprintf(fid,'\tBA_DEF_\n');
fprintf(fid,'\tBA_\n');
fprintf(fid,'\tVAL_\n');
fprintf(fid,'\tCAT_DEF_\n');
fprintf(fid,'\tCAT_\n');
fprintf(fid,'\tFILTER\n');
fprintf(fid,'\tBA_DEF_DEF_\n');
fprintf(fid,'\tEV_DATA_\n');
fprintf(fid,'\tENVVAR_DATA_\n');
fprintf(fid,'\tSGTYPE_\n');
fprintf(fid,'\tSGTYPE_VAL_\n');
fprintf(fid,'\tBA_DEF_SGTYPE_\n');
fprintf(fid,'\tBA_SGTYPE_\n');
fprintf(fid,'\tSIG_TYPE_REF_\n');
fprintf(fid,'\tVAL_TABLE_\n');
fprintf(fid,'\tSIG_GROUP_\n');
fprintf(fid,'\tSIG_VALTYPE_\n');
fprintf(fid,'\tSIGTYPE_VALTYPE_\n');
fprintf(fid,'\tBO_TX_BU_\n');
fprintf(fid,'\tBA_DEF_REL_\n');
fprintf(fid,'\tBA_REL_\n');
fprintf(fid,'\tBA_DEF_DEF_REL_\n');
fprintf(fid,'\tBU_SG_REL_\n');
fprintf(fid,'\tBU_EV_REL_\n');
fprintf(fid,'\tBU_BO_REL_\n');
fprintf(fid,'\tSG_MUL_VAL_\n');
fprintf(fid,'\n');
fprintf(fid,'BS_:\n');
fprintf(fid,'\n');
fprintf(fid,'BU_:');
nodeSet=unique(SendNode);
for iNode=1:length(nodeSet)
    fprintf(fid,' %s',nodeSet{iNode});
end
fprintf(fid,'\n\n\n');

% output BO and SG, already sort in Excel by ID, StartByte StartBit
CurrentMsgID='0';
for iSignal=1:length(ID)
    if ~strcmp(ID{iSignal},CurrentMsgID)
        % BO_ 518 EMS_6: 8 Gateway
        fprintf(fid,'\nBO_ %d %s: 8 %s\n',hex2dec(ID{iSignal}),MsgName{iSignal},SendNode{iSignal});
        CurrentMsgID=ID{iSignal};
    end
    % SG_ WorkingMode_EMS : 26|3@1+ (1,0) [0|7] ""  DMS
    if isnan(Unit{iSignal})
        UnitStr=[];
    else
        UnitStr=Unit{iSignal};
    end
    fprintf(fid,' SG_ %s : %d|%d@%d%s (%g,%g) [%g|%g] "%s" Vector__XXX\n',...
        SignalName{iSignal},8*StartByte{iSignal}+StartBit{iSignal},SignalLength{iSignal},...
        ByteOrder{iSignal},Signed{iSignal},factor{iSignal},offset{iSignal},MinValue{iSignal},MaxValue{iSignal},UnitStr);
end
% output VAL
% VAL_ 306 ErrorSt_ESC 1 "Error" 0 "No Error" ;
if length(VAL_ID)>=2
    fprintf(fid,'VAL_ %d %s ',hex2dec(VAL_ID{1}),VAL_SignalName{1});
    CurrentVAL_ID=VAL_ID{1};
    CurrentVAL_SignalName=VAL_SignalName{1};
    fprintf(fid,'%d "%s" ',VAL_Value{1},VAL_enum{1});

    for iVAL=2:length(VAL_ID)
        if (~strcmp(VAL_ID{iVAL},CurrentVAL_ID))||(~strcmp(VAL_SignalName{iVAL},CurrentVAL_SignalName))
            fprintf(fid,';\nVAL_ %d %s ',hex2dec(VAL_ID{iVAL}),VAL_SignalName{iVAL});
            CurrentVAL_ID=VAL_ID{iVAL};
            CurrentVAL_SignalName=VAL_SignalName{iVAL};
        end
        fprintf(fid,'%d "%s" ',VAL_Value{iVAL},VAL_enum{iVAL});
    end
    fprintf(fid,';\n');
end

fclose(fid);

