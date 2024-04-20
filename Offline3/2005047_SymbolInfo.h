#include <iostream>
#include <string>
using namespace std;
class Varinfo{

    int arraysize=0;
    string dataType="";
    public: 
            Varinfo(string dataType,int arraySize=-1)
            {
                this->arraysize=arraysize;
              //  cout<<this->arraysize<<"arrayset"<<endl;
                this->dataType=dataType;
            }
            void setArraySize(int arraysize)
            {
                this->arraysize=arraysize;
                //cout<<this->arraysize<<"set"<<endl;
            } 
            void setDataType(string dataType)
            {
                this->dataType=dataType;
            }
            int getArraySize()
            {
                //cout<<this->arraysize;
                return this->arraysize;
            }
            string getDataType()
            {
                return this->dataType;
            }
};
class FunInfo{
    string returnType="";
    string **parameters=NULL;
    int numDataParam=0;
    int infoType=-1;
   public:

         FunInfo(string returnType,int infoType){
                
                this->returnType=returnType;
                this->infoType=infoType;
                parameters = new string *[100];
        
                for (int i = 0; i < 5; i++)
                {
                    parameters[i] = NULL;
                } 
                this->numDataParam=0;     
        }
        void addParameter(string dataType,string paramName)
        {
            parameters[numDataParam][0]=dataType;
            parameters[numDataParam][1]=paramName;
            numDataParam++;
        }
        void setParameters(string **parameters,int size)
        {
            this->parameters=parameters;
            this->numDataParam=size;
        }
        string **getParameters()
        {
            return this->parameters;
        }
        void setReturnType(string dataType)
        {
            this->returnType=dataType;
        }
        string getReturnType()
        {
            return this->returnType;
        }
        int getInfoType()
        {
            return infoType;
        }
        void setInfoType(int infoType)
        {
            this->infoType=infoType;
        }
        int getParameterSize()
        {
            return this->numDataParam;
        }
        bool conflictCheck(FunInfo *func)
        {
            if(this->returnType!=func->getReturnType())
            {
                return false;
            }
            if(this->numDataParam!=func->getParameterSize())
            {
                return false;
            }
            string **temp=func->getParameters();
            for(int i=0;i<this->numDataParam;i++)
            {
                if(parameters[i][0]!=temp[i][0])
                {
                    return false;
                }


            }
            return true;



        }
        bool redefineCheck()
        {

           if(numDataParam){
            //cout<<"numdata"<<numDataParam<<endl;

                        for(int i=0;i<numDataParam-1;i++)
                         {
                            for(int j=i+1;j<numDataParam;j++){
                               // cout<<parameters[i][0]<<" "<< parameters[j][0]<<endl;
                                 if(parameters[i][1]==parameters[j][1]&&parameters[i][0]==parameters[j][0])
                                        {
                                                return true;
                                        }
                            }


                        }
           }
            return false;



        }

};

class SymbolInfo
{
private:
    string Name="";
    string Type="";
    SymbolInfo *next=NULL;
    Varinfo *variable=NULL;
    FunInfo *func=NULL;
    //variable declaration part(int a)



public:
    SymbolInfo(string Type, string Name)
    {
        this->Name = Name;
        this->Type = Type;
        this->next = NULL;
        this->variable=NULL;
        this->func=NULL;
    }
    // SymbolInfo(const SymbolInfo &s)
    // {
    //     this->Name = s.Name;
    //     this->Type = s.Type;
    //     this->next = s.next;
    //     this->variable=s.variable;
    //     this->func=s.func;
    // }
    string getSymbolName() { return this->Name; }
    string getSymbolType() { return this->Type; }
    SymbolInfo *getNextPointer() { return next; }
    void setNextPointer(SymbolInfo *next) { this->next = next; }
    void setSymbolName(string Name) { this->Name = Name; }
    void setSymbolType(string Type) { this->Type = Type; }
    void setVarInfo(Varinfo *variable){this->variable=variable;
                                       }
    void setFuncInfo(FunInfo *func){this->func=func;}
    Varinfo *getVarInfo(){return variable;}
    FunInfo *getFuncInfo(){return func;}

    
};
