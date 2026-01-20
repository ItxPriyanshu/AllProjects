//3314. Construct the Minimum Bitwise Array I
/*
You are given an array nums consisting of n prime integers.

You need to construct an array ans of length n, such that, for each index i, the bitwise OR of ans[i] and ans[i] + 1 is equal to nums[i], i.e. ans[i] OR (ans[i] + 1) == nums[i].

Additionally, you must minimize each value of ans[i] in the resulting array.

If it is not possible to find such a value for ans[i] that satisfies the condition, then set ans[i] = -1.*/

#include<bits/stdc++.h>
using namespace std;

class Solution {
public:
    vector<int> minBitwiseArray(vector<int>& nums) {
        
        vector<int> ans;
        for (int i =0;i<nums.size();i++){
            bool found =false;
            for(int j=0;j<=1000;j++){
                if(((j) | (j+1))==nums[i]){
                ans.push_back(j);
                found = true;
                break;
                }
            }
           if(!found)
           ans.push_back(-1);
        }
        return ans;
    }
};