//1411. Number of Ways to Paint N × 3 Grid
/*
You have a grid of size n x 3 and you want to paint each cell of the grid with exactly one of the three colors: Red, Yellow, or Green
while making sure that no two adjacent cells have the same color (i.e., no two cells that share vertical or horizontal sides have the same
 color).
Given n the number of rows of the grid, return the number of ways you can paint this grid. 
As the answer may grow large, the answer must be computed modulo 109 + 7.
*/




#include <bits/stdc++.h>
using namespace std;

class Solution {
public:
    int numOfWays(int n) {
      long long mod = 1e9+7;
      long long dpA=6;
      long long dpB=6;
      for(int i =1;i<n;i++){
        long long newA= dpA*3 + dpB*2;
        long long newB = dpA*2 + dpB*2;

        dpA = newA % mod;
        dpB= newB % mod;
      }

      return (dpA+dpB)%mod;
    }
};