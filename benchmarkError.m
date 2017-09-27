% Benchmark the three analytical local smoothing methods.
% To avoid multi-selection in IKT, the cutter data is randomly generated
% in MCS. Axial strides are considered.
% Strides for A and C axes are in rad.
mp = [0; 0; 172]; % geometric property of the machine tool.
pe = 0.4; % position error.
oe = deg2rad(0.4); % orientation error.
c = 0.25; % c = d1/d2.
strides = [0, 500; 0, 400; 0, 200; deg2rad([-20, 90; 0, 360]) ];
numberOfData = 2000;
cutterDataMCS = zeros(5, numberOfData);
cutterDataWCS = zeros(6, numberOfData);
numberOfTest = 1;
elapsedTime = zeros(2, numberOfTest);
for k = 1:numberOfTest
    r = rand(5, numberOfData);
    for i = 1:numberOfData
        cutterDataMCS(:, i) = strides(:, 1) .* (1-r(:, i) ) + ...
            strides(:, 2) .* r(:, i);
        cutterDataWCS(:, i) = FKT(cutterDataMCS(:, i), mp);
    end
    tic;
    [~, nrbsOriPro] = Proposed(cutterDataWCS, pe, oe, c);
    elapsedTime(1, k) = toc;
    tic;
    [~, nrbsOriYang] = Yang( cutterDataMCS, pe, oe, mp );
    elapsedTime(2, k) = toc;
end

avgDuration = mean(elapsedTime, 2);


%% Evaluate the performance.
[raPro, rmPro, eaPro, emPro] = SuccessRate(nrbsOriPro, oe, 1, 3);
[raYang, rmYang, eaYang, emYang] = SuccessRate(nrbsOriYang, oe, 0, 4);
eaPro  = rad2deg(eaPro);
emPro  = rad2deg(emPro);
eaYang  = rad2deg(eaYang);
emYang = rad2deg(emYang);
emMeanPro = mean(emPro);
emMeanYang = mean(emYang);
ratioPro = eaPro ./ emPro;
eamMeanPro = mean(ratioPro);
ratioYang = eaYang ./ emYang;
eamMeanYang = mean(ratioYang);
xaxis = 1:1:(numberOfData-2);
%% Draw figures
figure('Name', 'Proposed: corner error');
plot(xaxis, emPro, 'r+');
hold on;
plot( [1, numberOfData-2], rad2deg([oe, oe]), 'k-.', 'LineWidth', 1.5);
hold off;
ylim([0, rad2deg(oe)+0.005]);
xlabel('{\bfCorner Instance}');
ylabel('{\bf\epsilon_{O,E}}{\it(deg)}');
set(gca, 'FontName', 'Times New Roman');

figure('Name', 'Yang: corner error');
plot(xaxis, emYang, 'bo');
hold on;
plot( [1, numberOfData-2], rad2deg([oe, oe]), 'k-.', 'LineWidth', 1.5);
hold off;
xlabel('{\bfCorner Instance}');
ylabel('{\bf\epsilon_{O,E}}{\it(deg)}');
set(gca, 'FontName', 'Times New Roman');

figure('Name', 'Proposed: error ratio');
plot(xaxis, ratioPro, 'r*');
xlabel('{\bfCorner Instance}');
ylabel('{\bfError Ratio}');
set(gca, 'FontName', 'Times New Roman');

figure('Name', 'Yang: error ratio');
plot(xaxis, ratioYang, 'bd');
hold on;
xlabel('{\bfCorner Instance}');
ylabel('{\bfError Ratio}');
set(gca, 'FontName', 'Times New Roman');