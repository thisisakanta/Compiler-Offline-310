#include <iostream>
#include <sstream>
#include <string>
using namespace std;
#include "2005047_SymbolTable.cpp"
int main()
{
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "a", stdout);
    cout << "\tScopeTable# 1 created" << endl;
    int n, cmd = 0;
    cin >> n;
    string line;
    SymbolTable *test = new SymbolTable(n);

    while (getline(cin, line))
    {

        stringstream s(line);
        string token;
        string *tokens=new string[2];
        int count = 0;
        while (getline(s, token, ' '))
        {
            tokens[count++]=token;
            string *temp=new string[count+2];
            for(int i=0;i<count;i++)
            {
                temp[i]=tokens[i];
            }
        delete[] tokens;
        tokens=temp;

            // cout << token << endl;
        }
        // cout<<token.size()<<endl;
        if (count == 0)
        {
            continue;
        }
        cout << "Cmd " << ++cmd << ": " << line << endl;
        if (tokens[0] == "I")
        {

            if (count == 3)
            {
                test->insert(tokens[2], tokens[1]);
            }
            else
            {
                cout << "\tWrong number of arguments for the command " << tokens[0] << endl;
            }
        }
        else if (tokens[0] == "L")
        {
            if (count == 2)
            {
                if (!test->lookup(tokens[1]))
                {
                    cout << "\t'" << tokens[1] << "'"
                         << " not found in any of the ScopeTables" << endl;
                }
            }
            else
            {

                cout << "\tWrong number of arguments for the command " << tokens[0] << endl;
            }
        }
        else if (tokens[0] == "D")
        {

            if (count == 2)
            {
                test->remove(tokens[1]);
            }
            else
            {

                cout << "\tWrong number of arguments for the command " << tokens[0] << endl;
            }
        }
        else if (tokens[0] == "P")
        {
            if (count == 2)
            {

                if (tokens[1] == "C")
                {
                    test->printCurrScope();
                }
                else if (tokens[1] == "A")
                {
                    test->printAllScope();
                }
                else
                {

                    cout << "\tInvalid argument for the command " << tokens[0] << endl;
                }
            }
            else
            {

                cout << "\tWrong number of arguments for the command " << tokens[0] << endl;
            }
        }
        else if (tokens[0] == "S")
        {
            test->enterScope();
        }
        else if (tokens[0] == "E")
        {
            test->exitScope();
        }
        else if (tokens[0] == "Q")
        {
            delete test;
        } // by default it will call the destructor so no need to worry at all.
    }
}
