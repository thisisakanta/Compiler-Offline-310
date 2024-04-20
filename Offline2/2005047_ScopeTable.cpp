#include <iostream>
#include <string>
#include "2005047_SymbolInfo.cpp"
using namespace std;

class ScopeTable
{
private:
    SymbolInfo **hashtable;
    ScopeTable *parentScope;
    string id;
    int tablesize;
    int preScopeCount = 0;
   


public:
    ScopeTable(int n)
    {
        hashtable = new SymbolInfo *[n];
        this->tablesize = n;
        for (int i = 0; i < n; i++)
        {
            hashtable[i] = NULL;
        }
        id = "1";
        parentScope = NULL;
    }
    ~ScopeTable()
    {

        for (int i = 0; i < tablesize; i++)
        {
            if (hashtable[i] != NULL)
            {
                SymbolInfo *temp = hashtable[i];
                while (temp != NULL)
                {
                    SymbolInfo *next = temp;
                    temp = temp->getNextPointer();
                    delete next;
                }
            }
        }
        delete[] hashtable;
    }
    ScopeTable *getParentScope() { return parentScope; }
    void setParentScope(ScopeTable *s)
    {
        this->parentScope = s;
        parentScope->preScopeCount++;
        this->id = s->getid() + "." + to_string(s->preScopeCount);
    }
    string getid() { return id; }
    bool Insert(string type, string name)
    {
        int index = hashValue(name);

        if (hashtable[index] == NULL)
        {
            hashtable[index] = new SymbolInfo(type, name);
            return true;
        }
        SymbolInfo *curr = hashtable[index];
        SymbolInfo *prev = NULL;
        int count = 0;
        while (curr != NULL)
        {

            if (curr->getSymbolName() == name)
            {
                return false;
            }
            prev = curr;
            curr = curr->getNextPointer();
            count++;
        }
        prev->setNextPointer(new SymbolInfo(type, name));
        return true;
    }
    SymbolInfo *LookUp(string name)
    {
        int index = hashValue(name);
        SymbolInfo *curr = hashtable[index];
        int count = 0;
        while (curr != NULL)
        {
            count++;
            if (curr->getSymbolName() == name)
            {
                return curr;
            }
            curr = curr->getNextPointer();
        }
        return NULL;
    }
    int getpreScopeCount() { return preScopeCount; }
    bool Delete(string name)
    {
        int index = hashValue(name);
        int count = 0;
        SymbolInfo *curr = hashtable[index];
        SymbolInfo *prev = NULL;
        while (curr != NULL)
        {
            count++;
            if (curr->getSymbolName() == name)
            {
                if (prev == NULL)
                {
                    hashtable[index] = curr->getNextPointer(); // for the first element deletion
                }
                else
                {
                    prev->setNextPointer(curr->getNextPointer());
                }
                delete curr;
                return true;
            }
            prev = curr;
            curr = curr->getNextPointer();
        }
        return false;
    }
    void print()
    {
        cout << "\tScopeTable# " << this->id << endl;
        for (int i = 0; i < this->tablesize; i++)
        {
            SymbolInfo *curr = hashtable[i];

            cout << "\t" << i + 1;
            while (curr != NULL)
            {
                cout << " --> (" << curr->getSymbolName() << "," << curr->getSymbolType() << ")";
                curr = curr->getNextPointer();
            }
            cout << endl;
        }
    }

    int hashValue(string key)
    {
        int index = sdbhash(key) % this->tablesize;
        // cout << index << endl;
        return index;
    }
    unsigned long long sdbhash(string s)
    {
        unsigned long long hash = 0;
        // cout << s << endl;
        for (int i = 0; i < s.length(); i++)
        {
            hash = s[i] + (hash << 6) + (hash << 16) - hash;
        }
        // cout << hash << endl;
        return hash;
    }
};
