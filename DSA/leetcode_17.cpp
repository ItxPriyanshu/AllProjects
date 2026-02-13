//17. Letter Combinations of a Phone Number
/*Given a string containing digits from 2-9 inclusive, return all possible letter combinations that the number could represent. Return the answer in any order.

A mapping of digits to letters (just like on the telephone buttons) is given below. Note that 1 does not map to any letters.
*/

#include<bits/stdc++.h>
using namespace std;
class Solution {

private:
    void solve(vector<string>& ans, string output,int index,string keypad[],string digits){
        if(index>=digits.length()){
            ans.push_back(output);
            return;
        }
        int number = digits[index] - '0';
        string temp = keypad[number];
        for(int i =0;i<temp.length();i++){
            output.push_back(temp[i]);
            solve(ans,output,index+1,keypad,digits);
            output.pop_back();
        }
    }


public:
    vector<string> letterCombinations(string digits) {
        string keypad[10] ={"","","abc","def","ghi","jkl","mno","pqrs","tuv","wxyz"};
        vector<string> ans;
        string output;
        int index= 0;
        solve(ans,output,index,keypad,digits);
        return ans;
}
};