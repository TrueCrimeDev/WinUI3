#Requires AutoHotkey v2.0

; =============================================================================
; DataGridHelper - Sortable, filterable data model with ObservableCollection
; =============================================================================

class DataGridHelper {
    static _compiled := false
    static _factory := ""

    static _code := "
    (
    using System;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.ComponentModel;
    using System.Linq;

    public class DataRow : INotifyPropertyChanged
    {
        private Dictionary<string, object> _data = new Dictionary<string, object>();
        public event PropertyChangedEventHandler PropertyChanged;

        public DataRow Set(string column, object value)
        {
            _data[column] = value;
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(column));
            return this;
        }

        public object Get(string column)
        {
            return _data.ContainsKey(column) ? _data[column] : `"`";
        }

        public override string ToString()
        {
            return string.Join(`" | `", _data.Values);
        }
    }

    public class DataModel
    {
        private List<string> _columns = new List<string>();
        private List<string> _colTypes = new List<string>();
        private ObservableCollection<DataRow> _rows = new ObservableCollection<DataRow>();

        public int ColumnCount => _columns.Count;
        public int RowCount => _rows.Count;
        public ObservableCollection<DataRow> Rows => _rows;

        public void AddColumn(string name, string type)
        {
            _columns.Add(name);
            _colTypes.Add(type);
        }

        public DataRow AddRow()
        {
            var row = new DataRow();
            _rows.Add(row);
            return row;
        }

        public void RemoveAt(int index)
        {
            if (index >= 0 && index < _rows.Count)
                _rows.RemoveAt(index);
        }

        public void Clear()
        {
            _rows.Clear();
        }

        public ObservableCollection<DataRow> Filter(string column, string text)
        {
            var filtered = new ObservableCollection<DataRow>();
            foreach (var row in _rows)
            {
                var val = row.Get(column)?.ToString() ?? `"`";
                if (val.IndexOf(text, StringComparison.OrdinalIgnoreCase) >= 0)
                    filtered.Add(row);
            }
            return filtered;
        }

        public void Sort(string column, bool ascending)
        {
            var sorted = ascending
                ? _rows.OrderBy(r => r.Get(column)?.ToString() ?? `"`", StringComparer.OrdinalIgnoreCase).ToList()
                : _rows.OrderByDescending(r => r.Get(column)?.ToString() ?? `"`", StringComparer.OrdinalIgnoreCase).ToList();

            _rows.Clear();
            foreach (var row in sorted)
                _rows.Add(row);
        }
    }

    public class DataModelFactory
    {
        public DataModel CreateModel()
        {
            return new DataModel();
        }
    }
    )"

    static Init() {
        if this._compiled
            return
        this._factory := CSharpBridge.CreateInstance(this._code, "DataModelFactory", "DataGridHelper")
        this._compiled := true
    }

    static CreateModel() {
        this.Init()
        return this._factory.CreateModel()
    }
}
