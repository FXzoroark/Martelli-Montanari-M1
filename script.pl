
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

rules(X?=T, rename) :- var(X), var(T), !.

rules(X?=T, simplify) :- var(X), atomic(T), !; atomic(X), atomic(T), X==T, !.

rules(X?=T, expand) :- var(X), compound(T), \+appears(X, T), !.

rules(X?=T, check) :- var(X), X==T ; \+appears(X, T), !.

rules(T?=X, orient) :- var(X), nonvar(T), !.

rules(F?=G, decompose) :- compound(F), compound(G), functor(F, FNAME, FARITY), functor(G, GNAME, GARITY), FNAME==GNAME, FARITY==GARITY, !.

rules(F?=G, clash) :- compound(F), compound(G), functor(F, FNAME, FARITY), functor(G, GNAME, GARITY), FNAME == GNAME , FARITY == GARITY, !.

appears(X, T) :- var(X), X==T, !.
appears(X, T) :- var(X), compound(T), arg(_, T, Y), appears(X, Y).




