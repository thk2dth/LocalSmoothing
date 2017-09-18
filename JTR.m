function J = JTR( mc, mp )
% Eq. (35) in Bi's method.
% mc, coordinate in MCS, ie, [X; Y; Z; A; C].
% X, Y, Z in mm. A and C in radian.
% mp, machine parameter, ie, [mx; my; mz], in mm.
sa = sin(mc(4) );
ca = cos(mc(4) );
sc = sin(mc(5) );
cc = cos(mc(5) );
d = [mc(1)-mp(1); mc(2)+mp(2); mc(3)-mp(3)];
TA = [0, -sa*sc, ca*sc;...
    0, sa*cc, -ca*cc;...
    0, -ca, -sa];
TC = [-sc, ca*cc, sa*cc;...
    cc, ca*sc, sa*sc;...
    0, 0, 0];
J = [TA*d; TC*d];
end
