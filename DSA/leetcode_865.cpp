//865. Smallest Subtree with all the Deepest Nodes
/*
Given the root of a binary tree, the depth of each node is the shortest distance to the root.

Return the smallest subtree such that it contains all the deepest nodes in the original tree.

A node is called the deepest if it has the largest depth possible among any node in the entire tree.

The subtree of a node is a tree consisting of that node, plus the set of all descendants of that node.
*/


#include<bits/stdc++.h>
using namespace std;


//   Definition for a binary tree node.
  struct TreeNode {
      int val;
      TreeNode *left;
      TreeNode *right;
      TreeNode() : val(0), left(nullptr), right(nullptr) {}
      TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
      TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left),
  right(right) {}
  };

class Solution {
public:
    int height(TreeNode* root) {
        if (root == NULL)
            return 0;
        int left = height(root->left);
        int right = height(root->right);

        return max(left, right) + 1;
    }
    TreeNode* subtreeWithAllDeepest(TreeNode* root) {
        int left = height(root->left);
        int right = height(root->right);
        if(left==right)
            return root;
        TreeNode* node;
        if(left>right){
            node = subtreeWithAllDeepest(root->left);
        }
        else{
            node = subtreeWithAllDeepest(root->right);
        }
        return node;
    }

};

