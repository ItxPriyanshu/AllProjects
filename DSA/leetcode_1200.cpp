//1200. Minimum Absolute Difference
/*
Given an array of distinct integers arr, find all pairs of elements with the minimum absolute difference of any two elements.

Return a list of pairs in ascending order(with respect to pairs), each pair [a, b] follows

a, b are from arr
a < b
b - a equals to the minimum absolute difference of any two elements in arr
*/

#include<bits/stdc++.h>
using namespace std;

class Solution {
public:
    vector<vector<int>> minimumAbsDifference(vector<int>& arr) {
        sort(arr.begin(),arr.end());
        int mini = INT_MAX;
        for(int i=0;i<arr.size()-1;i++){
            int diff = arr[i+1]-arr[i];
            mini = min(mini, diff);
        }
        vector<vector<int>> ans;
        for(int i=0;i<arr.size()-1;i++){
            int diff = arr[i+1]-arr[i];
            if(diff == mini){
                ans.push_back({arr[i],arr[i+1]});
            }
        }
        return ans;
    }
};