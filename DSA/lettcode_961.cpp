// 961. N-Repeated Element in Size 2N Array

/*
You are given an integer array nums with the following properties:

nums.length == 2 * n.
nums contains n + 1 unique elements.
Exactly one element of nums is repeated n times.
Return the element that is repeated n times.
*/









#include <bits/stdc++.h>
using namespace std;

class Solution {
public:
    int repeatedNTimes(vector<int>& nums) {
        int size= nums.size();

//O(n sqaure)
        // int ans=0;
        // for(int i =0;i<size;i++){
        //     int count=1;
        //     for(int j=i+1;j<size;j++){
        //         if(nums[i]==nums[j]){
        //             count++;
        //         }
        //     }
        //     if(count==size/2)
        //     ans = nums[i];
        // }
        // return ans;


//O(n) optimal solution
        for(int i =0;i<size-2;i++){
            if((nums[i]==nums[i+1]) || (nums[i]==nums[i+2])){
                return nums[i];
            }
        }
        return nums[size-1];
    }
};