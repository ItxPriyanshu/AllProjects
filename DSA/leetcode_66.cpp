//LEETCODE 66.PLUS ONE (DATE = 01-01-2026)

/*
You are given a large integer represented as an integer array digits,
where each digits[i] is the ith digit of the integer.
 The digits are ordered from most significant to least significant in left-to-right order.
  The large integer does not contain any leading 0's.
Increment the large integer by one and return the resulting array of digits.
*/

#include <bits/stdc++.h>
using namespace std;

class Solution {
public:
    vector<int> plusOne(vector<int>& digits) {
        for (int i = digits.size() - 1; i >= 0; i--) {
            if (digits[i] < 9) {
                digits[i]++;
                return digits;
            }
            digits[i] = 0;
        }
        digits.insert(digits.begin(), 1);
        return digits;
    }
};
