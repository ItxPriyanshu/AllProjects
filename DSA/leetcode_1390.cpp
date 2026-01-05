// 1390. Four Divisors
/*
Given an integer array nums, return the sum of divisors of the integers in that array that
have exactly four divisors. If there is no such integer in the array, return 0.
*/

#include<bits/stdc++.h>
using namespace std;

//1st approach brute force(TLE)
/*
class Solution {
public:
    int sumFourDivisors(vector<int>& nums) {
        int ans = 0;
        for (int i = 0; i < nums.size(); i++) {
            int count = 0;
            int temp = 0;
            for (int j = 1; j <= nums[i]; j++) {
                if (nums[i] % j == 0) {
                    count++;
                    temp += j;
                }
            }
            if (count == 4) {
                ans += temp;
            }
        }
        return ans;
    }
};*/


//optimized solution
class Solution {
public:
    int sumFourDivisors(vector<int>& nums) {
        int ans = 0;
        for (int n : nums) {
            int count = 0;
            int temp = 0;
            for (int j = 1; j * j <= n; j++) {
                if (n % j == 0) {
                    int d1 = j;
                    int d2 = n / j;

                    if (d1 == d2) {
                        count += 1;
                        temp += d1;
                    } else {
                        count += 2;
                        temp += d1 + d2;
                    }

                    if (count > 4)
                        break;
                }
            }
            if (count == 4) {
                ans += temp;
            }
        }
        return ans;
    }
};

