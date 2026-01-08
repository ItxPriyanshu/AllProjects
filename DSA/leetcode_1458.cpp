//1458. Max Dot Product of Two Subsequences
/*
Given two arrays nums1 and nums2.

Return the maximum dot product between non-empty subsequences of nums1 and nums2 with the same length.

A subsequence of a array is a new array which is formed from the original array by deleting some (can be none) of the characters without disturbing the relative positions of the remaining characters.
 (ie, [2,3,5] is a subsequence of [1,2,3,4,5] while [1,5,3] is not).
*/


#include<bits/stdc++.h>
using namespace std;
class Solution {
public:
    int maxDotProduct(vector<int>& nums1, vector<int>& nums2) {
        int n=nums1.size(),m=nums2.size();

        vector<vector<int>>dp(n+1,vector<int>(m+1,-1e9));
      
        for(int i=1;i<=n;i++)
        {
            for(int j=1;j<=m;j++)
            {
                int take=nums1[i-1]*nums2[j-1]+max(0,dp[i-1][j-1]);
                int skip_e1=dp[i-1][j];
                int skip_e2=dp[i][j-1];

                dp[i][j]=max({take,skip_e1,skip_e2});
            }
        }

        return dp[n][m];
    }
};