//2943. Maximize Area of Square Hole in Grid
/*
You are given the two integers, n and m and two integer arrays, hBars and vBars. The grid has n + 2 horizontal and m + 2 vertical bars, creating 1 x 1 unit cells. The bars are indexed starting from 1.

You can remove some of the bars in hBars from horizontal bars and some of the bars in vBars from vertical bars. Note that other bars are fixed and cannot be removed.

Return an integer denoting the maximum area of a square-shaped hole in the grid, after removing some bars (possibly none).
*/


#include<bits/stdc++.h>
using namespace std;

class Solution {
public:
    int maximizeSquareHoleArea(int n, int m, vector<int>& hBars,
                               vector<int>& vBars) {
        sort(hBars.begin(), hBars.end());
        sort(vBars.begin(), vBars.end());
        int consH = 1, consV = 1,maxh=1,maxv=1;
        for (int i = 0; i < hBars.size()-1; i++) {
            if ((hBars[i+1] - hBars[i]) == 1) {
                consH++;
            } else {
                consH = 1;
            }
            maxh=max(maxh,consH);
        }
        for (int i = 0; i < vBars.size()-1; i++) {
            if ((vBars[i+1] - vBars[i]) == 1) {
                consV++;
            } else {
                consV = 1;
            }
            maxv=max(maxv,consV);

        }
        int vertical = maxh + 1;
        int horizontal = maxv + 1;
        int side = min(vertical, horizontal);
        int ans = side * side;
        return ans;
    }
};