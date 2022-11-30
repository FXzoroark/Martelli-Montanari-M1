include(script).

:- begin_tests(regles).

test(rename) :- regles(X?=T, rename).
test(rename, [fail]) :- regles(a?=b, rename).
test(rename, [fail]) :- regles(X?=a, rename).
test(rename, [fail]) :- regles(f(X)?=a, rename).

test(simplify) :- regles(X?=a, simplify).
test(simplify, [fail]) :- regles(a?=b, simplify).
test(simplify, [fail]) :- regles(X?=T, simplify).
test(simplify, [fail]) :- regles(f(X)?=a, simplify).

test(expand) :- regles(X?=f(Y), expand).
test(expand) :- regles(X?=f(a), expand).
test(expand, [fail]) :- regles(X?=f(X), expand).
test(expand, [fail]) :- regles(f(X)?=X, expand).
test(expand, [fail]) :- regles(a?=f(a), expand).

test(check) :- regles(X?=f(X), check).
test(check, [fail]) :- regles(X?=f(Y), check).
test(check, [fail]) :- regles(f(X)?=X, check).
test(check, [fail]) :- regles(X?=X, check).

test(orient) :- regles(f(X)?=X, orient).
test(orient, [fail]) :- regles(T?=X, orient).
test(orient, [fail]) :- regles(T?=f(X), orient).

test(decompose) :- regles(f(X,Y)?=f(Y,Z), decompose).
test(decompose, [fail]) :- regles(X?=f(Y,Z), decompose).
test(decompose, [fail]) :- regles(f(X,Y)?=Y, decompose).
test(decompose, [fail]) :- regles(f(X,Y)?=g(Y,Z), decompose).
test(decompose, [fail]) :- regles(f(X,Y)?=f(Y), decompose).

test(clash) :- regles(f(X,Y)?=g(Y,Z), clash).
test(clash) :- regles(f(X,Y)?=f(Y), clash).
test(clash, [fail]) :- regles(f(X,Y)?=f(Y,Z), clash).
test(clash, [fail]) :- regles(X?=f(Y,Z), clash).
test(clash, [fail]) :- regles(f(X,Y)?=Y, clash).

:- end_tests(regles).

:- begin_tests(reduit).

test(vide, [forall(member(R ,[rename, simplify, expand])), true(Q == [])]) :- reduit(R, X?=T, [], Q).

test(rename, [true(Q == [T?=a])]) :- reduit(rename, X?=T, [X?=a], Q).
test(rename, [true(Q == [Z?=a])]) :- reduit(rename, X?=T, [Z?=a], Q).
test(rename, [true(Q == [T?=a])]) :- reduit(rename, X?=T, [T?=a], Q).
test(rename, [true(Q == [Z?=T])]) :- reduit(rename, X?=T, [Z?=X], Q).

test(simplify, [true(Q == [a?=T])]) :- reduit(simplify, X?=a, [X?=T], Q).
test(simplify, [true(Q == [Y?=T])]) :- reduit(simplify, X?=a, [Y?=T], Q).
test(simplify, [true(Q == [Y?=a])]) :- reduit(simplify, X?=a, [Y?=X], Q).

test(expand, [true(Q == [f(Y)?=T])]) :- reduit(expand, X?=f(Y), [X?=T], Q).
test(expand, [true(Q == [Y?=T])]) :- reduit(expand, X?=f(Y), [Y?=T], Q).
test(expand, [true(Q == [Y?=f(Y)])]) :- reduit(expand, X?=f(Y), [Y?=X], Q).

test(orient, [true(Q == [X?=T])]) :- reduit(orient, T?=X, [], Q).
test(orient, [true(Q == [X?=T, X?=Y])]) :- reduit(orient, T?=X, [X?=Y], Q).
test(orient, [true(Q == [X?=f(Y)])]) :- reduit(orient, f(Y)?=X, [], Q).
test(orient, [true(Q == [X?=a])]) :- reduit(orient, a?=X, [], Q).

test(decompose, [true(Q == [X?=Y])]) :- reduit(decompose, f(X)?=f(Y), [], Q).
test(decompose, [true(Q == [X?=Y, X?=T])]) :- reduit(decompose, f(X)?=f(Y), [X?=T], Q).
test(decompose, [true(Q == [X?=Y, Y?=Z])]) :- reduit(decompose, f(X,Y)?=f(Y,Z), [], Q).
test(decompose, [true(Q == [X?=Y, Y?=a])]) :- reduit(decompose, f(X,Y)?=f(Y,a), [], Q).
test(decompose, [true(Q == [g(X)?=Y, Y?=a])]) :- reduit(decompose, f(g(X),Y)?=f(Y,a), [], Q).

:- end_tests(reduit).

:- begin_tests(strategy).

test(get_i, [true(I == 1)]) :- get_i(X?=f(Y), I).
test(get_i, [true(I == 2)]) :- get_i(f(X)?=f(Y), I).
test(get_i, [true(I == 3)]) :- get_i(f(T)?=X, I).
test(get_i, [true(I == 4)]) :- get_i(X?=T, I).
test(get_i, [true(I == 4)]) :- get_i(X?=a, I).
test(get_i, [true(I == 5)]) :- get_i(X?=f(X), I).
test(get_i, [true(I == 5)]) :- get_i(f(X)?=g(X), I).

test(choix_eq, [true(RES == [X?=f(X), X?=T, f(X)?=f(Z)])]) :- choix_eq([f(X)?=f(Z), X?=f(X)], [], X?=T, RES).
test(choix_eq, [true(RES == [f(X)?=g(Z), X?=f(X), X?=T])]) :- choix_eq([f(X)?=g(Z), X?=f(X)], [], X?=T, RES).
test(choix_eq, [true(RES == [X?=T])]) :- choix_eq([], [], X?=T, RES).

test(last_list, [true(RES == [X?=T])]) :- last_list([X?=T], RES).
test(last_list, [true(RES == [X?=a, X?=T])]) :- last_list([X?=T, X?=a], RES).
test(last_list, [true(RES == [f(Y) ?= Z, X?=T, X?=a])]) :- last_list([X?=T, X?=a, f(Y) ?= Z], RES).

:- end_tests(strategy).

:- begin_tests(unifie_).

test(unifie, [forall(member(STRATEGY ,[choix_premier, choix_pondere, choix_dernier]))]) :- unifie([f(X,Y)?= f(g(Z), h(a)), Z ?= f(Y)], STRATEGY).
test(unifie, [forall(member(STRATEGY ,[choix_premier, choix_pondere, choix_dernier])), fail]) :- unifie([f(X,Y)?= f(g(Z), h(a)), Z ?= f(Y), X ?= f(X)], STRATEGY).

:- end_tests(unifie_).