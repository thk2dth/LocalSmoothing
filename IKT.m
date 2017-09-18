function [ mc ] = IKT( wc, mp )
% inverse kinematic transformation.
% Input:
%   wc, workpiece coordinate, [x; y; z; i; j; k].
%   mp, machine property, [mx; my; mz]. in rad.
% Output:
%   mc, machine coordinate, [X; Y; Z; A; C]

% The strides of A and C axes are not considered here.
% The selection of A and C is not considered either.
C = -atan2( wc(4), wc(5) );
A = acos( wc(6) ) ;
sa = sin( A );
ca = cos( A );
sc = sin( C );
cc = cos( C );
T = [cc, sc, 0;...
    ca*sc, -ca*cc, -sa;...
    sa*sc, -sa*cc, ca];
d = wc(1:3) - mp;
trans = [mp(1); -mp(2); mp(3)] + T * d;
mc = [trans; A; C];

end

