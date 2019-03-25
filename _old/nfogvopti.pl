:- use_module(library(lists)).
%:- use_module('helpers.py').



placement2([], [], [], []).
placement2([C|Cs], [p(C,N)|Ps], [a(N, HReqs)|As], B) :-
    node(N, Op, HCaps, TCaps),
    service(C, HReqs, TReqs),
    forall(member(T, TReqs), member(T, TCaps)), 
    placement2(Cs, Ps, As, B),
    latencySupport(C, N, Ps),
    enoughHardware(N, HReqs, HCaps, As).


enoughHardware(N, HReqs, HCaps, A) :-
    findall(HAlloc, member(a(N, HAlloc), A), L),
    sum_list(L, R),
    HCaps - R >= HReqs.


latencySupport(C, N, P) :-
    findall( l( p(C1, M), link2(N, M, L, B, Path)), (flow(C, C1, LReq, BReq), member(p(C1,M), P), link2(N, M, L, B, Path)) , L),
    writenl(L).
    %forall( member( l(p(C1,M), LReq ), L ), ), 

%query(placement2([s1, s2, s3], P, A, B)).


path(X, Y, P, Lat, Bw) :-
    link2(X, Y, Lat, Bw, [X], Q),
    reverse(Q,P).

link(X, X, 0, 10000). 

link2(X, Y, Lat, Bw, Visited, [Y | Visited]) :-
    link(X, Y, Lat, Bw).
link2(X, Y, Lat, Bw, Visited, Path) :-
    link(X, Z, LatXZ, BwXZ),
    X \== Y,
    Z \== X,
    Z \== Y,
    \+ member(Z, Visited),
    link2(Z, Y, LatZY, BwZY, [Z|Visited], Path),
    Lat is LatXZ + LatZY,
    Bw is min(BwXZ, BwZY).



query(path(edge0, A, X, U, P)).

%%%% calls


chain(c1, [s1, s2]).

service(s1, 3, [thing1]).
service(s2, 3, [thing2]).
service(s3, 3, []).
flow(s1, s2, 300, 4).
flow(s2, s3, 100, 2).



%%%%%%%%%
% Utils
%%%%%%%%%

forall(G, C) :- not((G, not(C))).

del(X, [X|L], L).
del(X, [Y|L], [Y|L1]) :-
    del(X, L, L1).
