function [ nrbsPos, nrbsOri] = Proposed( wcs, pe, oe, c )
% Proposed method smooths the tool position and tool
% orientation both in WCS.
% Input:
%   wcs, cutter data in WCS.
%   pe, position error, in mm.
%   oe, orientation error, in rad.
%   c, d1/d2. c=0.25, by default.
% Output:
%   nrbsPos, inserted B-splines during position transition.
%   nrbsOri, inserted B-splines during orientation transition.
%               Note that this spline is not on the unit sphere.
num = size(wcs, 2) - 2; % number of transition curves.
nrbsPos = cell(1, num);
nrbsOri = cell(1, num);
d2p = zeros(1, num);
d2o = zeros(1, num);


for i = 1:num
    [nrbsPos{i}, d2p(i)] = localPositionSmoothing(wcs(1:3, i),...
        wcs(1:3, i+1), wcs(1:3, i+2), pe, c);
    [nrbsOri{i}, d2o(i)] = localOrientationSmoothing(wcs(4:6, i),...
        wcs(4:6, i+1), wcs(4:6, i+2), oe, c);
end
% Parameter synchronization.
% The inserted two intermediate points are calculated only
% for computation comparison.
for i = 1:num+1
    if (i > 1)
        d21p = d2p(i-1);
        d21o = d2p(i-1);
        V0p = nrbsPos{i-1}.coefs(1:3, 5);
        V0o = nrbsOri{i-1}.coefs(1:3, 5);
    else
        d21p = 0; % transition length of the first B-spline.
        d21o = 0;
        V0p = wcs(1:3, i);
        V0o = wcs(4:6, i);
    end
    if (i < num+1)
        d22p = d2p(i);
        d22o = d2o(i);
        V3p = nrbsPos{i}.coefs(1:3, 1);
        V3o = nrbsOri{i}.coefs(1:3, 1);
    else
        d22p = 0; % transitiong length of the last B-spline.
        d22o = 0;
        V3p = wcs(1:3, i);
        V3o = wcs(4:6, i);
    end
    vp = V3p - V0p;
    lp = sqrt( vp' * vp);
    vo = V3o - V0o;
    lo = sqrt(vo' * vo);
    tp = 2*c*d21p / (lp-(1+c)*(d21p+d22p) );
    V1p = V0p + vp * tp;
    V2p = V3p - vp * tp;
    to = 2*c*d21o / (lo-(1+c)*(d21o+d22o) );
    V1o = V0o + vo * to;
    V2o = V3o - vo * to;
end

end


%% Local position smoothing for three points.
function [nrb, d2] = localPositionSmoothing(p1, p2, p3, pe, c)
v1 = p2 - p1;
v2 = p3 - p2;
l1 = sqrt(v1' * v1);
l2 = sqrt(v2' * v2);
m1 = v1 / l1;
m2 = v2 / l2;
beta = 0.5 * acos( m1' * m2 );
% Eq. (9)
n1 = 2 * pe / (sin(beta) );
n2 = min(l1, l2) / (3*(1+c) ); % lm = min(l1, l2)/3.
d2 = min(n1, n2);
% inserted B-spline has five control points.
ctrls = zeros(3, 5);
knots = [0, 0, 0, 0, 0.5, 1, 1, 1, 1];
ctrls(:, 1) = p2 - m1 * (d2*(1+c) );
ctrls(:, 2) = p2 - m1 * d2;
ctrls(:, 3) = p2;
ctrls(:, 4) = p2 + m2 * d2;
ctrls(:, 5) = p2 + m2 * (d2*(1+c) );
nrb = nrbmak(ctrls, knots);
end


%% Local orientation smoothing for three points.
function [nrb, d2] = localOrientationSmoothing(o1, o2, o3, oe, c)
v1 = o2 - o1;
v2 = o3 - o2;
s1 = sqrt(v1' * v1);
s2 = sqrt(v2' * v2);
m1 = v1 / s1; % unit vector of v1.
m2 = v2 / s2; % unit vector of v2.
dv = m2 - m1;
k1 = 0.25 * dv' * o2;
k2 = dv' * dv / 16.0;
te = cos(oe)^2; % temp variable.
a = k1 * k1 - k2*te;

r0 = min(s1, s2) / (3*(1+c) ); % Eq. (16)
% Algorithm to determine d2.
if (a==0) && (k1<0)
    d2 = min(-0.5/k1, r0);
elseif (a<0)
    % Eq. (15)
    discri = (1-te) * (k2-k1*k1)*te; % 1/4 of the discriminant.
    r1 = ( (te-1)*k1 - sqrt(discri) ) / a; % Eq. (16)
    d2 = min(r1, r0);
else
    d2 = r0;
end
% inserted B-spline has five control points.
ctrls = zeros(3, 5);
knots = [0, 0, 0, 0, 0.5, 1, 1, 1, 1];
ctrls(:, 1) = o2 - m1 * (d2*(1+c) );
ctrls(:, 2) = o2 - m1 * d2;
ctrls(:, 3) = o2;
ctrls(:, 4) = o2 + m2 * d2;
ctrls(:, 5) = o2 + m2 * (d2*(1+c) );
nrb = nrbmak(ctrls, knots);
end
