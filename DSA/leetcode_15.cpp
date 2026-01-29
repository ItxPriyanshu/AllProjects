//15. 3Sum
/*
Given an integer array nums, return all the triplets [nums[i], nums[j], nums[k]] such that i != j, i != k, and j != k, and nums[i] + nums[j] + nums[k] == 0.

Notice that the solution set must not contain duplicate triplets.
*/

#include<bits/stdc++.h>
using namespace std;
class Solution {
public:
        vector<vector<int>> ans;

void twoSum(vector<int>& nums,int a , int i ,int j){
    while(i<j){
        if(nums[i]+nums[j]>a)
        j--;
        else if(nums[i]+nums[j]<a)
        i++;
        else{
            while(i<j && nums[i]==nums[i+1])
            i++;
            while(i<j && nums[j]==nums[j-1])
            j--;
            ans.push_back({nums[i],nums[j],-a});
            i++;j--;
        }
    }

}
    vector<vector<int>> threeSum(vector<int>& nums) {
       

        sort(nums.begin(),nums.end());
        
        for(int i=0;i<nums.size()-2;i++){
             if(i>0 && nums[i]==nums[i-1]){
            continue;
        }
            int a = -nums[i];
            twoSum(nums,a,i+1,nums.size()-1);
        }
        return ans;
    }
};