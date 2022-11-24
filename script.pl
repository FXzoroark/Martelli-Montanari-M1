:- op(20,xfy,?=).

% Prédicats d'affichage fournis

% set_echo: ce prédicat active l'affichage par le prédicat echo
set_echo :- assert(echo_on).

% clr_echo: ce prédicat inhibe l'affichage par le prédicat echo
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionné, echo(T) affiche le terme T
%          sinon, echo(T) réussit simplement en ne faisant rien.

toto.

echo(T) :- echo_on, !, write(T).
echo(_).

%-----------------------------------------------------------------------
% Règles

% Rename
% renvoie vrai si T est une variable
rules(X?=T, rename) :- var(X), var(T).  

% Simplify
% renvoie vrai si X est une constante
rules(X?=T, simplify) :- var(X), atomic(T).

% Expand
% renvoi vrai si T est une fonction et X n'apparaît pas dans T
rules(X?=T, expand) :- var(X), compound(T), not(occur_check(X, T)).

% Check
% renvoie vrai si X est différent de T et X apparaît dans T
rules(X?=T, check) :- var(X), X\==T , occur_check(X, T).

% Orient
% renvoi vrai si T n'est pas une variable
rules(T?=X, orient) :- var(X), nonvar(T).

% Decompose
% renvoi vrai si X et T ont le même symbol et la même arité
rules(F?=G, decompose) :- functor(F, NAME, ARITY), functor(G, NAME, ARITY).

% Clash
% renvoi vrai si X et T n'ont pas le même symbol ou la me arité
rules(F?=G, clash) :- functor(F, _, _), functor(G, _, _).

% Occur-check
occur_check(V, T) :- var(V), compound(T), contains_var(V, T).

%---------------------------------------------------------------------------------------------------
% Réduits

reduit(rename, X?=T, P, Q) :- X=T, Q=P.

reduit(simplify, X?=T, P,Q) :- X=T, Q=P.

reduit(expand, X?=T, P, Q) :- X=T, Q=P.

reduit(check, _, _, _):- fail.

reduit(orient, T?=X, P, Q) :- append(P, [X?=T], Q).

reduit(decompose, F?=G, P, Q) :-functor(F, _, _), decomposition(F, G, RES), append(P, RES, Q).

reduit(clash, _, _, _):- fail.

decomposition([H1|T1], [H2|T2], RES) :- decomposition(T1, T2, ACC), append([H1?=H2], ACC, RES).
decomposition([], [], []).

%---------------------------------------------------------------------------------------------------

unifie([H|T]) :- aff_sys(H|T), rules(H, R), aff_regle(R, H), reduit(R, H, T, Q), unifie(Q).
unifie([]).

%--------------------------------------------------------------------------------------------------
% Predicat pour l'affichage
aff_sys(P) :- echo('system: '),echo(P),echo('\n').
aff_regle(R,E) :- echo(R),echo(': '),echo(E),echo('\n').