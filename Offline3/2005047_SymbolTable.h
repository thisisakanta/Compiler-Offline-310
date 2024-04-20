#include <iostream>
#include <string>
#include "2005047_ScopeTable.h"
using namespace std;

class SymbolTable
{

private:
    ScopeTable *curr;
    int scopeTableSize = 11;
    

public:
    SymbolTable(int n)
    {
        this->scopeTableSize = n;
        curr = new ScopeTable(n);
    }
    ~SymbolTable()
    {
        ScopeTable *temp = curr;
        while (temp != NULL)
        {
            cout << "\tScopeTable# " << curr->getid() << " deleted" << endl;
            curr = curr->getParentScope();
            delete temp;
            temp = curr;
        }
        delete curr;
    }
  
    void enterScope()
    {
        ScopeTable *newScope = new ScopeTable(scopeTableSize);
        newScope->setParentScope(curr);
        curr = newScope;
      //  cout<<"new scope has been created?"<<endl;
       // cout << "\tScopeTable# " << curr->getid() << " created" << endl;
       
    }
    
    void exitScope()
    {
        if (curr->getParentScope() == NULL)
        {
           // cout << "\tScopeTable# 1 cannot be deleted" << endl;
        }
        else
        {
            //cout << "\tScopeTable# " << curr->getid() << " deleted" << endl;
            ScopeTable *temp=curr;
            curr = curr->getParentScope();
            delete temp;
        }
    }
    ScopeTable *currentScope(){
            return curr;
    }
    // bool insert(string type, string name)
    // {
    //     if (curr->Insert(type, name))
    //     {
    //         return true;
    //     }
    //     else
    //     {
    //        return false;
    //     }
    // }
    bool insert(SymbolInfo *symbolinfo)
    {
        
        return curr->Insert(symbolinfo);
    }
    bool remove(string name)
    {
        if (curr->Delete(name))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    SymbolInfo *lookup(string name)
    {
        ScopeTable *temp = curr;
        while (temp != NULL)
        {
            SymbolInfo *s = temp->LookUp(name);
            if (s != NULL)
            {
                return s;
            }
            temp = temp->getParentScope();
        }
        return NULL;
    }
    void printCurrScope()
    {
        if (curr != NULL)
            curr->print();
    }
    void printAllScope()
    {
        ScopeTable *temp = curr;
        while (temp != NULL)
        {
            temp->print();
            temp = temp->getParentScope();
        }
    }
    
};
