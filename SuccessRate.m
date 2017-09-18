function [ra, rm, ea, em] = SuccessRate( nrbs, oe, isWCS, cornerIndex )
% Evaluate the success rate of the transition method.
% If the orientation error is under the specified value, i.e., oe,
% the method succeedes.
% Input:
%   nrbs, inserted B-splines during orientation smoothing.
%   oe, specified orientation error.
%   isWCS, whether the nrbs is in WCS.
%   cornerIndex, the index of the corner point in the B-spline
% Output:
%   ra, success rate for all points.
%   rm, success rate for middle points.
%   ea, minimum error of all points.
%   em, error of middle point.

if nargin == 2
    isWCS =1;
    cornerIndex = 3;
end

% num points are sampled on each B-spline.
numSpline = length(nrbs);
numPts = 5001;
u = linspace(0, 1, numPts);
ea = zeros(1, numSpline);
em = ea;
numFailAll = 0;
numFailMid = 0;
coe = cos(oe);
% This value is used to avoid numeric issues when
% testing the success of the algorithm.
num_eps = 1e-12;
pool_obj = parpool(4); % quad-core CPU
parfor i = 1:numSpline
    if isWCS
        O = nrbs{i}.coefs(1:3, cornerIndex); % Corner point is the third point.
    else
         % Corner point is the fourth point.
        O = Ori(nrbs{i}.coefs(1, cornerIndex), nrbs{i}.coefs(2, cornerIndex));
    end
    ce = 0.0;
    for j = 1:numPts
        p = nrbeval(nrbs{i}, u(j) );
        if isWCS
            lp = sqrt( p' * p);
            cet = O' * p / lp;
        else
            o = Ori(p(1), p(2));
            cet = O' * o;
        end
        % Minimum angle bewteen the sampled points and
        % O.
        if (cet > ce)
            ce = cet;
        end
    end
    % Numeric issues should be considered.
    if coe - ce >= num_eps
        numFailAll = numFailAll + 1;
    end
    if (ce > 1)
        ce = 1;
    end
    if (ce < -1)
        ce = -1;
    end
    ea(i) = acos(ce); % in rad.
    
    % Smoothing error at middle point.
    m = nrbeval(nrbs{i}, 0.5 );
    if isWCS
        ml = sqrt(m' * m);
        me = O' * m / ml;
    else
        o = Ori(m(1), m(2));
        me = O' * o;
    end
    % Numeric issues should be considered.
    if coe - me >= num_eps
        numFailMid = numFailMid + 1;
    end
    em(i) = acos(me);
end
delete(pool_obj);
ra = numFailAll / numSpline;
rm = numFailMid / numSpline;
end

%% Mapping A and C to an orientation.
function O = Ori(A, C)
O = [sin(A)*sin(C); -sin(A)*cos(C); cos(A)];
end
