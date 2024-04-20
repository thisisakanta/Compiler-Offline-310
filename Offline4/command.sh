yacc --yacc -d 2005047.y -o y.tab.cpp
flex -o 2005047.cpp 2005047.l
g++ -w *.cpp
rm 2005047.cpp y.tab.cpp y.tab.hpp
./a.out input.c