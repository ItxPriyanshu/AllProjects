//3454. Separate Squares II
/*
You are given a 2D integer array squares. Each squares[i] = [xi, yi, li] represents the coordinates of the bottom-left point and the side length of a square parallel to the x-axis.

Find the minimum y-coordinate value of a horizontal line such that the total area covered by squares above the line equals the total area covered by squares below the line.

Answers within 10-5 of the actual answer will be accepted.

Note: Squares may overlap. Overlapping areas should be counted only once in this version.
*/

#include<bits/stdc++.h>
using namespace std;

class Solution {
public:
    double separateSquares(vector<vector<int>>& squares) {
        vector<array<long long,4>> events;
        for (auto &s : squares) {
            long long x = s[0], y = s[1], l = s[2];
            events.push_back({y, 1, x, x + l});
            events.push_back({y + l, -1, x, x + l});
        }

        sort(events.begin(), events.end());

        multiset<pair<long long,long long>> active;
        vector<double> ys, areas, widths;

        double prevY = events[0][0];
        double totalArea = 0;

        for (auto &e : events) {
            double curY = e[0];
            double height = curY - prevY;

            if (height > 0 && !active.empty()) {
                double width = unionX(active);
                double area = width * height;
                ys.push_back(prevY);
                areas.push_back(area);
                widths.push_back(width);
                totalArea += area;
            }

            if (e[1] == 1)
                active.insert({e[2], e[3]});
            else
                active.erase(active.find({e[2], e[3]}));

            prevY = curY;
        }

        double target = totalArea / 2.0;
        double pref = 0;

        for (int i = 0; i < areas.size(); i++) {
            if (pref + areas[i] >= target) {
                double remain = target - pref;
                return ys[i] + remain / widths[i];
            }
            pref += areas[i];
        }

        return 0.0;
    }

private:
    double unionX(const multiset<pair<long long,long long>>& segs) {
        double res = 0;
        long long l = -1e18, r = -1e18;

        for (auto &s : segs) {
            if (s.first > r) {
                res += max(0LL, r - l);
                l = s.first;
                r = s.second;
            } else {
                r = max(r, s.second);
            }
        }
        res += max(0LL, r - l);
        return res;
    }
};