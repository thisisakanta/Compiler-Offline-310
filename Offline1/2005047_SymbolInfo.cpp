#include <iostream>
#include <string>
using namespace std;
class SymbolInfo
{
private:
    string Name;
    string Type;
    SymbolInfo *next;

public:
    SymbolInfo(string Type, string Name)
    {
        this->Name = Name;
        this->Type = Type;
        this->next = NULL;
    }
    SymbolInfo(SymbolInfo &s)
    {
        this->Name = s.Name;
        this->Type = s.Type;
        this->next = s.next;
    }
    string getSymbolName() { return this->Name; }
    string getSymbolType() { return this->Type; }
    SymbolInfo *getNextPointer() { return next; }
    void setNextPointer(SymbolInfo *next) { this->next = next; }
    void setSymbolName(string Name) { this->Name = Name; }
    void setSymbolType(string Type) { this->Type = Type; }
};