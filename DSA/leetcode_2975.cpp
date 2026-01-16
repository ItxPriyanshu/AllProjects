//2975. Maximum Square Area by Removing Fences From a Field
/*
There is a large (m - 1) x (n - 1) rectangular field with corners at (1, 1) and (m, n) containing some horizontal and vertical fences given in arrays hFences and vFences respectively.

Horizontal fences are from the coordinates (hFences[i], 1) to (hFences[i], n) and vertical fences are from the coordinates (1, vFences[i]) to (m, vFences[i]).

Return the maximum area of a square field that can be formed by removing some fences (possibly none) or -1 if it is impossible to make a square field.

Since the answer may be large, return it modulo 109 + 7.

Note: The field is surrounded by two horizontal fences from the coordinates (1, 1) to (1, n) and (m, 1) to (m, n) and two vertical fences from the coordinates (1, 1) to (m, 1) and (1, n) to (m, n). These fences cannot be removed.
*/

#include<bits/stdc++.h>
using namespace std;

class Solution {
public:
    int maximizeSquareArea(int m, int n, vector<int>& hFences, vector<int>& vFences) {
     long long M = 1e9 + 7;
       hFences.push_back(1);
       hFences.push_back(m);

       vFences.push_back(1);
       vFences.push_back(n);

       sort(hFences.begin(),hFences.end());
       sort(vFences.begin(),vFences.end());

       unordered_set<int> width;

    for(int i=0;i<hFences.size();i++){
        for(int j=i+1;j<hFences.size();j++){
            int temp = hFences[j]-hFences[i];
            width.insert(temp);
        }
    }
    int ans =0;
    for(int i=0;i<vFences.size();i++){
        for(int j=i+1;j<vFences.size();j++){
            int temp = vFences[j]-vFences[i];
            if(width.count(temp)){
                ans = max(ans,temp);
            }
        }
    }
    if(ans == 0){
        return -1;
    }else{
        return (1LL* ans*ans)%M;
    }
    

    }
};