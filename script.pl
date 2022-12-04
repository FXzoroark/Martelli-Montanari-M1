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
regles(X?=T, rename) :- var(X), var(T), !.  

% Simplify
% renvoie vrai si T est une constante
regles(X?=T, simplify) :- var(X), atomic(T), !.

% Expand
% renvoi vrai si T est une fonction et X n'apparaît pas dans T
regles(X?=T, expand) :- var(X), compound(T), not(occur_check(X, T)), !.

% Check
% renvoie vrai si X est différent de T et X apparaît dans T
regles(X?=T, check) :- var(X), X\==T , occur_check(X, T), !.

% Orient
% renvoi vrai si T n'est pas une variable
regles(T?=X, orient) :- var(X), nonvar(T), !.

% Decompose
% renvoi vrai si X et T ont le même symbol et la même arité
regles(F?=G, decompose) :- compound(F), compound(G), functor(F, NAME, ARITY), functor(G, NAME, ARITY), !.

% Clash
% renvoi vrai si X et T n'ont pas le même symbol ou la meme arité
regles(F?=G, clash) :- compound(F), compound(G), functor(F, FNAME, FARITY), functor(G, GNAME, GARITY), (FNAME \== GNAME ; FARITY \== GARITY), !.

% Occur-check
occur_check(V, T) :- var(V), compound(T), contains_var(V, T), !.

%---------------------------------------------------------------------------------------------------
% Réduits

% Renommage d'une variable
% Renomme toute les occurence de X par la variable T dans P et met le résultat dans  Q.
reduit(rename, X?=T, P, Q) :- X=T, Q=P.

% Simplification d'une constante
% Renomme toute les occurence de X par la constante T dans P et met le résultat dans  Q.
reduit(simplify, X?=T, P,Q) :- X=T, Q=P.

% Unification d'une variable avec un terme composé
% Renomme les occurences de X par le terme composé T dans P et met le résultat dans Q.
reduit(expand, X?=T, P, Q) :- X=T, Q=P.

% Check
% Fail car occur check trouvé par regles(X?=T, check).
reduit(check, _, _, _):- echo("\n No\n"), fail.

% Echange
% Permute le terme T avec la variable X
reduit(orient, T?=X, P, Q) :- append([X?=T], P, Q).

% Décomposition de deux fonctions
% Décompose deux à deux les arguments de deux termes composés.
reduit(decompose, F?=G, P, Q) :- F =.. [_|FARGS], G =.. [_|GARGS], decomposition(FARGS, GARGS, RES), append(RES, P, Q).

% Clash
% Fail car clash trouvé par regles(F?=G, clash).
reduit(clash, _, _, _):- echo("\n No\n"), fail.

% Ajoute la relation ?= entre chaque éléments des deux listes données.
decomposition([H1|T1], [H2|T2], RES) :- decomposition(T1, T2, ACC), append([H1?=H2], ACC, RES).
decomposition([], [], []).

%---------------------------------------------------------------------------------------------------

unifie_([H|T], S) :- aff_sys(H|T), regles(H, R), aff_regle(H, R), reduit(R, H, T, Q), unifie(Q, S).
unifie_(fin) :- echo("\n Yes\n").

%---------------------------------------------------------------------------------------------------
%   QUESTION 2.
%---------------------------------------------------------------------------------------------------

% Associe un poids à une équation en fonction de la première règle applicable à cette dernière.
get_i(E, I) :- (regles(E, clash); regles(E, check)) -> I = 5, !;
               (regles(E, rename); regles(E, simplify)) -> I = 4, !;
               regles(E, orient) -> I = 3, !;
               regles(E, decompose) -> I = 2, !;
               regles(E, expand) -> I = 1, !.

% Compare deux à deux le poids associé aux équations afin d'obtenir celle de poids le plus élévé.
choix_eq([H|T], TMP, E, RES) :- get_i(E, I1), get_i(H, I2),
                                (I1>=I2 -> append([H], TMP, NEWTMP),choix_eq(T, NEWTMP, E, RES);
                                    (choix_eq(T, [E|TMP], H, RES))
                                ).
choix_eq([], TMP, E, RES) :- append([E], TMP , RES).

% Prend le dernier élément de la liste et le met au début.
last_list(P, [LAST|RESTE]) :- reverse(P, [LAST|R]), reverse(R, RESTE).

%---------------------------------------------------------------------------------------------------
% Unification avec les différentes stratégies.


unifie(P, choix_premier) :- unifie_(P, choix_premier), !.

unifie([H|T], choix_pondere) :- choix_eq(T, [], H, Q), unifie_(Q, choix_pondere), !.

unifie(P, choix_dernier) :- last_list(P, RES), unifie_(RES, choix_dernier), !.

unifie([], _) :- unifie_(fin).

%---------------------------------------------------------------------------------------------------
%   QUESTION 3.
%---------------------------------------------------------------------------------------------------

% Désactive l'affichage de la trace.
unif(P,S) :- clr_echo, unifie(P,S).

% Active l'affichage de la trace.
trace_unif(P,S) :- set_echo, unifie(P,S).

%---------------------------------------------------------------------------------------------------
% Prédicat pour l'affichage
aff_sys(P) :- echo('system: '),echo(P),echo('\n').
aff_regle(E,R) :- echo(R),echo(': '),echo(E),echo('\n').



:- initialization(main).

main :- set_echo,
        write("\n\nAlgorithme d\'unification de Martelli-Montanari\n\n"),
        write("P est un système d'équation du type [X1?=Y1, ... ,Xn?=Yn] où Xi, Yi peuvent être des termes (f(X)), des variables (X) ou des constantes (a).\n\n"),
        write("S est la stratégie d'unification souhaitée:\nchoix_premier\nchoix_pondere\nchoix_dernier\n\n"),
        write("Par défaut l'affichage des étapes est activé.\n\n")    ,
        write("Pour activer l'affichage des étapes et unifier, saisir:\ntrace_unif(P,S).\n\n"),
        write("Pour désactiver l'affichage des étapes et unifier, saisir:\nunif(P,S).\n\n"),
        write("Pour simplement unifier, saisir:\nunifie(P,S).\n\n\n").

