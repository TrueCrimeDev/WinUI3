#Requires AutoHotkey v2.0

; =============================================================================
; TreeViewHelper - Hierarchical TreeView builder via C#
; =============================================================================

class TreeViewHelper {
    static _compiled := false
    static _factory := ""

    static _code := "
    (
    using System;
    using System.Collections.Generic;
    using Microsoft.UI.Xaml.Controls;

    public class TreeBuilder
    {
        private TreeView _treeView;
        private Dictionary<int, TreeViewNode> _nodes = new Dictionary<int, TreeViewNode>();
        private int _nextId = 1;

        public TreeBuilder()
        {
            _treeView = new TreeView();
            _treeView.SelectionMode = TreeViewSelectionMode.Single;
        }

        public TreeView Control => _treeView;

        public int AddRootNode(string text)
        {
            var node = new TreeViewNode();
            node.Content = text;
            node.IsExpanded = true;
            _treeView.RootNodes.Add(node);
            int id = _nextId++;
            _nodes[id] = node;
            return id;
        }

        public int AddChildNode(int parentId, string text)
        {
            if (!_nodes.ContainsKey(parentId)) return -1;
            var parent = _nodes[parentId];
            var node = new TreeViewNode();
            node.Content = text;
            parent.Children.Add(node);
            int id = _nextId++;
            _nodes[id] = node;
            return id;
        }

        public void ExpandAll()
        {
            foreach (var node in _nodes.Values)
                node.IsExpanded = true;
        }

        public void CollapseAll()
        {
            foreach (var node in _nodes.Values)
                node.IsExpanded = false;
        }
    }

    public class TreeBuilderFactory
    {
        public TreeBuilder Create()
        {
            return new TreeBuilder();
        }
    }
    )"

    static Init() {
        if this._compiled
            return
        this._factory := CSharpBridge.CreateInstance(this._code, "TreeBuilderFactory", "TreeViewHelper")
        this._compiled := true
    }

    static Create() {
        this.Init()
        return this._factory.Create()
    }
}
