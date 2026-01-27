//3650. Minimum Cost Path with Edge Reversals
/*
You are given a directed, weighted graph with n nodes labeled from 0 to n - 1, and an array edges where edges[i] = [ui, vi, wi] represents a directed edge from node ui to node vi with cost wi.

Each node ui has a switch that can be used at most once: when you arrive at ui and have not yet used its switch, you may activate it on one of its incoming edges vi → ui reverse that edge to ui → vi and immediately traverse it.

The reversal is only valid for that single move, and using a reversed edge costs 2 * wi.

Return the minimum total cost to travel from node 0 to node n - 1. If it is not possible, return -1.
*/


#include<bits/stdc++.h>
using namespace std;
class Solution {
public:
    int minCost(int n, vector<vector<int>>& edges){
        unordered_map<int,list<pair<int,int>>>Adj;
        for(int i=0; i<edges.size(); i++){
            int u = edges[i][0];
            int v = edges[i][1];
            int w = edges[i][2];
            Adj[u].push_back(make_pair(v,w));
            Adj[v].push_back(make_pair(u,2*w));
        }
        vector<int> dist(n,INT_MAX);
        set<pair<int,int>> st;
        st.insert(make_pair(0,0));
        dist[0] = 0;
        while(!st.empty()){
            auto top = *(st.begin());
            int distance = top.first;
            int node = top.second;
            if(node == n-1){
                return distance;
            }
            st.erase(st.begin());

            for(auto neighbour:Adj[node]){
                if(distance + neighbour.second < dist[neighbour.first]){
                    auto record = st.find(make_pair(dist[neighbour.first],neighbour.first));
                    if(record != st.end()){
                        st.erase(record);
                    }
                    dist[neighbour.first] = distance + neighbour.second;
                    st.insert(make_pair(distance + neighbour.second,neighbour.first));
                }
            }
        }
        return -1;
    }
};