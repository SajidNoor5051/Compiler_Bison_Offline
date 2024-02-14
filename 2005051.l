%option noyywrap

%x SingleLineComment

%x MultiLineComment

%x StringState

%{
#include<iostream>
#include<fstream>
#include<cstdlib>
#include<sstream>
#include<cstring>
#include "2005051_SymbolTable.cpp"
#define YYSTYPE SymbolInfo*
#define scopeTableSize 11
#include "y.tab.h"

using namespace std;


extern YYSTYPE yylval;
void yyerror(char *);



int charcountForString = 0;
int tempLineCount =0;
int tabCount =0;
int spaceCount = 0 ;
bool insideLine = true;
int indentationLevel= 0 ;

string stringForToken;
string stringForLog;
string multiLineCommentString;

int errorCount=0;
extern int line_count=1;
int warningCount = 0;
int scopeCount = 0;

extern ofstream logFile ;
ofstream tokenFile;

SymboleTable s(10);

void setYylVal(string name, string type){
	yylval = new SymbolInfo(name,type,true);
	yylval->setStartLine(line_count);
	yylval->setEndLine(line_count);
	yylval->setIsLeaf(true);
}

void printKeyWord(string keyword , string token){
       // tokenFile<<"<"<<keyword<<", "<<token<<">"<<endl;
}



void printLog(string token , string lexeme,int thislineCount){
		logFile<<"Line# "<<thislineCount<<": Token <"<<token<<"> Lexeme "<<lexeme<<" found"<<endl;
}

void printError(string errorMessage, string errorText , int thislineCount){
	//	logFile<<"Error at line# "<<thislineCount<<": "<<errorMessage<<" "<<errorText<<endl;
}



void idAlreadyExists(string id){
	//logFile<<"\t"<<id<<" already exists in the current ScopeTable"<<endl;
}

void printWarning(){
	if(insideLine == false){
		if(spaceCount>0){
			warningCount++;
			//logFile<<"Line# "<<line_count<<": Warning, tab required but got space."<<endl;
		}
		else{
			if((tabCount-indentationLevel)!=0){
				warningCount++;
				//logFile<<"Line# "<<line_count<<": warning, "<<indentationLevel<<" of tabs needed but got "<<tabCount<<" tabs."<<endl;
			}
		}
	}
}

%}





WHITESPACE [\f\r\v]+
Digit [0-9]
Space [ ]
Tab [\t]
NotSingleQuote[!-&(-~ ]
Letter [a-zA-Z]
IDBegin ({Letter}|_)
EXP [eE][-+]?{Digit}+


%%
{WHITESPACE}+ {}
\n {
	line_count++;
	tabCount = 0 ;
	insideLine = false;
	spaceCount = 0;
	}
{Tab} {
	tabCount++;
}

{Space} {
	spaceCount++;
	if((spaceCount % 4) == 0 ){
		spaceCount =  0;
		tabCount++;
	}
}

"if" {
	printWarning();
	insideLine = true;
	printKeyWord("IF",yytext);
	setYylVal(yytext,"IF");
	return IF;
	}
"for" 	{
			printWarning();
			insideLine = true;
			printKeyWord("FOR",yytext);
			printLog("FOR",yytext,line_count);
			setYylVal(yytext,"FOR");
			return FOR;
		}
"int" 	{	
			printWarning();
			insideLine = true;
			printKeyWord("INT",yytext);
			printLog("INT",yytext,line_count);
			setYylVal(yytext,"INT");
			return INT;
		}
"float" {	
			printWarning();
			insideLine = true;
			printKeyWord("FLOAT",yytext);
			printLog("FLOAT",yytext,line_count);
			setYylVal(yytext,"FLOAT");
			return FLOAT;
		}
"void" 	{	
			printWarning();
			insideLine = true;
			printKeyWord("VOID",yytext);
			setYylVal(yytext,"VOID");
			printLog("VOID",yytext,line_count);
			return VOID;
		}

"else" 	{	
			printWarning();
			insideLine = true;
			printKeyWord("ELSE",yytext);
			printLog("ELSE",yytext,line_count);
			setYylVal(yytext,"ELSE");
			return ELSE;
		}
"while" {	
			printWarning();
			insideLine = true;
			printKeyWord("WHILE",yytext);
			printLog("WHILE",yytext,line_count);
			setYylVal(yytext,"WHILE");	
			return WHILE;
		}

"return" {
			printWarning();
			insideLine = true;
			printKeyWord("RETURN",yytext);
			printLog("RETURN",yytext,line_count);
			setYylVal(yytext,"RETURN");
			return RETURN;
		}




"printLn" {
			printWarning();
			insideLine = true;
			printKeyWord("PRINTLN",yytext);
			printLog("PRINTLN",yytext,line_count);
			setYylVal(yytext,"PRINTLN");
			return PRINTLN;
		}

"+"|"-" {
			printWarning();
			insideLine = true;
			printKeyWord("ADDOP",yytext);
			printLog("ADDOP",yytext,line_count);
			setYylVal(yytext,"ADDOP");
			return ADDOP;
			}
"*"|"/"|"%" {
			printWarning();
			insideLine = true;
			printKeyWord("MULOP",yytext);
			printLog("MULOP",yytext,line_count);
			setYylVal(yytext,"MULOP");
			return MULOP;
			}
"++"|"--" {		
			printWarning();
			insideLine = true;
			printKeyWord("INCOP",yytext);
			printLog("INCOP",yytext,line_count);
			setYylVal(yytext,"INCOP");
			return INCOP;
			}
"<"|"<="|">"|">="|"=="|"!=" {	
								printWarning();
								insideLine = true;
								printKeyWord("RELOP",yytext);
								printLog("RELOP",yytext,line_count);
								setYylVal(yytext,"RELOP");
								return RELOP;
							}
"=" 		{
				printWarning();
				insideLine = true;
				printKeyWord("ASSIGNOP",yytext);
				printLog("ASSIGNOP",yytext,line_count);
				setYylVal(yytext,"ASSIGNOP");
				return ASSIGNOP;
				}
"&&"|"||" 	{	
				printWarning();
				insideLine = true;
				printKeyWord("LOGICOP",yytext);
				printLog("LOGICOP",yytext,line_count);
				setYylVal(yytext,"LOGICOP");
				return LOGICOP;
			}

"!" 		{
				printWarning();
				insideLine = true;
				printKeyWord("NOT",yytext);
				printLog("NOT",yytext,line_count);
				setYylVal(yytext,"NOT");
				return NOT;
			}
"(" 		{
				printWarning();
				insideLine = true;
				printKeyWord("LPAREN",yytext);
				printLog("LPAREN",yytext,line_count);
				setYylVal(yytext,"LPAREN");
				return LPAREN;
			}
")" 		{
				printWarning();
				insideLine = true;
				printKeyWord("RPAREN",yytext);
				printLog("RPAREN",yytext,line_count);
				setYylVal(yytext,"RPAREN");
				return RPAREN;
			}
"{" 		{ 
				
				if(insideLine==false){
					if((indentationLevel-tabCount)!=0){
						printWarning();
					}
					insideLine = true;
				}
				indentationLevel++;	
				s.enterScope();	
				printKeyWord("LCURL",yytext);
				printLog("LCURL",yytext,line_count);
				setYylVal(yytext,"LCURL");
				return LCURL;
			}
"}" {
		indentationLevel--;
		if(insideLine==false){
			if((indentationLevel-tabCount)!=0){
					printWarning();
				}
			insideLine = true;
		}
		s.exitScope();
		printKeyWord("RCURL",yytext);
		printLog("RCURL",yytext,line_count);
		setYylVal(yytext,"RCURL");
		return RCURL;
	}

"[" {
		printWarning();
		insideLine = true;
		printKeyWord("LSQUARE",yytext);
		printLog("LSQUARE",yytext,line_count);
		setYylVal(yytext,"LSQUARE");
		return LTHIRD;
	}
"]" {
		printWarning();
		insideLine = true;
		printKeyWord("RSQUARE",yytext);
		printLog("RSQUARE",yytext,line_count);
		setYylVal(yytext,"RSQUARE");
		return RTHIRD;
	}
"," {	
		printWarning();
		insideLine = true;
		printKeyWord("COMMA",yytext);
		printLog("COMMA",yytext,line_count);
		setYylVal(yytext,"COMMA");
		return COMMA;
	}
";" {	
		printWarning();
		insideLine = true;
		printKeyWord("SEMICOLON",yytext);
		printLog("SEMICOLON",yytext,line_count);
		setYylVal(yytext,"SEMICOLON");
		return SEMICOLON;
	}


{Digit}+ { 
	// for integer numbers
	printWarning();
	insideLine = true;
	printKeyWord("CONST_INT",yytext);
	printLog("CONST_INT",yytext,line_count);
	setYylVal(yytext,"CONST_INT");
	return CONST_INT;
	}


{Digit}+("."{Digit}+{EXP}?|{EXP})	{//float numbers
	printWarning();
	insideLine = true;
	printKeyWord("CONST_FLOAT",yytext);
	printLog("CONST_FLOAT",yytext,line_count);
	setYylVal(yytext,"CONST_FLOAT");
	return CONST_FLOAT;
}
[-+]?{Digit}+((".")({Digit}*{Letter}+)({Digit}|{Letter}|".")*) {
	//ill float number
	printWarning();
	insideLine = true;
	printError("ILLFORMED_NUMBER",yytext,line_count);
	errorCount++;
}

[-+]?{Digit}+{EXP}("."({Digit}|{Letter}|".")*) {
	//ill float number
	printWarning();
	insideLine = true;
	printError("ILLFORMED_NUMBER",yytext,line_count);
	errorCount++;
}

[-+]?{Digit}+("."({Digit}+{EXP}?))"."("."|{Digit}|{Letter})* {
	//too many decimal points
	printWarning();
	insideLine = true;
	printError("TOO_MANY_DECIMAL_POINTS",yytext,line_count);
	errorCount++;
}


{IDBegin}({Letter}|_|{Digit})* {
	//Identifier
	printWarning();
	insideLine = true;
	printKeyWord("ID",yytext); 
	printLog("ID",yytext,line_count);
		setYylVal(yytext,"ID");
		//cout<<yytext<<endl;
		return ID;
		
}


{Digit}+({Letter}|_|{Digit})+ {
	//identifier error
	printWarning();
	insideLine = true;
	printError("INVALID_ID_SUFFIX_NUM_PREFIX",yytext,line_count);
	errorCount++;
}



'\\[ntbafrv0"\\']'    { 
	printWarning();
	insideLine = true;
	string value;
    switch(yytext[2]) {
        case 'n': value = "\n"; break;
        case 't': value = "\t"; break;
        case 'a': value = "\a"; break;
        case 'f': value = "\f"; break;
        case 'r': value = "\r"; break;
        case 'v': value = "\v"; break;
        case '0': value = "\0"; break;
        case '"': value = "\""; break;
        case '\\': value = "\\"; break;
		case 'b': value = "\b"; break;
        default: 
		value = "\'";
		break;
    }
	printKeyWord("CONST_CHAR",value); 
	printLog("CONST_CHAR",value,line_count);
	//return CONST_CHAR;
	}

'' {
	printWarning();
	insideLine = true;
	printError("EMPTY_CONST_CHAR",yytext,line_count);
	errorCount++;
}
'\\' {
	printWarning();
	insideLine = true;
	printError("UNFINISHED_CONST_CHAR",yytext,line_count);
	errorCount++;
}
'([!-~ ])'			{
						printWarning();
						insideLine = true;
						//tokenFile<<"<CONST_CHAR, "<< yytext[1]<<">"<<endl;
						//logFile<<"Line# "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext[1]<<" found"<<endl;
						//return CONST_CHAR;
	 				}


'{NotSingleQuote}{NotSingleQuote}+' {
	printWarning();
	insideLine = true;
	printError("MULTICHAR_CONST_CHAR",yytext,line_count);
	errorCount++;
}

'{NotSingleQuote}*(\n) {
	printWarning();
	insideLine = true;
	//logFile<<"Error at line# "<<line_count<<": UNFINISHED_CONST_CHAR "<<yytext;
	errorCount++;
	line_count++;
}


\/\/ {
		printWarning();
		insideLine = true;
		BEGIN SingleLineComment ;
		tempLineCount = line_count;
		//logFile<<"Line# "<<tempLineCount<<": Token <SINGLE LINE COMMENT> Lexeme "<<yytext;
	}

<SingleLineComment>\\\n {
	tabCount = 0;
	insideLine = false;
	spaceCount = 0;
	line_count++;
	logFile<<yytext;
}
<SingleLineComment>\\\r\n {
	tabCount = 0;
	insideLine = false;
	spaceCount = 0;
	line_count++;
	logFile<<yytext;
} 
<SingleLineComment>\n {
	tabCount = 0;
	insideLine = false;
	spaceCount = 0;
	line_count++;
	logFile<<" found"<<yytext;
	BEGIN INITIAL;
}

<SingleLineComment>\t {
	tabCount++;
	logFile<<yytext;
}

<SingleLineComment>[ ] {
	spaceCount++;
	if((spaceCount % 4) == 0 ){
		spaceCount =  0;
		tabCount++;
	}
	logFile<<yytext;
}

<SingleLineComment>. {
	printWarning();
	insideLine = true;
	logFile<<yytext;
}


\/\* {
	printWarning();
	insideLine = true;
	BEGIN MultiLineComment ;
	tempLineCount = line_count;
	multiLineCommentString += yytext;
}


<MultiLineComment>\n 	{
							tabCount = 0;
							insideLine = false;
							spaceCount = 0;
							line_count++;
						  	multiLineCommentString += yytext;
						}


<MultiLineComment>\*\/  {
							multiLineCommentString += yytext;
							printLog("MULTI LINE COMMENT",multiLineCommentString,tempLineCount);
							multiLineCommentString="";
							BEGIN INITIAL;
						}

<MultiLineComment>\t {
	tabCount++;
	multiLineCommentString += yytext;
}

<MultiLineComment>[ ] {
	spaceCount++;
	if((spaceCount % 4) == 0 ){
		spaceCount =  0;
		tabCount++;
	}
	multiLineCommentString += yytext;
}
	


<MultiLineComment>. 	{ 
							printWarning();
							insideLine = true;
							multiLineCommentString += yytext;
						}	


<MultiLineComment><<EOF>> {
								printError("UNFINISHED_COMMENT",multiLineCommentString,line_count);
								errorCount++;
								multiLineCommentString="";
								BEGIN INITIAL;
						  }											




\" {
	printWarning();
	insideLine = true;
	BEGIN StringState;
	tempLineCount = line_count;
	stringForLog = stringForLog + yytext;
}

<StringState>\\[ntbafrv0"\\'] {
		string escapeChar ;
		if(yytext[1]=='n'){
			escapeChar = "\n";
		}
		else if(yytext[1]=='t'){
			escapeChar = "\t";
		}
		else if(yytext[1]=='b'){
			escapeChar = "\a";
		}
		else if(yytext[1]=='a'){
			escapeChar = "\a";
		}
		else if(yytext[1]=='f'){
			escapeChar = "\f";
		}
		else if(yytext[1]=='r'){
			escapeChar = "\r";
		}
		else if(yytext[1]=='v'){
			escapeChar = "\v";
		}
		else if(yytext[1]=='"'){
			escapeChar = "\"";
		}
		else if(yytext[1]=='\\'){
			escapeChar = "\\";
		}
		else{
			escapeChar = "\'";
		}
		stringForLog = stringForLog + yytext;
		stringForToken = stringForToken + escapeChar;
		
}

<StringState>\\\n {
	tabCount = 0;
	insideLine = false;
	spaceCount = 0;
	line_count++;
	stringForLog = stringForLog + yytext;

}


<StringState>\\\r\n {
	tabCount = 0;
	insideLine = false;
	spaceCount = 0;
	line_count++;
	stringForLog = stringForLog + yytext;
	
}

<StringState>\n {
	tabCount = 0;
	insideLine = false;
	spaceCount = 0;
	printError("UNFINISHED_STRING",stringForLog,line_count);
	errorCount++;
	line_count++;
	stringForLog= "";
	stringForToken= "";
	BEGIN INITIAL;
}

<StringState>\t {
	tabCount++;
	stringForToken =  stringForToken + yytext;
	stringForLog = stringForLog + yytext;
}

<StringState>[ ] {
	spaceCount++;
	if((spaceCount % 4) == 0 ){
		spaceCount =  0;
		tabCount++;
	}
	stringForToken =  stringForToken + yytext;
	stringForLog = stringForLog + yytext;
}

<StringState><<EOF>> {
	printError("UNFINISHED_STRING",stringForLog,line_count);
	errorCount++;
	stringForLog= "";
	stringForToken= "";
	BEGIN INITIAL;
}

<StringState>\" {
	stringForLog = stringForLog + yytext;
	
	if(tempLineCount==line_count){
		printKeyWord("SINGLE LINE STRING",stringForToken); 
		printLog("SINGLE LINE STRING",stringForLog,tempLineCount);
	}
	else{
		printKeyWord("MULTI LINE STRING",stringForToken);
		printLog("MULTI LINE STRING",stringForLog,tempLineCount);
	}
	stringForLog= "";
	stringForToken= "";
	BEGIN INITIAL;
	/*if(tempLineCount==line_count){
		return SINGLE
	}*/
}
<StringState>. {
	printWarning();
	insideLine = true;
	stringForLog = stringForLog + yytext;
	stringForToken = stringForToken + yytext;
}

<<EOF>> {
	//logFile<<"Total lines: "<<line_count<<endl;
	//logFile<<"Total errors: "<<errorCount<<endl;
	//logFile<<"Total warnings: "<<warningCount<<endl;
	return 0;
}
. {
	printError("UNRECOGNIZED_CHAR",yytext,line_count);
	errorCount++;
}
%%


