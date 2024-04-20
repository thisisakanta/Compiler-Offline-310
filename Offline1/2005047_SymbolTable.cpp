#include <iostream>
#include <string>
#include "2005047_ScopeTable.cpp"
using namespace std;

class SymbolTable
{

private:
    ScopeTable *curr;
    int scopeTableSize = 0;

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
        cout << "\tScopeTable# " << curr->getid() << " created" << endl;
    }
    void exitScope()
    {
        if (curr->getParentScope() == NULL)
        {
            cout << "\tScopeTable# 1 cannot be deleted" << endl;
        }
        else
        {
            cout << "\tScopeTable# " << curr->getid() << " deleted" << endl;
            ScopeTable *temp=curr;
            curr = curr->getParentScope();
            delete temp;
        }
    }
    bool insert(string type, string name)
    {
        if (curr->Insert(type, name))
        {
            cout << " of ScopeTable# " << curr->getid() << endl;
        }
        else
        {
            cout << "\t'" << name << "'"
                 << " already exists in the current ScopeTable# " << curr->getid() << endl;
        }
    }
    bool remove(string name)
    {
        if (curr->Delete(name))
        {
            cout << " of ScopeTable# " << curr->getid() << endl;
            return true;
        }
        else
        {
            cout << "\tNot found in the current ScopeTable# " << curr->getid() << endl;
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
                cout << " of ScopeTable# " << temp->getid() << endl;
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
