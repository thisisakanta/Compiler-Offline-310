%{
#include<iostream>
#include<fstream>
#include<cstdlib>
#include<cstring>
#include<cmath>
//#include"dbg.h"



#include "2005047_SymbolTable.h"
#include "2005047_DeclarationPart.h"
using namespace std;
ofstream parseOut("parsetree.txt");
ofstream errorFile("error.txt");


int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int yylineno;
bool zeroFound=false;
int errorCount=0;



SymbolTable *table=new SymbolTable(11);
varDeclare **vardeclarelist=NULL;
int vardeclarelistSize=0;
string **funParmas=NULL;

int funParmasSize=0;
string *funArg=NULL;
int funArgSize=0;
bool flag=false;
void yyerror(char *s)
{
	errorCount++;
	errorFile << "Line# " << yylineno << ": " <<s<<" ";
	cout<<"Error at Line# "<<yylineno<<": "<<s<<endl;
}




 void printParseTree(parseTreeNode *root,int height)
{
	if(root==NULL)
	{
		return;
	}
	for(int i=0;i<height-1;i++)
	{
		parseOut<<" ";
	}
	if(root->getsymbolinfo()){parseOut<<root->getRule()<<" \t<Line: "<<root->getFirstLine()<<">\n";}
	else {parseOut<<root->getRule()<<" \t<Line: "<<root->getFirstLine()<<"-"<<root->getLastLine()<<">\n";}
	parseTreeNode **child=root->getChildren();
	for(int i=0;i<root->getChildrenSize();i++)
	{
		printParseTree(child[i],height+1);

	}
}
	void error_redeclare_different_type(int lineno,string id)
	{
		errorFile << "Line# " << lineno << ": " << "'" << id << "' redeclared as different kind of symbol\n";
		errorCount++;
	}
	void error_conflicting_type(int lineno,string id)
	{
		errorFile << "Line# " << lineno << ": " << "Conflicting types for '" << id << "'\n";
		errorCount++;
	}
	void error_multiple_definition(int lineno,string id)
	{
		errorFile << "Line# " << lineno << ": " << "Multiple definition of '" << id<< "'\n";
		errorCount++;
	}
	void error_void_variable(int lineno,string id)
	{
		errorFile << "Line# " << lineno << ": " << "Variable or field '" << id << "' declared void\n";
		errorCount++;
	}
	void error_undeclared_variable(int lineno,string id)
	{
		errorFile << "Line# " << lineno << ": " << "Undeclared variable '" << id<< "'\n";
		errorCount++;
	}
	void error_not_array_type(int lineno,string id)
	{
		errorFile << "Line# " << lineno << ": " << "'" << id << "' is not an array\n";
		errorCount++;
	}
	void error_index_not_integer(int lineno)
	{
		errorFile << "Line# " << lineno << ": " << "Array subscript is not an integer\n";
		errorCount++;
	}
	void error_data_loss(int lineno)
	{
		errorFile << "Line# " << lineno << ": " << "Warning: possible loss of data in assignment of "<<"FLOAT"<<" to "<<"INT"<<"\n";
		errorCount++;
	}
	void error_mod_not_integer(int lineno)
	{
		errorFile << "Line# " << lineno << ": " << "Operands of modulus must be integers\n";
		errorCount++;
	}
	void error_undeclared_function(int lineno,string funcName)
	{
		errorFile << "Line# " << lineno << ": " << "Undeclared function '" << funcName << "'\n";
		errorCount++;
	}
	void error_div_by_zero(int lineno)
	{
		errorFile << "Line# " << lineno << ": " << "Warning: division by zero\n";
		errorCount++;
	}

	void error_argument_type_mismatch(int lineno, int argno, string funcName)
	{
		errorFile << "Line# " << lineno << ": Type mismatch for argument " << argno << " of '" << funcName << "'\n";
		errorCount++; 
	}

	void error_too_few_arguments(int lineno, string funcName)
	{
		errorFile << "Line# " << lineno << ": Too few arguments to function '" << funcName << "'\n";
		errorCount++;
	}

	void error_too_many_arguments(int lineno, string funcName)
	{
		errorFile << "Line# " << lineno << ": Too many arguments to function '" << funcName << "'\n";
		errorCount++;
	}
	void errror_redefine_parameter(int lineno, string funcName)
	{
		errorFile << "Line# " << lineno << ": Redefinition of parameter '" << funcName << "'\n";
		errorCount++;
	}

	void error_custom(int lineno,string errorMessage)
	{
		errorFile << "Line# " << lineno << ": " << errorMessage << "\n";
		errorCount++;
	}
void funArgCheck(FunInfo *func,int lineno,string funcName){
	
	int numDataParam=func->getParameterSize();
	if(numDataParam){
		string **parameters=func->getParameters();
	 	for(int i=0;i<numDataParam-1;i++)
        {
             for(int j=i+1;j<numDataParam;j++){
                               // cout<<parameters[i][0]<<" "<< parameters[j][0]<<endl;
                if(parameters[i][1]==parameters[j][1]&&parameters[i][0]==parameters[j][0])
                    {
						errror_redefine_parameter(lineno,parameters[i][1]);
                       
                    }
				else if(parameters[i][0]!=parameters[j][0]&&parameters[i][1]==parameters[j][1])
				{
					error_conflicting_type(lineno,parameters[i][1]);
				}
            }


        }

	}
}


%}
%union{

SymbolInfo* symbolInfo;
parseTreeNode* parsetreeNode;
	
}

%locations


%token IF FOR RPAREN ELSE RETURN WHILE INT FLOAT VOID LPAREN LCURL RCURL LTHIRD RTHIRD SEMICOLON COMMA PRINTLN
 
%type<parsetreeNode> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments 
%token<symbolInfo> ID CONST_INT CONST_FLOAT

%left <symbolInfo> LOGICOP RELOP ADDOP MULOP
%right  ASSIGNOP NOT INCOP DECOP


 
 
%nonassoc LOWER_THAN_ELSE 
%nonassoc ELSE


%%

 start : program
	{
		//write your code in this block in all the similar blocks below
		$$=new parseTreeNode();$$->setFirstLine(@$.first_line);$$->setLasttLine(@$.last_line);$$->setRule("start : program");
		$$->addChildren($1);
		printParseTree($$,1);
		//table->printAllScope();
		cout<<"start : program"<<endl;
		cout<<"Total Lines: "<<@$.last_line<<endl;
		cout<<"Total Errors: "<<errorCount<<endl;

	}
	;

program : program unit 
		{
			$$=new parseTreeNode();$$->setFirstLine(@$.first_line);$$->setLasttLine(@$.last_line);$$->setRule("program : program unit");
			$$->addChildren($1);
			$$->addChildren($2);
			cout<<"program: program unit"<<endl;
		}
	| unit
	{
		$$=new parseTreeNode();$$->setFirstLine(@$.first_line);$$->setLasttLine(@$.last_line);$$->setRule("program : unit");
		$$->addChildren($1);
		cout<<"program: unit"<<endl;
	}
	;
	
unit : var_declaration
	{
		$$=new parseTreeNode();
		$$->setFirstLine(@$.first_line);
		$$->setLasttLine(@$.last_line);
		$$->setRule("unit : var_declaration");
		$$->addChildren($1);
		cout<<"unit : var_declaration"<<endl;

	}
     | func_declaration
	 {
		$$=new parseTreeNode();
		$$->setFirstLine(@$.first_line);
		$$->setLasttLine(@$.last_line);
		$$->setRule("unit : func_declaration");
		$$->addChildren($1);
		cout<<"unit : func_declaration"<<endl;

	 }
     | func_definition
	 {
		$$=new parseTreeNode();
		$$->setFirstLine(@$.first_line);
		$$->setLasttLine(@$.last_line);
		$$->setRule("unit : func_definition");
		$$->addChildren($1);
		cout<<"unit : func_definition"<<endl;

	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
				{		//id parseTree
						parseTreeNode* id=new parseTreeNode();
						id->setFirstLine(@2.first_line);
						id->setLasttLine(@2.last_line);
						id->setRule("ID : "+ $2->getSymbolName());
						id->setsymbolinfo();
						//lparen parseTree
						parseTreeNode* lparen=new parseTreeNode();
						lparen->setFirstLine(@3.first_line);
						lparen->setLasttLine(@3.last_line);
						lparen->setRule("LPAREN : (");
						lparen->setsymbolinfo();
						//rparen parenParseTree
						parseTreeNode* rparen=new parseTreeNode();
						rparen->setFirstLine(@5.first_line);
						rparen->setLasttLine(@5.last_line);
						rparen->setRule("RPAREN : )");
						rparen->setsymbolinfo();
						//semicolon parseTree
						parseTreeNode* semicolon=new parseTreeNode();
						semicolon->setFirstLine(@6.first_line);
						semicolon->setLasttLine(@6.last_line);
						semicolon->setRule("SEMICOLON : ;");
						semicolon->setsymbolinfo();


						$$=new parseTreeNode();
						$$->setFirstLine(@$.first_line);
						$$->setLasttLine(@$.last_line);
						$$->setRule("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
						
						//$$->addChildren($1);
						//childrenadd
						$$->addChildren($1);
						$$->addChildren(id);
						$$->addChildren(lparen);
						$$->addChildren($4);
						$$->addChildren(rparen);
						$$->addChildren(semicolon);
						cout<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"<<endl;

					if(flag)
						{
							errorFile<<"parameter list of function declaration"<<endl;
						}
					

					else{

					if(funParmasSize){
					string **temp=funParmas;
					FunInfo *func=new FunInfo($1->getDataType(),1);//1 for FUNTION DECLARATION
					//cout<<"function argument "<<funParmasSize<<endl;
					func->setParameters(temp,funParmasSize);
					func->setReturnType($1->getDataType());
					
					SymbolInfo *symbol=table->lookup($2->getSymbolName());
					if(symbol==NULL)
					{
						//cout<<$2->getSymbolName()<<endl;
						SymbolInfo *symbolinfo=new SymbolInfo("FUNCTION",$2->getSymbolName());
						symbolinfo->setFuncInfo(func);
						table->insert(symbolinfo);
						// if((func->funArgCheck()))
						// {
						// 	errror_redefine_parameter(@2.first_line,$2->getSymbolName());
						// }
						funArgCheck(func,@2.first_line,$2->getSymbolName());
						funParmasSize=0;
						break;
					}
					 
					
					
					
					else if(symbol->getSymbolType()=="VAR")
					{
						error_redeclare_different_type(@2.first_line,$2->getSymbolName());

					}
					else if(((symbol->getFuncInfo())->getInfoType())==1&&!(func->conflictCheck(symbol->getFuncInfo())))
					{
						error_conflicting_type(@2.first_line,$2->getSymbolName());
					}
					

					if(((symbol->getFuncInfo())->getInfoType())==1&&(func->redefineCheck()))
					{
						funArgCheck(func,@2.first_line,$2->getSymbolName());
					}

					}
					}
			
						funParmasSize=0;
						flag=false;
						//cout<<funParmasSize<<"after"<<endl;
					// for(int i=0;i<funParmasSize;i++){
					// 	delete funParmas[i];
					// }
					// delete funParmas;
					


				}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		{

			parseTreeNode* id=new parseTreeNode();
			id->setFirstLine(@2.first_line);
			id->setLasttLine(@2.last_line);
			id->setRule("ID : "+ $2->getSymbolName());
			id->setsymbolinfo();
						//lparen parseTree
			parseTreeNode* lparen=new parseTreeNode();
			lparen->setFirstLine(@3.first_line);
			lparen->setLasttLine(@3.last_line);
			lparen->setRule("LPAREN : (");
			lparen->setsymbolinfo();
						//rparen parenParseTree
			parseTreeNode* rparen=new parseTreeNode();
			rparen->setFirstLine(@4.first_line);
			rparen->setLasttLine(@4.last_line);
			rparen->setRule("RPAREN : )");
			rparen->setsymbolinfo();		
						//semicolon parseTree
			parseTreeNode* semicolon=new parseTreeNode();
			semicolon->setFirstLine(@5.first_line);
			semicolon->setLasttLine(@5.last_line);
			semicolon->setRule("SEMICOLON : ;");
			semicolon->setsymbolinfo();
						//childrenadd
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("func_definition : type_specifier ID LPAREN RPAREN SEMICOLON");
						
			$$->addChildren($1);
			$$->addChildren(id);
			$$->addChildren(lparen);
			$$->addChildren(rparen);
			$$->addChildren(semicolon);

			cout<<"func_definition : type_specifier ID LPAREN RPAREN SEMICOLON"<<endl;

			//string **temp=funParmas;
			FunInfo *func=new FunInfo($1->getDataType(),1);//1 for FUNTION DECLARATION
			//func->setParameters(temp,funParmasSize);
			func->setReturnType($1->getDataType());
			SymbolInfo *symbol=table->lookup($2->getSymbolName());
			if(symbol==NULL)
			{
				SymbolInfo *symbolinfo=new SymbolInfo("FUNCTION",$2->getSymbolName());
				symbolinfo->setFuncInfo(func);
				table->insert(symbolinfo);
			}
			else if(symbol->getSymbolType()=="VAR")
				{
					error_redeclare_different_type(@2.first_line,$2->getSymbolName());

				}
				else if(((symbol->getFuncInfo())->getInfoType())==1&&!(func->conflictCheck(symbol->getFuncInfo())))
					{
						error_conflicting_type(@2.first_line,$2->getSymbolName());
					}
				else if(((symbol->getFuncInfo())->getInfoType())==1&&(func->redefineCheck()))
				{
					funArgCheck(func,@2.first_line,$2->getSymbolName());
				}
				funParmasSize=0;
				//cout<<funParmasSize<<"after"<<endl;
			
			
			



		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
				{
					parseTreeNode* id=new parseTreeNode();
					id->setFirstLine(@2.first_line);
					id->setLasttLine(@2.last_line);
					id->setRule("ID : "+ $2->getSymbolName());
					id->setsymbolinfo();
						//lparen parseTree
					parseTreeNode* lparen=new parseTreeNode();
					lparen->setFirstLine(@3.first_line);
					lparen->setLasttLine(@3.last_line);
					lparen->setRule("LPAREN : (");
					lparen->setsymbolinfo();
						//rparen parenParseTree
					parseTreeNode* rparen=new parseTreeNode();
					rparen->setFirstLine(@5.first_line);
					rparen->setLasttLine(@5.last_line);
					rparen->setRule("RPAREN : )");
					rparen->setsymbolinfo();

					$$=new parseTreeNode();
					$$->setFirstLine(@$.first_line);
					$$->setLasttLine(@$.last_line);
					$$->setRule("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
						
					//childrenadd	
					$$->addChildren($1);
					$$->addChildren(id);
					$$->addChildren(lparen);
					$$->addChildren($4);
					$$->addChildren(rparen);
					$$->addChildren($6);
					if(flag)
					{
						errorFile<<"parameter list of function definition"<<endl;
		
					}
					
					
					
					
					//cout<<"yes from bahire"<<endl;
				//cout<<funParmasSize<<" size of argument"<<endl;
				if(funParmasSize){
					string **temp=funParmas;
					FunInfo *func=new FunInfo($1->getDataType(),0);
					//cout<<"function argument "<<funParmasSize<<endl;//0 for FUNTION DEFINITION
					func->setParameters(temp,funParmasSize);
					func->setReturnType($1->getDataType());
					SymbolInfo *symbol=table->lookup($2->getSymbolName());
					//cout<<"yes from bahire"<<endl;
					if(symbol==NULL)
					{
						//cout<<"yes from null"<<endl;
						SymbolInfo *symbolinfo=new SymbolInfo("FUNCTION",$2->getSymbolName());
						symbolinfo->setFuncInfo(func);
						if(!flag){
						table->insert(symbolinfo);
						// if((func->funArgCheck()))
						// {
						// 	errror_redefine_parameter(@2.first_line,$2->getSymbolName());
						// }
						funArgCheck(func,@2.first_line,$2->getSymbolName());
						}
					}
					else if(symbol->getSymbolType()=="VAR")
					{
						error_redeclare_different_type(@2.first_line,$2->getSymbolName());

					}
					else if((symbol->getFuncInfo())->getInfoType()==0)
					{
						error_multiple_definition(@2.first_line,$2->getSymbolName());
					}
					else if(((symbol->getFuncInfo())->getInfoType())==1 && !(func->conflictCheck(symbol->getFuncInfo())))
					{
						//cout<<"yes from definition"<<endl;
						error_conflicting_type(@2.first_line,$2->getSymbolName());
					}

				
			}
				if(!flag)
				{
					cout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"<<endl;
				}
				funParmasSize=0;
				flag=false;
					// for(int i=0;i<funParmasSize;i++){
					// 	delete funParmas[i];
					// }
					// delete funParmas;
					


				}
		| type_specifier ID LPAREN RPAREN compound_statement
		{
					parseTreeNode* id=new parseTreeNode();
					id->setFirstLine(@2.first_line);
					id->setLasttLine(@2.last_line);
					id->setRule("ID : "+ $2->getSymbolName());
					id->setsymbolinfo();
						//lparen parseTree
					parseTreeNode* lparen=new parseTreeNode();
					lparen->setFirstLine(@3.first_line);
					lparen->setLasttLine(@3.last_line);
					lparen->setRule("LPAREN : (");
					lparen->setsymbolinfo();
						//rparen parenParseTree
					parseTreeNode* rparen=new parseTreeNode();
					rparen->setFirstLine(@4.first_line);
					rparen->setLasttLine(@4.last_line);
					rparen->setRule("RPAREN : )");
					rparen->setsymbolinfo();

					$$=new parseTreeNode();
					$$->setFirstLine(@$.first_line);
					$$->setLasttLine(@$.last_line);
					$$->setRule("func_definition : type_specifier ID LPAREN RPAREN compound_statement");
					cout<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl;
						
					//childrenadd	
					$$->addChildren($1);
					$$->addChildren(id);
					$$->addChildren(lparen);
					$$->addChildren(rparen);
					$$->addChildren($5);

					//string **temp=funParmas;
					FunInfo *func=new FunInfo($1->getDataType(),0);//1 for FUNTION DECLARATION
					func->setParameters(NULL,0);
					func->setReturnType($1->getDataType());
					SymbolInfo *symbol=table->lookup($2->getSymbolName());
					if(symbol==NULL)
					{
						SymbolInfo *symbolinfo=new SymbolInfo("FUNCTION",$2->getSymbolName());
						symbolinfo->setFuncInfo(func);
						table->insert(symbolinfo);
					}
					else if(symbol->getSymbolType()=="VAR")
					{
						error_redeclare_different_type(@2.first_line,$2->getSymbolName());

					}
					else if((symbol->getFuncInfo())->getInfoType()==0)
					{
						error_multiple_definition(@2.first_line,$2->getSymbolName());
					}
					else if(((symbol->getFuncInfo())->getInfoType())==1&&!(func->conflictCheck(symbol->getFuncInfo())))
					{
						error_conflicting_type(@2.first_line,$2->getSymbolName());
					}
					funParmasSize=0;

		}
 		;				


parameter_list : parameter_list COMMA type_specifier ID
				{
					
						//lparen parseTree
					parseTreeNode* comma=new parseTreeNode();
					comma->setFirstLine(@2.first_line);
					comma->setLasttLine(@2.last_line);
					comma->setRule("COMMA : ,");
					comma->setsymbolinfo();
						//rparen parenParseTree
					parseTreeNode* id=new parseTreeNode();
					id->setFirstLine(@4.first_line);
					id->setLasttLine(@4.last_line);
					id->setRule("ID : "+$4->getSymbolName());
					id->setsymbolinfo();

					$$=new parseTreeNode();
					$$->setFirstLine(@$.first_line);
					$$->setLasttLine(@$.last_line);
					$$->setRule("parameter_list : parameter_list COMMA type_specifier ID");

					$$->addChildren($1);
					$$->addChildren(comma);
					$$->addChildren($3);
					$$->addChildren(id);
					cout<<"parameter_list : parameter_list COMMA type_specifier ID"<<endl;

			if(!flag){
			string **temp;
			temp=new string*[funParmasSize+2];
			for (int i = 0; i < funParmasSize+2; i++) {
				temp[i]=new string[3];
			}
			if(funParmasSize){
				for(int i=0;i<funParmasSize;i++)
				{
				temp[i][0]=funParmas[i][0];
				temp[i][1]=funParmas[i][1];
				}
			}
			
			temp[funParmasSize][0]=$3->getDataType();
			temp[funParmasSize][1]=$4->getSymbolName();
			funParmasSize=funParmasSize+1;
			funParmas=temp;
			//cout<<funParmasSize<<" please"<<endl;
			}
		}
		| parameter_list COMMA type_specifier
		{
					parseTreeNode* comma=new parseTreeNode();
					comma->setFirstLine(@2.first_line);
					comma->setLasttLine(@2.last_line);
					comma->setRule("COMMA : ,");
					comma->setsymbolinfo();
						//rparen parenParseTree
					

					$$=new parseTreeNode();
					$$->setFirstLine(@$.first_line);
					$$->setLasttLine(@$.last_line);
					$$->setRule("parameter_list : parameter_list COMMA type_specifier");

					$$->addChildren($1);
					$$->addChildren(comma);
					$$->addChildren($3);

					cout<<"parameter_list : parameter_list COMMA type_specifier"<<endl;

			if(!flag){
			string **temp;
			temp=new string*[funParmasSize+2];
			for (int i = 0; i < funParmasSize+1; i++) {
				temp[i]=new string[3];
			}
			if(funParmasSize){
				
				for(int i=0;i<funParmasSize;i++)
				{
				temp[i][0]=funParmas[i][0];
				temp[i][1]=funParmas[i][1];
				}
			}
				
			temp[funParmasSize][0]=$3->getDataType();
			temp[funParmasSize][1]="";
			funParmasSize++;
			funParmas=temp;
			}
		}
 		| type_specifier ID
		{
				parseTreeNode* id=new parseTreeNode();
				id->setFirstLine(@2.first_line);
				id->setLasttLine(@2.last_line);
				id->setRule("ID : "+$2->getSymbolName());
				id->setsymbolinfo();

				$$=new parseTreeNode();
				$$->setFirstLine(@$.first_line);
				$$->setLasttLine(@$.last_line);
				$$->setRule("parameter_list : type_specifier ID");

				$$->addChildren($1);
				$$->addChildren(id);
				cout<<"parameter_list : type_specifier ID"<<endl;
			if(!flag){
			string **temp;
			temp=new string*[funParmasSize+2];
			for (int i = 0; i < funParmasSize+2; i++) {
				temp[i]=new string[3];
			}
			if(funParmasSize){
				for(int i=0;i<funParmasSize;i++)
				{
				temp[i][0]=funParmas[i][0];
				temp[i][1]=funParmas[i][1];
				}
			}
			temp[funParmasSize][0]=$1->getDataType();
			temp[funParmasSize][1]=$2->getSymbolName();
			
			funParmasSize++;
			funParmas=temp;
			}
					
		}
		| type_specifier
		{
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("parameter_list : type_specifier");

			$$->addChildren($1);
			cout<<"parameter_list : type_specifier"<<endl;
			if(!flag){
			string **temp;
			temp=new string*[funParmasSize+2];
			for (int i = 0; i < funParmasSize+1; i++) {
				temp[i]=new string[3];
			}
			if(funParmasSize){
				for(int i=0;i<funParmasSize;i++)
				{
				temp[i][0]=funParmas[i][0];
				temp[i][1]=funParmas[i][1];
				}
			}
			temp[funParmasSize][0]=$1->getDataType();
			temp[funParmasSize][1]="";
			funParmasSize++;
			funParmas=temp;
			}
		}
		|
		error
		{
			yyclearin;
			//errorFile<<"i am in now error";
			//yyerror(@$.first_line,"parameter list of function definition");
			flag=true;
			
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			//$$->setDataType($1->getDataType());
			$$->setRule("parameter_list : error");
			//errorFile<<"parameter list of function definition"<<endl;
		}
 		;

 		
compound_statement : 
			LCURL
				{
						table->enterScope();
						//cout<<"yes"<<endl;
						if(funParmasSize>0)
						{
							for(int i=0;i<funParmasSize;i++)
							{
								Varinfo *varinfo=new Varinfo(funParmas[i][0]);
								SymbolInfo *symbol=new SymbolInfo("VAR",funParmas[i][1]);
								symbol->setVarInfo(varinfo);
								ScopeTable *s=table->currentScope();
								SymbolInfo *temp=s->LookUp(symbol->getSymbolName());
								if(temp==NULL)
								{
									//cout<<"inserted"<<endl;
									table->insert(symbol);//variable insert in the symbolTable;
								}
							}
							
						}
						//cout<<"compound_statement : LCURL"<<endl;

				}
				 statements RCURL
				 {
					
						//lparen parseTree
					parseTreeNode* lcurl=new parseTreeNode();
					lcurl->setFirstLine(@1.first_line);
					lcurl->setLasttLine(@1.last_line);
					lcurl->setRule("LCURL : {");
					lcurl->setsymbolinfo();
						//rparen parenParseTree
					parseTreeNode* rcurl=new parseTreeNode();
					rcurl->setFirstLine(@4.first_line);
					rcurl->setLasttLine(@4.last_line);
					rcurl->setRule("RCURL : }");
					rcurl->setsymbolinfo();

					$$=new parseTreeNode();
					$$->setFirstLine(@$.first_line);
					$$->setLasttLine(@$.last_line);
					$$->setRule("compound_statement : LCURL statements RCURL");
						
					//childrenadd	
					$$->addChildren(lcurl);
					$$->addChildren($3);
					$$->addChildren(rcurl);
					
					
					cout<<"compound_statement : LCURL statements RCURL"<<endl;
					table->printAllScope();
					//funParmasSize=0;
					table->exitScope();
			}
					

 		    | LCURL RCURL
			{
					parseTreeNode* lcurl=new parseTreeNode();
					lcurl->setFirstLine(@1.first_line);
					lcurl->setLasttLine(@1.last_line);
					lcurl->setRule("LCURL : {");
					lcurl->setsymbolinfo();
						//rparen parenParseTree
					parseTreeNode* rcurl=new parseTreeNode();
					rcurl->setFirstLine(@2.first_line);
					rcurl->setLasttLine(@2.last_line);
					rcurl->setRule("RCURL : }");
					rcurl->setsymbolinfo();

					$$=new parseTreeNode();
					$$->setFirstLine(@$.first_line);
					$$->setLasttLine(@$.last_line);
					$$->setRule("compound_statement : LCURL RCURL");
						
					//childrenadd	
					$$->addChildren(lcurl);
					//$$->addChildren($2);
					$$->addChildren(rcurl);
					
					cout<<"compound_statement : LCURL RCURL"<<endl;
					table->enterScope();
					
					table->printAllScope();
					table->exitScope();
					//funParmasSize=0;
					//table->exitScope();


			}
			
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
				{
					parseTreeNode* semicolon=new parseTreeNode();
					semicolon->setFirstLine(@3.first_line);
					semicolon->setLasttLine(@3.last_line);
					semicolon->setRule("SEMICOLON : ;");
					semicolon->setsymbolinfo();
					$$=new parseTreeNode();
					$$->setFirstLine(@$.first_line);
					$$->setLasttLine(@$.last_line);
					$$->setRule("var_declaration : type_specifier declaration_list SEMICOLON");
						
					//childrenadd	
					$$->addChildren($1);

					$$->addChildren($2);
					$$->addChildren(semicolon);
					if(flag)
					{
						errorFile<<"declaration list of variable declaration"<<endl;
		
					}
					//errorFile<<vardeclarelistSize<<endl;

				//it is remaining as i have not yet figured it out how can i access it/
				if(vardeclarelistSize){
					
					for(int i=0;i<vardeclarelistSize;i++)
					{

						parseTreeNode* temp=new parseTreeNode();
						temp->setDataType($1->getDataType());
						vardeclarelist[i]->setNode(temp);
						
						//vardeclarelist[i].setNode(temp);
						
						// cout<<varinfo->getDataType()<<endl;
						// cout<<varinfo->getArraySize()<<endl;
						//cout<<endl;
						//scout<<(vardeclarelist[i]->getSymbol())->getSymbolName()<<endl;
						ScopeTable *s=table->currentScope();
						SymbolInfo *symbol=s->LookUp((vardeclarelist[i]->getSymbol())->getSymbolName());
						if(symbol!=NULL)
						{
							//cout<<symbol->getSymbolName()<<endl;
						}
						
						//SymbolInfo *symbol=table->lookup((vardeclarelist[i]->getSymbol())->getSymbolName());
						//cout<<(vardeclarelist[i]->getSymbol())->getSymbolName()<<endl;

						//Varinfo *tempVar=symbol->getVarInfo();
						if($1->getDataType()=="VOID")
						{
							error_void_variable(@$.first_line, (vardeclarelist[i]->getSymbol())->getSymbolName());

						}
						
						else if(symbol==NULL)
						{
							Varinfo *varinfo=new Varinfo($1->getDataType(),vardeclarelist[i]->getArraySize());
							varinfo->setArraySize(vardeclarelist[i]->getArraySize());
							//cout<<$1->getDataType()<<" ahon"<<endl;
							SymbolInfo *temp2=new SymbolInfo((vardeclarelist[i]->getSymbol())->getSymbolType(),(vardeclarelist[i]->getSymbol())->getSymbolName());
							
							temp2->setSymbolType("VAR");
							temp2->setSymbolName((vardeclarelist[i]->getSymbol())->getSymbolName());
							// if(varinfo!=NULL)
							// {
							// 	cout<<"varinfo is not null"<<endl;
							// }
							
							temp2->setVarInfo(varinfo);
							
							// cout<<(temp2->getSymbolName())<<endl;
							// cout<<"yes"<<endl;
							//cout<<(temp2->getVarInfo())->getDataType()<<endl;
            				//cout<<(temp2->getVarInfo())->getArraySize()<<"check for it"<<endl;
							
							
							table->insert(temp2);
							
						}
						 else if((symbol->getVarInfo())->getDataType()=="VOID")
						{
							error_void_variable(@$.first_line, symbol->getSymbolName());
						}
						else if(symbol->getVarInfo()->getDataType()==$1->getDataType())
						{
							errror_redefine_parameter(@$.first_line,symbol->getSymbolName());
						}
						else	
						{
							error_conflicting_type(@$.first_line, symbol->getSymbolName());
						}
					}
				}
				vardeclarelistSize=0;
				cout<<"var_declaration : type_specifier declaration_list SEMICOLON"<<endl;
				flag=false;
				}
				
 				;
 		 
type_specifier : INT
				{
					parseTreeNode* i=new parseTreeNode();
					i->setFirstLine(@1.first_line);
					i->setLasttLine(@1.last_line);
					i->setRule("INT : int");
					i->setsymbolinfo();

					$$=new parseTreeNode();
					$$->setFirstLine(@$.first_line);
					$$->setLasttLine(@$.last_line);
					$$->setDataType("INT");
					$$->setRule("type_specifier : INT");

					$$->addChildren(i);
					cout<<"type_specifier : INT"<<endl;



				}
 		| FLOAT
		{

			parseTreeNode* i=new parseTreeNode();
			i->setFirstLine(@1.first_line);
			i->setLasttLine(@1.last_line);
			i->setRule("FLOAT : float");
			i->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType("FLOAT");
			$$->setRule("type_specifier : FLOAT");

			$$->addChildren(i);
			cout<<"type_specifier : FLOAT"<<endl;
		}
 		| VOID
		{
			parseTreeNode* i=new parseTreeNode();
			i->setFirstLine(@1.first_line);
			i->setLasttLine(@1.last_line);
			i->setRule("VOID : void");
			i->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType("VOID");
			$$->setRule("type_specifier : VOID");

			$$->addChildren(i);
			cout<<"type_specifier : VOID"<<endl;


		}
 		;
 		
declaration_list : 
			declaration_list COMMA ID
			{
				parseTreeNode* comma=new parseTreeNode();
				comma->setFirstLine(@2.first_line);
				comma->setLasttLine(@2.last_line);
				comma->setRule("COMMA : ,");
				comma->setsymbolinfo();
				parseTreeNode* id=new parseTreeNode();
				id->setFirstLine(@3.first_line);
				id->setLasttLine(@3.last_line);
				id->setRule("ID : "+$3->getSymbolName());
				id->setsymbolinfo();

				$$=new parseTreeNode();
				$$->setFirstLine(@$.first_line);
				$$->setLasttLine(@$.last_line);
				$$->setRule("declaration_list : declaration_list COMMA ID");
				
			if(flag)
			{
				$$=$1;
			}
				
			else {

				$$->addChildren($1);
				$$->addChildren(comma);
				$$->addChildren(id);
			

				varDeclare **temp=new varDeclare*[vardeclarelistSize+2];
				
				//vardeclarelist=new VarDeclare[vardeclarelistSize+2];
				if(vardeclarelistSize){
				for(int i=0;i<vardeclarelistSize;i++)
				{
					temp[i]=vardeclarelist[i];
				}
				}
				else{
					temp[0]=NULL;
					//cout<<"yes from id";
				}
				
				varDeclare *temp2=new varDeclare();
				//cout<<$1->getSymbolName()<<$1->getSymbolType()<<endl;
				temp2->setSymbol($3);
				temp2->setNode(id);
				temp[vardeclarelistSize]=temp2;
				vardeclarelistSize++;
				vardeclarelist=temp;
				cout<<"declaration_list : declaration_list COMMA ID"<<endl;
			}



			}

 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		  {
				parseTreeNode* id=new parseTreeNode();
				id->setFirstLine(@3.first_line);
				id->setLasttLine(@3.last_line);
				id->setRule("ID : "+$3->getSymbolName());
				id->setsymbolinfo();

				parseTreeNode* lthird=new parseTreeNode();
				lthird->setFirstLine(@4.first_line);
				lthird->setLasttLine(@4.last_line);
				lthird->setRule("LTHIRD : [");
				lthird->setsymbolinfo();

				parseTreeNode* rthird=new parseTreeNode();
				rthird->setFirstLine(@6.first_line);
				rthird->setLasttLine(@6.last_line);
				rthird->setRule("RTHIRD : ]");
				rthird->setsymbolinfo();

				parseTreeNode* constINT=new parseTreeNode();
				constINT->setFirstLine(@5.first_line);
				constINT->setLasttLine(@5.last_line);
				constINT->setRule("CONST_INT : "+$5->getSymbolName());
				constINT->setsymbolinfo();

				parseTreeNode* comma=new parseTreeNode();
				comma->setFirstLine(@2.first_line);
				comma->setLasttLine(@2.last_line);
				comma->setRule("COMMA : ,");
				comma->setsymbolinfo();

				$$=new parseTreeNode();
				$$->setFirstLine(@$.first_line);
				$$->setLasttLine(@$.last_line);
				$$->setRule("declaration_list : ID LTHIRD CONST_INT RTHIRD");
			
					if(flag)
					{
						$$=$1;
					}
				

				if(!flag){
				$$->addChildren($1);
				$$->addChildren(comma);
				$$->addChildren(id);
				
				
				$$->addChildren(lthird);
				$$->addChildren(constINT);
				$$->addChildren(rthird);
				
				varDeclare **temp=new varDeclare*[vardeclarelistSize+2];
				
				//vardeclarelist=new VarDeclare[vardeclarelistSize+2];
				if(vardeclarelistSize){
				for(int i=0;i<vardeclarelistSize;i++)
				{
					temp[i]=vardeclarelist[i];
				}
				}
				else{
					temp[0]=NULL;
					//cout<<"yes from id";
				}
				
			
				varDeclare *temp2=new varDeclare();
				temp2->setSymbol($3);
				temp2->setArraySize(stoi($5->getSymbolName()));
				temp2->setNode(id);
				temp[vardeclarelistSize]=temp2;
				vardeclarelistSize++;
				vardeclarelist=temp;
				cout<<"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD"<<endl;
				}
			}
 		  | ID
		  {
				parseTreeNode* id=new parseTreeNode();
				id->setFirstLine(@1.first_line);
				id->setLasttLine(@1.last_line);
				id->setRule("ID : "+$1->getSymbolName());
				id->setsymbolinfo();

				$$=new parseTreeNode();
				$$->setFirstLine(@$.first_line);
				$$->setLasttLine(@$.last_line);
				$$->setRule("declaration_list : ID");

				if(!flag){
				$$->addChildren(id);
				

				varDeclare **temp=new varDeclare*[vardeclarelistSize+2];
				
				//vardeclarelist=new VarDeclare[vardeclarelistSize+2];
				if(vardeclarelistSize){
				for(int i=0;i<vardeclarelistSize;i++)
				{
					temp[i]=vardeclarelist[i];
				}
				}
				else{
					temp[0]=NULL;
					//cout<<"yes from id";
				}
				
				varDeclare *temp2=new varDeclare();
				//cout<<$1->getSymbolName()<<$1->getSymbolType()<<endl;
				temp2->setSymbol($1);
				temp2->setNode(id);
				temp[vardeclarelistSize]=temp2;
				vardeclarelistSize++;
				vardeclarelist=temp;
				cout<<"declaration_list : ID"<<endl;
			}
			}
 		  | ID LTHIRD CONST_INT RTHIRD
		  {
				parseTreeNode* id=new parseTreeNode();
				id->setFirstLine(@1.first_line);
				id->setLasttLine(@1.last_line);
				id->setRule("ID : "+$1->getSymbolName());
				id->setsymbolinfo();

				parseTreeNode* lthird=new parseTreeNode();
				lthird->setFirstLine(@2.first_line);
				lthird->setLasttLine(@2.last_line);
				lthird->setRule("LTHIRD : [");
				lthird->setsymbolinfo();

				

				parseTreeNode* constINT=new parseTreeNode();
				constINT->setFirstLine(@3.first_line);
				constINT->setLasttLine(@3.last_line);
				constINT->setRule("CONST_INT : "+$3->getSymbolName());
				constINT->setsymbolinfo();

				

				parseTreeNode* rthird=new parseTreeNode();
				rthird->setFirstLine(@4.first_line);
				rthird->setLasttLine(@4.last_line);
				rthird->setRule("RTHIRD : ]");
				rthird->setsymbolinfo();

				$$=new parseTreeNode();
				$$->setFirstLine(@$.first_line);
				$$->setLasttLine(@$.last_line);
				$$->setRule("declaration_list : ID LTHIRD CONST_INT RTHIRD");

				if(!flag){
				$$->addChildren(id);
				
				$$->addChildren(lthird);
				$$->addChildren(constINT);
				$$->addChildren(rthird);
				varDeclare **temp=new varDeclare*[vardeclarelistSize+2];
				
				//vardeclarelist=new VarDeclare[vardeclarelistSize+2];
				if(vardeclarelistSize){
				for(int i=0;i<vardeclarelistSize;i++)
				{
					temp[i]=vardeclarelist[i];
				}
				}
				else{
					temp[0]=NULL;
					//cout<<"yes from id";
				}
				varDeclare *temp2=new varDeclare();
				temp2->setSymbol($1);
				temp2->setArraySize(stoi($3->getSymbolName()));
				temp2->setNode(id);
				temp[vardeclarelistSize]=temp2;
				vardeclarelistSize++;
				vardeclarelist=temp;
				cout<<"declaration_list : ID LTHIRD CONST_INT RTHIRD"<<endl;
			}
		}
		|
		error
		{
			yyclearin;
			//yyerror(@$.first_line,"declaration list of variable declaration");
			flag=true;
			
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			//$$->setDataType($1->getDataType());
			$$->setRule("declaration_list : error");
			//lyyerror(@1, "string %s found where name required", "declaration list of variable declaration");
		}
 		  ;
 		  
statements : 
		statement
		{
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("statements : statement");

			$$->addChildren($1);
			cout<<"statements : statement"<<endl;
		}

	   | statements statement
	   	{
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("statements : statements statement");

			$$->addChildren($1);
			$$->addChildren($2);
			cout<<"statements : statements statement"<<endl;
		}
	   ;
	   
statement : 
		var_declaration
		{
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("statement : var_declaration");

			$$->addChildren($1);
			cout<<"statement : var_declaration"<<endl;
		}

	  | expression_statement
	  {
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("statement : expression_statement");

			$$->addChildren($1);
			cout<<"statement : expression_statement"<<endl;


	  }
	  | compound_statement
	  {
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("statement : compound_statement");

			$$->addChildren($1);
			cout<<"statement : compound_statement"<<endl;

	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
			parseTreeNode* forNode=new parseTreeNode();
			forNode->setFirstLine(@1.first_line);
			forNode->setLasttLine(@1.last_line);
			forNode->setRule("FOR : for");
			forNode->setsymbolinfo();

			parseTreeNode* lparen=new parseTreeNode();
			lparen->setFirstLine(@2.first_line);
			lparen->setLasttLine(@2.last_line);
			lparen->setRule("LPAREN : (");
			lparen->setsymbolinfo();

			parseTreeNode* rparen=new parseTreeNode();
			rparen->setFirstLine(@6.first_line);
			rparen->setLasttLine(@6.last_line);
			rparen->setRule("RPAREN : )");
			rparen->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");

			$$->addChildren(forNode);
			$$->addChildren(lparen);
			$$->addChildren($3);
			$$->addChildren($4);
			$$->addChildren($5);
			$$->addChildren(rparen);
			$$->addChildren($7);
			cout<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement"<<endl;
		}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
			parseTreeNode* ifNode=new parseTreeNode();
			ifNode->setFirstLine(@1.first_line);
			ifNode->setLasttLine(@1.last_line);
			ifNode->setRule("IF : if");
			ifNode->setsymbolinfo();

			parseTreeNode* lparen=new parseTreeNode();
			lparen->setFirstLine(@2.first_line);
			lparen->setLasttLine(@2.last_line);
			lparen->setRule("LPAREN : (");
			lparen->setsymbolinfo();

			parseTreeNode* rparen=new parseTreeNode();
			rparen->setFirstLine(@4.first_line);
			rparen->setLasttLine(@4.last_line);
			rparen->setRule("RPAREN : )");
			rparen->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("statement : IF LPAREN expression RPAREN statement");

			$$->addChildren(ifNode);
			$$->addChildren(lparen);
			$$->addChildren($3);
			$$->addChildren(rparen);
			$$->addChildren($5);
			cout<<"statement : IF LPAREN expression RPAREN statement"<<endl;
		}
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
			parseTreeNode* ifNode=new parseTreeNode();
			ifNode->setFirstLine(@1.first_line);
			ifNode->setLasttLine(@1.last_line);
			ifNode->setRule("IF : if");
			ifNode->setsymbolinfo();

			parseTreeNode* lparen=new parseTreeNode();
			lparen->setFirstLine(@2.first_line);
			lparen->setLasttLine(@2.last_line);
			lparen->setRule("LPAREN : (");
			lparen->setsymbolinfo();

			parseTreeNode* rparen=new parseTreeNode();
			rparen->setFirstLine(@4.first_line);
			rparen->setLasttLine(@4.last_line);
			rparen->setRule("RPAREN : )");
			rparen->setsymbolinfo();

			parseTreeNode* elseNode=new parseTreeNode();
			elseNode->setFirstLine(@6.first_line);
			elseNode->setLasttLine(@6.last_line);
			elseNode->setRule("ELSE : else");
			elseNode->setsymbolinfo();
			
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("statement : IF LPAREN expression RPAREN statement ELSE statement");

			$$->addChildren(ifNode);
			$$->addChildren(lparen);
			$$->addChildren($3);
			$$->addChildren(rparen);
			$$->addChildren($5);
			$$->addChildren(elseNode);
			$$->addChildren($7);

				cout<<"statement : IF LPAREN expression RPAREN statement ELSE statement"<<endl;




	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
			parseTreeNode* whileNode=new parseTreeNode();
			whileNode->setFirstLine(@1.first_line);
			whileNode->setLasttLine(@1.last_line);
			whileNode->setRule("WHILE : while");
			whileNode->setsymbolinfo();
			parseTreeNode* lparen=new parseTreeNode();
			lparen->setFirstLine(@2.first_line);
			lparen->setLasttLine(@2.last_line);
			lparen->setRule("LPAREN : (");
			lparen->setsymbolinfo();

			parseTreeNode* rparen=new parseTreeNode();
			rparen->setFirstLine(@4.first_line);
			rparen->setLasttLine(@4.last_line);
			rparen->setRule("RPAREN : )");
			rparen->setsymbolinfo();
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("statement : WHILE LPAREN expression RPAREN statement");

			$$->addChildren(whileNode);
			$$->addChildren(lparen);
			$$->addChildren($3);
			$$->addChildren(rparen);
			$$->addChildren($5);
			cout<<"statement : WHILE LPAREN expression RPAREN statement"<<endl;


	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
			parseTreeNode* printlnNode=new parseTreeNode();
			printlnNode->setFirstLine(@1.first_line);
			printlnNode->setLasttLine(@1.last_line);
			printlnNode->setRule("PRINTLN : println");
			printlnNode->setsymbolinfo();

			parseTreeNode* lparen=new parseTreeNode();
			lparen->setFirstLine(@2.first_line);
			lparen->setLasttLine(@2.last_line);
			lparen->setRule("LPAREN : (");
			lparen->setsymbolinfo();

			parseTreeNode* rparen=new parseTreeNode();
			rparen->setFirstLine(@4.first_line);
			rparen->setLasttLine(@4.last_line);
			rparen->setRule("RPAREN : )");
			rparen->setsymbolinfo();

			parseTreeNode* id=new parseTreeNode();
			id->setFirstLine(@3.first_line);
			id->setLasttLine(@3.last_line);
			id->setRule("ID : "+$3->getSymbolName());
			id->setsymbolinfo();

			parseTreeNode* semicolon=new parseTreeNode();
			semicolon->setFirstLine(@5.first_line);
			semicolon->setLasttLine(@5.last_line);
			semicolon->setRule("SEMICOLON : ;");
			semicolon->setsymbolinfo();


			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("statement : PRINTLN LPAREN ID RPAREN SEMICOLON");

			$$->addChildren(printlnNode);
			$$->addChildren(lparen);
			$$->addChildren(id);
			$$->addChildren(rparen);
			$$->addChildren(semicolon);
			cout<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON"<<endl;

		}
	  | RETURN expression SEMICOLON
	  {
			parseTreeNode* returnNode=new parseTreeNode();
			returnNode->setFirstLine(@1.first_line);
			returnNode->setLasttLine(@1.last_line);
			returnNode->setRule("RETURN : return");
			returnNode->setsymbolinfo();

			parseTreeNode* semicolon=new parseTreeNode();
			semicolon->setFirstLine(@3.first_line);
			semicolon->setLasttLine(@3.last_line);
			semicolon->setRule("SEMICOLON : ;");
			semicolon->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("statement : RETURN expression SEMICOLON");

			$$->addChildren(returnNode);
			$$->addChildren($2);
			$$->addChildren(semicolon);

			cout<<"statement : RETURN expression SEMICOLON"<<endl;

	  }
	  ;
	  
expression_statement 	: 
			 expression SEMICOLON
			{
				parseTreeNode* semicolon=new parseTreeNode();
				semicolon->setFirstLine(@2.first_line);
				semicolon->setLasttLine(@2.last_line);
				semicolon->setRule("SEMICOLON : ;");
				semicolon->setsymbolinfo();


				$$=new parseTreeNode();
				$$->setFirstLine(@$.first_line);
				$$->setLasttLine(@$.last_line);
				$$->setRule("expression_statement : expression SEMICOLON");

				$$->addChildren($1);
				$$->addChildren(semicolon);
				cout<<"expression_statement 	: expression SEMICOLON"<<endl;
				if(flag)
				errorFile<<"expression of expression statement"<<endl;
				flag=false;


			}
			|
			SEMICOLON
			{
				parseTreeNode* semicolon=new parseTreeNode();
				semicolon->setFirstLine(@1.first_line);
				semicolon->setLasttLine(@1.last_line);
				semicolon->setRule("SEMICOLON : ;");
				semicolon->setsymbolinfo();


				$$=new parseTreeNode();
				$$->setFirstLine(@$.first_line);
				$$->setLasttLine(@$.last_line);
				$$->setRule("expression_statement : SEMICOLON");

				$$->addChildren(semicolon);
				cout<<"expression_statement 	: SEMICOLON"<<endl;
			}
					
			
			;
	  
variable : 
		ID
		{
			parseTreeNode* id=new parseTreeNode();
			id->setFirstLine(@1.first_line);
			id->setLasttLine(@1.last_line);
			id->setRule("ID : "+$1->getSymbolName());
			id->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setRule("variable : ID");

			$$->addChildren(id);

			 SymbolInfo *symbol=table->lookup($1->getSymbolName());
			if(symbol==NULL)
			 {
			 	$$->setDataType("VAR");
				error_undeclared_variable(@1.first_line,$1->getSymbolName());
			}
			else if(symbol->getSymbolType()=="VAR")
				{
					id->setDataType((symbol->getVarInfo())->getDataType());
			 		$$->setDataType((symbol->getVarInfo())->getDataType());
				}
			
				cout<<"variable : ID"<<endl;

		}	
	 | ID LTHIRD expression RTHIRD
	 {
			parseTreeNode* id=new parseTreeNode();
			id->setFirstLine(@1.first_line);
			id->setLasttLine(@1.last_line);
			id->setRule("ID : "+$1->getSymbolName());
			id->setsymbolinfo();

			parseTreeNode* lthird=new parseTreeNode();
			lthird->setFirstLine(@2.first_line);
			lthird->setLasttLine(@2.last_line);
			lthird->setRule("LTHIRD : [");
			lthird->setsymbolinfo();

			parseTreeNode* rthird=new parseTreeNode();
			rthird->setFirstLine(@4.first_line);
			rthird->setLasttLine(@4.last_line);
			rthird->setRule("RTHIRD : ]");
			rthird->setsymbolinfo();

			parseTreeNode *temp=new parseTreeNode();
			temp->setFirstLine(@$.first_line);
			temp->setLasttLine(@$.last_line);
			temp->setRule("variable : ID LTHIRD expression RTHIRD");

			temp->addChildren(id);
			temp->addChildren(lthird);
			temp->addChildren($3);
			temp->addChildren(rthird);
			$$=temp;

			SymbolInfo *symbol=table->lookup($1->getSymbolName());
			//cout<<symbol->getSymbolName()<<" "<<(symbol->getVarInfo())->getArraySize()<<"yes"<<endl;
			if(symbol==NULL)
			 {
			 	error_undeclared_variable(@1.first_line,$1->getSymbolName());
				break;
			}
			if(symbol->getFuncInfo()!=NULL)
			{
				error_undeclared_variable(@1.first_line,$1->getSymbolName());
			}
			 if(symbol->getSymbolType()=="VAR"&&(symbol->getVarInfo())->getArraySize()==-1)
			{
				error_not_array_type(@1.first_line,$1->getSymbolName());
			}
			 if($3->getDataType()!="INT")
			{
				error_index_not_integer(@2.first_line);
			}
			
			 if(symbol->getSymbolType()=="VAR" && (symbol->getVarInfo())->getArraySize()>-1)
			{
				id->setDataType((symbol->getVarInfo())->getDataType());
				$$->setDataType((symbol->getVarInfo())->getDataType());
			}
			cout<<"variable : ID LTHIRD expression RTHIRD"<<endl;


	 }
	 ;
	 
 expression : 
		logic_expression
		{
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("expression : logic_expression");

			$$->addChildren($1);
			cout<<" expression : logic_expression"<<endl;
			zeroFound=false;


		}	
	   | variable ASSIGNOP logic_expression
	   {
			parseTreeNode* assign=new parseTreeNode();
			assign->setFirstLine(@1.first_line);
			assign->setLasttLine(@1.last_line);
			assign->setRule("ASSIGNOP : =");
			assign->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("expression : variable ASSIGNOP logic_expression");

			$$->addChildren($1);
			$$->addChildren(assign);
			$$->addChildren($3);
			
			if($3->getDataType()=="VOID")
			{
				error_custom(@2.first_line,"Void cannot be used in expression ");
			}
			else if($3->getDataType() =="FLOAT" && $1->getDataType() == "INT")
			{
				error_data_loss(@1.first_line);
			}
			//else if($3->getArraySize()
			cout<<" expression : variable ASSIGNOP logic_expression"<<endl;
			zeroFound=false;
			

		}
		|
		error
		{
			yyclearin;
			//yyerror(@$.first_line,"expression of expression statement");
			flag=true;
		
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			//$$->setDataType($1->getDataType());
			$$->setRule("expression : error");
			//yyerrok;
		}
	   ;
			
logic_expression : 
		rel_expression
		{
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("logic_expression : rel_expression");

			$$->addChildren($1);
			cout<<"logic_expression : rel_expression"<<endl;
		}
		| 
		rel_expression LOGICOP rel_expression
		{
			parseTreeNode* logic=new parseTreeNode();
			logic->setFirstLine(@1.first_line);
			logic->setLasttLine(@1.last_line);
			logic->setRule("LOGICOP : "+$2->getSymbolName());
			logic->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("logic_expression : rel_expression LOGICOP rel_expression");

			$$->addChildren($1);
			$$->addChildren(logic);
			$$->addChildren($3);

			if($3->getDataType()=="VOID"||$1->getDataType()=="VOID")
			{
				error_custom(@2.first_line,"Void cannot be used in expression ");
			}
			cout<<"logic_expression : rel_expression LOGICOP rel_expression"<<endl;
			


		}
		 ;
			
rel_expression	: 
		simple_expression
		{	
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("rel_expression : simple_expression");

			$$->addChildren($1);
			cout<<"rel_expression	: simple_expression"<<endl;
		} 
		| simple_expression RELOP simple_expression
		{
			parseTreeNode* relop=new parseTreeNode();
			relop->setFirstLine(@1.first_line);
			relop->setLasttLine(@1.last_line);
			relop->setRule("RELOP : "+$2->getSymbolName());
			relop->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("rel_expression : simple_expression RELOP simple_expression");

			$$->addChildren($1);
			$$->addChildren(relop);
			$$->addChildren($3);

			if($3->getDataType()=="VOID"||$1->getDataType()=="VOID")
			{
				error_custom(@2.first_line,"Void cannot be used in expression ");
			}
			cout<<"rel_expression	: simple_expression RELOP simple_expression"<<endl;

		}	
		;
				
simple_expression : 
		term 
		{
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("simple_expression : term");

			$$->addChildren($1);
			cout<<"simple_expression : term"<<endl;
			//zeroFound=false;
		}
		| simple_expression ADDOP term
		{
			parseTreeNode* addNode=new parseTreeNode();
			addNode->setFirstLine(@1.first_line);
			addNode->setLasttLine(@1.last_line);
			addNode->setRule("ADDOP : +");
			addNode->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("simple_expression : simple_expression ADDOP term");

			$$->addChildren($1);
			$$->addChildren(addNode);
			$$->addChildren($3);

			if($3->getDataType()=="VOID"||$1->getDataType()=="VOID")
			{
				error_custom(@2.first_line,"Void cannot be used in expression ");
			}
			cout<<"simple_expression : simple_expression ADDOP term"<<endl;
			//zeroFound=false;
		}
		;
					
term :	
		unary_expression
		{
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("term : unary_expression");

			$$->addChildren($1);
			cout<<"term :  unary_expression"<<endl;
			//zeroFound=false;
		}
     |  term MULOP unary_expression
	 {
			parseTreeNode* mulNode=new parseTreeNode();
			mulNode->setFirstLine(@1.first_line);
			mulNode->setLasttLine(@1.last_line);
			mulNode->setRule("MULOP : +");
			mulNode->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("term : term MULOP unary_expression");

			$$->addChildren($1);
			$$->addChildren(mulNode);
			$$->addChildren($3);

			if($3->getDataType()=="VOID"||$1->getDataType()=="VOID")
			{
				error_custom(@2.first_line,"Void cannot be used in expression ");
			}
			else if(($2->getSymbolName() == "%")&& zeroFound){
				
				error_div_by_zero(@2.first_line);
				zeroFound=false;

			}
			else if(($2->getSymbolName() == "%") && ($1->getDataType() != "INT" || $3->getDataType() != "INT"))
			{
				error_mod_not_integer(@2.first_line);
			}
			cout<<"term :  term MULOP unary_expression"<<endl;
			//zeroFound=false;
			
	}
    ;

unary_expression : 
		ADDOP unary_expression
		{
			parseTreeNode* addNode=new parseTreeNode();
			addNode->setFirstLine(@1.first_line);
			addNode->setLasttLine(@1.last_line);
			addNode->setRule("ADDOP : +");
			addNode->setsymbolinfo();
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($2->getDataType());
			$$->setRule("unary_expression : ADDOP unary_expression");

			//$$->addChildren($1);
			$$->addChildren(addNode);
			$$->addChildren($2);
			if($2->getDataType()=="VOID")
			{
				error_custom(@1.first_line,"Cannot use unary operator on void type");
			}
			cout<<"unary_expression : ADDOP unary_expression"<<endl;
			//zeroFound=false;
		}  
		 | NOT unary_expression
		 {
			parseTreeNode* notNode=new parseTreeNode();
			notNode->setFirstLine(@1.first_line);
			notNode->setLasttLine(@1.last_line);
			notNode->setRule("NOT : !");
			notNode->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($2->getDataType());
			$$->setRule("unary_expression : NOT unary_expression");

			//$$->addChildren($1);
			$$->addChildren(notNode);
			$$->addChildren($2);

			if($2->getDataType()=="VOID")
			{
				error_custom(@1.first_line,"Cannot use unary operator on void type");
			}
			cout<<"unary_expression : NOT unary_expression"<<endl;
			//zeroFound=false;
		 }
		 | factor
		 {
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("unary_expression : factor");

			//$$->addChildren($1);
			
			$$->addChildren($1);
			cout<<"unary_expression : factor"<<endl;
			//zeroFound=false;



		 } 
		 ;
	
factor	: variable
		{
			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("factor : variable");

			//$$->addChildren($1);
			//cout<<$1->getDataType()<<" it is correct"<<endl;
			
			$$->addChildren($1);
			cout<<"factor	: variable"<<endl;
		}

	| ID LPAREN argument_list RPAREN
	{
			parseTreeNode* id=new parseTreeNode();
			id->setFirstLine(@1.first_line);
			id->setLasttLine(@1.last_line);
			id->setRule("ID : "+$1->getSymbolName());
			id->setsymbolinfo();

			parseTreeNode* lparen=new parseTreeNode();
			lparen->setFirstLine(@2.first_line);
			lparen->setLasttLine(@2.last_line);
			lparen->setRule("LPAREN : (");
			lparen->setsymbolinfo();

			parseTreeNode* rparen=new parseTreeNode();
			rparen->setFirstLine(@4.first_line);
			rparen->setLasttLine(@4.last_line);
			rparen->setRule("RPAREN : )");
			rparen->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType("");
			$$->setRule("factor : ID LPAREN argument_list RPAREN");

			//$$->addChildren($1);
			
			$$->addChildren(id);
			$$->addChildren(lparen);
			$$->addChildren($3);
			$$->addChildren(rparen);
			
			
			SymbolInfo *symbol=table->lookup($1->getSymbolName());
			//cout<<funArgSize<<" funcarg"<<endl;
			if(symbol==NULL)
			{
				error_undeclared_function(@1.first_line, $1->getSymbolName());
			}
			else if(symbol->getVarInfo()!=NULL)
			{
				error_undeclared_function(@1.first_line, $1->getSymbolName());
			}
			
			else if((symbol->getFuncInfo())->getInfoType()!=-1)
			{
				bool flag=true;
				
				string **temp=(symbol->getFuncInfo())->getParameters();
				int size=(symbol->getFuncInfo())->getParameterSize();
				//cout<<"func size"<<size<<endl;

				if(size>funArgSize)
				{
					error_too_few_arguments(@1.first_line, $1->getSymbolName());
					
				}
				else if(size<funArgSize)
				{
					error_too_many_arguments(@1.first_line, $1->getSymbolName());

				}
				
				
				else {

					// for(int i=0;i<size;i++)
					// {
					// 	cout<<temp[i][0]<<" "<<temp[i][1]<<"funArg "<<funArg[i]<<endl;
					// 	//cout<<temp[i][1]<<endl;
					// }
					for(int i=0;i<size;i++)
					{
						if(temp[i][0].compare(funArg[i]))
						{
							error_argument_type_mismatch(@1.first_line, i+1, $1->getSymbolName());
							flag=false;
						}

					}

					funArgSize=0;
				
				}
				if(flag)
				{
					$$->setDataType((symbol->getFuncInfo())->getReturnType());
				}
				
			}
			funArgSize=0;
			cout<<"factor	: ID LPAREN argument_list RPAREN"<<endl;
	}
	| LPAREN expression RPAREN
	{
		parseTreeNode* lparen=new parseTreeNode();
		lparen->setFirstLine(@2.first_line);
		lparen->setLasttLine(@2.last_line);
		//lparen->setDataType("INT");
		lparen->setRule("LPAREN : (");
		lparen->setsymbolinfo();

		parseTreeNode* rparen=new parseTreeNode();
		rparen->setFirstLine(@2.first_line);
		rparen->setLasttLine(@2.last_line);
		//lparen->setDataType("INT");
		rparen->setRule("RPAREN : )");
		rparen->setsymbolinfo();

		$$=new parseTreeNode();
		$$->setFirstLine(@$.first_line);
		$$->setLasttLine(@$.last_line);
		$$->setDataType($2->getDataType());
		$$->setRule("factor : LPAREN expression RPAREN");

			//$$->addChildren($1);
		$$->addChildren(lparen);
		$$->addChildren($2);
		$$->addChildren(rparen);
		cout<<"factor	: LPAREN expression RPAREN"<<endl;

	}
	| CONST_INT 
	{
		parseTreeNode* constINT=new parseTreeNode();
		constINT->setFirstLine(@1.first_line);
		constINT->setLasttLine(@1.last_line);
		constINT->setDataType("INT");
		constINT->setRule("CONST_INT : "+$1->getSymbolName());
		constINT->setsymbolinfo();

		$$=new parseTreeNode();
		$$->setFirstLine(@$.first_line);
		$$->setLasttLine(@$.last_line);
		$$->setDataType("INT");
		$$->setRule("factor : CONST_INT");

		if($1->getSymbolName()=="0")
		{
			zeroFound=true;
		}

			//$$->addChildren($1);
		$$->addChildren(constINT);
		//$$->addChildren(incopNode);
		cout<<"factor	: CONST_INT"<<endl;



	}
	| CONST_FLOAT
	{
		parseTreeNode* constFloat=new parseTreeNode();
		constFloat->setFirstLine(@1.first_line);
		constFloat->setLasttLine(@1.last_line);
		constFloat->setDataType("FLOAT");
		constFloat->setRule("CONST_FLOAT : "+$1->getSymbolName());
		constFloat->setsymbolinfo();

		$$=new parseTreeNode();
		$$->setFirstLine(@$.first_line);
		$$->setLasttLine(@$.last_line);
		$$->setDataType("FLOAT");
		$$->setRule("factor : CONST_FLOAT");

			//$$->addChildren($1);
		$$->addChildren(constFloat);
		cout<<"factor	: CONST_FLOAT"<<endl;



	}
	| variable INCOP 
	{
		parseTreeNode* incopNode=new parseTreeNode();
		incopNode->setFirstLine(@1.first_line);
		incopNode->setLasttLine(@1.last_line);
		incopNode->setRule("INCOP : ++");
		incopNode->setsymbolinfo();

		$$=new parseTreeNode();
		$$->setFirstLine(@$.first_line);
		$$->setLasttLine(@$.last_line);
		$$->setDataType($1->getDataType());
		$$->setRule("factor : variable INCOP");

			//$$->addChildren($1);
		$$->addChildren($1);
		$$->addChildren(incopNode);
		cout<<"factor	: variable INCOP"<<endl;

	}
	| variable DECOP
	{
		parseTreeNode* decopNode=new parseTreeNode();
		decopNode->setFirstLine(@1.first_line);
		decopNode->setLasttLine(@1.last_line);
		decopNode->setRule("DECOP : ++");
		decopNode->setsymbolinfo();

			$$=new parseTreeNode();
			$$->setFirstLine(@$.first_line);
			$$->setLasttLine(@$.last_line);
			$$->setDataType($1->getDataType());
			$$->setRule("factor : variable DECOP");

			//$$->addChildren($1);
			$$->addChildren($1);
			$$->addChildren(decopNode);
			cout<<"factor	: variable DECOP"<<endl;

	}
	;
	
argument_list : arguments
				{
					$$=new parseTreeNode();
					$$->setFirstLine(@$.first_line);
					$$->setLasttLine(@$.last_line);
					//$$->setDataType($1->getDataType());
					$$->setRule("argument_list : arguments");

					//$$->addChildren($1);
			
					$$->addChildren($1);
					cout<<"argument_list : arguments"<<endl;
				}
			  |
			  {
					$$=new parseTreeNode();
					$$->setFirstLine(@$.first_line);
					$$->setLasttLine(@$.last_line);
					//$$->setDataType($1->getDataType());
					$$->setRule("argument_list : ");
					cout<<"argument_list : "<<endl;

			  }
			  ;
	
arguments : arguments COMMA logic_expression
			{
				parseTreeNode* comma=new parseTreeNode();
				comma->setFirstLine(@1.first_line);
				comma->setLasttLine(@1.last_line);
				comma->setRule("COMMA : ,");
				comma->setsymbolinfo();

				$$=new parseTreeNode();
				$$->setFirstLine(@$.first_line);
				$$->setLasttLine(@$.last_line);
				$$->setDataType($1->getDataType());
				$$->setRule("arguments : arguments COMMA logic_expression");

				$$->addChildren($1);
				$$->addChildren(comma);
				$$->addChildren($3);
				
				string *temp=new string[funArgSize+2];
				if(funArgSize){

					for(int i=0;i<funArgSize;i++)
					{
						temp[i]=funArg[i];
					}
				}
				temp[funArgSize]=$3->getDataType();
				//cout<<$3->getDataType()<<" setting"<<endl;
				funArgSize=funArgSize+1;
				funArg=temp;
				//delete temp;
				cout<<"arguments : arguments COMMA logic_expression"<<endl;

			}

	      | logic_expression
		  	{
				parseTreeNode *temp2=new parseTreeNode();
				temp2->setFirstLine(@$.first_line);
				temp2->setLasttLine(@$.last_line);
				//$$->setDataType($1->getDataType());
				temp2->setRule("arguments : logic_expression");

				temp2->addChildren($1);
				$$=temp2;
				
				string *temp=new string[funArgSize+2];
				if(funArgSize){

					for(int i=0;i<funArgSize;i++)
					{
						temp[i]=funArg[i];
					}
				}
				temp[funArgSize]=$1->getDataType();
				//cout<<$1->getDataType()<<" setting"<<endl;
				funArgSize=funArgSize+1;
				funArg=temp;
				//delete temp;

				cout<<"arguments :  logic expression"<<endl;



				
			}
	      ; 
 

%%


int main(int argc,char *argv[]){
    if(argc != 2){
        cout<<"Please provide input file name and try again."<<endl;
        return 0;
    }

    FILE *fin = freopen(argv[1], "r", stdin);
    if(fin == nullptr){
        cout<<"Can't open specified file."<<endl;
        return 0;
    }

	cout<<argv[1]<<" opened successfully."<<endl;
	
   // errorOut.open("error.txt");
    freopen("log.txt", "w", stdout);

    // if we don't init the yyin, it will use stdin(console)
    yyin = fin;

    yylineno = 1; // line number starts from 1

    // start scanning the file here
	yyparse();

    fclose(yyin);
    return 0;
}
