function J = JRR( A, C )
% Eq. (37) in Bi's method.
% Also Eq. (33) in Yang's method.
% A and C in radian.
sa = sin(A);
ca = cos(A);
sc = sin(C);
cc = cos(C);
J =[ca*sc, sa*cc;...
    -ca*cc, -sa*sc;...
    -sa, 0];
end

