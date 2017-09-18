function [ nrbsTrans, nrbsRot] = Bi( mcs, pe, oe, mp )
% Bi's method smooths the tool position and tool
% orientation both in MCS.
% Input:
%   mcs, cutter data in MCS.
%   pe, position error in WCS.
%   oe, orientation error in WCS.
%   mp, geometric property of machine tool.
% Output:
%   nrbsTrans, inserted B-spline (Bezier) curve for
%                   translational axes in MCS.
%   nrbsRot, inserted B-spline (Bezier) curve for
%               rotary axes in MCS.

num = size(mcs, 2) - 2; % number of transition curves.
nrbsTrans = cell(1, num);
nrbsRot = cell(1, num);
tl = zeros(1, num);
tr = zeros(1, num);

for i = 1:num
    [nrbsTrans{i}, nrbsRot{i}, tl(i), tr(i)] = localSmoothing(mcs(1:3, i),...
        mcs(1:3, i+1), mcs(1:3, i+2), mcs(4:5, i), mcs(4:5, i+1), mcs(4:5, i+2),...
        pe, oe, mp);
end


end

%% Local smoothing for three cutter data.
% In Bi's method, the translational axes and rotary axes cannot
% be smoothed seperately.
function [nrbTrans, nrbRot, tl, tr] = localSmoothing(T1, T2, T3, R1, R2, R3, pe, oe, mp)
% The algorithm should do FKT, since either the machine coordinate
% or the workpiece coordinate is known in pratical applications.
wc1 = FKT([T1; R1], mp);
wc2 = FKT([T2; R2], mp);
% wc3 = FKT([T3; R3], mp);
p1 = wc1(1:3); % tool position.
p2 = wc2(1:3);
% p3 = wc3(1:3);
n = wc2(4:6); % tool orientation.
vp1 =p2 - p1;
t = vp1 - n * (vp1'*n);
t = t / sqrt(t'*t); % normalize t.
b = cross(t, n); % b
Jrr = JRR(R2(1), R2(2) );
% Eq. (11)
T = [t'; b'] * Jrr; % Matrix of dimension 2*2.
Tn = T' * T; % Eq. (12)
e1 = max(eig(Tn) );
dOmr = sin(oe) / e1; % Eq. (13)
% Eq. (5)
Jtr = JTR([T2; R2], mp);
e2 = max(eig(Jtr' * Jtr) );
Jtt = JTT(R2(1), R2(2) );
e3 = max(eig(Jtt' * Jtt) );
dQmr = (pe - e2*dOmr) / e3;

v1 = T2 - T1;
v2 = T3 - T2;
u1 = R2 - R1;
u2 = R3 - R2;
l1 = sqrt(v1' * v1);
l2 = sqrt(v2' * v2);
s1 = sqrt(u1' * u1);
s2 = sqrt(u2' * u2);
m1 = v1 / l1;
m2 = v2 / l2;
n1 = u1 / s1;
n2 = u2 / s2;
theta = acos(m1' * m2);
alpha = acos(n1' * n2);
% Eq. (29)
dP = 4*dQmr / sin(0.5 * theta);
dO = 4*dOmr / sin(0.5 * alpha);
% Eq. (31)
tl = min(min(dO/s1, dP/l1), 0.5);
tr = min(min(dO/s2, dP/l2), 0.5);
% inserted B-splines in MCS.
% In Bi's paper, Bezier curve is inserted. We convert the 
% Bezier curve to B-spline curve for expression consistence.
knots = [0, 0, 0, 0, 1, 1, 1, 1];
ctrls = zeros(3, 4);
% Eq. (28)
ctrls(:, 2) = T2;
ctrls(:, 3) = T3;
ctrls(:, 1) = T1 *  tl + T2 * (1-tl);
ctrls(:, 4) = T2 * tr + T3 * (1 - tr);
nrbTrans = nrbmak(ctrls, knots);

ctrls = zeros(2, 3);
ctrls(:, 2) = R2;
ctrls(:, 3) = R2;
ctrls(:, 1) = R1 *  tl + R2 * (1-tl);
ctrls(:, 4) = R2 * tr + R3 * (1 - tr);
nrbRot = nrbmak(ctrls, knots); 

end