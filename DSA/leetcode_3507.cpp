//3507. Minimum Pair Removal to Sort Array I
/*
Given an array nums, you can perform the following operation any number of times:

Select the adjacent pair with the minimum sum in nums. If multiple such pairs exist, choose the leftmost one.
Replace the pair with their sum.
Return the minimum number of operations needed to make the array non-decreasing.

An array is said to be non-decreasing if each element is greater than or equal to its previous element (if it exists).
*/


#include<bits/stdc++.h>
using namespace std;
class Solution {
    int check(vector<int>& nums){
        int j =-1;
        int mini=INT_MAX;
        for(int i =0;i<nums.size()-1;i++){
            if((nums[i]+nums[i+1])<mini){
                j =i;
                mini= nums[i]+nums[i+1];
            }
        }
        return j;
    }
public:
    int minimumPairRemoval(vector<int>& nums) {
        int cnt=0;
      while(!is_sorted(nums.begin(),nums.end())){
        int index = check(nums);
        nums[index]= nums[index]+nums[index+1];
        nums.erase(nums.begin()+index+1);
        cnt++;
      }
      return cnt;
    }
};