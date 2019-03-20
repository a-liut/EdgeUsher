:- use_module(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Queries
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%query(sumflows(m,n,[f(m,n,1), f(m,n,1)],Sum)).
%query(findpath(m,v,15,1,Flow)).
query(place(C,P,L)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Place Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
place(C, P, L) :-
    chain(C, Services),
    placeServices(Services, P, []),
    findall(f(N, M, LReq, BReq), (flow(A,B,LReq,BReq), member(p(A,N),P), member(p(B,M), P), M\==N), Flows),
    placeFlows(Flows, P, L).


%%%%%%%%%%%%%%%%%%%%%%%%%
%% Placement of Flows
%%%%%%%%%%%%%%%%%%%%%%%%%
placeFlows([], P, []).
placeFlows([f(N,M,LReq,BReq)|Fs], P, [A1|Alloc]):-
    findpath(N,M,LReq,BReq,A1),
    placeFlows(Fs, P, Alloc).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X, Y nodi,
% Visited nodi visitati,
% Path, percorso nodi visitati,
% L, B latenza e banda del percorso
% LReq, BReq latenza e banda richiesti sul percorso,
% Flow taccuino per ricordare i flussi mappati su un certo link.

findpath(X,Y,LReq,BReq,Flow) :-
    path(X,Y,[X],Q,L,B,LReq,BReq,Flow,4), %%% arrives at depth 4 
    reverse(Q,Path),
    X \== Y.

path(X,Y,P,[Y|P],L,B,LReq,BReq,[f(X,Y,BReq)],D) :- 
    D > 0,
    link(X, Y, L, B),
    L =< LReq,
    B >= BReq.
path(X,Y,Visited,Path,L,B,LReq,BReq,[f(X,Z,BReq)|Flow],D) :-
    D > 0,
    link(X, Z, Lxz, Bxz),    
    Z \== Y,
    \+ member(Z,Visited),
    D1 is D - 1,
    path(Z,Y,[Z|Visited],Path,Lzy,Bzy,LReq,BReq,Flow,D1),
    B is min(Bxz, Bzy),
    B >= BReq,
    L is Lxz + Lzy,
    L =< LReq,
    sumflows(X,Z,Flow,Sum),     
    B - Sum >= BReq.

sumflows(X,Z,[],0).
sumflows(X,Z,[f(A,B,BReq)],BReq):-
    A == X,
    B == Z.
sumflows(X,Z,[f(A,B,BReq)],0):-
    A \== X,
    B \== Z.
sumflows(X,Z,[f(A,B,BReq)|Flow],Sum):-
    A == X,
    B == Z,
    sumflows(X,Z,Flow,Sum1),
    Sum is Sum1 + BReq.
sumflows(X,Z,[f(A,B,BReq)|Flow],Sum):-
    A \== X,
    B \== Z,
    sumflows(X,Z,Flow,Sum).
    
%%%%%%%%%%%%%%%%%%%%%%%%%
%% Placement of Services
%%%%%%%%%%%%%%%%%%%%%%%%%
placeServices([], [], _).
placeServices([S|Ss], [p(S,N)|P], Alloc) :-
    service(S, HReqs, TReqs),
    node(N, OpN, HCaps, TCaps),
    subset(TReqs, TCaps),
    HCaps >= HReqs,
    checkHardware(N, HCaps, [a(N, HReqs)|Alloc]),
    placeServices(Ss, P, [a(N, HReqs)|Alloc]).

checkHardware(N, HCaps, Alloc) :-
    findall(HAll, member(a(N,HAll), Alloc), H),
    sum_list(H, Sum),
    Sum =< HCaps.
%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

chain(chain1, [a,b,c]).
service(a, 10, [t1]).
service(b, 2, []).
service(c, 3, []).

flow(a,b,150,1).
flow(a,c,100,1).

node(edge0, OpA, 4, []).
node(edge1, OpA, 4, []).
node(edge2, OpB, 35, []).
node(edge3, OpB, 15, [t1]).
node(edge4, OpA, 11, []).
node(edge5, OpA, 33, []).
node(edge6, OpB, 2, []).
node(edge7, OpA, 45, []).
node(edge8, OpB, 16, []).
node(edge9, OpA, 50, []).
node(edge10, OpB, 26, []).
node(cloud11, OpB, 10000, []).
node(edge12, OpA, 46, []).
node(edge13, OpB, 31, []).
node(edge14, OpA, 32, []).
node(edge15, OpB, 39, []).
node(edge16, OpB, 21, []).
node(edge17, OpA, 38, []).
node(edge18, OpB, 10, []).
node(edge19, OpB, 40, []).
node(edge20, OpB, 16, []).
node(edge21, OpA, 46, []).
node(edge22, OpA, 26, []).
node(edge23, OpA, 14, []).
node(edge24, OpA, 22, []).
node(edge25, OpA, 22, []).
node(edge26, OpA, 50, []).
node(edge27, OpB, 12, []).
node(edge28, OpA, 31, []).
node(edge29, OpA, 17, []).
node(edge30, OpB, 21, []).
node(edge31, OpA, 41, []).
node(edge32, OpB, 7, []).
node(edge33, OpB, 44, []).
node(edge34, OpB, 16, []).
node(edge35, OpA, 8, []).
node(edge36, OpA, 17, []).
node(edge37, OpA, 34, []).
node(edge38, OpA, 5, []).
node(edge39, OpA, 43, []).
node(edge40, OpA, 44, []).
node(edge41, OpA, 38, []).
node(edge42, OpB, 30, []).
node(edge43, OpA, 4, []).
node(edge44, OpA, 16, []).
node(edge45, OpA, 48, []).
node(cloud46, OpA, 10000, []).
node(edge47, OpA, 12, []).
node(edge48, OpB, 32, []).
node(edge49, OpA, 17, []).
link(edge0, edge13, 39, 12).
link(edge13, edge0, 45, 37).
link(edge0, edge19, 92, 35).
link(edge19, edge0, 104, 3).
link(edge0, edge34, 114, 23).
link(edge34, edge0, 112, 17).
link(edge0, edge49, 131, 19).
link(edge49, edge0, 6, 50).
link(edge1, edge23, 4, 15).
link(edge23, edge1, 122, 43).
link(edge1, edge24, 76, 5).
link(edge24, edge1, 123, 34).
link(edge1, edge30, 107, 4).
link(edge30, edge1, 114, 8).
link(edge2, edge17, 70, 13).
link(edge17, edge2, 36, 49).
link(edge2, edge32, 144, 19).
link(edge32, edge2, 130, 31).
link(edge3, edge26, 51, 7).
link(edge26, edge3, 12, 19).
link(edge3, edge39, 63, 10).
link(edge39, edge3, 109, 4).
link(edge3, edge47, 25, 26).
link(edge47, edge3, 81, 27).
link(edge4, edge5, 65, 21).
link(edge5, edge4, 96, 29).
link(edge4, edge30, 46, 8).
link(edge30, edge4, 12, 13).
link(edge5, edge22, 126, 26).
link(edge22, edge5, 19, 38).
link(edge5, edge41, 110, 42).
link(edge41, edge5, 61, 3).
link(edge6, edge47, 90, 10).
link(edge47, edge6, 128, 46).
link(edge7, edge37, 91, 12).
link(edge37, edge7, 90, 44).
link(edge8, edge20, 49, 30).
link(edge20, edge8, 116, 34).
link(edge8, edge22, 56, 3).
link(edge22, edge8, 79, 18).
link(edge9, edge15, 128, 32).
link(edge15, edge9, 103, 28).
link(edge9, edge16, 32, 5).
link(edge16, edge9, 117, 16).
link(edge9, edge39, 22, 23).
link(edge39, edge9, 123, 24).
link(edge10, edge12, 73, 39).
link(edge12, edge10, 8, 45).
link(edge10, edge22, 51, 45).
link(edge22, edge10, 51, 34).
link(edge10, edge26, 9, 38).
link(edge26, edge10, 8, 3).
link(edge10, cloud46, 69, 8).
link(cloud46, edge10, 129, 15).
link(cloud11, edge33, 58, 28).
link(edge33, cloud11, 62, 6).
link(cloud11, edge39, 10, 25).
link(edge39, cloud11, 31, 29).
link(edge12, edge40, 52, 12).
link(edge40, edge12, 111, 48).
link(edge13, edge31, 40, 7).
link(edge31, edge13, 41, 8).
link(edge13, cloud46, 55, 9).
link(cloud46, edge13, 106, 37).
link(edge14, edge21, 6, 43).
link(edge21, edge14, 97, 46).
link(edge16, edge32, 98, 36).
link(edge32, edge16, 135, 4).
link(edge17, edge36, 25, 29).
link(edge36, edge17, 119, 30).
link(edge18, edge43, 49, 34).
link(edge43, edge18, 82, 47).
link(edge20, edge44, 68, 32).
link(edge44, edge20, 75, 40).
link(edge21, edge22, 29, 6).
link(edge22, edge21, 97, 45).
link(edge21, edge27, 32, 13).
link(edge27, edge21, 79, 9).
link(edge22, edge35, 5, 19).
link(edge35, edge22, 30, 47).
link(edge23, edge33, 128, 8).
link(edge33, edge23, 120, 32).
link(edge23, edge34, 106, 35).
link(edge34, edge23, 89, 24).
link(edge23, edge35, 131, 41).
link(edge35, edge23, 56, 41).
link(edge23, edge36, 86, 11).
link(edge36, edge23, 93, 32).
link(edge24, edge35, 91, 12).
link(edge35, edge24, 36, 16).
link(edge24, edge42, 63, 32).
link(edge42, edge24, 149, 36).
link(edge24, edge43, 36, 23).
link(edge43, edge24, 62, 10).
link(edge24, edge49, 25, 23).
link(edge49, edge24, 82, 21).
link(edge25, edge36, 74, 1).
link(edge36, edge25, 139, 26).
link(edge25, edge42, 100, 45).
link(edge42, edge25, 17, 4).
link(edge25, edge44, 135, 32).
link(edge44, edge25, 118, 48).
link(edge25, edge45, 13, 19).
link(edge45, edge25, 82, 5).
link(edge26, edge47, 72, 50).
link(edge47, edge26, 27, 2).
link(edge27, edge36, 144, 7).
link(edge36, edge27, 111, 27).
link(edge27, edge37, 142, 13).
link(edge37, edge27, 150, 13).
link(edge28, edge48, 57, 25).
link(edge48, edge28, 120, 33).
link(edge29, edge39, 13, 11).
link(edge39, edge29, 75, 18).
link(edge29, cloud46, 123, 3).
link(cloud46, edge29, 145, 40).
link(edge31, edge44, 6, 19).
link(edge44, edge31, 92, 39).
link(edge32, edge44, 28, 20).
link(edge44, edge32, 44, 46).
link(edge34, edge42, 126, 24).
link(edge42, edge34, 83, 36).
link(edge35, edge43, 108, 22).
link(edge43, edge35, 128, 17).
link(edge36, edge48, 14, 21).
link(edge48, edge36, 126, 34).
link(edge37, edge38, 80, 46).
link(edge38, edge37, 36, 39).
link(edge38, edge43, 99, 18).
link(edge43, edge38, 80, 8).
link(edge39, cloud46, 60, 16).
link(cloud46, edge39, 41, 4).
link(edge41, edge43, 75, 31).
link(edge43, edge41, 122, 35).
link(edge41, cloud46, 23, 41).
link(cloud46, edge41, 25, 9).
link(edge41, edge47, 73, 12).
link(edge47, edge41, 113, 39).

%%%%%%%%%
% Utils
%%%%%%%%%

forall(G, C) :- not((G, not(C))).

