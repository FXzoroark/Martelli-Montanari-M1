:- begin_tests(regles).
include(script).

%test(oui, [forall(member(R ,[check, clash]))]) :- regles(f(X) ?= g(X), R).
test(oui, [fail]) :- regles(f(X) ?= X, clash).
test(non) :- regles(f(X) ?= X, clash).

:- end_tests(regles).