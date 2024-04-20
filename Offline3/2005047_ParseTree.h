#include <iostream>
#include <string>

using namespace std;

class parseTreeNode{

    int firstLine;
    int lastLine;
    string dataType;
    string rule;
    parseTreeNode **children;
    int symbolinfo=0;
    int childrenSize=0;
public:
        parseTreeNode()
        {
            this->firstLine=-1;
            this->lastLine=-1;
            dataType="";
            rule="";
            children=NULL;
            childrenSize=0; 

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
        string getRule()
        {
            return this->rule;
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
       

};