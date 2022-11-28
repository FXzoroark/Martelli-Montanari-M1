:- op(20,xfy,?=).

% Prédicats d'affichage fournis

% set_echo: ce prédicat active l'affichage par le prédicat echo
set_echo :- assert(echo_on).

% clr_echo: ce prédicat inhibe l'affichage par le prédicat echo
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionné, echo(T) affiche le terme T
%          sinon, echo(T) réussit simplement en ne faisant rien.

echo(T) :- echo_on, !, write(T).
echo(_).

%-----------------------------------------------------------------------
%   QUESTION 1.
%-----------------------------------------------------------------------

% Règles

% Rename
% renvoie vrai si T est une variable
regles(X?=T, rename) :- var(X), var(T),!.  

% Simplify
% renvoie vrai si X est une constante
regles(X?=T, simplify) :- var(X), atomic(T),!.

% Expand
% renvoi vrai si T est une fonction et X n'apparaît pas dans T
regles(X?=T, expand) :- var(X), compound(T), not(occur_check(X, T)),!.

% Check
% renvoie vrai si X est différent de T et X apparaît dans T
regles(X?=T, check) :- var(X), X\==T , occur_check(X, T),!.

% Orient
% renvoi vrai si T n'est pas une variable
regles(T?=X, orient) :- var(X), nonvar(T),!.

% Decompose
% renvoi vrai si X et T ont le même symbol et la même arité
regles(F?=G, decompose) :- compound(F), compound(G), functor(F, NAME, ARITY), functor(G, NAME, ARITY),!.

% Clash
% renvoi vrai si X et T n'ont pas le même symbol ou la meme arité
regles(F?=G, clash) :- compound(F), compound(G), functor(F, FNAME, FARITY), functor(G, GNAME, GARITY), (FNAME \== GNAME ; FARITY \== GARITY),!.

% Occur-check
occur_check(V, T) :- var(V), compound(T), contains_var(V, T),!.

%---------------------------------------------------------------------------------------------------
% Réduits

reduit(rename, X?=T, P, Q) :- X=T, Q=P.

reduit(simplify, X?=T, P,Q) :- X=T, Q=P.

reduit(expand, X?=T, P, Q) :- X=T, Q=P.

reduit(check, _, _, _):- echo("\n No\n"), fail.

reduit(orient, T?=X, P, Q) :- append(P, [X?=T], Q).

reduit(decompose, F?=G, P, Q) :- F =.. [_|FARGS], G =.. [_|GARGS], decomposition(FARGS, GARGS, RES), append(RES, P, Q).

reduit(clash, _, _, _):- echo("\n No\n"), fail.

decomposition([H1|T1], [H2|T2], RES) :- decomposition(T1, T2, ACC), append([H1?=H2], ACC, RES).
decomposition([], [], []).

%---------------------------------------------------------------------------------------------------

unifie_([H|T], STRATEGY) :- aff_sys(H|T), regles(H, R), aff_regle(R, H), reduit(R, H, T, Q), unifie(Q, STRATEGY).
unifie_([], _) :- echo("\n Yes\n").

%---------------------------------------------------------------------------------------------------
%   QUESTION 2.
%---------------------------------------------------------------------------------------------------


get_i(E, I) :- (regles(E, clash); regles(E, check)) -> I = 5, !;
               (regles(E, rename); regles(E, simplify)) -> I = 4, !;
               regles(E, orient) -> I = 3, !;
               regles(E, decompose) -> I = 2, !;
               regles(E, expand) -> I = 1, !.

choix_eq([H|T], TMP, E, RES) :- get_i(E, I1), get_i(H, I2),
                                (I1>=I2 -> append([H], TMP, NEWTMP),choix_eq(T, NEWTMP, E, RES);
                                    (choix_eq(T, [E|TMP], H, RES))
                                ).
choix_eq([], TMP, E, RES) :- append([E], TMP , RES). %,!.


last_list(P, [LAST|RESTE]) :- reverse(P, [LAST|R]), reverse(R, RESTE).

%---------------------------------------------------------------------------------------------------

unifie(P, choix_premier) :- unifie_(P, choix_premier).

unifie([H|T], choix_pondere_1) :- choix_eq(T, [], H, Q), unifie_(Q, choix_pondere_1).

unifie(P, choix_dernier) :- last_list(P, RES), unifie_(RES, choix_dernier).

%---------------------------------------------------------------------------------------------------
%   QUESTION 3.
%---------------------------------------------------------------------------------------------------

unif(P,S) :- clr_echo, unifie(P,S).

trace_unif(P,S) :- set_echo, unifie(P,S).

%---------------------------------------------------------------------------------------------------
% Predicat pour l'affichage
aff_sys(P) :- echo('system: '),echo(P),echo('\n').
aff_regle(R,E) :- echo(R),echo(': '),echo(E),echo('\n').