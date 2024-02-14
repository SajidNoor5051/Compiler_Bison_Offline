#include <iostream>
#include <cstring>
#include <list>
#include <vector>
using namespace std;
class Function;
class SymbolInfo
{
    public:
    string type;
    string name;
    bool isArray;
	int arraySize;
	double value;
    SymbolInfo *next;
    bool isLeaf;
    vector <SymbolInfo*> childList;
    int startLine,endLine;
    Function *function;
    SymbolInfo(string name, string type,bool isLeaf = false){
        this->type = type;
        this->name =  name;
        this->setIsLeaf(isLeaf);
        this->isArray = false;
        next = NULL;
        function = NULL;
        value = -100000;
    }
    SymbolInfo(SymbolInfo* symbol){
        this->type = symbol->getType();
        this->name =  symbol->getName();
        this->setIsLeaf(symbol->getIsLeaf());
        this->next = symbol->getNext();
        this->isArray = symbol->isArray;
        function = symbol->function;
        this->value = symbol->value;

    }
    SymbolInfo(){
        this->next=NULL;
    }
    void setType(string type){
        this->type = type;
    }
    string getType(){
        return this->type;
    }
    void setName(string name){
        this->name = name;
    }
    string getName(){
        return this->name;
    }
    SymbolInfo *getNext(){
        return this->next;
    }
    
    void addChild(SymbolInfo* child){
        childList.push_back(child);
    }
    void setIsLeaf(bool result){
        isLeaf = result;
    }
    bool getIsLeaf(){
        return isLeaf;
    }
    void setStartLine(int startLine){
        this->startLine = startLine;
    }
    int getStartLine(){
        return this->startLine;
    }
    
    void setEndLine(int endLine){
        this->endLine = endLine;
    }
    int getEndLine(){
        return this->endLine;
    }

    void setIsArray(bool isArray){
        this->isArray = isArray;
    }

    bool getIsArray(){
        return this->isArray;
    }

	void setArraySize(int size){
		this->arraySize = size;

	}
	int getArraySize(){
		return this->arraySize;
	}


	
};


class Function{
    public:
    string name;
    string returnType;
    vector<SymbolInfo*> parameterList;
    bool functionDefined;
    Function(string name, string returnType,vector<SymbolInfo*> paramList){
                 
            this->name = name;
            this->returnType = toUpperCase(returnType);
            if(paramList.size()!=0){
            this->parameterList = paramList;
            this->functionDefined = false;
            }
            functionDefined = false;
            
    }

    string toUpperCase(string str){
	for(int i = 0; i < str.length(); i++) {
        str[i] = toupper(str[i]);
    }
	return str;
    }

};