//1984. Minimum Difference Between Highest and Lowest of K Scores
/*
You are given a 0-indexed integer array nums, where nums[i] represents the score of the ith student. You are also given an integer k.

Pick the scores of any k students from the array so that the difference between the highest and the lowest of the k scores is minimized.

Return the minimum possible difference.
*/

#include<bits/stdc++.h>
using namespace std;

class Solution {
public:
    int minimumDifference(vector<int>& nums, int k) {
        sort(nums.begin(), nums.end());
        int n = nums.size();
        if (n < 1) {
            return 0;
        }
        int ans  = INT_MAX;
        for(int i=0;i+k-1<n;i++){
            ans = min(ans,nums[i+k-1]-nums[i]);
        }
        return ans;
    }
};