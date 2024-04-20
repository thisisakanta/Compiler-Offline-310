#include <iostream>
#include <string>
#include "2005047_ParseTree.h"
//#include "2005047_SymbolInfo.h"

using namespace std;
class varDeclare{
    SymbolInfo *symbol=NULL;
    int arraySize=-1;
   parseTreeNode *node=NULL;
public:
        varDeclare()
        {
            symbol=NULL;
            node=NULL;
        }
        // varDeclare(const varDeclare &v)
        // {   
        //     this->symbol=v.symbol;
        //     this->node=v.node;
        // }
        void setSymbol(SymbolInfo *symbol)
        {
            this->symbol=symbol;
        }
        void setNode(parseTreeNode *node)
        {
            this->node=node;
        }
       SymbolInfo *getSymbol()
        {
            return symbol;
        }
       parseTreeNode *getNode()
        {
            return node;
        }
        void setArraySize(int size)
        {
            this->arraySize=size;
        }
        int getArraySize()
        {
            return arraySize;
        }

};