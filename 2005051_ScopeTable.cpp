#include <iostream>
#include <string>
#include "2005051_SymbolInfo.cpp"
using namespace std;
class ScopeTable
{
public:
    SymbolInfo **arrOfSymbolInfo;
    ScopeTable *parentTable;
    int scopeId;
    int totalBuckets;
    int levelNo;

    ScopeTable(int n, ScopeTable *parentTable, int scopeId)
    {
        this->totalBuckets = n;
        arrOfSymbolInfo = new SymbolInfo *[n];
        for (int i = 0; i < n; i++)
        {
            arrOfSymbolInfo[i] = NULL;
        }
        this->levelNo = 1;
        this->parentTable = parentTable;
        this->scopeId = scopeId;
      //  cout << "ScopeTable# " << this->getID() << " created" << endl;
    }
    ~ScopeTable()
    {
       // cout << '\t' << "ScopeTable# " << this->getID() << " deleted" << endl;
        for (int i = 0; i < totalBuckets; i++)
        {
            delete arrOfSymbolInfo[i];
        }
        delete[] arrOfSymbolInfo;
    }

    static unsigned long long sdbm(string &str)
    {
        unsigned long long hash = 0;
        for (char c : str)
        {
            hash = c + (hash << 6) + (hash << 16) - hash;
        }
        return hash;
    }
    int hash(unsigned long long hashValue)
    {
        return hashValue % this->getTotalBucketsNo();
    }
    int getTotalBucketsNo()
    {
        return this->totalBuckets;
    }

    SymbolInfo* getArrOfSymbolnfo(int i){
        return arrOfSymbolInfo[i];
    }

    void setID(int id)
    {
        this->scopeId = id;
    }
    int getID()
    {
        return this->scopeId;
    }

    SymbolInfo *lookUp(string name)
    {
        int hashValue = hash(sdbm(name));
        int collision = 1;

        SymbolInfo *ptr = arrOfSymbolInfo[hashValue];
        while (ptr != NULL)
        {
            if (ptr->getName() == name)
            {
              //  cout << "'" << ptr->getName() << "' found at position <" << hashValue + 1 << ", " << collision << "> of ScopeTable# " << this->getID() << endl;
                break;
            }
            ptr = ptr->next;
            collision++;
        }
        return ptr;
    }

    SymbolInfo *lookUpHelpForInsertAndDelete(int hashValue, string name)
    {
        SymbolInfo *ptr = arrOfSymbolInfo[hashValue];
        while (ptr != NULL)
        {
            if (ptr->getName() == name)
            {
                break;
            }
            ptr = ptr->next;
        }
        return ptr;
    }

    bool insert(string name, string type)
    {
        
        int hashValue = hash(sdbm(name));
        SymbolInfo *findPtr = lookUpHelpForInsertAndDelete(hashValue, name);

        if (findPtr == NULL)
        {
            int collision = 1;
            if (arrOfSymbolInfo[hashValue] == NULL)
            {
                arrOfSymbolInfo[hashValue] = new SymbolInfo(name, type);
            }
            else
            {
                collision++;
                SymbolInfo *curr = arrOfSymbolInfo[hashValue];
                while (curr->next != NULL)
                {
                    collision++;
                    curr = curr->next;
                }
                SymbolInfo *newPtr = new SymbolInfo(name, type);
                curr->next = newPtr;
            }
            //cout << "Inserted  at position <" << hashValue + 1 << ", " << collision << "> of ScopeTable# " << this->getID() << endl;
            return true;
        }
        else
        {
            cout << "'" << name << "' already exists in the current ScopeTable# " << this->getID() << endl;
            return false;
        }
    }

    bool insert(SymbolInfo* symbol)
    {
        string name = symbol->getName();
        int hashValue = hash(sdbm(name));
        SymbolInfo *findPtr = lookUpHelpForInsertAndDelete(hashValue, symbol->getName());

        if (findPtr == NULL)
        {
            if (arrOfSymbolInfo[hashValue] == NULL)
            {
                //arrOfSymbolInfo[hashValue] = symbol;
                arrOfSymbolInfo[hashValue] = new SymbolInfo(symbol);

            }
            else
            {
                
                SymbolInfo *curr = arrOfSymbolInfo[hashValue];
                while (curr->next != NULL)
                {
                    curr = curr->next;
                }
               // SymbolInfo *newPtr = symbol;
               SymbolInfo *newPtr = new SymbolInfo(symbol);
                curr->next = newPtr;
            }
            return true;
        }
        else
        {
          //  cout << "'" << name << "' already exists in the current ScopeTable# " << this->getID() << endl;
            return false;
        }
    }

    bool remove(string name)
    {
        int hashValue = hash(sdbm(name));
        int deleteFlag = 0;
        int collision = 1;

        SymbolInfo *found = lookUpHelpForInsertAndDelete(hashValue, name);
        if (found != NULL)
        {

            if (arrOfSymbolInfo[hashValue]->getName() == name)
            {
                arrOfSymbolInfo[hashValue] = arrOfSymbolInfo[hashValue]->next;
                deleteFlag = 1;
            }
            else
            {
                SymbolInfo *curr = arrOfSymbolInfo[hashValue];
                SymbolInfo *prev = arrOfSymbolInfo[hashValue];
                while (curr != NULL)
                {
                    if (curr->getName() == name)
                    {
                        prev->next = curr->next;
                        delete curr;
                        deleteFlag = 1;
                        break;
                    }
                    else
                    {
                        prev = curr;
                        curr = curr->next;
                        collision++;
                    }
                }
            }
        }
        if (deleteFlag)
        {
            //cout << "Deleted '" << name << "' from position <" << hashValue + 1 << ", " << collision << "> of ScopeTable# " << this->getID() << endl;
            return true;
        }
        else
        {
           // cout << "Not found in the current ScopeTable# " << this->getID() << endl;
            return false;
        }
    }

    void print()
    {
        cout << '\t' << "ScopeTable# " << this->getID() << endl;
        for (int i = 0; i < totalBuckets; i++)
        {
            SymbolInfo *curr = arrOfSymbolInfo[i];
            if(curr != NULL){
            cout << '\t';
            cout << i + 1 << " --> ";
            }
            
            while (curr != NULL)
            {
                cout << " --> "
                     << "<" << curr->getName() << "," << curr->getType();
                     if(curr->function != NULL){
                            cout<<","<< curr->function->returnType;
                     }
                     cout<< "> ";
                curr = curr->next;
            }
            cout << endl;
        }
    }
};
