//3047. Find the Largest Area of Square Inside Two Rectangles
/*
There exist n rectangles in a 2D plane with edges parallel to the x and y axis. You are given two 2D integer arrays bottomLeft and topRight where bottomLeft[i] = [a_i, b_i] and topRight[i] = [c_i, d_i] represent the bottom-left and top-right coordinates of the ith rectangle, respectively.

You need to find the maximum area of a square that can fit inside the intersecting region of at least two rectangles. Return 0 if such a square does not exist.
*/


#include<bits/stdc++.h>
using namespace std;

class Solution {
public:
    long long largestSquareArea(vector<vector<int>>& bottomLeft,
                                vector<vector<int>>& topRight) {
        
        int n = bottomLeft.size();
        long long ans = 0;

        for(int i = 0; i < n; i++) {
            for(int j = i + 1; j < n; j++) {

                int left   = max(bottomLeft[i][0], bottomLeft[j][0]);
                int bottom = max(bottomLeft[i][1], bottomLeft[j][1]);

                int right = min(topRight[i][0], topRight[j][0]);
                int top   = min(topRight[i][1], topRight[j][1]);

                if(right > left && top > bottom) {
                    long long side = min(right - left, top - bottom);
                    ans = max(ans, side * side);
                }
            }
        }
        return ans;
    }
};