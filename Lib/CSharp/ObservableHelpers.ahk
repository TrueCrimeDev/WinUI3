#Requires AutoHotkey v2.0

; =============================================================================
; ObservableHelpers - INotifyPropertyChanged + ObservableCollection for WinUI3
; =============================================================================
; Provides observable data types that WinUI3 ListView/ItemsControl can bind to.
; C# code is compiled at runtime via CSharpBridge.

class ObservableHelpers {
    static _compiled := false
    static _factory := ""

    static _code := "
    (
    using System;
    using System.Collections.ObjectModel;
    using System.Collections.Generic;
    using System.ComponentModel;

    public class ObservableItem : INotifyPropertyChanged
    {
        private Dictionary<string, string> _props = new Dictionary<string, string>();
        public event PropertyChangedEventHandler PropertyChanged;

        public string Display
        {
            get => GetProp(`"Display`");
            set => SetProp(`"Display`", value);
        }

        public string GetProp(string name)
        {
            return _props.ContainsKey(name) ? _props[name] : `"`";
        }

        public void SetProp(string name, string value)
        {
            _props[name] = value;
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }

        public override string ToString() => Display;
    }

    public class ObservableListFactory
    {
        public ObservableCollection<ObservableItem> CreateList()
        {
            return new ObservableCollection<ObservableItem>();
        }

        public ObservableItem CreateItem()
        {
            return new ObservableItem();
        }

        public ObservableItem CreateItemWith(string prop, string value)
        {
            var item = new ObservableItem();
            item.SetProp(prop, value);
            return item;
        }
    }
    )"

    static Init() {
        if this._compiled
            return
        this._factory := CSharpBridge.CreateInstance(this._code, "ObservableListFactory", "ObservableHelpers")
        this._compiled := true
    }

    static CreateList() {
        this.Init()
        return this._factory.CreateList()
    }

    static CreateItem() {
        this.Init()
        return this._factory.CreateItem()
    }

    static CreateItemWith(prop, value) {
        this.Init()
        return this._factory.CreateItemWith(prop, value)
    }
}
