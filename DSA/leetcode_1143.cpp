//1143. Longest Common Subsequence
/*
Given two strings text1 and text2, return the length of their longest common subsequence. If there is no common subsequence, return 0.

A subsequence of a string is a new string generated from the original string with some characters (can be none) deleted without changing the relative order of the remaining characters.

For example, "ace" is a subsequence of "abcde".
A common subsequence of two strings is a subsequence that is common to both strings.
*/


#include<bits/stdc++.h>
using namespace std;

//Using DP (optmized solution)
class Solution {
private: 
    int solve(string& text1, string& text2, int i , int j,vector<vector<int>>& dp){
        int ans;
        if(i == text1.length()){
            return 0;
        }
        if(j == text2.length()){
            return 0;
        }
        if(dp[i][j] !=- 1){
            return dp[i][j];
        }
        if(text1[i]==text2[j]){
        ans = 1+solve(text1,text2,i+1,j+1,dp);
        }
        else
        ans = max(solve(text1,text2,i+1,j,dp),solve(text1,text2,i,j+1,dp));

        return dp[i][j]=ans;
    }
public:
    int longestCommonSubsequence(string text1, string text2) {
        vector<vector<int>>dp(text1.length(),vector<int>(text2.length(),-1));
        return solve(text1,text2,0,0,dp);
    }
};


//without using DP (TLE) solution 
class Solution {
private: 
    int solve(string text1, string text2, int i , int j){
        int ans;
        if(i == text1.length()){
            return 0;
        }
        if(j == text2.length()){
            return 0;
        }
        if(text1[i]==text2[j]){
        ans = 1+solve(text1,text2,i+1,j+1);
        return ans;
        }
        else
        return max(solve(text1,text2,i+1,j),solve(text1,text2,i,j+1));
    }
public:
    int longestCommonSubsequence(string text1, string text2) {
        return solve(text1,text2,0,0);
    }
};