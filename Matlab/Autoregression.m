% ���������.
curMetric = 'mem_9253';
rowsCount = 1950000;
targetFilename = 'cloud_week.csv';
targetFiledata = readtable(targetFilename);
% ������� ������ �������.gpuDeviceCount
targetFiledata = removevars(targetFiledata, 'Var1');
targetFiledata = removevars(targetFiledata, 'Var2');
targetFiledata = removevars(targetFiledata, 'Var3');
targetFiledata = removevars(targetFiledata, 'Var5');

targetFiledataTemp = targetFiledata;
cond=ismember(targetFiledataTemp.Var4, curMetric);
targetFiledataTemp(~cond,:)=[];
T = targetFiledataTemp(:, 2);
T = table2cell(T);
T = T(1:8740);
T=T';
BaseData = targetFiledataTemp(:, 2);
BaseData = table2cell(BaseData);
BaseData = BaseData';

% �������� ���������.
feedbackDelays = 1:165;  % ������ �������� ��������.
hiddenLayerSize = 2:2;   % ���������� ������� ��������.
net =  narnet(feedbackDelays,hiddenLayerSize);
net.divideFcn = 'divideblock';
net.divideParam.trainRatio = 70/100;%����������
net.divideParam.valRatio = 15/100;  %��������      
net.divideParam.testRatio = 15/100; %������������
net.trainFcn = 'trainscg'; %��� GPU. trainlm - default.
[Xs,Xi,~,Ts] = preparets(net,{},{},T);
net = train(net,Xs,Ts,'useGPU','yes');
%view(net)

[Y,Xf,Af] = net(Xs,Xi);
performance = perform(net,Ts,Y);

[netc,Xic,Aic] = closeloop(net,Xf,Af);
%view(netc)

y2 = netc(cell(0,400),Xic,Aic);
result = cell2mat(y2);
ttttt = [cell2mat(T), result];
xs = [1:1:length(ttttt)];
figure
plot(xs,ttttt,xs,cell2mat(BaseData))

% ������� ��������������.
figure
autocorr(cell2mat(T),'NumLags', 400);
%[normalizedACF, lags] = autocorr(cell2mat(T),'NumLags', 100);
%unnormalizedACF = normalizedACF*var(y,1);

% ���������� ������� ��� �������������.!!!
% ������� �� ��� � ����, ��������� ���������� � ������� �� ���.
% ������.
% �� ������ ������� �����������?
% �������� ����. +