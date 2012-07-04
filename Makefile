CFLAGS=-Xs abate,hawick,meyer,tarjan

all:
	ocamlbuild ${CFLAGS} -classic-display -use-ocamlfind rand_graph.native

clean:
	ocamlbuild ${CFLAGS} -clean
	rm -f *.dot
