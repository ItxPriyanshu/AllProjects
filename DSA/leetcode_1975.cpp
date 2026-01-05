// 1975. Maximum Matrix Sum
/*
You are given an n x n integer matrix. You can do the following operation any number of times:

Choose any two adjacent elements of matrix and multiply each of them by -1.
Two elements are considered adjacent if and only if they share a border.

Your goal is to maximize the summation of the matrix's elements. Return the maximum sum of the matrix's elements using the operation mentioned above.
*/


#include<bits/stdc++.h>
using namespace std;

class Solution {
public:
    long long maxMatrixSum(vector<vector<int>>& matrix) {
        long long sum = 0;
        int count = 0;
        int mn = INT_MAX;

        for (int i = 0; i < matrix.size(); i++) {
            for (int j = 0; j < matrix[i].size(); j++) {
                int x = matrix[i][j];
                sum += abs(x);

                if (x < 0) count++;
                mn = min(mn, abs(x));
            }
        }

        if (count % 2 == 0)
            return sum;

        return sum -2LL* mn;
    }
};
