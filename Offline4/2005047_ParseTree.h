#include <iostream>
#include <string>
#include<vector>

#include "2005047_DeclarationPart.h"

using namespace std;
class parseTreeNode{

    int firstLine;
    int lastLine;
    string dataType;
    string rule;
    parseTreeNode **children;
    varDeclare **symbol;//for storing variableNodeS;
    int symbolinfo=0;
    int childrenSize=0;
    
public:
        string funcName;
        bool globalFlag;
        int stackSize;
        bool isCond=false;
        bool assign=false;
        int symbolSize=0;
        string truelabel="";
        string falselabel="";
        string labelEnd="";
        string nextlabel="";
        SymbolInfo *symbolin=NULL;
        vector<SymbolInfo*> temporary;
        parseTreeNode()
        {
            this->firstLine=-1;
            this->lastLine=-1;
            dataType="";
            rule="";
            children=NULL;
            symbol=NULL;
            childrenSize=0;

            symbolinfo=NULL;
           // globalFlag=false; 

        }
        int getFirstLine()
        {
            return this->firstLine;
        }
        int getLastLine()
        {
            return this->lastLine;
        }
        int getsymbolinfo(){return symbolinfo;}
        void setsymbolinfo(){this->symbolinfo=1;}
        string getDataType()
        {
            return this->dataType;
        }
     
        parseTreeNode  **getChildren()
        {
            return this->children;
        }
        void setFirstLine(int firstLine)
        {
            this->firstLine=firstLine;
        }
        void setLasttLine(int lastLine)
        {
            this->lastLine=lastLine;
        }
        void setRule(string rule)
        {
            this->rule=rule;
        }
        string getRule(){
            return this->rule;
        }
        void setDataType(string type)
        {
            this->dataType=type;
        }
        void setChildren(parseTreeNode **children,int childrenSize)
        {
            this->children=children;
            this->childrenSize=childrenSize;
        }

        
        
        void addChildren(parseTreeNode *child)
        {
            parseTreeNode **temp;
            temp = new parseTreeNode *[this->childrenSize+3];
            if(this->childrenSize){
            for (int i = 0; i < this->childrenSize; i++)
                {
                    temp[i]=this->children[i];
                }
            }
            temp[childrenSize]=child;
            this->childrenSize++;
            
            //deleteChildParseTree();
            //children=new parseTreeNode*[this->childrenSize+2]
            this->children=temp;
            
        }
        int getChildrenSize()
        {
            return this->childrenSize;
        }
       //ICG
       void setSymbol(varDeclare **s){
            //symbol=new varDeclare*();
                symbol=s;
       }
       varDeclare **getSymbol(){
            return symbol;
       }
       

};