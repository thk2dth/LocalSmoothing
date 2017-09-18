function [ nrbsPos, nrbsRot] = Yang( mcs, pe, oe, mp )
% Yang's method smooths the tool position in WCS and tool
% orientation in MCS.
% Input:
%   mcs, cutter data in MCS.
%   pe, position error in WCS.
%   oe, orientation error in WCS.
%   mp, geometric property of machine tool.
% Output:
%   nrbsPos, inserted B-spline (Bezier) curve for
%                  tool position in WCS.
%   nrbsRot, inserted B-spline (Bezier) curve for
%               rotary axes in MCS.

num = size(mcs, 2) - 2; % number of transition curves.
nrbsPos = cell(1, num);
nrbsRot = cell(1, num);
lp = zeros(1, num);
for i = 1:num
    [nrbsPos{i}, nrbsRot{i}, lp(i)] = localSmoothing(mcs(1:3, i),...
        mcs(1:3, i+1), mcs(1:3, i+2), mcs(4:5, i), mcs(4:5, i+1), mcs(4:5, i+2),...
        pe, oe, mp);
end

end

%% Local position smoothing for three cutter data.
% In Yang's method, the tool position and rotary axes cannot
% be smoothed seperately.
function [nrbPos, nrbRot, lp] = localSmoothing(T1, T2, T3, R1, R2, R3, pe, oe, mp)
% The algorithm should do FKT, since either the machine coordinate
% or the workpiece coordinate is known in pratical applications.
wc1 = FKT([T1; R1], mp);
wc2 = FKT([T2; R2], mp);
wc3 = FKT([T3; R3], mp);
p1 = wc1(1:3);
p2 = wc2(1:3);
p3 = wc3(1:3);
v1 = p1 - p2; % The reverse direction is adopted.
v2 = p3 - p2;
l1 = sqrt(v1' * v1);
l2 = sqrt(v2' * v2);
m1 = v1 / l1; % unit vector of v1.
m2 = v2 / l2;
alpha = acos( m1' * m2 );

% Eq. (5) without consideration of synchronization.
lp = min(4*pe/(3*cos(0.5*alpha) ), 0.2*min(l1, l2) );

u1 = R1 - R2;
u2 = R3 - R2;
s1 = sqrt(u1' * u1);
s2 = sqrt( u2' * u2);
n1 = u1 / s1;
n2 = u2 / s2;
beta = acos(n1' * n2);

k = s2*l1 / (s1*l2); % Eq. (20)
O = wc2(4:6); % tool orientation.
% skew-symmetric matrix of O. Eq. (28)
Ohat = [0, -O(3), O(2);...
    O(3), 0, -O(1);...
    -O(2), O(1), 0];
Jo = JRR(R2(1), R2(2) ); % Eq. (33)
T1 = Ohat * Jo;
T2 = T1' * T1;
% maximum eigen values of T2.
m_eig = max( eig(T2) );
% Eq. (28)
lop = 8*sin(oe)*l1 / (3*m_eig*s1 * sqrt(1+k*k+2*k*cos(beta)) );
% Eq. (29)
lp = min(lp, lop);
% Eq. (19)
loa = s1*lp / l1;
% Eq. (20)
lob = k * loa;
% inserted B-spline has seven control points.
ctrls = zeros(3, 7);
knots = [zeros(1, 6), 0.5, ones(1, 6)];
% inserted B-spline for tool position.
% Eq. (4)
ctrls(:, 4) = p2;
ctrls(:, 3) = p2 + m1 * lp;
ctrls(:, 5) = p2 + m2 * lp;
ctrls(:, 2) = ctrls(:, 3)*2 - p2;
ctrls(:, 1) = 0.5 * (ctrls(:, 3)*5 - p2*3);
ctrls(:, 6) = ctrls(:, 5)*2 - p2;
ctrls(:, 7) = 0.5 * (ctrls(:, 5)*5 - p2*3);
nrbPos = nrbmak(ctrls, knots);
% inserted B-spline for rotary axes.
% Eq. (30)
ctrls = zeros(2, 7); % Two dimension data
ctrls(:, 4) = R2;
ctrls(:, 3) = R2 + n1 * loa;
ctrls(:, 5) = R2 + n2 * lob;
ctrls(:, 2) = ctrls(:, 3)*2 - R2;
ctrls(:, 1) = 0.5 * (ctrls(:, 3)*5 - R2*3);
ctrls(:, 6) = ctrls(:, 5)*2 - R2;
ctrls(:, 7) = 0.5 * (ctrls(:, 5)*5 - R2*3);
nrbRot = nrbmak(ctrls, knots);
end
