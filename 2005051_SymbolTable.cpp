#include <iostream>
#include <string>
#include <stack>
#include "2005051_ScopeTable.cpp"
using namespace std;
class SymboleTable
{
public:
    ScopeTable *currentScopeTable;
    int sizeOfScopeTable;
    SymboleTable(int sizeOfScopeTable)
    {
        this->sizeOfScopeTable = sizeOfScopeTable;
        currentScopeTable = new ScopeTable(sizeOfScopeTable, NULL, 1);
       
    }
    ~SymboleTable(){
        exitAllScope();
    }

    ScopeTable* getCurrentScopeTable(){
        return this->currentScopeTable;
    }
    void enterScope()
    {
        ScopeTable *newTable = new ScopeTable(this->sizeOfScopeTable, currentScopeTable, currentScopeTable->getID() +  currentScopeTable->levelNo);

        currentScopeTable = newTable;
    }
    void exitScope()
    {
        if (currentScopeTable->parentTable != NULL)
        {
            ScopeTable *tempScope = currentScopeTable->parentTable;
            delete currentScopeTable;
            tempScope->levelNo++;
            currentScopeTable = tempScope;
        }
        else
        {
           // cout<<'\t'<< "ScopeTable# " << currentScopeTable->getID() << " cannot be deleted" << endl;
        }
    }
    bool insert(string name, string type)
    {
        return currentScopeTable->insert(name, type);
    }
    bool insert(SymbolInfo* symbol){
        return currentScopeTable->insert(symbol);
    }
    bool remove(string name)
    {
        return currentScopeTable->remove(name);
    }
    void printCurrentScopeTable()
    {
        currentScopeTable->print();
    }
    SymbolInfo *lookUp(string name)
    {
        ScopeTable *ptr = currentScopeTable;
        SymbolInfo *found = NULL;
        while (ptr != NULL)
        {
            found = ptr->lookUp(name);
            if (found != NULL)
            {
                break;
            }
            ptr = ptr->parentTable;
        }
        if (found == NULL)
        {
           // cout << "'" << name << "' not found in any of the ScopeTables" << endl;
        }
        return found;
    }
    void printAllScopeTable()
    {
        ScopeTable *ptr = currentScopeTable;
        while (ptr != NULL)
        {
            ptr->print();
            ptr = ptr->parentTable;
        }
    }
    void exitAllScope()
    {
        while (currentScopeTable != NULL)
        {
            ScopeTable *temp = currentScopeTable->parentTable;
            delete currentScopeTable;
            currentScopeTable = temp;
        }
    }
};