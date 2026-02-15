#Requires AutoHotkey v2.1-alpha.14

class TableViewHelper {
    static _compiled := false
    static _assembly := ""

    static _code := "
    (
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Globalization;

    public class ColumnDef
    {
        public string Name;
        public int Width;
        public string Type;
        public string Align;
    }

    public class TableViewModel
    {
        private List<ColumnDef> _columns = new List<ColumnDef>();
        private List<List<string>> _rows = new List<List<string>>();
        private List<int> _view = null;
        private string _sortColumn = `"`";
        private string _sortDirection = `"`";
        private string _filterText = `"`";

        public int ColumnCount => _columns.Count;
        public int RowCount => _rows.Count;
        public int ViewCount => (_view ?? Enumerable.Range(0, _rows.Count).ToList()).Count;
        public string SortColumn => _sortColumn;
        public string SortDirection => _sortDirection;
        public string FilterText => _filterText;

        public void AddColumn(string name, string width, string type, string align)
        {
            int w = 100;
            int.TryParse(width, out w);
            _columns.Add(new ColumnDef { Name = name, Width = w, Type = type, Align = align });
        }

        public string GetColumnName(int index)
        {
            return index >= 0 && index < _columns.Count ? _columns[index].Name : `"`";
        }

        public int GetColumnWidth(int index)
        {
            return index >= 0 && index < _columns.Count ? _columns[index].Width : 100;
        }

        public string GetColumnType(int index)
        {
            return index >= 0 && index < _columns.Count ? _columns[index].Type : `"string`";
        }

        public string GetColumnAlign(int index)
        {
            return index >= 0 && index < _columns.Count ? _columns[index].Align : `"Left`";
        }

        public int AddRowFromValues(string values, string sep)
        {
            var parts = values.Split(new string[] { sep }, StringSplitOptions.None);
            var row = new List<string>();
            for (int i = 0; i < _columns.Count; i++)
                row.Add(i < parts.Length ? parts[i] : `"`");
            _rows.Add(row);
            if (_filterText != `"`")
                ApplyFilter();
            else
                _view = null;
            return _rows.Count - 1;
        }

        public void RemoveRow(int viewIndex)
        {
            var indices = _view ?? Enumerable.Range(0, _rows.Count).ToList();
            if (viewIndex >= 0 && viewIndex < indices.Count)
            {
                int realIndex = indices[viewIndex];
                _rows.RemoveAt(realIndex);
                if (_filterText != `"`")
                    ApplyFilter();
                else
                    _view = null;
                if (_sortColumn != `"`")
                    ApplySort();
            }
        }

        public void Clear()
        {
            _rows.Clear();
            _view = null;
            _sortColumn = `"`";
            _sortDirection = `"`";
            _filterText = `"`";
        }

        public string GetCell(string viewIndexStr, string column)
        {
            int viewIndex = 0;
            int.TryParse(viewIndexStr, out viewIndex);
            var indices = _view ?? Enumerable.Range(0, _rows.Count).ToList();
            if (viewIndex < 0 || viewIndex >= indices.Count) return `"`";
            int realIndex = indices[viewIndex];
            int colIdx = _columns.FindIndex(c => c.Name == column);
            if (colIdx < 0 || colIdx >= _rows[realIndex].Count) return `"`";
            return _rows[realIndex][colIdx];
        }

        public string GetRowDisplay(string viewIndexStr, string sep)
        {
            int viewIndex = 0;
            int.TryParse(viewIndexStr, out viewIndex);
            var indices = _view ?? Enumerable.Range(0, _rows.Count).ToList();
            if (viewIndex < 0 || viewIndex >= indices.Count) return `"`";
            int realIndex = indices[viewIndex];
            return string.Join(sep, _rows[realIndex]);
        }

        public void Sort(string column, string direction)
        {
            _sortColumn = column;
            _sortDirection = direction;
            ApplySort();
        }

        private void ApplySort()
        {
            int colIdx = _columns.FindIndex(c => c.Name == _sortColumn);
            if (colIdx < 0) return;
            var indices = _view ?? Enumerable.Range(0, _rows.Count).ToList();
            bool isNumber = _columns[colIdx].Type == `"number`";
            if (_sortDirection == `"asc`")
            {
                if (isNumber)
                    _view = indices.OrderBy(i => ParseNum(_rows[i][colIdx])).ToList();
                else
                    _view = indices.OrderBy(i => _rows[i][colIdx], StringComparer.OrdinalIgnoreCase).ToList();
            }
            else
            {
                if (isNumber)
                    _view = indices.OrderByDescending(i => ParseNum(_rows[i][colIdx])).ToList();
                else
                    _view = indices.OrderByDescending(i => _rows[i][colIdx], StringComparer.OrdinalIgnoreCase).ToList();
            }
        }

        public void Filter(string text)
        {
            _filterText = text;
            if (string.IsNullOrEmpty(text))
            {
                _view = null;
                if (_sortColumn != `"`")
                    ApplySort();
                return;
            }
            ApplyFilter();
            if (_sortColumn != `"`")
                ApplySort();
        }

        private void ApplyFilter()
        {
            _view = new List<int>();
            for (int i = 0; i < _rows.Count; i++)
            {
                foreach (var cell in _rows[i])
                {
                    if (cell.IndexOf(_filterText, StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        _view.Add(i);
                        break;
                    }
                }
            }
        }

        public void ResetView()
        {
            _view = null;
            _sortColumn = `"`";
            _sortDirection = `"`";
            _filterText = `"`";
        }

        public void UpdateCell(string viewIndexStr, string column, string value)
        {
            int viewIndex = 0;
            int.TryParse(viewIndexStr, out viewIndex);
            var indices = _view ?? Enumerable.Range(0, _rows.Count).ToList();
            if (viewIndex < 0 || viewIndex >= indices.Count) return;
            int realIndex = indices[viewIndex];
            int colIdx = _columns.FindIndex(c => c.Name == column);
            if (colIdx < 0 || colIdx >= _rows[realIndex].Count) return;
            _rows[realIndex][colIdx] = value;
        }

        public string GetColumnSum(string column)
        {
            int colIdx = _columns.FindIndex(c => c.Name == column);
            if (colIdx < 0) return `"$0`";
            var indices = _view ?? Enumerable.Range(0, _rows.Count).ToList();
            double sum = 0;
            foreach (var i in indices)
                sum += ParseNum(_rows[i][colIdx]);
            return `"$`" + sum.ToString(`"N0`");
        }

        public string GetStatus()
        {
            var indices = _view ?? Enumerable.Range(0, _rows.Count).ToList();
            string status = `"Rows: `" + indices.Count + `"/`" + _rows.Count;
            if (_sortColumn != `"`")
                status += `" | Sort: `" + _sortColumn + `" `" + (_sortDirection == `"asc`" ? `"\u25B2`" : `"\u25BC`");
            if (_filterText != `"`")
                status += `" | Filter: `" + _filterText;
            return status;
        }

        private static double ParseNum(string s)
        {
            string cleaned = s.Replace(`"$`", `"`").Replace(`",`", `"`").Trim();
            double v;
            double.TryParse(cleaned, NumberStyles.Any, CultureInfo.InvariantCulture, out v);
            return v;
        }
    }
    )"

    static Init() {
        if this._compiled
            return
        this._assembly := CSharpBridge.Compile(this._code, "TableViewHelper")
        this._compiled := true
    }

    static CreateModel() {
        this.Init()
        return this._assembly.CreateInstance("TableViewModel")
    }
}
