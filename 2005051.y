%{
#include<iostream>
#include<fstream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include <list>
#include <vector>
#include<bits/stdc++.h>
#include "2005051_SymbolTable.cpp"
#define YYSTYPE SymbolInfo*
#define scopeTableSize 11

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
ofstream logFile;
ofstream parseTreeFile;
SymboleTable table(scopeTableSize);

vector <SymbolInfo*> idList;
vector <SymbolInfo*> parameterList;
vector <SymbolInfo*> argumentList;
string idType="";
bool functionFound;

bool arrayUsedAsVariable=false;
string arrayVariableName="";

extern int errorCount;
extern int line_count;
ofstream errorFile;

string functionReturnType="";

void yyerror(char *s)
{
	cout<<s<<" at line "<<line_count-1<<endl;
}

void printLog(string log){
	logFile<<log<<" "<<endl;
}

string idTypeCHecker(SymbolInfo *symbol){
	string type = "";
	if(symbol->type == "INT" && symbol->name !="int" ){
		type = "ID";
	}
	else if(symbol->type == "FLOAT" && symbol->name !="float" ){
		type = "ID";
	}
	else if(symbol->type == "VOID" && symbol->name !="void" ){
		type = "ID";
	}
	else if(symbol->type == "FUNCTION"){
		type = "ID";
	}
	else{
		type = symbol->type;
	}

	return type;
}

void printAllScopeTable()
    {
       	ScopeTable *ptr = table.getCurrentScopeTable();
        while (ptr != NULL)
        {
            logFile << '\t' << "ScopeTable# " << ptr->getID() << endl;
        
			for (int i = 0; i < ptr->getTotalBucketsNo(); i++)
        	{
            SymbolInfo *curr = ptr->getArrOfSymbolnfo(i);
			bool isCurrNull = true;
			if(curr != NULL){
            logFile << '\t';
            logFile << i + 1<<"-->";
			isCurrNull = false;
            }
            while (curr != NULL)
            {
                     logFile<< "<" << curr->getName() << ",";
					 if(curr->isArray){
						logFile << "ARRAY";
					 }
					 else{
						logFile << curr->getType();
					 }
					 if(curr->function != NULL){
                            logFile<<","<< curr->function->returnType;
                     }
					 logFile<< ">";
                curr = curr->next;
            }
			if(!isCurrNull){
            	logFile << endl;
				isCurrNull = true;
			}
       		 }
            ptr = ptr->parentTable;
        }
    }

void compoundStatementStart(){
					table.enterScope();
					for(int i=0 ; i<parameterList.size();i++){
						bool exists = table.insert(parameterList[i]);
					}
			
}


void insertAndCheckFunctionErrors(string name,string returnType){
				functionReturnType = returnType;
				SymbolInfo* lookUpResult = table.lookUp(name);
				if(lookUpResult== NULL){
					//insert successfully
					functionFound = false;
				}
				else{
					if(lookUpResult->function== NULL){
							errorFile<<"Line# "<<line_count<<": '"<<name<<"' redeclared as different kind of symbol"<<endl;
							errorCount++;
					}

					else if(lookUpResult->function->returnType != returnType){
						errorFile<<"Line# "<<line_count<<": Conflicting types for '"<<name<<"'"<<endl;
						errorCount++;
					}
					else if( parameterList.size() != lookUpResult->function->parameterList.size() ){
							
						errorFile<<"Line# "<<line_count<<": Conflicting types for '"<<name<<"'"<<endl;
						errorCount++;
							
					}
					else if (lookUpResult->function->functionDefined){
						errorFile<<"Line# "<<line_count<<": Redefintion of function '"<<name<<";"<<endl;
						errorCount++;
					}
					functionFound = true;
				}

}

void printParseTree(int level, SymbolInfo *symbol){
	if(symbol->isLeaf){
		for(int i=0; i<level ; i++){
			parseTreeFile<<" ";
		}
		
		parseTreeFile<< idTypeCHecker(symbol) << " : "<<symbol->getName() << "\t" << "<Line: " << symbol->getStartLine() <<">"<<endl;
		return;
	}
	//for printing non -terminal
	for(int i=0; i<level ; i++){
			parseTreeFile<<" ";
		}
	parseTreeFile<<symbol->getName() << " : ";
	for(int i=0 ; i<symbol->childList.size(); i++){
		if(symbol->childList[i]->isLeaf){
			parseTreeFile<<idTypeCHecker(symbol->childList[i]);
		}
		else{
			parseTreeFile<<symbol->childList[i]->getName();
		}
		parseTreeFile<<" ";
	}
	parseTreeFile<< "\t" << "<Line: " << symbol->getStartLine() <<"-"<<symbol->getEndLine()<<">"<<endl;

	for(int i=0 ; i<symbol->childList.size(); i++){
			printParseTree(level+1,symbol->childList[i]);
	}

}

%}


%token IF ELSE FOR WHILE RPAREN LPAREN LTHIRD RTHIRD SEMICOLON COMMA LCURL RCURL VOID RETURN PRINTLN
%token LOGICOP ADDOP ASSIGNOP INCOP DECOP NOT MULOP RELOP INT FLOAT ID CONST_FLOAT CONST_INT

%type declaration_list type_specifier lcurl logic_expression rel_expression program parameter_list 
%type unit func_declaration func_definition compound_statement var_declaration statements statement
%type expression_statement variable expression simple_expression term unary_expression factor argument_list arguments

%start start

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
	{
					printLog("start : program");
					$$ = new SymbolInfo("start","START");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
					printParseTree(0,$$);

					logFile<<"Total Lines: "<<line_count<<endl;
					logFile<<"Total Errors: "<<errorCount<<endl;
		//write your code in this block in all the similar blocks below
	}
	;
program : program unit {
					printLog("program : program unit");
					$$ = new SymbolInfo("program","PROGRAM");
					$$->addChild($1);
					$$->addChild($2);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($2->getEndLine());
	}
	| unit 		{
					printLog("program : unit");
					$$ = new SymbolInfo("program","PROGRAM");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());

	}
	;
	
unit : var_declaration {
					printLog("unit : var_declaration");
					$$ = new SymbolInfo("unit","UNIT");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
}
     | func_declaration {
					printLog("unit : func_declaration");
					$$ = new SymbolInfo("unit","UNIT");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
	 }
     | func_definition {
					printLog("unit : func_definition");
					$$ = new SymbolInfo("unit","UNIT");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
	 }
     ;
   
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
					printLog("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
					Function* function = new Function($2->getName(),$1->childList[0]->getName(),parameterList);
					$2->function = function ;
					$2->type = "FUNCTION";

					bool inserted = table.insert($2);
					if(!inserted){
						errorFile<<"Line# "<<line_count<<": '"<<$2->getName()<<"' redeclared as different kind of symbol"<<endl;
						errorCount++;
					}

					parameterList.clear();

					$$ = new SymbolInfo("func_declaration","FUNC_DECLARATION");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->addChild($5);
					$$->addChild($6);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($6->getEndLine());
}
		| type_specifier ID LPAREN RPAREN SEMICOLON {
					printLog("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
					Function* function = new Function($2->getName(),$1->childList[0]->getName(),parameterList);
					$2->function = function ;
					$2->type = "FUNCTION";

					bool inserted = table.insert($2);
					if(!inserted){
						errorFile<<"Line# "<<line_count<<": '"<<$2->getName()<<"' redeclared as different kind of symbol"<<endl;
						errorCount++;
					}

					parameterList.clear();

					$$ = new SymbolInfo("func_declaration","FUNC_DECLARATION");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->addChild($5);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($5->getEndLine());
		}
		; 
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {
							insertAndCheckFunctionErrors($2->getName(),$1->childList[0]->getType());
							} compound_statement 
				{
					printLog("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
					if(!functionFound){
						Function* function = new Function($2->getName(),$1->childList[0]->getType(),parameterList);
						$2->function = function ;
						$2->function->functionDefined = true ;
						$2->type = "FUNCTION";

						bool inserted = table.insert($2);
						functionFound = true;
					}
					parameterList.clear();
					$$ = new SymbolInfo("func_definition","FUNCTION_DEFINITION");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->addChild($5);
					$$->addChild($7);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($7->getEndLine());
			}
		| type_specifier ID LPAREN RPAREN {
							insertAndCheckFunctionErrors($2->getName(),$1->childList[0]->getType());
							} compound_statement 
			{
					printLog("func_definition : type_specifier ID LPAREN RPAREN compound_statement");
					if(!functionFound){
						Function* function = new Function($2->getName(),$1->childList[0]->getType(),parameterList);
						$2->function = function ;
						$2->function->functionDefined = true ;
						$2->type = "FUNCTION";

						bool inserted = table.insert($2);
						functionFound = true;
					}

					parameterList.clear();

					$$ = new SymbolInfo("func_definition","FUNCTION_DEFINITION");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->addChild($6);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($6->getEndLine());
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {
	
					printLog("parameter_list  : parameter_list COMMA type_specifier ID");

					$4->setType(idType);
					for(int i=0 ; i<parameterList.size(); i++){
							if(parameterList[i]->getName() == $4->getName()){
								errorFile<<"Line# "<<line_count<<": Redefinition of parameter '"<<$4->getName()<<"'"<<endl;
								errorCount++;
								break;
							}
					}
					parameterList.push_back($4);
					

					$$ = new SymbolInfo("parameter_list","PARAMETER_LIST");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($4->getEndLine());
}
		| parameter_list COMMA type_specifier {
					printLog("parameter_list  : parameter_list COMMA type_specifier");

					$$ = new SymbolInfo("parameter_list","PARAMETER_LIST");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($3->getEndLine());
		}
 		| type_specifier ID {
					printLog("parameter_list  : type_specifier ID");
					
					$2->setType(idType);
					for(int i=0 ; i<parameterList.size(); i++){
							if(parameterList[i]->getName() == $2->getName()){
								errorFile<<"reclaration : id already exists"<<endl;
								errorCount++;
								break;
							}
					}
					parameterList.push_back($2);
					

					
					$$ = new SymbolInfo("parameter_list","PARAMETER_LIST");
					$$->addChild($1);
					$$->addChild($2);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($2->getEndLine());
		}
		| type_specifier {
					printLog("parameter_list  : type_specifier");


					$$ = new SymbolInfo("parameter_list","PARAMETER_LIST");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
		}
 		;
	
compound_statement : lcurl statements RCURL {
					printLog("compound_statement : LCURL statements RCURL");

					printAllScopeTable();
					table.exitScope();

					$$ = new SymbolInfo("compound_statement","COMPOUND_STATEMENT");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($3->getEndLine());
}
 		    | lcurl RCURL {
					printLog("compound_statement : LCURL RCURL");
					

					printAllScopeTable();
					table.exitScope();
					

					$$ = new SymbolInfo("compound_statement","COMPOUND_STATEMENT");
					$$->addChild($1);
					$$->addChild($2);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($2->getEndLine());
			}
 		    ;

lcurl : LCURL {
			compoundStatementStart();
			$$ = $1;
}
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
								printLog("var_declaration : type_specifier declaration_list SEMICOLON");
								$$ = new SymbolInfo("var_declaration","VAR_DECLARATION");
								$$->addChild($1);
								$$->addChild($2);
								$$->addChild($3);
								$$->setStartLine($1->getStartLine());
								$$->setEndLine($3->getEndLine());

								if($1->getType()== "VOID"){

									//variables declared as void
									errorFile<<"Line# "<<line_count<<": Variable or field ";
									for(int i= 0 ; i<idList.size();i++){
										errorFile<<"'"<<idList[i]->getName()<<"'";
										if(i != idList.size()-1){
											errorFile<<",";
										}
									}
									errorFile<<" declared void"<<endl;
									errorCount++;
								}
							}
 		 		;
 		 
type_specifier	: INT {
						printLog("type_specifier : INT");

						idType = "INT";

						$$ = new SymbolInfo("type_specifier","type_specifier");
						$$->addChild($1);
						$$->setStartLine($1->getStartLine());
						$$->setEndLine($1->getEndLine());

						$$->setType(idType);
					} 
 		| FLOAT {
						printLog("type_specifier : FLOAT");

						idType = "FLOAT";

						$$ = new SymbolInfo("type_specifier","type_specifier");
						$$->addChild($1);
						$$->setStartLine($1->getStartLine());
						$$->setEndLine($1->getEndLine());

						$$->setType(idType);
						
		}
 		| VOID {
						printLog("type_specifier : VOID");

						idType = "VOID";

						$$ = new SymbolInfo("type_specifier","type_specifier");
						$$->addChild($1);
						$$->setStartLine($1->getStartLine());
						$$->setEndLine($1->getEndLine());

						$$->setType(idType);
		}
 		;
 		
declaration_list : declaration_list COMMA ID {
					printLog("declaration_list : declaration_list COMMA ID");

					$3->setType(idType);
					idList.push_back($3);

					if(idType != "VOID"){
						bool inserted = table.insert($3);
						if(!inserted){
						errorFile<<"Line# "<<line_count<<": Conflicting types for '"<<$3->getName()<<"'"<<endl;
						errorCount++;
					}
			}

					$$ = new SymbolInfo("declaration_list","DECLARATION_LIST");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($3->getEndLine());
					
					}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
					printLog("declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");

					$3->setType(idType);
					$3->isArray = true;;
					idList.push_back($3);

					if(idType != "VOID"){
						bool inserted = table.insert($3);
						if(!inserted){
						errorFile<<"Line# "<<line_count<<": Conflicting types for '"<<$3->getName()<<"'"<<endl;
						errorCount++;
						}
			}

					$$ = new SymbolInfo("declaration_list","DECLARATION_LIST");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->addChild($5);
					$$->addChild($6);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($6->getEndLine());
		  }
 		  | ID {
			printLog("declaration_list : ID");
			$1->setType(idType);
			idList.clear();
			idList.push_back($1);
			if(idType != "VOID"){
					bool inserted = table.insert($1);
					if(!inserted){
						errorFile<<"Line# "<<line_count<<": Conflicting types for '"<<$1->getName()<<"'"<<endl;
						errorCount++;
					}
			}
			$$ = new SymbolInfo("declaration_list","DECLARATION_LIST");
			$$->addChild($1);
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($1->getEndLine());
			
		  }


 		  | ID LTHIRD CONST_INT RTHIRD {
			printLog("declaration_list : ID LSQUARE CONST_INT RSQUARE");
			int size = idList.size();
			for(int i=0 ; i<size ; i++){
				idList.pop_back(); //deleting the list
			}
			$1->setType(idType);
			$1->isArray = true;


			if(idType != "VOID"){
					bool inserted = table.insert($1);
					if(!inserted){
						errorFile<<"Line# "<<line_count<<": Conflicting types for '"<<$1->getName()<<"'"<<endl;
						errorCount++;
					}
			}
			
			idList.push_back($1);

			$$ = new SymbolInfo("declaration_list","DECLARATION_LIST");
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->setStartLine($1->getStartLine());
			$$->setEndLine($4->getEndLine());
			
		  }
 		  ;
 		  
statements : statement {
					printLog("statements : statement");

					$$ = new SymbolInfo("statements","STATEMENTS");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
}
	   | statements statement {
					printLog("statements : statements statement");

					$$ = new SymbolInfo("statements","STATEMENTS");
					$$->addChild($1);
					$$->addChild($2);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($2->getEndLine());
	   }
	   ;
	   
statement : var_declaration {
					printLog("statement: var_declaration");

					$$ = new SymbolInfo("statement","STATEMENT");
					$$->addChild($1);
					
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
}
	  | expression_statement {
					printLog("statement: expression_statement");

					$$ = new SymbolInfo("statement","STATEMENT");
					$$->addChild($1);
					
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
	  }
	  | compound_statement {
					printLog("statement: compound_statement");

					$$ = new SymbolInfo("statement","STATEMENT");
					$$->addChild($1);
					
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
					
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
					printLog("statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement");

					$$ = new SymbolInfo("statement","STATEMENT");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->addChild($5);
					$$->addChild($6);
					$$->addChild($7);
					
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($7->getEndLine());
					
		
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
					printLog("statement: IF LPAREN expression RPAREN statement");

					$$ = new SymbolInfo("statement","STATEMENT");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->addChild($5);
					
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($5->getEndLine());
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {
					printLog("statement: IF LPAREN expression RPAREN statement ELSE statement");

					$$ = new SymbolInfo("statement","STATEMENT");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->addChild($5);
					$$->addChild($6);
					$$->addChild($7);

					$$->setStartLine($1->getStartLine());
					$$->setEndLine($7->getEndLine());
	  }
	  | WHILE LPAREN expression RPAREN statement  {
					printLog("statement: WHILE LPAREN expression RPAREN statement ");

					$$ = new SymbolInfo("statement","STATEMENT");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->addChild($5);
		

					$$->setStartLine($1->getStartLine());
					$$->setEndLine($5->getEndLine());
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
					printLog("statement: PRINTLN LPAREN ID RPAREN SEMICOLON");

					$$ = new SymbolInfo("statement","STATEMENT");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->addChild($5);
		
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($5->getEndLine());
	  }
	  | RETURN expression SEMICOLON {
					printLog("statement: RETURN expression SEMICOLON");

					$$ = new SymbolInfo("statement","STATEMENT");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($3->getEndLine());

	  }
	  ;
	  
expression_statement 	: SEMICOLON		 {
					printLog("expression_statement	: SEMICOLON");

					$$ = new SymbolInfo("expression_statement","EXPRESSION_STATEMENT");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
}	
			| expression SEMICOLON  {
					printLog("expression_statement : expression SEMICOLON");

					$$ = new SymbolInfo("expression_statement","EXPRESSION_STATEMENT");
					$$->addChild($1);
					$$->addChild($2);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($2->getEndLine());
			}
			;
	  
variable : ID 		 {
					printLog("variable : ID");

					$$ = new SymbolInfo("variable","VARIABLE");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());


					SymbolInfo* lookUpResult = table.lookUp($1->getName());
					if(lookUpResult==NULL){
						errorFile<<"Line# "<<line_count<<": Undeclared variable '"<<$1->getName()<<"'"<<endl;
						errorCount++;
					}
					else{
						if(lookUpResult->isArray){
							arrayUsedAsVariable =true;
							arrayVariableName = $1->getName();
						}
						else{
							arrayUsedAsVariable =false;
						}
						$$->type = lookUpResult->type;
					}

					
}
	 | ID LTHIRD expression RTHIRD  {
					printLog("variable : ID LSQUARE expression RSQUARE");

					$$ = new SymbolInfo("variable","VARIABLE");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($4->getEndLine());


					SymbolInfo* lookUpResult = table.lookUp($1->getName());
					if(lookUpResult==NULL){
						errorFile<<"Line# "<<line_count<<": Undeclared variable '"<<$1->getName()<<"'"<<endl;
						errorCount++;
					}
					else{
						if(!lookUpResult->isArray){
							errorFile<<"Line# "<<line_count<<": '"<<$1->getName()<<"' is not an array"<<endl;
							errorCount++;
						}
						$$->type = lookUpResult->type;
					}
					if($3->type != "INT"){
						errorFile<<"Line# "<<line_count<<": Array subscript is not an integer"<<endl;
						errorCount++;
					}
					
					
	 }
	 ;
	 
expression : logic_expression	 {
					printLog("expression : logic_expression");
					
					$$ = new SymbolInfo("expression","EXPRESSION");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());

					$$->type = $1->type;
					$$->value = $1->value;
}
	   | variable ASSIGNOP logic_expression 	 {
					printLog("expression : variable ASSIGNOP logic_expression");
					
					$$ = new SymbolInfo("expression","EXPRESSION");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($3->getEndLine());

					$$->type = $1->type;
					if($3->type == "VOID"){
						
						errorFile<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
						errorCount++;
					}
					else if($1->type == "INT" && $3->type == "FLOAT"){
						// warning : type Casting float to int
						errorFile<<"Line# "<<line_count<<": Warning: possible loss of data in assignment of FLOAT to INT"<<endl;
						errorCount++;
					}
					if(arrayUsedAsVariable){
						errorFile<<"Line# "<<line_count<<": Index is not used with array variable '"<<arrayVariableName<<"'"<<endl;
						errorCount++;
						//arrayUsedAsVariable = false;
					}
	   }
	   ;
			
logic_expression : rel_expression 	 {
					printLog("logic_expression : rel_expression");
					
					$$ = new SymbolInfo("logic_expression","LOGIC_EXPRESSION");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());

					$$->type = $1->type;
					$$->value = $1->value;
}
		 | rel_expression LOGICOP rel_expression  {
					printLog("logic_expression : rel_expression LOGICOP rel_expression");
					
					$$ = new SymbolInfo("logic_expression","LOGIC_EXPRESSION");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($3->getEndLine());
					$$->type = "int";

					if($3->type == "VOID"){
						
						errorFile<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
						errorCount++;
					}

		 }	
		 ;
			
rel_expression	: simple_expression  {
					printLog("rel_expression : simple_expression");
					
					$$ = new SymbolInfo("rel_expression","REL_EXPRESSION");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
					$$->type = $1->type;
					$$->value = $1->value;
}
		| simple_expression RELOP simple_expression	 {
					printLog("rel_expression : simple_expression RELOP simple_expression");
					
					$$ = new SymbolInfo("rel_expression","REL_EXPRESSION");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($3->getEndLine());
					$$->type = "int";

					if($3->type == "VOID"){
						
						errorFile<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
						errorCount++;
					}

		}
		;
				
simple_expression : term  {
					printLog("simple_expression : term");
					
					$$ = new SymbolInfo("simple_expression","SIMPLE_EXPRESSION");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());

					$$->type = $1->type;
					$$->value = $1->value;

					
}
		  | simple_expression ADDOP term  {
					printLog("simple_expression : simple_expression ADDOP term");
					
					$$ = new SymbolInfo("simple_expression","SIMPLE_EXPRESSION");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($3->getEndLine());

					if($3->type == "VOID"){
						
						errorFile<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
						errorCount++;
					}
					
					if($1->type == "float" || $1->type == "float"){
						$$->type = "float";
					}
					else{
						$$->type = "int";
					}
					
			
		  }
		  ;
					
term :	unary_expression {
					printLog("term : unary_expression");
					
					$$ = new SymbolInfo("term","TERM");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());

					$$->type = $1->type;
					$$->value = $1->value;
}
     |  term MULOP unary_expression {
					printLog("term : term MULOP unary_expression");
					
					$$ = new SymbolInfo("term","TERM");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($3->getEndLine());

					if($3->type == "VOID"){
						
						errorFile<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
						errorCount++;
					}

					else if($2->getName()=="%"){
						if($3->value == 0){
							errorFile<<"Line# "<<line_count<<": Warning: division by zero i=0f=1Const=0"<<endl;
							errorCount++;
						}
						else if($1->type == "FLOAT" || $3->type == "FLOAT"){
							//both operands must be integer
							errorFile<<"Line# "<<line_count<<": Operands of modulus must be integers"<<endl;
							errorCount++;
						}
					}

					if($2->getName()=="/"){
						if($3->value == 0){
							errorFile<<"Line# "<<line_count<<": Warning: division by zero i=0f=1Const=0"<<endl;
							errorCount++;
						}
					}

					if($1->type == "FLOAT" || $3->type == "FLOAT"){
						if($2->getName()=="%"){
							$$->type = "INT";
						}
						else{
							$$->type = "FLOAT";
						}
					}
					else{
						$$->type = "INT";
					}
				

	 }
     ;
unary_expression : ADDOP unary_expression  {
					printLog("unary_expression : ADDOP unary_expression");
					
					$$ = new SymbolInfo("unary_expression","UNARY_EXPRESSION");
					$$->addChild($1);
					$$->addChild($2);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($2->getEndLine());

					$$->type = $2->type;

					if($2->type == "VOID"){
						errorFile<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
						errorCount++;
					}



} 
		 | NOT unary_expression  {
					printLog("unary_expression : NOT unary_expression");
					
					$$ = new SymbolInfo("unary_expression","UNARY_EXPRESSION");
					$$->addChild($1);
					$$->addChild($2);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($2->getEndLine());

					$$->type = $2->type;

					if($2->type == "VOID"){
						errorFile<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
						errorCount++;
					}

					
					
		 }
		 | factor  {
					printLog("unary_expression : factor");
					
					$$ = new SymbolInfo("unary_expression","UNARY_EXPRESSION");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());


					$$->type = $1->type;
					$$->value = $1->value;
					
		 }
		 ;
	
factor	: variable  {
					printLog("factor : variable");
					
					$$ = new SymbolInfo("factor","FACTOR");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());

					$$->type = $1->type;
					$$->value = $1->value;

}
	| ID LPAREN argument_list RPAREN {
		//MATCHING FUNCTION
					printLog("factor : ID LPAREN argument_list RPAREN");
					
					$$ = new SymbolInfo("factor","FACTOR");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->addChild($4);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($4->getEndLine());

					SymbolInfo* lookUpResult = table.lookUp($1->getName());
					if(lookUpResult == NULL){
						errorFile<<"Line# "<<line_count<<": Undeclared function '"<<$1->getName()<<"'"<<endl;
						errorCount++;
					}
					else{
						if(lookUpResult->function ==NULL){
							errorFile<<"Line# "<<line_count<<": Undeclared function '"<<$1->getName()<<"'"<<endl; 
							errorCount++;
						}
						else{
							$$->type = lookUpResult->function->returnType;
							//match parameters size and type
							if(lookUpResult->function->parameterList.size() != argumentList.size()){
								if(lookUpResult->function->parameterList.size() > argumentList.size()){
									errorFile<<"Line# "<<line_count<<": Too few arguments to function '"<<$1->getName()<<"'"<<endl;
									errorCount++;
								}
								else{
									errorFile<<"Line# "<<line_count<<": Too many arguments to function '"<<$1->getName()<<"'"<<endl;
									errorCount++;
								}
								
							}
							else{
								bool foundError =false;
								for(int i=0 ; i< argumentList.size(); i++){
									if(argumentList[i]->type != lookUpResult->function->parameterList[i]->type ){
										errorFile<<"Line# "<<line_count<<": Type mismatch for argument "<<i+1<<" of '"<<$1->getName()<<"'"<<endl;
										foundError=true;
									}
								}
								if(foundError){
								errorCount++;
								}
							}

						}
					}

					argumentList.clear();
					arrayUsedAsVariable = false;

	}
	| LPAREN expression RPAREN {
					printLog("factor : LPAREN expression RPAREN");
					
					$$ = new SymbolInfo("factor","FACTOR");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($3->getEndLine());

					$$->type = $2->type;
					$$->value = $2->value;

	}
	| CONST_INT  {
					printLog("factor : CONST_INT");
					
					$$ = new SymbolInfo("factor","FACTOR");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());

					$$->type = "INT";
					$$->value = stod($1->getName());

	}
	| CONST_FLOAT {
					printLog("factor : CONST_FLOAT");
					
					$$ = new SymbolInfo("factor","FACTOR");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());

					$$->type = "FLOAT";
					$$->value = stod($1->getName());
	}
	| variable INCOP  {

					printLog("factor : variable INCOP");
					
					$$ = new SymbolInfo("factor","FACTOR");
					$$->addChild($1);
					$$->addChild($2);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($2->getEndLine());

					$$->type = $1->type;
	}
	| variable DECOP {
					printLog("factor : variable DECOP");
					
					$$ = new SymbolInfo("factor","FACTOR");
					$$->addChild($1);
					$$->addChild($2);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($2->getEndLine());

					$$->type = $1->type;
	}
	;
	
argument_list : arguments {
					printLog("argument_list : arguments");
					
					$$ = new SymbolInfo("argument_list","AARGUMENT_LIST");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
} 
			  | {
					cout<<"argument_list :"<<endl;
					$$ = new SymbolInfo("argument_list","AARGUMENT_LIST");
					$$->isLeaf = true;
			  }
			  ;
	
arguments : arguments COMMA logic_expression {
					printLog("arguments : arguments COMMA logic_expression");
					
					$$ = new SymbolInfo("arguments","ARGUMENTS");
					$$->addChild($1);
					$$->addChild($2);
					$$->addChild($3);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($3->getEndLine());

					argumentList.push_back($3);
}
	      | logic_expression {
					printLog("arguments : logic_expression");
					
					$$ = new SymbolInfo("arguments","ARGUMENTS");
					$$->addChild($1);
					$$->setStartLine($1->getStartLine());
					$$->setEndLine($1->getEndLine());
					argumentList.push_back($1);

		  }
	      ;
 

%%
int main(int argc,char *argv[])
{
	FILE *fp;
	logFile.open("2005051_log.txt");
	errorFile.open("2005051_error.txt");
	parseTreeFile.open("2005051_parseTree.txt");
	
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	


	yyin=fp;
	yyparse();

	
	return 0;
}

