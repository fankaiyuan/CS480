#include <iostream>
#include <map>

extern int yylex();

extern std::map<std::string, float> symbols;
extern bool _error;
extern std::string* programs;

int main(int argc, char const *argv[]) {
  if (!yylex() && !_error) {
	  std::cout << "#include <iostream>\nint main(){\n";
	  std::map<std::string, float>::iterator it;
    for (it = symbols.begin(); it != symbols.end(); it++) {
		std::cout << "double " << it->first << ";\n";
    }
	std::cout << "\n" << "/* Begin program */" << "\n\n";
	std::cout << *programs << std::endl;
	std::cout << "\n" << "/* End program */" << "\n\n";
	for (it = symbols.begin(); it != symbols.end(); it++) {
		std::cout << "std::cout << \"" << it->first << ": \" << " << it->first << " << std::endl;\n";
	}
	std::cout << "}\n";
    return 0;
  } else {
    return 1;
  }
}
