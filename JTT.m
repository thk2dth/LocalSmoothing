function J = JTT( A, C )
% Eq. (34) in Bi's method.
% A and C in radian.
sa = sin(A);
ca = cos(A);
sc = sin(C);
cc = cos(C);
J = [cc, ca*sc, sa*sc;...
    sc, -ca*cc, -sa*cc;...
    0, -sa, ca];
end

