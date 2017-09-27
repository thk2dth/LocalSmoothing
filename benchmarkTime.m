% Benchmark the three analytical local smoothing methods.
% To avoid multi-selection in IKT, the cutter data is randomly generated
% in MCS. Axial strides are considered.
% Strides for A and C axes are in rad.
mp = [0; 0; 172]; % geometric property of the machine tool.
pe = 0.4; % position error.
oe = deg2rad(0.4); % orientation error.
c = 0.25; % c = d1/d2.
strides = [0, 500; 0, 400; 0, 200; deg2rad([-20, 90; 0, 360]) ];
% numberOfData = 2000;
step = 50;
numberOfDuration = 100;
avgDuration = zeros(2, numberOfDuration);
for n = 1:numberOfDuration
    n
    numberOfData = n * step;
    cutterDataMCS = zeros(5, numberOfData);
    cutterDataWCS = zeros(6, numberOfData);
    numberOfTest = 100;
    elapsedTime = zeros(2, numberOfTest);
    for k = 1:numberOfTest
        r = rand(5, numberOfData);
        for i = 1:numberOfData
            cutterDataMCS(:, i) = strides(:, 1) .* (1-r(:, i) ) + ...
            strides(:, 2) .* r(:, i);
            cutterDataWCS(:, i) = FKT(cutterDataMCS(:, i), mp);
        end
        tic;
        [~, ~] = Proposed(cutterDataWCS, pe, oe, c);
        elapsedTime(1, k) = toc;
        tic;
        [~, ~] = Yang( cutterDataMCS, pe, oe, mp );
        elapsedTime(2, k) = toc;
    end
    avgDuration(:, n) = mean(elapsedTime, 2);
end

%% figure
xaxis = (1:100) * step;
figure('Name', 'Consumed Time');
plot(xaxis, avgDuration(1, :) * 1000, 'r-', 'LineWidth', 1.5);
hold on;
plot(xaxis, avgDuration(2, :) * 1000, 'b-.');
hold off;
legend('Proposed', 'Yang');
xlabel('\bfCutter Data Number');
ylabel('{\bfConsuming Time}{\it(ms)}');
set(gca, 'FontName', 'Times New Roman');

effInc = avgDuration(2, :) ./ avgDuration(1, :) - 1;
figure('Name', 'Ratio')
plot(xaxis, effInc * 100, 'b', 'LineWidth', 1.5);
xlabel('\bfCutter Data Number');
ylabel('{\bfComputation Efficiency Increase}{\it(%)}');
set(gca, 'FontName', 'Times New Roman');