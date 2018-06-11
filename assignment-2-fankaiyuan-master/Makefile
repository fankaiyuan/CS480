all: parser-push 

parser-push.cpp parser-push.hpp: parser-push.y
	bison -d -o parser-push.cpp parser-push.y

scanner-push.cpp: scanner-push.l
	flex -o scanner-push.cpp scanner-push.l

parser-push: main-push.cpp parser-push.cpp scanner-push.cpp
	g++ main-push.cpp parser-push.cpp scanner-push.cpp -o parser-push

clean:
	rm -f parser-push scanner-push.cpp parser-push.cpp parser-push.hpp
