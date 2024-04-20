#include <iostream>
#include <string>
//#include "2005047_ParseTree.h"
#include "2005047_SymbolTable.h"

using namespace std;
class varDeclare{
    SymbolInfo *symbol=NULL;
    int arraySize=-1;
  // parseTreeNode *node=NULL;
   
public:
        int stackSize=0;
        bool globalFlag=false;//ICG
        varDeclare()
        {
            symbol=NULL;
            //node=NULL;
            globalFlag=false;
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
      SymbolInfo *getSymbol()
        {
            return symbol;
        }
     
        void setArraySize(int size)
        {
            this->arraySize=size;
        }
        int getArraySize()
        {
            return arraySize;
        }

         int getStackSize(){
            return stackSize;
    }
        void setStackSize(int n){
            this->stackSize=n;
    }

};