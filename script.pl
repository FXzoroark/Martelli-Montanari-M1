
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

rules(X?=T, rename) :- var(X), var(T).

rules(X?=T, simplify) :- var(X), atomic(T).

rules(X?=T, expand) :- var(X), compound(T), not(appears(X, T)).

rules(X?=T, check) :- var(X), X\==T , appears(X, T).

rules(T?=X, orient) :- var(X), nonvar(T).

rules(F?=G, decompose) :- functor(F, NAME, ARITY), functor(G, NAME, ARITY).

rules(F?=G, clash) :- functor(F, _, _), functor(G, _, _).


appears(X, T) :- var(X), compound(T), contains_var(X, T).





