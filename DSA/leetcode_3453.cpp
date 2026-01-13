//3453. Separate Squares I
/*
You are given a 2D integer array squares. Each squares[i] = [xi, yi, li] represents the coordinates of the bottom-left point and the side length of a square parallel to the x-axis.

Find the minimum y-coordinate value of a horizontal line such that the total area of the squares above the line equals the total area of the squares below the line.

Answers within 10-5 of the actual answer will be accepted.

Note: Squares may overlap. Overlapping areas should be counted multiple times.*/

#include<bits/stdc++.h>
using namespace std;


class Solution {
public:
    bool isSatisfied(vector<vector<int>>& squares,double mxY,double mxArea){
        double area = 0.0;

        for(const auto& sq :squares){
            int y = sq[1];
            int l = sq[2];
            if((double)y<mxY){
                area += (double)l * min(mxY-(double)y,(double)l);
            }
        }
        return area*2 >= mxArea; 
    }
    double separateSquares(vector<vector<int>>& squares) {
        double area = 0.0,mxY = 0.0;

        for(const auto& sq :squares){
            int y = sq[1];
            int l = sq[2];
            area += (double)l*(double)l;
            mxY = max(mxY,(double)(y+l));
        }
        double l = 0.0,h = mxY;
        double ex = 1e-5;
        while(abs(h-l)>ex){
            double mid = (l+h)/2;
            if(isSatisfied(squares,mid,area)){
                h = mid;
            }else{
                l = mid;
            }
        }
        return h;
    }
};