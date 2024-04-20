%option noyywrap
%x STRING
%x SINGLE_LINE_COMMENT
%x MULTI_LINE_COMMENT

%{
#include<iostream>
#include<fstream>
#include<string>
using namespace std;
#include "2005047_SymbolTable.cpp"
ofstream fout("2005047_token.txt");
int firstLineSet=1;
int tabCount=0;
int verticalCount=0;
int spaceCount=0;
int requiredCount=0;
int f=0;
int lineCount=1;
int errorCount=0;
int warningCount=0;
SymbolTable *test=new SymbolTable(10);
string temp;
int tempStartCount=0;
void printLog(string token,string lexeme){
    cout<<"Line# "<<lineCount<<": Token "<<"<"<<token<<"> Lexeme "<<lexeme<<" found"<<endl;
}

void printToken(string token,string lexeme){
    fout<<"<"<<token<<", "<<lexeme<<">"<<endl;
}
void addKeyWord(string token,string key){
    printLog(token,key);
    printToken(token,key);
}
void addConstNumber(string token,string num){
    printLog(token,num);
    printToken(token,num);
} 
void addConstChar(string token,string c){
    string temp="";
    temp+=c[1];
     printLog(token,temp);
     printToken(token,temp);
}
void addconstEscapeChar(string token,string s){
    
    string temp="";
      
              if(s[2]=='n')
            {
                temp+="\n";
            }
            else if(s[2]=='t')
            {
                temp+="\t";
            }
            else if(s[2]=='\\')
            {
                temp+="\\";
            }
            else if(s[2]=='\'')
            {
                temp+="\'";
            }
            else if(s[2]=='a')
            {
                temp+="\a";
            }
             else if(s[2]=='f')
            {
                temp+="\a";
            }
             else if(s[2]=='r')
            {
                temp+="\a";
            }
             else if(s[2]=='b')
            {
                temp+="\a";
            }
             else if(s[2]=='v')
            {
                temp+="\a";
            }
             else if(s[2]=='0')
            {
                temp+="\0";
            }
            else if(s[2]=='\"')
            {
                temp+="\"";
            }
            else
                {
                    temp+=s[2];
                }
            printLog(token,temp);
        printToken("CONST_CHAR",temp);

}
void addOperator(string token,string otr){
    printLog(token,otr);
    printToken(token,otr);
    
}
void addPunctuator(string token,string  punctuator){
    printLog(token,punctuator);
    printToken(token,punctuator);
}
void addIdentifier(string token,string id){
    //cout<<id<<endl;
    printLog(token,id);
    printToken(token,id);
    if(test->insert(token,id)) 
    {
        test->printAllScope();
    }
    else
        {
            cout<<"\t"<<id<<" already exists in the current ScopeTable"<<endl;
        }
}
void addString(string token,string s,int lineStart){
    //fout<<s.length()<<endl;
     cout<<"Line# "<<lineStart<<": Token "<<"<"<<token<<"> Lexeme "<<s<<" found"<<endl;
    string temp="";
    for(int i=0;i<s.length();i++)
    {
       
        if(s[i]=='"')
        {
            continue;
        }
        else if(s[i]=='\\')
        {
            if(s[i+1]=='n')
            {
                temp+="\n";
            }
            else if(s[i+1]=='t')
            {
                temp+="\t";
            }
            else if(s[i+1]=='\\')
            {
                temp+="\\";
            }
            else if(s[i+1]=='\'')
            {
                temp+="\'";
            }
            else if(s[i+1]=='a')
            {
                temp+="\a";
            }
             else if(s[i+1]=='f')
            {
                temp+="\a";
            }
             else if(s[i+1]=='r')
            {
                temp+="\a";
            }
             else if(s[i+1]=='b')
            {
                temp+="\a";
            }
             else if(s[i+1]=='v')
            {
                temp+="\a";
            }
             else if(s[i+1]=='0')
            {
                temp+="\0";
            }
            else if(s[i+1]=='\"')
            {
                temp+="\"";
            }
            i++;              
        }
        else
            {
               
                //fout<<"tab"<<endl;
                temp+=s[i];
            }

    }
    printToken(token,temp);

}
void addComment(string token,string s,int lineStart){
    cout<<"Line# "<<lineStart<<": Token "<<"<"<<token<<"> Lexeme "<<s<<" found"<<endl;
    
}
void printDecimalPointError(string s){
    errorCount++;
    cout<<"Error at line# "<<lineCount<<": TOO_MANY_DECIMAL_POINTS "<<s<<endl;
}
void printIllFormedError(string s){
    errorCount++;
    cout<<"Error at line# "<<lineCount<<": ILLFORMED_NUMBER "<<s<<endl;

}
void printSuffixPrefixError(string s){  
    errorCount++;
    cout<<"Error at line# "<<lineCount<<": INVALID_ID_SUFFIX_NUM_PREFIX "<<s<<endl;
}
void printMultiCharConstError(string s){
    errorCount++;
    cout<<"Error at line# "<<lineCount<<": MULTICHAR_CONST_CHAR "<<s<<endl;
}
void printUnfinishedCharError(string s){ 
    errorCount++;
    cout<<"Error at line# "<<lineCount<<": UNFINISHED_CONST_CHAR "<<s<<endl;
}
void printUnfinishedStrError(string s,int lineStart){
    errorCount++;
    cout<<"Error at line# "<<lineStart<<": UNFINISHED_STRING "<<s<<endl;
}
void printEmptyCharError(string s){
    errorCount++;
   cout<<"Error at line# "<<lineCount<<": EMPTY_CONST_CHAR "<<s<<endl;
}
void printUnRecognizedError(string s){
    errorCount++;
    cout<<"Error at line# "<<lineCount<<": UNRECOGNIZED_CHAR "<<s<<endl;
}
void printUnfinishedCommentError(string s,int lineStart){   
    errorCount++;
    cout<<"Error at line# "<<lineStart<<": UNFINISHED_COMMENT "<<s<<endl;
}
void setSpaceTab(int space,int tab,string yytext)
{
    if(firstLineSet)
    {
        firstLineSet=0;
        if(requiredCount!=tab)
        {   
            if(space)
            {
                cout<<"Line# "<<lineCount<<": Warning, tab requrired but got space."<<endl;
            }
            else
            {
                cout<<"Line# "<<lineCount<<": warning, "<< requiredCount<<" of tabs needed but got "<<tab<<" tabs."<<endl;
            }
            warningCount++;
        }
        else
            {
                if(space)
                {
                    cout<<"Line# "<<lineCount<<": Warning, tab requrired but got space."<<endl;
                    warningCount++;
                }
            }
       
       
    }
}



%}
DIGIT [0-9]
DIGITS ([0-9]+)
CONST_INT {DIGITS}
EXPONENT ([Ee][+-]?{DIGITS})
CONST_FLOAT {DIGITS}{EXPONENT}|{DIGITS}\.{DIGITS}?{EXPONENT}?|\.{DIGITS}{EXPONENT}?
CONST_CHAR \'[^\'\\\n\\r]\'
CONST_ESCAPE_CHAR \'\\[nt\\\'\"afrv0]\'
LETTER [a-zA-Z]
LETTER_ [a-zA-Z_]
IDENTIFIER {LETTER_}[a-zA-Z0-9_]*
ADD_OPERATOR [+-]
INC_OPERATOR "++"|"--"
RELOP_OPERATOR "<"|"<="|">"|">="|"=="|"!="
BITOP_OPERATOR "&"|"\|"|"^"|"<<"|">>"
ASSIGN "="
LOGIC_OPERATOR "&&"|"\|\|"
NOT "!"
LPAREN "("
RPAREN ")"
NEWLINE (\r)?\n
TOO_MUCH_DECIMAL_POINTS {DIGITS}((\.){DIGITS})((\.){DIGITS})+{EXPONENT}?|(\.{DIGITS})((\.){DIGITS})+{EXPONENT}?|{DIGITS}((\.)+{DIGITS}){EXPONENT}?|((\.)+{DIGITS}){EXPONENT}?
ILLFORMED_NUMBERS {DIGITS}(\.{DIGITS})?[Ee][+-]?{DIGITS}?(\.{DIGITS})
INVALID_ID_SUFFIX_NUM_PREFIX {CONST_INT}{IDENTIFIER}|{CONST_FLOAT}{IDENTIFIER}
MULTI_CHAR_CONST_ERROR \'.[^\'\r\n]+\'
UNFINISHED_CHARACTER \'\\\'|\'(([^\\\'\n\r]))|\'\\[nt\\\'\"afrv0]?|\'
%%
[\t\v] {tabCount++;}
[ ] {spaceCount++;}

        /* NEW LINE COUNT*/
{NEWLINE} {
    // cout<<"tab "<<tabCount<<endl;
    // cout<<"space" <<spaceCount<<endl;
    // cout<<"vertical "<<verticalCount<<endl;
    // cout<<"line "<<lineCount<<endl;
    //cout<<"newline"<<endl;
    tabCount=0;
    verticalCount=0;
    spaceCount=0;
    lineCount++;
    firstLineSet=1;
    }
	        /*KEYWORD ADD*/
"if" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("IF","if");}
"else" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("ELSE","else");}
"for" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("FOR","for");}
"while" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("WHILE","while");}
"do" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("DO","do");}
"break" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("BREAK","break");}
"int" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("INT","int");}
"char" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("CHAR","char");}
"float" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("FLOAT","float");}
"double" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("DOUBLE","double");}
"void" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("VOID","void");}
"return" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("RETURN","return");}
"switch" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("SWITCH","switch");}
"case" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("CASE","case");}
"default" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("DEFAULT","default");}
"continue" {setSpaceTab(spaceCount,tabCount,yytext);addKeyWord("CONTINUE","continue");}
    /*CONSTANT ADD*/
{CONST_INT} {setSpaceTab(spaceCount,tabCount,yytext);
    addConstNumber("CONST_INT",yytext);
}
{CONST_FLOAT} {
    //cout<<yytext<<endl;
    setSpaceTab(spaceCount,tabCount,yytext);
    addConstNumber("CONST_FLOAT",yytext);
}
{CONST_CHAR} {
    setSpaceTab(spaceCount,tabCount,yytext);
    addConstChar("CONST_CHAR",yytext);
}
{CONST_ESCAPE_CHAR} {
    setSpaceTab(spaceCount,tabCount,yytext);
    addconstEscapeChar("CONST_CHAR",yytext);
}
    /*OPERATOR ADD*/
{ADD_OPERATOR} {
   setSpaceTab(spaceCount,tabCount,yytext);
    addOperator("ADDOP",yytext);
}
[\*\/\%] {
    setSpaceTab(spaceCount,tabCount,yytext);
    addOperator("MULOP",yytext);
}
{RELOP_OPERATOR} {
    setSpaceTab(spaceCount,tabCount,yytext);
    addOperator("RELOP",yytext);
}
{ASSIGN} {
    setSpaceTab(spaceCount,tabCount,yytext);
    addOperator("ASSIGNOP",yytext);
}
{INC_OPERATOR} {
    setSpaceTab(spaceCount,tabCount,yytext);
    addOperator("INCOP",yytext);

}
{LOGIC_OPERATOR} {
    setSpaceTab(spaceCount,tabCount,yytext);
    addOperator("LOGICOP",yytext);
}
{BITOP_OPERATOR} {
    setSpaceTab(spaceCount,tabCount,yytext);
    addOperator("BITOP",yytext);
}
{NOT} {
    setSpaceTab(spaceCount,tabCount,yytext);
    addOperator("NOT",yytext);
}
        /*PUNCTUATOR ADD*/
{LPAREN} {
    setSpaceTab(spaceCount,tabCount,yytext);
   addPunctuator("LPAREN",yytext);
}
{RPAREN} {
    setSpaceTab(spaceCount,tabCount,yytext);
    addPunctuator("RPAREN",yytext);
}
\{ {
    setSpaceTab(spaceCount,tabCount,yytext);
    
    requiredCount++;
   addPunctuator("LCURL",yytext);
   test->enterScope();
}
\} {
    requiredCount--;
    setSpaceTab(spaceCount,tabCount,yytext);
    addPunctuator("RCURL",yytext);
    test->exitScope();
}
\[ {
   setSpaceTab(spaceCount,tabCount,yytext);
   addPunctuator("LSQUARE",yytext);
}
\] {
   setSpaceTab(spaceCount,tabCount,yytext);
    addPunctuator("RSQUARE",yytext);

}
\, {
    setSpaceTab(spaceCount,tabCount,yytext);
    addPunctuator("COMMA",yytext);
}
\; {
    setSpaceTab(spaceCount,tabCount,yytext);
    addPunctuator("SEMICOLON",yytext);
}
        /*IDENTIFIER ADD*/
{IDENTIFIER} {
   // cout<<yytext;
   setSpaceTab(spaceCount,tabCount,yytext);
    addIdentifier("ID",yytext);
}
    /* STIRNG ADD */
\" {
    
    temp=yytext;
    tempStartCount=lineCount;
    BEGIN STRING;
}
<STRING>\\{NEWLINE} {
        temp+=yytext;
        f=1;
        lineCount++;
}  
<STRING>\\\" {
    temp+=yytext;
}
<STRING>[^\"\n\r]  {
    temp+=yytext;
}
<STRING>\" {
    temp+=yytext;
    //fout<<temp<<endl;
    if(f==1)
    {
        addString("MULTI LINE STRING",temp,tempStartCount);
    }
    else
    {
        addString("SINGLE LINE STRING",temp,tempStartCount);
    }
    f=0;
    BEGIN INITIAL;
}
<STRING>{NEWLINE} {
    printUnfinishedStrError(temp,lineCount);
    lineCount++;
    BEGIN INITIAL;
}


        /*ADD COMMENT*/
        /*THIS IS SINGLE LINE COMMENT*/
"//" {
        temp=yytext;
        tempStartCount=lineCount;
        BEGIN SINGLE_LINE_COMMENT;
}
<SINGLE_LINE_COMMENT>\\{NEWLINE} {

        temp+=yytext;
        lineCount++;
}
<SINGLE_LINE_COMMENT>{NEWLINE} {
    
        addComment("SINGLE LINE COMMENT",temp,tempStartCount);
        tabCount=0;
        verticalCount=0;
        spaceCount=0;
        lineCount++;
        firstLineSet=1;
        BEGIN INITIAL;
}
<SINGLE_LINE_COMMENT>. {
    temp+=yytext;
}
        /*THIS IS MULTILINE COMMENT */
"/*" {
    temp=yytext;
    tempStartCount=lineCount;
    BEGIN MULTI_LINE_COMMENT;
}
<MULTI_LINE_COMMENT>{NEWLINE}   {
    temp+=yytext;
    lineCount++;
}

<MULTI_LINE_COMMENT>"*/" {
    temp+=yytext;
    addComment("MULTI LINE COMMENT",temp,tempStartCount);
    BEGIN INITIAL;
}
<MULTI_LINE_COMMENT>. {
    temp+=yytext;
}
<MULTI_LINE_COMMENT><<EOF>> {
    
    printUnfinishedCommentError(temp,lineCount);
    test->printAllScope();
    
    cout<<"Total lines: "<<lineCount<<endl;
    cout<<"Total errors: "<<errorCount<<endl;
    cout<<"Total warnings: "<<warningCount<<endl;
    return 0;
}

                /* ADD ERROR*/

{TOO_MUCH_DECIMAL_POINTS} {
    printDecimalPointError(yytext);
}
{ILLFORMED_NUMBERS} {
    printIllFormedError(yytext);
}
{INVALID_ID_SUFFIX_NUM_PREFIX} {
    printSuffixPrefixError(yytext);
}
{MULTI_CHAR_CONST_ERROR} {
    printMultiCharConstError(yytext);
}
\'\' {
    printEmptyCharError(yytext);
}
{UNFINISHED_CHARACTER} {
    printUnfinishedCharError(yytext);
}
<<EOF>> {
    test->printAllScope();
    cout<<"Total lines: "<<lineCount<<endl;
    cout<<"Total errors: "<<errorCount<<endl;
    cout<<"Total warnings: "<<warningCount<<endl;
    return 0;
}
. {
    setSpaceTab(spaceCount,tabCount,yytext);
    printUnRecognizedError(yytext);
}

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	freopen("2005047_log.txt","a",stdout);
    yyin= fin;
	yylex();
	fclose(yyin);
	return 0;
}
