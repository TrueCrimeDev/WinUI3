using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Collections;
using System.Reflection;
using System.Diagnostics.CodeAnalysis;
using System.Runtime.Loader;
using System.IO.Pipes;
using System.Text;

namespace AHK_DotNet_Interop
{
    public static class Lib
    {
        public static bool DebugWriteLineEnabled { get; set; } = true;

        public static void DebugWriteLine(string s)
        {
            if (DebugWriteLineEnabled)
            {
                Console.WriteLine(s);
            }
        }

        public static int Hello(IntPtr arg, int argLength)
        {
            Console.WriteLine("hello world");
            var ptr = Marshal.GetComInterfaceForObject(new Wrapper(_list), typeof(IDispatch));
            Marshal.WriteIntPtr(arg, ptr);
            return 0;
        }

        public static int GetClass(string FullName, IntPtr out_IDispatch)
        {
            try
            {
                Type? found_type = AppDomain.CurrentDomain.GetAssemblies().SelectMany(x => x.GetTypes()).FirstOrDefault(t => t.FullName == FullName);
                if (found_type == null)
                {
                    return 1;
                }
                Marshal.WriteIntPtr(out_IDispatch, Marshal.GetComInterfaceForObject(new Wrapper(found_type), typeof(IDispatch)));
                return 0;
            }
            catch (Exception e)
            {
                DebugWriteLine(e.ToString());
                throw;
            }
        }

        public static int LoadAssembly([MarshalAs(UnmanagedType.LPWStr)] string path, IntPtr out_IDispatch)
        {
            try
            {
                Assembly assembly = AssemblyLoadContext.Default.LoadFromAssemblyPath(path);
                Marshal.WriteIntPtr(out_IDispatch, Marshal.GetComInterfaceForObject(new Wrapper(assembly), typeof(IDispatch)));
                return 0;
            }
            catch (Exception e)
            {
                DebugWriteLine(e.ToString());
                throw;
            }
        }

        public static int CompileAssembly([MarshalAs(UnmanagedType.LPWStr)] string code, [MarshalAs(UnmanagedType.LPWStr)] string assemblyName, [MarshalAs(UnmanagedType.LPWStr)] string externalReferences, IntPtr out_IDispatch)
        {
            try
            {
                using var pipe = new NamedPipeClientStream(
                    ".", // local machine
                    "CSharp-Compiler-Wrapper",
                    PipeDirection.InOut,
                    PipeOptions.None
                );

                pipe.Connect();

                using var reader = new BinaryReader(pipe, Encoding.UTF8, leaveOpen: true);
                using var writer = new BinaryWriter(pipe, Encoding.UTF8, leaveOpen: true);

                writer.Write(assemblyName);
                writer.Write(externalReferences);
                writer.Write(code);

                string success = reader.ReadString();
                switch (success)
                {
                    case "success":
                        {
                            long length = reader.Read7BitEncodedInt64();
                            byte[] payload = reader.ReadBytes((int)length); // or manual loop if large

                            using var ms = new MemoryStream(payload);
                            Assembly assembly = AssemblyLoadContext.Default.LoadFromStream(ms);
                            Marshal.WriteIntPtr(out_IDispatch, Marshal.GetComInterfaceForObject(new Wrapper(assembly), typeof(IDispatch)));
                            return 0;
                        }
                    case "failure":
                        Console.WriteLine(reader.ReadString());
                        break;
                }
                Marshal.WriteIntPtr(out_IDispatch, 0);
                return 1;
            }
            catch (Exception e)
            {
                DebugWriteLine(e.ToString());
                throw;
            }
        }

        static ArrayList _list = ["1", "2", "3", "4"];

        public static void Main()
        {
            IntPtr pointer = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(IntPtr)));

            Hello(pointer, 0);
            // Get all assemblies loaded into the current application domain
            Assembly[] loadedAssemblies = AppDomain.CurrentDomain.GetAssemblies();

            Console.WriteLine("List of assemblies loaded in current appdomain:");

            // Iterate over the assemblies and display their names
            foreach (Assembly assembly in loadedAssemblies)
            {
                Console.WriteLine(assembly.GetName().FullName);
            }
        }
    }

    [Guid("00020400-0000-0000-C000-000000000046")]
    [ComImport]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IDispatch
    {
        [PreserveSig]
        uint GetTypeInfoCount(out uint pctinfo);

        [PreserveSig]
        uint GetTypeInfo(uint iTInfo, int lcid, out IntPtr info);

        [PreserveSig]
        uint GetIDsOfNames(
            ref Guid iid,
            [MarshalAs(UnmanagedType.LPArray, ArraySubType = UnmanagedType.LPWStr, SizeParamIndex = 2)]
            string[] names,
            uint cNames,
            int lcid,
            [Out]
            [MarshalAs(UnmanagedType.LPArray, ArraySubType = UnmanagedType.I4, SizeParamIndex = 2)]
            int[] rgDispId);

        [PreserveSig]
        uint Invoke(
            int dispIdMember,
            ref Guid riid,
            int lcid,
            InvokeFlags wFlags,
            DISPPARAMS pDispParams,
            IntPtr VarResult,
            IntPtr pExcepInfo,
            IntPtr puArgErr);
    }

    [Flags]
    public enum InvokeFlags : short
    {
        DISPATCH_METHOD = 1,
        DISPATCH_PROPERTYGET = 2,
        DISPATCH_PROPERTYPUT = 4,
        DISPATCH_PROPERTYPUTREF = 8
    }

    public class Wrapper : IDispatch
    {
        private const int DISPID_UNKNOWN = -1;
        private const int DISPID_NEWENUM = -4;
        private const uint DISP_E_UNKNOWNNAME = 0x80020006;
        private const uint DISP_E_MEMBERNOTFOUND = 0x80020003;

        private object _obj;
        private Type _type;

        private Dictionary<Type, TypeEntry> _type_entries = [];

        List<List<object>?> _methods_list;
        Dictionary<string, ListAndIdx> _methods_dict;


        struct TypeEntry
        {
            public List<List<object>?> methods_list;
            public Dictionary<string, ListAndIdx> methods_dict;
        }

        struct ListAndIdx
        {
            public List<object> list; // this needs not be stored in _methods_dict
            public int idx;
        }

        public Wrapper(object obj) : this(obj, obj.GetType()) { }
        public Wrapper(Type type) : this(type, type) { }

        public Wrapper(object obj, Type type)
        {
            _obj = obj;
            _type = type;

            ref var type_entry_ref = ref CollectionsMarshal.GetValueRefOrAddDefault(_type_entries, type, out bool type_entry_exists);
            if (type_entry_exists)
            {
                _methods_list = type_entry_ref.methods_list;
                _methods_dict = type_entry_ref.methods_dict;
            }
            else
            {
                _methods_list = [];
                _methods_dict = new(StringComparer.OrdinalIgnoreCase);
                type_entry_ref = new TypeEntry
                {
                    methods_list = _methods_list,
                    methods_dict = _methods_dict
                };
                HashSet<MethodInfo> properties = new();
                foreach (var item in type.GetProperties())
                {
                    MethodInfo? method = item.GetMethod;
                    if (method != null)
                    {
                        properties.Add(method);
                    }
                    method = item.SetMethod;
                    if (method != null)
                    {
                        properties.Add(method);
                    }
                }
                int idx_counter = 1;
                // Console.WriteLine("++++++++++++++++++++");
                // Console.WriteLine(_type.ToString());
                // foreach (var method in type.GetMethods(BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance | BindingFlags.Static))
                foreach (var method in type.GetMethods())
                {
                    // if (method.IsStatic)
                    // {
                    //     continue;
                    // }
                    var name = method.Name;
                    if (properties.Contains(method))
                    {
                        name = name[4..];
                    }

                    // var parameters = method.GetParameters();
                    // var parameterDescriptions = string.Join
                    //     (", ", method.GetParameters()
                    //                 .Select(x => x.ParameterType + " " + x.Name)
                    //                 .ToArray());
                    // Console.WriteLine("{0} {1} ({2}) {3}",
                    //                 method.ReturnType,
                    //                 method.Name,
                    //                 parameterDescriptions,
                    //                 method.IsSpecialName ? "special" : "");

                    ref var itemRef = ref CollectionsMarshal.GetValueRefOrAddDefault(_methods_dict, name, out bool exists);
                    if (!exists)
                    {
                        itemRef = new ListAndIdx { list = [], idx = idx_counter };
                        ++idx_counter;
                    }
                    itemRef.list.Add(method);
                }
                if (_methods_dict.TryGetValue("Item", out var value))
                {
                    _methods_list.Add(value.list);
                }
                else
                {
                    _methods_list.Add(null);
                }
                foreach (var item in _methods_dict.Values)
                {
                    _methods_list.Add(item.list);
                }

                foreach (var field in type.GetFields())
                {
                    ref var itemRef = ref CollectionsMarshal.GetValueRefOrAddDefault(_methods_dict, field.Name, out bool exists);
                    if (!exists)
                    {
                        itemRef = new ListAndIdx { list = [], idx = idx_counter };
                        ++idx_counter;
                    }
                    itemRef.list.Add(field);
                    _methods_list.Add(itemRef.list);
                }
            }
        }

        public uint GetTypeInfoCount(out uint pctinfo)
        {
            Lib.DebugWriteLine("GetTypeInfoCount");
            pctinfo = 0;
            return 0;
        }

        public uint GetTypeInfo(uint iTInfo, int lcid, out nint info)
        {
            Lib.DebugWriteLine("GetTypeInfo");
            info = 0;
            return 0;
        }

        public uint GetIDsOfNames(ref Guid iid, [MarshalAs(UnmanagedType.LPArray, ArraySubType = UnmanagedType.LPWStr, SizeParamIndex = 2)] string[] names, uint cNames, int lcid, [MarshalAs(UnmanagedType.LPArray, ArraySubType = UnmanagedType.I4, SizeParamIndex = 2), Out] int[] rgDispId)
        {
            // Console.WriteLine($"Name: {names[0]}");
            if (_methods_dict.TryGetValue(names[0], out var value))
            {
                rgDispId[0] = value.idx;
                return 0;
            }
            else
            {
                rgDispId[0] = DISPID_UNKNOWN;
                return DISP_E_UNKNOWNNAME;
            }
        }
        public static readonly int sizeof_VARIANT = Marshal.SizeOf<nint>() * 2 + 0x8;

        public static object? VariantToObject(nint variant, Type type)
        {
            object? obj = Marshal.GetObjectForNativeVariant(variant);
            switch (obj)
            {
                case Wrapper wrapper:
                    return wrapper._obj;
                case Int32 maybe_bool:
                    if (type == typeof(bool) && (maybe_bool == 0 || maybe_bool == 1))
                    {
                        return Convert.ToBoolean(maybe_bool);
                    }
                    return maybe_bool;
                default:
                    return obj;
            }
        }

        public static object?[] DISPPARAMS_to_objectArray(DISPPARAMS pDispParams, ParameterInfo[] parameters)
        {
            object?[] arr = new object[pDispParams.cArgs];
            for (int i = arr.Length - 1, j = 0; i >= 0; --i, j += sizeof_VARIANT)
            {
                arr[i] = VariantToObject(pDispParams.rgvarg + j, parameters[i].ParameterType);
            }
            return arr;
        }

        public static object? ConditionallyWrap(object? obj)
        {
            if (NeedsWrapping(obj))
            {
                return new Wrapper(obj);
            }
            else
            {
                return obj;
            }
        }

        public static bool NeedsWrapping([NotNullWhen(true)] object? obj)
        {
            if (obj == null)
                return false; // or true if you want to wrap null

            Type t = obj.GetType();

            // Primitive types + string + decimal + enum don't need wrapping
            if (t.IsPrimitive || t == typeof(string) || t == typeof(decimal) || t.IsEnum)
                return false;

            // Everything else should be wrapped
            return true;
        }

        public void WriteToVARIANT(object? obj, nint VarResult)
        {
            if (NeedsWrapping(obj))
            {
                Marshal.WriteInt16(VarResult, (short)VarEnum.VT_DISPATCH);
                Marshal.WriteIntPtr(VarResult, 8, Marshal.GetComInterfaceForObject(new Wrapper(obj), typeof(IDispatch)));
            }
            else
            {
                Marshal.GetNativeVariantForObject(obj, VarResult);
            }
        }

        public static bool VariantCanConvert(nint variant, Type type)
        {
            // Console.WriteLine((VarEnum)Marshal.ReadInt16(variant));
            switch ((VarEnum)Marshal.ReadInt16(variant))
            {
                case VarEnum.VT_I4:
                    if (type == typeof(bool))
                    {
                        Int32 value = Marshal.ReadInt32(variant + 8);
                        if (value == 0 || value == 1)
                        {
                            return true;
                        }
                    }
                    if (type.IsEnum && type.GetEnumUnderlyingType() == typeof(Int32))
                    {
                        return true;
                    }
                    return type == typeof(Int32);
                case VarEnum.VT_I8: return type == typeof(Int64);
                case VarEnum.VT_R8: return type == typeof(double);
                case VarEnum.VT_BSTR: return type == typeof(string);
                case VarEnum.VT_DISPATCH:
                    nint pdispVal = Marshal.ReadIntPtr(variant + 8);
                    Type otherType = ((Wrapper)Marshal.GetObjectForIUnknown(pdispVal))._obj.GetType();
                    if (type == otherType) // handles value types
                    {
                        return true;
                    }
                    if (type.IsAssignableFrom(otherType))
                    {
                        return true;
                    }
                    return false;
            }
            return false;
        }

        public uint Invoke(int dispIdMember, ref Guid riid, int lcid, InvokeFlags wFlags, DISPPARAMS pDispParams, nint VarResult, nint pExcepInfo, nint puArgErr)
        {
            try
            {
                // Console.WriteLine($"dispId: {dispIdMember}");
                IEnumerable<object>? methods_or_field;
                if (dispIdMember < 0)
                {
                    if (dispIdMember == DISPID_NEWENUM
                        // && pDispParams.cArgs == 1
                        // && Marshal.ReadInt16(pDispParams.rgvarg) == (short)(VarEnum.VT_BYREF | VarEnum.VT_VARIANT) // AHK specific
                        && _obj is IEnumerable enumerable)
                    {
                        // var ptr_dest = Marshal.ReadIntPtr(pDispParams.rgvarg + 8);
                        var ptr = Marshal.GetComInterfaceForObject(new Enumerator(enumerable.GetEnumerator()), typeof(IEnumVARIANT));
                        // Marshal.WriteInt16(ptr_dest, (short)VarEnum.VT_UNKNOWN);
                        // Marshal.WriteIntPtr(ptr_dest + 8, ptr);
                        Marshal.WriteInt16(VarResult, (short)VarEnum.VT_UNKNOWN);
                        Marshal.WriteIntPtr(VarResult + 8, ptr);
                        return 0;
                    }
                    return DISP_E_MEMBERNOTFOUND;
                }
                if (dispIdMember >= _methods_list.Count || ((methods_or_field = _methods_list[dispIdMember]) == null)) // get_Item/set_Item(always dispId=0) could be null
                {
                    return DISP_E_MEMBERNOTFOUND;
                }

                switch (methods_or_field.First())
                {
                    case MethodInfo method:
                        MethodInfo? found_method = null;
                        ParameterInfo[]? found_parameters = null;
                        found_method = (MethodInfo?)methods_or_field.FirstOrDefault(v =>
                        {
                            MethodInfo method = (MethodInfo)v;
                            ParameterInfo[] parameters = method.GetParameters();
                            if (parameters.Length != pDispParams.cArgs)
                            {
                                return false;
                            }
                            nint j = pDispParams.rgvarg;
                            for (int i = 0; i < parameters.Length; ++i, j += sizeof_VARIANT)
                            {
                                if (!VariantCanConvert(j, parameters[i].ParameterType))
                                {
                                    return false;
                                }
                            }
                            found_parameters = parameters;
                            return true;
                        });
                        if (found_method == null)
                        {
                            return DISP_E_MEMBERNOTFOUND;
                        }
                        var args = DISPPARAMS_to_objectArray(pDispParams, found_parameters!);
                        object? res = found_method.Invoke(_obj, args);
                        if (VarResult != 0)
                        {
                            WriteToVARIANT(res, VarResult);
                        }
                        break;
                    case FieldInfo field:
                        switch (wFlags)
                        {
                            case InvokeFlags.DISPATCH_PROPERTYGET:
                                WriteToVARIANT(field.GetValue(_obj), VarResult);
                                break;
                            case InvokeFlags.DISPATCH_PROPERTYPUT:
                                if (pDispParams.cArgs != 1)
                                {
                                    return DISP_E_MEMBERNOTFOUND;
                                }
                                if (!VariantCanConvert(pDispParams.rgvarg, field.FieldType))
                                {
                                    return DISP_E_MEMBERNOTFOUND;
                                }
                                field.SetValue(_obj, VariantToObject(pDispParams.rgvarg, field.FieldType));
                                break;
                            default:
                                return DISP_E_MEMBERNOTFOUND;
                        }
                        break;
                }
                return 0;
            }
            catch (Exception e)
            {
                Lib.DebugWriteLine(e.ToString());
                throw;
            }
        }
    }

    [Guid("00020404-0000-0000-C000-000000000046")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [ComImport]
    public interface IEnumVARIANT
    {
        [PreserveSig]
        int Next(int celt, nint rgVar, nint pceltFetched);

        [PreserveSig]
        int Skip(int celt);

        [PreserveSig]
        int Reset();

        IEnumVARIANT Clone();
    }

    public class Enumerator : IEnumVARIANT
    {
        public Enumerator(IEnumerator enumerator)
        {
            _enumerator = enumerator;
            _idx = 0;
            _saved = [];
        }

        private IEnumerator _enumerator;
        private int _idx;
        private List<object?> _saved;

        public Enumerator(Enumerator that)
        {
            _enumerator = that._enumerator;
            _idx = that._idx;
            _saved = that._saved;
        }

        public int Next(int celt, nint rgVar, nint pceltFetched)
        {
            int i = 0;
            for (int j = 0; i < celt; ++i, j += Wrapper.sizeof_VARIANT)
            {
                if (_idx >= _saved.Count)
                {
                    if (_enumerator.MoveNext())
                    {
                        _saved.Add(Wrapper.ConditionallyWrap(_enumerator.Current));
                    }
                    else
                    {
                        break;
                    }
                }
                object? res = _saved[_idx];
                nint VarResult = rgVar + j;
                if (res is Wrapper wrapper)
                {
                    Marshal.WriteInt16(VarResult, (short)VarEnum.VT_DISPATCH);
                    Marshal.WriteIntPtr(VarResult, 8, Marshal.GetComInterfaceForObject(wrapper, typeof(IDispatch)));
                }
                else
                {
                    Marshal.GetNativeVariantForObject(res, VarResult);
                }
                ++_idx;
            }
            if (pceltFetched != 0)
            {
                Marshal.WriteInt32(pceltFetched, i);
            }
            if (i == celt)
            {
                return 0;
            }
            else
            {
                return 1;
            }
        }

        public int Skip(int celt)
        {
            // implementation taken from Next(), but trimmed
            int i = 0;
            for (; i < celt; ++i)
            {
                if (_idx >= _saved.Count)
                {
                    if (_enumerator.MoveNext())
                    {
                        _saved.Add(Wrapper.ConditionallyWrap(_enumerator.Current));
                    }
                    else
                    {
                        break;
                    }
                }
                ++_idx;
            }
            if (i == celt)
            {
                return 0;
            }
            else
            {
                return 1;
            }
        }

        public int Reset()
        {
            _idx = 0;
            return 0;
        }

        public IEnumVARIANT Clone()
        {
            return new Enumerator(this);
        }
    }

}
