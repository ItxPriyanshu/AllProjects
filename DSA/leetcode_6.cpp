//6. Zigzag Conversion
/*
The string "PAYPALISHIRING" is written in a zigzag pattern on a given number of rows like this: (you may want to display this pattern in a fixed font for better legibility)

P   A   H   N
A P L S I I G
Y   I   R
And then read line by line: "PAHNAPLSIIGYIR"

Write the code that will take a string and make this conversion given a number of rows:

string convert(string s, int numRows);
*/

#include<bits/stdc++.h>
using namespace std;

class Solution {
public:
    string convert(string s, int numRows) {
        if(numRows == 1)
        return s;
        int j =0;
        vector<string> temp(numRows);
        bool goingdown=false;
        for(char ch : s){
             temp[j].push_back(ch);
            if(j==numRows-1 || j ==0){         
                goingdown = !goingdown;
            }
            j+= goingdown? 1 : -1;
        }
        string ans="";
        for(auto& j:temp){
            for(char ch:j){
                ans+=ch;
            }
        }
        return ans;
    }
};
