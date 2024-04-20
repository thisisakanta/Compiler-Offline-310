#include <iostream>
#include <string>
#include "2005047_SymbolInfo.h"
using namespace std;

class ScopeTable
{
private:
    SymbolInfo **hashtable;
    ScopeTable *parentScope;
    string id;
    int tablesize;
    int preScopeCount = 0;
    int scopeResult=0;
   


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
        this->id = to_string((s->preScopeCount)+1);
    }
    string getid() { return id; }
    //Insert a symbolInfo;
    bool Insert(SymbolInfo *symbolinfo)
    {
        int index = hashValue(symbolinfo->getSymbolName());
        
        SymbolInfo *symbol=new SymbolInfo(symbolinfo->getSymbolType(),symbolinfo->getSymbolName());
         //cout<<symbolinfo->getSymbolType()<<endl;
         
        
        if(symbolinfo->getSymbolType()=="VAR")
        {
           
            
            
            //cout<<(symbolinfo->getVarInfo())->getArraySize()<<"scopetable"<<endl;
            Varinfo *varinfo=new Varinfo((symbolinfo->getVarInfo())->getDataType(),(symbolinfo->getVarInfo())->getArraySize());
            varinfo->setArraySize((symbolinfo->getVarInfo())->getArraySize());
            symbol->setVarInfo(varinfo);
            
           
        }
        else if((symbolinfo->getFuncInfo())->getInfoType()!=-1)
        {
            FunInfo *func=new FunInfo((symbolinfo->getFuncInfo())->getReturnType(),(symbolinfo->getFuncInfo())->getInfoType());
			func->setParameters((symbolinfo->getFuncInfo())->getParameters(),(symbolinfo->getFuncInfo())->getParameterSize());
			symbol->setFuncInfo(func);
        }



        if (hashtable[index] == NULL)
        {
            hashtable[index] = symbol;
            return true;
        }
        SymbolInfo *curr = hashtable[index];
        SymbolInfo *prev = NULL;
        int count = 0;
        while (curr != NULL)
        {

            if (curr->getSymbolName() ==symbolinfo->getSymbolName() )
            {
                return false;
            }
            prev = curr;
            curr = curr->getNextPointer();
            count++;
        }
        prev->setNextPointer(symbol);
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
            int newLineset=0;
            SymbolInfo *curr = hashtable[i];
            
            if(curr!=NULL){

            cout << "\t" << i + 1<<"-->";
            newLineset=1;
            
            }
            while (curr != NULL)
            {
                if(curr->getSymbolType()=="VAR")
                {
                    if(curr->getVarInfo()!=NULL)
                    {
                        if((curr->getVarInfo())->getArraySize()>0)
                            {
                                 cout << " <" << curr->getSymbolName() << "," << "ARRAY" << ">";
                            }
                        else
                            {
                                cout << " <" << curr->getSymbolName() << "," << (curr->getVarInfo())->getDataType() << ">";

                            }
                    }
                    
                }
                else if((curr->getFuncInfo())->getInfoType()!=-1)
                {
                    cout << " <" << curr->getSymbolName() << "," << curr->getSymbolType() <<","<<(curr->getFuncInfo())->getReturnType()<< ">";
                    
                }
                
                curr = curr->getNextPointer();
            }
            if(newLineset)
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
