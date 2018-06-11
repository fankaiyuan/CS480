#include <iostream>
#include <map>
#include <vector>
#include <queue>
#include <string>
#include <sstream>


extern int yylex();

extern std::map<std::string, float> symbols;
extern bool _error;

struct AST {
	int ID;
	std::string* value;
	std::vector<struct AST*> child;
};

extern struct AST* root;




namespace patch
{
	template < typename T > std::string to_string( const T& n )
	{
		std::ostringstream stm ;
		stm << n ;
		return stm.str() ;
	}
}


void print(struct AST *node, struct AST *root, int preLevel){
	int level = preLevel;
	for(int i = 0; i< node->child.size(); ++i){
		if(node->child[i]->value != 0 && node->value != 0){
			std::cout << node->ID <<" -> " << node->child[i]->ID<<";\n"<<node->child[i]->ID<<"[label=\""<< *node->child[i]->value <<"\"];\n" ;
		}	
		print(node->child[i], root, level);
	}
	
}


int main(int argc, char const *argv[]) {
	if (!yylex() && _error == false) {
		std::cout<<"digraph G {\n3[label=\"block\"]" <<";\n";
		print(root, root,2);
		std::cout<<"}" << "\n";
		return 0;
	} else {
		return 1;
	}
}
