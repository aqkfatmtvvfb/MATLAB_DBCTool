function DBC2Excel(DBC_file_path)
fid = fopen(DBC_file_path,'r');
XLSX_file_path=[DBC_file_path(1:end-4) '_autogen.xlsx'];

%% Define regexp patten

%% Define Output Excel column
Max_Signal=400;

Signal_MsgTxNode=cell(Max_Signal,1);
Signal_MsgID_dec=cell(Max_Signal,1);
Signal_MsgName=cell(Max_Signal,1);
Signal_StartByte=cell(Max_Signal,1);
Signal_StartBit=cell(Max_Signal,1);
Signal_SignalName=cell(Max_Signal,1);
Signal_SignalSize=cell(Max_Signal,1);
Signal_factor=cell(Max_Signal,1);
Signal_offset=cell(Max_Signal,1);
Signal_ByteOrder=cell(Max_Signal,1);
Signal_Signed=cell(Max_Signal,1);
Signal_min=cell(Max_Signal,1);
Signal_max=cell(Max_Signal,1);
Signal_unit = cell(Max_Signal,1);

%% Read dbc to textData
textData={};
Line=fgetl(fid);
while ischar(Line) 
    textData=cat(1,textData,strip(Line));
    Line=fgetl(fid);
end
N_Lines=length(textData);
fclose(fid);

%% Read Msg and Signal
MsgPatten=('^BO\_ (?<ID_dec>\w+) (?<MsgName>\w+) *: (?<DLC>\w+) (?<TxNode>\w+)');
SignalPatten=('^SG\_ (?<SignalName>\w+) : (?<startBit>\d+)\|(?<signalSize>\d+)@(?<is_little_endian>\d+)(?<is_signed>[\+|\-]) \((?<factor>[0-9.+\-eE]+),(?<offset>[0-9.+\-eE]+)\) \[(?<min>[0-9.+\-eE]+)\|(?<max>[0-9.+\-eE]+)\] \"(?<unit>.*)\"\s+(?<RxNodeList>.*)');
idxSignal=1;
for idxLine=1:N_Lines
    strLine=textData(idxLine);
    if startsWith(strLine,'BO_ ')
        MsgInfo = regexp(strLine{1,1}, MsgPatten, 'names');
    elseif startsWith(strLine,'SG_ ')
        SignalInfo=regexp(strLine{1,1}, SignalPatten, 'names');
        if isempty(SignalInfo)
            warning(strLine{1,1})
        end
        Signal_MsgTxNode{idxSignal,1}=MsgInfo.TxNode;
        Signal_MsgID_dec{idxSignal,1}=MsgInfo.ID_dec;
        Signal_MsgName{idxSignal,1}=MsgInfo.MsgName;
        Signal_StartByte{idxSignal,1}=floor(str2double(SignalInfo.startBit)/8);
        Signal_StartBit{idxSignal,1}=rem(str2double(SignalInfo.startBit),8);
        Signal_SignalName{idxSignal,1}=SignalInfo.SignalName;
        Signal_SignalSize{idxSignal,1}=SignalInfo.signalSize;
        Signal_factor{idxSignal,1}=SignalInfo.factor;
        Signal_offset{idxSignal,1}=SignalInfo.offset;
        Signal_ByteOrder{idxSignal,1}=SignalInfo.is_little_endian;
        Signal_Signed{idxSignal,1}=SignalInfo.is_signed;
        Signal_min{idxSignal,1}=SignalInfo.min;
        Signal_max{idxSignal,1}=SignalInfo.max;
        Signal_unit{idxSignal,1}=SignalInfo.unit;
        idxSignal=idxSignal+1;
    else
        continue;
    end
end
N_Signal=idxSignal-1;
Signal_MsgTxNode=Signal_MsgTxNode(1:N_Signal);
Signal_MsgID_dec=Signal_MsgID_dec(1:N_Signal);
Signal_MsgName=Signal_MsgName(1:N_Signal);
Signal_StartByte=Signal_StartByte(1:N_Signal);
Signal_StartBit=Signal_StartBit(1:N_Signal);
Signal_SignalName=Signal_SignalName(1:N_Signal);
Signal_SignalSize=Signal_SignalSize(1:N_Signal);
Signal_factor=Signal_factor(1:N_Signal);
Signal_offset=Signal_offset(1:N_Signal);
Signal_ByteOrder=Signal_ByteOrder(1:N_Signal);
Signal_Signed=Signal_Signed(1:N_Signal);
Signal_min=Signal_min(1:N_Signal);
Signal_max=Signal_max(1:N_Signal);
Signal_unit = Signal_unit(1:N_Signal);
%% Read Value Descption
VALPatten='^VAL\_ (?<ID_dec>\d+) (?<SignalName>\w+) (?<Table>.+);';
Max_VAL=1000;
VAL_MsgID_dec=cell(Max_VAL,1);
VAL_SignalName=cell(Max_VAL,1);
VAL_SignalValue=cell(Max_VAL,1);
VAL_SignalString=cell(Max_VAL,1);

idxVAL=1;
for idxLine=1:N_Lines
    strLine=textData(idxLine);
    if startsWith(strLine,'VAL_ ')
        VALInfo = regexp(strLine{1,1}, VALPatten, 'names');
        ValueStringStartPositionList=regexp(strip(VALInfo.Table),'\d+ \"','all');
        for index=1:length(ValueStringStartPositionList)-1
            ValueString=regexp(VALInfo.Table(ValueStringStartPositionList(index):ValueStringStartPositionList(index+1)-1),'(?<Value>\d+) \"(?<String>.+)\"','names');
            VAL_MsgID_dec{idxVAL,1}=VALInfo.ID_dec;
            VAL_SignalName{idxVAL,1}=VALInfo.SignalName;
            VAL_SignalValue{idxVAL,1}=ValueString.Value;
            VAL_SignalString{idxVAL,1}=ValueString.String;
            idxVAL=idxVAL+1;
        end
        ValueString=regexp(VALInfo.Table(ValueStringStartPositionList(length(ValueStringStartPositionList)):end),'(?<Value>\d+) \"(?<String>.+)\"','names');
        VAL_MsgID_dec{idxVAL,1}=VALInfo.ID_dec;
        VAL_SignalName{idxVAL,1}=VALInfo.SignalName;
        VAL_SignalValue{idxVAL,1}=ValueString.Value;
        VAL_SignalString{idxVAL,1}=ValueString.String;
        idxVAL=idxVAL+1;
    end
end
N_VAL=idxVAL-1;
VAL_MsgID_dec=VAL_MsgID_dec(1:N_VAL);
VAL_SignalName=VAL_SignalName(1:N_VAL);
VAL_SignalValue=VAL_SignalValue(1:N_VAL);
VAL_SignalString=VAL_SignalString(1:N_VAL);

%% xlswrite
Signal_MsgID_hex=cell(N_Signal,1);
Signal_PrimaryKey = cell(N_Signal,1);

for i=1:N_Signal
    Signal_MsgID_hex{i,1}=['0x' dec2hex(str2double(Signal_MsgID_dec{i,1}))];
    Signal_PrimaryKey{i,1}=[Signal_MsgID_hex{i,1} '_' num2str(Signal_StartByte{i,1}) '_' num2str(Signal_StartBit{i,1}) '_' num2str(Signal_SignalSize{i,1})];
end
[~,MsgIndex,~]=unique(Signal_MsgName);
c1_ID=['ID';Signal_MsgID_hex(MsgIndex)];
c1_SendNode=['SendNode';Signal_MsgTxNode(MsgIndex)];
c1_MsgName=['MsgName';Signal_MsgName(MsgIndex)];
xlswrite(XLSX_file_path,[c1_ID c1_SendNode c1_MsgName],1);

[~,sort_index] = sort(Signal_PrimaryKey);
c2_ID=['ID';Signal_MsgID_hex(sort_index)];
c2_SendNode=['SendNode';Signal_MsgTxNode(sort_index)];
c2_MsgName=['MsgName';Signal_MsgName(sort_index)];
c2_StartByte=['StartByte';Signal_StartByte(sort_index)];
c2_StartBit=['StartBit';Signal_StartBit(sort_index)];
c2_SignalLength=['SignalLength';Signal_SignalSize(sort_index)];
c2_SignalName=['SignalName';Signal_SignalName(sort_index)];
c2_factor=['factor';Signal_factor(sort_index)];
c2_offset=['offset';Signal_offset(sort_index)];
c2_ByteOrder=['ByteOrder';Signal_ByteOrder(sort_index)];
c2_Signed=['Signed';Signal_Signed(sort_index)];
c2_Min=['Min';Signal_min(sort_index)];
c2_Max=['Max';Signal_max(sort_index)];
c2_Unit = ['Unit';Signal_unit(sort_index)];
c2_PrimaryKey = ['PrimaryKey';Signal_PrimaryKey(sort_index)];

xlswrite(XLSX_file_path,[c2_ID c2_SendNode c2_MsgName c2_StartByte c2_StartBit...
    c2_SignalLength c2_SignalName c2_Unit...
    c2_factor c2_offset c2_ByteOrder c2_Signed c2_Min c2_Max c2_PrimaryKey],2);


VAL_MsgID_hex = cell(N_VAL,1);
VAL_SignalValue_hex = cell(N_VAL,1);
VAL_PrimaryKey = cell(N_VAL,1);
for i=1:N_VAL
    VAL_MsgID_hex{i,1}=['0x' dec2hex(str2double(VAL_MsgID_dec{i,1}))];
    VAL_SignalValue_hex{i,1} = str2double(VAL_SignalValue{i,1});
    VAL_PrimaryKey{i,1} = [VAL_MsgID_hex{i,1} '_' VAL_SignalName{i,1} '_' num2str(VAL_SignalValue_hex{i,1})];
end

[~,sort_index] = sort(VAL_PrimaryKey);
c1=['SignalName';VAL_SignalName(sort_index)];
c2=['ID';VAL_MsgID_hex(sort_index)];
c3=['Value';VAL_SignalValue_hex(sort_index)];
c4=['enum';VAL_SignalString(sort_index)];
c5=['PrimaryKey';VAL_PrimaryKey(sort_index)];

xlswrite(XLSX_file_path,[c2 c1 c3 c4 c5],3);
end



