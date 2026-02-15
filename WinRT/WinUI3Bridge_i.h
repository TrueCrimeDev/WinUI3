

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 8.01.0628 */
/* at Mon Jan 18 22:14:07 2038
 */
/* Compiler settings for WinUI3Bridge.idl:
    Oicf, W1, Zp8, env=Win64 (32b run), target_arch=AMD64 8.01.0628 
    protocol : all , ms_ext, c_ext, robust
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
/* @@MIDL_FILE_HEADING(  ) */



/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 500
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __RPCNDR_H_VERSION__
#error this stub requires an updated version of <rpcndr.h>
#endif /* __RPCNDR_H_VERSION__ */


#ifndef __WinUI3Bridge_i_h__
#define __WinUI3Bridge_i_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#ifndef DECLSPEC_XFGVIRT
#if defined(_CONTROL_FLOW_GUARD_XFG)
#define DECLSPEC_XFGVIRT(base, func) __declspec(xfg_virtual(base, func))
#else
#define DECLSPEC_XFGVIRT(base, func)
#endif
#endif

/* Forward Declarations */ 

#ifndef __IXamlHost_FWD_DEFINED__
#define __IXamlHost_FWD_DEFINED__
typedef interface IXamlHost IXamlHost;

#endif 	/* __IXamlHost_FWD_DEFINED__ */


#ifndef __IXamlElement_FWD_DEFINED__
#define __IXamlElement_FWD_DEFINED__
typedef interface IXamlElement IXamlElement;

#endif 	/* __IXamlElement_FWD_DEFINED__ */


#ifndef __IControlWrapper_FWD_DEFINED__
#define __IControlWrapper_FWD_DEFINED__
typedef interface IControlWrapper IControlWrapper;

#endif 	/* __IControlWrapper_FWD_DEFINED__ */


#ifndef __IButtonWrapper_FWD_DEFINED__
#define __IButtonWrapper_FWD_DEFINED__
typedef interface IButtonWrapper IButtonWrapper;

#endif 	/* __IButtonWrapper_FWD_DEFINED__ */


#ifndef __ITextBoxWrapper_FWD_DEFINED__
#define __ITextBoxWrapper_FWD_DEFINED__
typedef interface ITextBoxWrapper ITextBoxWrapper;

#endif 	/* __ITextBoxWrapper_FWD_DEFINED__ */


#ifndef __ICheckBoxWrapper_FWD_DEFINED__
#define __ICheckBoxWrapper_FWD_DEFINED__
typedef interface ICheckBoxWrapper ICheckBoxWrapper;

#endif 	/* __ICheckBoxWrapper_FWD_DEFINED__ */


#ifndef __IComboBoxWrapper_FWD_DEFINED__
#define __IComboBoxWrapper_FWD_DEFINED__
typedef interface IComboBoxWrapper IComboBoxWrapper;

#endif 	/* __IComboBoxWrapper_FWD_DEFINED__ */


#ifndef __ISliderWrapper_FWD_DEFINED__
#define __ISliderWrapper_FWD_DEFINED__
typedef interface ISliderWrapper ISliderWrapper;

#endif 	/* __ISliderWrapper_FWD_DEFINED__ */


#ifndef __IProgressWrapper_FWD_DEFINED__
#define __IProgressWrapper_FWD_DEFINED__
typedef interface IProgressWrapper IProgressWrapper;

#endif 	/* __IProgressWrapper_FWD_DEFINED__ */


#ifndef __ITextBlockWrapper_FWD_DEFINED__
#define __ITextBlockWrapper_FWD_DEFINED__
typedef interface ITextBlockWrapper ITextBlockWrapper;

#endif 	/* __ITextBlockWrapper_FWD_DEFINED__ */


#ifndef __IListViewWrapper_FWD_DEFINED__
#define __IListViewWrapper_FWD_DEFINED__
typedef interface IListViewWrapper IListViewWrapper;

#endif 	/* __IListViewWrapper_FWD_DEFINED__ */


#ifndef __IToggleSwitchWrapper_FWD_DEFINED__
#define __IToggleSwitchWrapper_FWD_DEFINED__
typedef interface IToggleSwitchWrapper IToggleSwitchWrapper;

#endif 	/* __IToggleSwitchWrapper_FWD_DEFINED__ */


#ifndef __XamlHost_FWD_DEFINED__
#define __XamlHost_FWD_DEFINED__

#ifdef __cplusplus
typedef class XamlHost XamlHost;
#else
typedef struct XamlHost XamlHost;
#endif /* __cplusplus */

#endif 	/* __XamlHost_FWD_DEFINED__ */


#ifndef __XamlElement_FWD_DEFINED__
#define __XamlElement_FWD_DEFINED__

#ifdef __cplusplus
typedef class XamlElement XamlElement;
#else
typedef struct XamlElement XamlElement;
#endif /* __cplusplus */

#endif 	/* __XamlElement_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"

#ifdef __cplusplus
extern "C"{
#endif 



#ifndef __WinUI3BridgeLib_LIBRARY_DEFINED__
#define __WinUI3BridgeLib_LIBRARY_DEFINED__

/* library WinUI3BridgeLib */
/* [helpstring][version][uuid] */ 




typedef /* [v1_enum][uuid] */  DECLSPEC_UUID("A1B2C3D4-0001-0001-0001-000000000001") 
enum Visibility
    {
        Visible	= 0,
        Collapsed	= 1
    } 	Visibility;

typedef /* [v1_enum][uuid] */  DECLSPEC_UUID("A1B2C3D4-0001-0001-0002-000000000001") 
enum TextWrapping
    {
        NoWrap	= 0,
        Wrap	= 1,
        WrapWholeWords	= 2
    } 	TextWrapping;

typedef /* [v1_enum][uuid] */  DECLSPEC_UUID("A1B2C3D4-0001-0001-0003-000000000001") 
enum TextAlignment
    {
        TextAlignLeft	= 0,
        TextAlignCenter	= 1,
        TextAlignRight	= 2,
        TextAlignJustify	= 3
    } 	TextAlignment;

typedef /* [v1_enum][uuid] */  DECLSPEC_UUID("A1B2C3D4-0001-0001-0004-000000000001") 
enum SelectionMode
    {
        SelectNone	= 0,
        SelectSingle	= 1,
        SelectMultiple	= 2,
        SelectExtended	= 3
    } 	SelectionMode;

typedef /* [v1_enum][uuid] */  DECLSPEC_UUID("A1B2C3D4-0001-0001-0005-000000000001") 
enum CheckState
    {
        Unchecked	= 0,
        Checked	= 1,
        Indeterminate	= 2
    } 	CheckState;

typedef /* [v1_enum][uuid] */  DECLSPEC_UUID("A1B2C3D4-0001-0001-0006-000000000001") 
enum Orientation
    {
        Horizontal	= 0,
        Vertical	= 1
    } 	Orientation;


EXTERN_C const IID LIBID_WinUI3BridgeLib;

#ifndef __IXamlHost_INTERFACE_DEFINED__
#define __IXamlHost_INTERFACE_DEFINED__

/* interface IXamlHost */
/* [helpstring][unique][nonextensible][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_IXamlHost;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("F1E2D3C4-B5A6-4978-8C9D-0A1B2C3D4E5F")
    IXamlHost : public IDispatch
    {
    public:
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Initialize( 
            /* [in] */ LONG_PTR parentHwnd,
            /* [retval][out] */ VARIANT_BOOL *pResult) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE LoadXaml( 
            /* [in] */ BSTR xamlString,
            /* [retval][out] */ IDispatch **ppRootElement) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE GetElement( 
            /* [in] */ BSTR name,
            /* [retval][out] */ IDispatch **ppElement) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE GetControl( 
            /* [in] */ BSTR name,
            /* [retval][out] */ IDispatch **ppControl) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE SetEventHandler( 
            /* [in] */ BSTR elementName,
            /* [in] */ BSTR eventName,
            /* [in] */ LONGLONG callbackPtr,
            /* [retval][out] */ VARIANT_BOOL *pResult) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE RemoveEventHandler( 
            /* [in] */ BSTR elementName,
            /* [in] */ BSTR eventName,
            /* [retval][out] */ VARIANT_BOOL *pResult) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Resize( 
            /* [defaultvalue][optional][in] */ LONG width = 0,
            /* [defaultvalue][optional][in] */ LONG height = 0) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Close( void) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Hwnd( 
            /* [retval][out] */ LONG_PTR *pHwnd) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_ParentHwnd( 
            /* [retval][out] */ LONG_PTR *pHwnd) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsInitialized( 
            /* [retval][out] */ VARIANT_BOOL *pResult) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_HasThreadAccess( 
            /* [retval][out] */ VARIANT_BOOL *pResult) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IXamlHostVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IXamlHost * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IXamlHost * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IXamlHost * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IXamlHost * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IXamlHost * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IXamlHost * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IXamlHost * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IXamlHost, Initialize)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Initialize )( 
            IXamlHost * This,
            /* [in] */ LONG_PTR parentHwnd,
            /* [retval][out] */ VARIANT_BOOL *pResult);
        
        DECLSPEC_XFGVIRT(IXamlHost, LoadXaml)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *LoadXaml )( 
            IXamlHost * This,
            /* [in] */ BSTR xamlString,
            /* [retval][out] */ IDispatch **ppRootElement);
        
        DECLSPEC_XFGVIRT(IXamlHost, GetElement)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *GetElement )( 
            IXamlHost * This,
            /* [in] */ BSTR name,
            /* [retval][out] */ IDispatch **ppElement);
        
        DECLSPEC_XFGVIRT(IXamlHost, GetControl)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *GetControl )( 
            IXamlHost * This,
            /* [in] */ BSTR name,
            /* [retval][out] */ IDispatch **ppControl);
        
        DECLSPEC_XFGVIRT(IXamlHost, SetEventHandler)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *SetEventHandler )( 
            IXamlHost * This,
            /* [in] */ BSTR elementName,
            /* [in] */ BSTR eventName,
            /* [in] */ LONGLONG callbackPtr,
            /* [retval][out] */ VARIANT_BOOL *pResult);
        
        DECLSPEC_XFGVIRT(IXamlHost, RemoveEventHandler)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *RemoveEventHandler )( 
            IXamlHost * This,
            /* [in] */ BSTR elementName,
            /* [in] */ BSTR eventName,
            /* [retval][out] */ VARIANT_BOOL *pResult);
        
        DECLSPEC_XFGVIRT(IXamlHost, Resize)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Resize )( 
            IXamlHost * This,
            /* [defaultvalue][optional][in] */ LONG width,
            /* [defaultvalue][optional][in] */ LONG height);
        
        DECLSPEC_XFGVIRT(IXamlHost, Close)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Close )( 
            IXamlHost * This);
        
        DECLSPEC_XFGVIRT(IXamlHost, get_Hwnd)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Hwnd )( 
            IXamlHost * This,
            /* [retval][out] */ LONG_PTR *pHwnd);
        
        DECLSPEC_XFGVIRT(IXamlHost, get_ParentHwnd)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ParentHwnd )( 
            IXamlHost * This,
            /* [retval][out] */ LONG_PTR *pHwnd);
        
        DECLSPEC_XFGVIRT(IXamlHost, get_IsInitialized)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsInitialized )( 
            IXamlHost * This,
            /* [retval][out] */ VARIANT_BOOL *pResult);
        
        DECLSPEC_XFGVIRT(IXamlHost, get_HasThreadAccess)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_HasThreadAccess )( 
            IXamlHost * This,
            /* [retval][out] */ VARIANT_BOOL *pResult);
        
        END_INTERFACE
    } IXamlHostVtbl;

    interface IXamlHost
    {
        CONST_VTBL struct IXamlHostVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IXamlHost_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IXamlHost_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IXamlHost_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IXamlHost_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IXamlHost_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IXamlHost_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IXamlHost_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IXamlHost_Initialize(This,parentHwnd,pResult)	\
    ( (This)->lpVtbl -> Initialize(This,parentHwnd,pResult) ) 

#define IXamlHost_LoadXaml(This,xamlString,ppRootElement)	\
    ( (This)->lpVtbl -> LoadXaml(This,xamlString,ppRootElement) ) 

#define IXamlHost_GetElement(This,name,ppElement)	\
    ( (This)->lpVtbl -> GetElement(This,name,ppElement) ) 

#define IXamlHost_GetControl(This,name,ppControl)	\
    ( (This)->lpVtbl -> GetControl(This,name,ppControl) ) 

#define IXamlHost_SetEventHandler(This,elementName,eventName,callbackPtr,pResult)	\
    ( (This)->lpVtbl -> SetEventHandler(This,elementName,eventName,callbackPtr,pResult) ) 

#define IXamlHost_RemoveEventHandler(This,elementName,eventName,pResult)	\
    ( (This)->lpVtbl -> RemoveEventHandler(This,elementName,eventName,pResult) ) 

#define IXamlHost_Resize(This,width,height)	\
    ( (This)->lpVtbl -> Resize(This,width,height) ) 

#define IXamlHost_Close(This)	\
    ( (This)->lpVtbl -> Close(This) ) 

#define IXamlHost_get_Hwnd(This,pHwnd)	\
    ( (This)->lpVtbl -> get_Hwnd(This,pHwnd) ) 

#define IXamlHost_get_ParentHwnd(This,pHwnd)	\
    ( (This)->lpVtbl -> get_ParentHwnd(This,pHwnd) ) 

#define IXamlHost_get_IsInitialized(This,pResult)	\
    ( (This)->lpVtbl -> get_IsInitialized(This,pResult) ) 

#define IXamlHost_get_HasThreadAccess(This,pResult)	\
    ( (This)->lpVtbl -> get_HasThreadAccess(This,pResult) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IXamlHost_INTERFACE_DEFINED__ */


#ifndef __IXamlElement_INTERFACE_DEFINED__
#define __IXamlElement_INTERFACE_DEFINED__

/* interface IXamlElement */
/* [helpstring][unique][nonextensible][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_IXamlElement;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("A2B3C4D5-E6F7-4089-9A0B-1C2D3E4F5A6B")
    IXamlElement : public IDispatch
    {
    public:
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Name( 
            /* [retval][out] */ BSTR *pName) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_ClassName( 
            /* [retval][out] */ BSTR *pClassName) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Width( 
            /* [retval][out] */ DOUBLE *pWidth) = 0;
        
        virtual /* [helpstring][propput][id] */ HRESULT STDMETHODCALLTYPE put_Width( 
            /* [in] */ DOUBLE width) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Height( 
            /* [retval][out] */ DOUBLE *pHeight) = 0;
        
        virtual /* [helpstring][propput][id] */ HRESULT STDMETHODCALLTYPE put_Height( 
            /* [in] */ DOUBLE height) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsEnabled( 
            /* [retval][out] */ VARIANT_BOOL *pEnabled) = 0;
        
        virtual /* [helpstring][propput][id] */ HRESULT STDMETHODCALLTYPE put_IsEnabled( 
            /* [in] */ VARIANT_BOOL enabled) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Visibility( 
            /* [retval][out] */ Visibility *pVisibility) = 0;
        
        virtual /* [helpstring][propput][id] */ HRESULT STDMETHODCALLTYPE put_Visibility( 
            /* [in] */ Visibility visibility) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Content( 
            /* [retval][out] */ BSTR *pContent) = 0;
        
        virtual /* [helpstring][propput][id] */ HRESULT STDMETHODCALLTYPE put_Content( 
            /* [in] */ BSTR content) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Text( 
            /* [retval][out] */ BSTR *pText) = 0;
        
        virtual /* [helpstring][propput][id] */ HRESULT STDMETHODCALLTYPE put_Text( 
            /* [in] */ BSTR text) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Focus( 
            /* [retval][out] */ VARIANT_BOOL *pSuccess) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE GetProperty( 
            /* [in] */ BSTR propertyName,
            /* [retval][out] */ VARIANT *pValue) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE SetProperty( 
            /* [in] */ BSTR propertyName,
            /* [in] */ VARIANT value) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IXamlElementVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IXamlElement * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IXamlElement * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IXamlElement * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IXamlElement * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IXamlElement * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IXamlElement * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IXamlElement * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IXamlElement, get_Name)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Name )( 
            IXamlElement * This,
            /* [retval][out] */ BSTR *pName);
        
        DECLSPEC_XFGVIRT(IXamlElement, get_ClassName)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ClassName )( 
            IXamlElement * This,
            /* [retval][out] */ BSTR *pClassName);
        
        DECLSPEC_XFGVIRT(IXamlElement, get_Width)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Width )( 
            IXamlElement * This,
            /* [retval][out] */ DOUBLE *pWidth);
        
        DECLSPEC_XFGVIRT(IXamlElement, put_Width)
        /* [helpstring][propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Width )( 
            IXamlElement * This,
            /* [in] */ DOUBLE width);
        
        DECLSPEC_XFGVIRT(IXamlElement, get_Height)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Height )( 
            IXamlElement * This,
            /* [retval][out] */ DOUBLE *pHeight);
        
        DECLSPEC_XFGVIRT(IXamlElement, put_Height)
        /* [helpstring][propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Height )( 
            IXamlElement * This,
            /* [in] */ DOUBLE height);
        
        DECLSPEC_XFGVIRT(IXamlElement, get_IsEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEnabled )( 
            IXamlElement * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(IXamlElement, put_IsEnabled)
        /* [helpstring][propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEnabled )( 
            IXamlElement * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        DECLSPEC_XFGVIRT(IXamlElement, get_Visibility)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Visibility )( 
            IXamlElement * This,
            /* [retval][out] */ Visibility *pVisibility);
        
        DECLSPEC_XFGVIRT(IXamlElement, put_Visibility)
        /* [helpstring][propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Visibility )( 
            IXamlElement * This,
            /* [in] */ Visibility visibility);
        
        DECLSPEC_XFGVIRT(IXamlElement, get_Content)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Content )( 
            IXamlElement * This,
            /* [retval][out] */ BSTR *pContent);
        
        DECLSPEC_XFGVIRT(IXamlElement, put_Content)
        /* [helpstring][propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Content )( 
            IXamlElement * This,
            /* [in] */ BSTR content);
        
        DECLSPEC_XFGVIRT(IXamlElement, get_Text)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Text )( 
            IXamlElement * This,
            /* [retval][out] */ BSTR *pText);
        
        DECLSPEC_XFGVIRT(IXamlElement, put_Text)
        /* [helpstring][propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Text )( 
            IXamlElement * This,
            /* [in] */ BSTR text);
        
        DECLSPEC_XFGVIRT(IXamlElement, Focus)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Focus )( 
            IXamlElement * This,
            /* [retval][out] */ VARIANT_BOOL *pSuccess);
        
        DECLSPEC_XFGVIRT(IXamlElement, GetProperty)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *GetProperty )( 
            IXamlElement * This,
            /* [in] */ BSTR propertyName,
            /* [retval][out] */ VARIANT *pValue);
        
        DECLSPEC_XFGVIRT(IXamlElement, SetProperty)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *SetProperty )( 
            IXamlElement * This,
            /* [in] */ BSTR propertyName,
            /* [in] */ VARIANT value);
        
        END_INTERFACE
    } IXamlElementVtbl;

    interface IXamlElement
    {
        CONST_VTBL struct IXamlElementVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IXamlElement_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IXamlElement_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IXamlElement_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IXamlElement_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IXamlElement_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IXamlElement_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IXamlElement_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IXamlElement_get_Name(This,pName)	\
    ( (This)->lpVtbl -> get_Name(This,pName) ) 

#define IXamlElement_get_ClassName(This,pClassName)	\
    ( (This)->lpVtbl -> get_ClassName(This,pClassName) ) 

#define IXamlElement_get_Width(This,pWidth)	\
    ( (This)->lpVtbl -> get_Width(This,pWidth) ) 

#define IXamlElement_put_Width(This,width)	\
    ( (This)->lpVtbl -> put_Width(This,width) ) 

#define IXamlElement_get_Height(This,pHeight)	\
    ( (This)->lpVtbl -> get_Height(This,pHeight) ) 

#define IXamlElement_put_Height(This,height)	\
    ( (This)->lpVtbl -> put_Height(This,height) ) 

#define IXamlElement_get_IsEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsEnabled(This,pEnabled) ) 

#define IXamlElement_put_IsEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsEnabled(This,enabled) ) 

#define IXamlElement_get_Visibility(This,pVisibility)	\
    ( (This)->lpVtbl -> get_Visibility(This,pVisibility) ) 

#define IXamlElement_put_Visibility(This,visibility)	\
    ( (This)->lpVtbl -> put_Visibility(This,visibility) ) 

#define IXamlElement_get_Content(This,pContent)	\
    ( (This)->lpVtbl -> get_Content(This,pContent) ) 

#define IXamlElement_put_Content(This,content)	\
    ( (This)->lpVtbl -> put_Content(This,content) ) 

#define IXamlElement_get_Text(This,pText)	\
    ( (This)->lpVtbl -> get_Text(This,pText) ) 

#define IXamlElement_put_Text(This,text)	\
    ( (This)->lpVtbl -> put_Text(This,text) ) 

#define IXamlElement_Focus(This,pSuccess)	\
    ( (This)->lpVtbl -> Focus(This,pSuccess) ) 

#define IXamlElement_GetProperty(This,propertyName,pValue)	\
    ( (This)->lpVtbl -> GetProperty(This,propertyName,pValue) ) 

#define IXamlElement_SetProperty(This,propertyName,value)	\
    ( (This)->lpVtbl -> SetProperty(This,propertyName,value) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IXamlElement_INTERFACE_DEFINED__ */


#ifndef __IControlWrapper_INTERFACE_DEFINED__
#define __IControlWrapper_INTERFACE_DEFINED__

/* interface IControlWrapper */
/* [helpstring][unique][nonextensible][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_IControlWrapper;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("B3C4D5E6-F7A8-4190-0B1C-2D3E4F5A6B7C")
    IControlWrapper : public IDispatch
    {
    public:
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Name( 
            /* [retval][out] */ BSTR *pName) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_ControlType( 
            /* [retval][out] */ BSTR *pType) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsValid( 
            /* [retval][out] */ VARIANT_BOOL *pValid) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Width( 
            /* [retval][out] */ DOUBLE *pWidth) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Width( 
            /* [in] */ DOUBLE width) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Height( 
            /* [retval][out] */ DOUBLE *pHeight) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Height( 
            /* [in] */ DOUBLE height) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsEnabled( 
            /* [retval][out] */ VARIANT_BOOL *pEnabled) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_IsEnabled( 
            /* [in] */ VARIANT_BOOL enabled) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Visibility( 
            /* [retval][out] */ LONG *pVisibility) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Visibility( 
            /* [in] */ LONG visibility) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Focus( 
            /* [retval][out] */ VARIANT_BOOL *pSuccess) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IControlWrapperVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IControlWrapper * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IControlWrapper * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IControlWrapper * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IControlWrapper * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IControlWrapper * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IControlWrapper * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IControlWrapper * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Name)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Name )( 
            IControlWrapper * This,
            /* [retval][out] */ BSTR *pName);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_ControlType)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ControlType )( 
            IControlWrapper * This,
            /* [retval][out] */ BSTR *pType);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsValid)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsValid )( 
            IControlWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pValid);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Width)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Width )( 
            IControlWrapper * This,
            /* [retval][out] */ DOUBLE *pWidth);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Width)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Width )( 
            IControlWrapper * This,
            /* [in] */ DOUBLE width);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Height)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Height )( 
            IControlWrapper * This,
            /* [retval][out] */ DOUBLE *pHeight);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Height)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Height )( 
            IControlWrapper * This,
            /* [in] */ DOUBLE height);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEnabled )( 
            IControlWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_IsEnabled)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEnabled )( 
            IControlWrapper * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Visibility)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Visibility )( 
            IControlWrapper * This,
            /* [retval][out] */ LONG *pVisibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Visibility)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Visibility )( 
            IControlWrapper * This,
            /* [in] */ LONG visibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, Focus)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Focus )( 
            IControlWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pSuccess);
        
        END_INTERFACE
    } IControlWrapperVtbl;

    interface IControlWrapper
    {
        CONST_VTBL struct IControlWrapperVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IControlWrapper_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IControlWrapper_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IControlWrapper_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IControlWrapper_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IControlWrapper_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IControlWrapper_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IControlWrapper_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IControlWrapper_get_Name(This,pName)	\
    ( (This)->lpVtbl -> get_Name(This,pName) ) 

#define IControlWrapper_get_ControlType(This,pType)	\
    ( (This)->lpVtbl -> get_ControlType(This,pType) ) 

#define IControlWrapper_get_IsValid(This,pValid)	\
    ( (This)->lpVtbl -> get_IsValid(This,pValid) ) 

#define IControlWrapper_get_Width(This,pWidth)	\
    ( (This)->lpVtbl -> get_Width(This,pWidth) ) 

#define IControlWrapper_put_Width(This,width)	\
    ( (This)->lpVtbl -> put_Width(This,width) ) 

#define IControlWrapper_get_Height(This,pHeight)	\
    ( (This)->lpVtbl -> get_Height(This,pHeight) ) 

#define IControlWrapper_put_Height(This,height)	\
    ( (This)->lpVtbl -> put_Height(This,height) ) 

#define IControlWrapper_get_IsEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsEnabled(This,pEnabled) ) 

#define IControlWrapper_put_IsEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsEnabled(This,enabled) ) 

#define IControlWrapper_get_Visibility(This,pVisibility)	\
    ( (This)->lpVtbl -> get_Visibility(This,pVisibility) ) 

#define IControlWrapper_put_Visibility(This,visibility)	\
    ( (This)->lpVtbl -> put_Visibility(This,visibility) ) 

#define IControlWrapper_Focus(This,pSuccess)	\
    ( (This)->lpVtbl -> Focus(This,pSuccess) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IControlWrapper_INTERFACE_DEFINED__ */


#ifndef __IButtonWrapper_INTERFACE_DEFINED__
#define __IButtonWrapper_INTERFACE_DEFINED__

/* interface IButtonWrapper */
/* [helpstring][unique][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_IButtonWrapper;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("C4D5E6F7-A8B9-4201-1C2D-3E4F5A6B7C8D")
    IButtonWrapper : public IControlWrapper
    {
    public:
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Content( 
            /* [retval][out] */ BSTR *pContent) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Content( 
            /* [in] */ BSTR content) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsPressed( 
            /* [retval][out] */ VARIANT_BOOL *pPressed) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_IsPressed( 
            /* [in] */ VARIANT_BOOL pressed) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Click( void) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IButtonWrapperVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IButtonWrapper * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IButtonWrapper * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IButtonWrapper * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IButtonWrapper * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IButtonWrapper * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IButtonWrapper * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IButtonWrapper * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Name)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Name )( 
            IButtonWrapper * This,
            /* [retval][out] */ BSTR *pName);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_ControlType)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ControlType )( 
            IButtonWrapper * This,
            /* [retval][out] */ BSTR *pType);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsValid)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsValid )( 
            IButtonWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pValid);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Width)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Width )( 
            IButtonWrapper * This,
            /* [retval][out] */ DOUBLE *pWidth);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Width)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Width )( 
            IButtonWrapper * This,
            /* [in] */ DOUBLE width);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Height)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Height )( 
            IButtonWrapper * This,
            /* [retval][out] */ DOUBLE *pHeight);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Height)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Height )( 
            IButtonWrapper * This,
            /* [in] */ DOUBLE height);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEnabled )( 
            IButtonWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_IsEnabled)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEnabled )( 
            IButtonWrapper * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Visibility)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Visibility )( 
            IButtonWrapper * This,
            /* [retval][out] */ LONG *pVisibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Visibility)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Visibility )( 
            IButtonWrapper * This,
            /* [in] */ LONG visibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, Focus)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Focus )( 
            IButtonWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pSuccess);
        
        DECLSPEC_XFGVIRT(IButtonWrapper, get_Content)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Content )( 
            IButtonWrapper * This,
            /* [retval][out] */ BSTR *pContent);
        
        DECLSPEC_XFGVIRT(IButtonWrapper, put_Content)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Content )( 
            IButtonWrapper * This,
            /* [in] */ BSTR content);
        
        DECLSPEC_XFGVIRT(IButtonWrapper, get_IsPressed)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsPressed )( 
            IButtonWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pPressed);
        
        DECLSPEC_XFGVIRT(IButtonWrapper, put_IsPressed)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsPressed )( 
            IButtonWrapper * This,
            /* [in] */ VARIANT_BOOL pressed);
        
        DECLSPEC_XFGVIRT(IButtonWrapper, Click)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Click )( 
            IButtonWrapper * This);
        
        END_INTERFACE
    } IButtonWrapperVtbl;

    interface IButtonWrapper
    {
        CONST_VTBL struct IButtonWrapperVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IButtonWrapper_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IButtonWrapper_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IButtonWrapper_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IButtonWrapper_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IButtonWrapper_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IButtonWrapper_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IButtonWrapper_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IButtonWrapper_get_Name(This,pName)	\
    ( (This)->lpVtbl -> get_Name(This,pName) ) 

#define IButtonWrapper_get_ControlType(This,pType)	\
    ( (This)->lpVtbl -> get_ControlType(This,pType) ) 

#define IButtonWrapper_get_IsValid(This,pValid)	\
    ( (This)->lpVtbl -> get_IsValid(This,pValid) ) 

#define IButtonWrapper_get_Width(This,pWidth)	\
    ( (This)->lpVtbl -> get_Width(This,pWidth) ) 

#define IButtonWrapper_put_Width(This,width)	\
    ( (This)->lpVtbl -> put_Width(This,width) ) 

#define IButtonWrapper_get_Height(This,pHeight)	\
    ( (This)->lpVtbl -> get_Height(This,pHeight) ) 

#define IButtonWrapper_put_Height(This,height)	\
    ( (This)->lpVtbl -> put_Height(This,height) ) 

#define IButtonWrapper_get_IsEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsEnabled(This,pEnabled) ) 

#define IButtonWrapper_put_IsEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsEnabled(This,enabled) ) 

#define IButtonWrapper_get_Visibility(This,pVisibility)	\
    ( (This)->lpVtbl -> get_Visibility(This,pVisibility) ) 

#define IButtonWrapper_put_Visibility(This,visibility)	\
    ( (This)->lpVtbl -> put_Visibility(This,visibility) ) 

#define IButtonWrapper_Focus(This,pSuccess)	\
    ( (This)->lpVtbl -> Focus(This,pSuccess) ) 


#define IButtonWrapper_get_Content(This,pContent)	\
    ( (This)->lpVtbl -> get_Content(This,pContent) ) 

#define IButtonWrapper_put_Content(This,content)	\
    ( (This)->lpVtbl -> put_Content(This,content) ) 

#define IButtonWrapper_get_IsPressed(This,pPressed)	\
    ( (This)->lpVtbl -> get_IsPressed(This,pPressed) ) 

#define IButtonWrapper_put_IsPressed(This,pressed)	\
    ( (This)->lpVtbl -> put_IsPressed(This,pressed) ) 

#define IButtonWrapper_Click(This)	\
    ( (This)->lpVtbl -> Click(This) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IButtonWrapper_INTERFACE_DEFINED__ */


#ifndef __ITextBoxWrapper_INTERFACE_DEFINED__
#define __ITextBoxWrapper_INTERFACE_DEFINED__

/* interface ITextBoxWrapper */
/* [helpstring][unique][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_ITextBoxWrapper;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("D5E6F7A8-B9C0-4312-2D3E-4F5A6B7C8D9E")
    ITextBoxWrapper : public IControlWrapper
    {
    public:
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Text( 
            /* [retval][out] */ BSTR *pText) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Text( 
            /* [in] */ BSTR text) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_PlaceholderText( 
            /* [retval][out] */ BSTR *pText) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_PlaceholderText( 
            /* [in] */ BSTR text) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_SelectionStart( 
            /* [retval][out] */ LONG *pStart) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_SelectionStart( 
            /* [in] */ LONG start) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_SelectionLength( 
            /* [retval][out] */ LONG *pLength) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_SelectionLength( 
            /* [in] */ LONG length) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_SelectedText( 
            /* [retval][out] */ BSTR *pText) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsReadOnly( 
            /* [retval][out] */ VARIANT_BOOL *pReadOnly) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_IsReadOnly( 
            /* [in] */ VARIANT_BOOL readOnly) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_MaxLength( 
            /* [retval][out] */ LONG *pLength) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_MaxLength( 
            /* [in] */ LONG length) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE SelectAll( void) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Clear( void) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct ITextBoxWrapperVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            ITextBoxWrapper * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            ITextBoxWrapper * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            ITextBoxWrapper * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            ITextBoxWrapper * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            ITextBoxWrapper * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            ITextBoxWrapper * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            ITextBoxWrapper * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Name)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Name )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ BSTR *pName);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_ControlType)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ControlType )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ BSTR *pType);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsValid)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsValid )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pValid);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Width)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Width )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ DOUBLE *pWidth);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Width)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Width )( 
            ITextBoxWrapper * This,
            /* [in] */ DOUBLE width);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Height)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Height )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ DOUBLE *pHeight);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Height)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Height )( 
            ITextBoxWrapper * This,
            /* [in] */ DOUBLE height);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEnabled )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_IsEnabled)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEnabled )( 
            ITextBoxWrapper * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Visibility)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Visibility )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ LONG *pVisibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Visibility)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Visibility )( 
            ITextBoxWrapper * This,
            /* [in] */ LONG visibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, Focus)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Focus )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pSuccess);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, get_Text)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Text )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ BSTR *pText);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, put_Text)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Text )( 
            ITextBoxWrapper * This,
            /* [in] */ BSTR text);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, get_PlaceholderText)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_PlaceholderText )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ BSTR *pText);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, put_PlaceholderText)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_PlaceholderText )( 
            ITextBoxWrapper * This,
            /* [in] */ BSTR text);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, get_SelectionStart)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_SelectionStart )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ LONG *pStart);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, put_SelectionStart)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_SelectionStart )( 
            ITextBoxWrapper * This,
            /* [in] */ LONG start);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, get_SelectionLength)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_SelectionLength )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ LONG *pLength);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, put_SelectionLength)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_SelectionLength )( 
            ITextBoxWrapper * This,
            /* [in] */ LONG length);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, get_SelectedText)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_SelectedText )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ BSTR *pText);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, get_IsReadOnly)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsReadOnly )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pReadOnly);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, put_IsReadOnly)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsReadOnly )( 
            ITextBoxWrapper * This,
            /* [in] */ VARIANT_BOOL readOnly);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, get_MaxLength)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_MaxLength )( 
            ITextBoxWrapper * This,
            /* [retval][out] */ LONG *pLength);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, put_MaxLength)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_MaxLength )( 
            ITextBoxWrapper * This,
            /* [in] */ LONG length);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, SelectAll)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *SelectAll )( 
            ITextBoxWrapper * This);
        
        DECLSPEC_XFGVIRT(ITextBoxWrapper, Clear)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Clear )( 
            ITextBoxWrapper * This);
        
        END_INTERFACE
    } ITextBoxWrapperVtbl;

    interface ITextBoxWrapper
    {
        CONST_VTBL struct ITextBoxWrapperVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ITextBoxWrapper_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define ITextBoxWrapper_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define ITextBoxWrapper_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define ITextBoxWrapper_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define ITextBoxWrapper_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define ITextBoxWrapper_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define ITextBoxWrapper_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define ITextBoxWrapper_get_Name(This,pName)	\
    ( (This)->lpVtbl -> get_Name(This,pName) ) 

#define ITextBoxWrapper_get_ControlType(This,pType)	\
    ( (This)->lpVtbl -> get_ControlType(This,pType) ) 

#define ITextBoxWrapper_get_IsValid(This,pValid)	\
    ( (This)->lpVtbl -> get_IsValid(This,pValid) ) 

#define ITextBoxWrapper_get_Width(This,pWidth)	\
    ( (This)->lpVtbl -> get_Width(This,pWidth) ) 

#define ITextBoxWrapper_put_Width(This,width)	\
    ( (This)->lpVtbl -> put_Width(This,width) ) 

#define ITextBoxWrapper_get_Height(This,pHeight)	\
    ( (This)->lpVtbl -> get_Height(This,pHeight) ) 

#define ITextBoxWrapper_put_Height(This,height)	\
    ( (This)->lpVtbl -> put_Height(This,height) ) 

#define ITextBoxWrapper_get_IsEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsEnabled(This,pEnabled) ) 

#define ITextBoxWrapper_put_IsEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsEnabled(This,enabled) ) 

#define ITextBoxWrapper_get_Visibility(This,pVisibility)	\
    ( (This)->lpVtbl -> get_Visibility(This,pVisibility) ) 

#define ITextBoxWrapper_put_Visibility(This,visibility)	\
    ( (This)->lpVtbl -> put_Visibility(This,visibility) ) 

#define ITextBoxWrapper_Focus(This,pSuccess)	\
    ( (This)->lpVtbl -> Focus(This,pSuccess) ) 


#define ITextBoxWrapper_get_Text(This,pText)	\
    ( (This)->lpVtbl -> get_Text(This,pText) ) 

#define ITextBoxWrapper_put_Text(This,text)	\
    ( (This)->lpVtbl -> put_Text(This,text) ) 

#define ITextBoxWrapper_get_PlaceholderText(This,pText)	\
    ( (This)->lpVtbl -> get_PlaceholderText(This,pText) ) 

#define ITextBoxWrapper_put_PlaceholderText(This,text)	\
    ( (This)->lpVtbl -> put_PlaceholderText(This,text) ) 

#define ITextBoxWrapper_get_SelectionStart(This,pStart)	\
    ( (This)->lpVtbl -> get_SelectionStart(This,pStart) ) 

#define ITextBoxWrapper_put_SelectionStart(This,start)	\
    ( (This)->lpVtbl -> put_SelectionStart(This,start) ) 

#define ITextBoxWrapper_get_SelectionLength(This,pLength)	\
    ( (This)->lpVtbl -> get_SelectionLength(This,pLength) ) 

#define ITextBoxWrapper_put_SelectionLength(This,length)	\
    ( (This)->lpVtbl -> put_SelectionLength(This,length) ) 

#define ITextBoxWrapper_get_SelectedText(This,pText)	\
    ( (This)->lpVtbl -> get_SelectedText(This,pText) ) 

#define ITextBoxWrapper_get_IsReadOnly(This,pReadOnly)	\
    ( (This)->lpVtbl -> get_IsReadOnly(This,pReadOnly) ) 

#define ITextBoxWrapper_put_IsReadOnly(This,readOnly)	\
    ( (This)->lpVtbl -> put_IsReadOnly(This,readOnly) ) 

#define ITextBoxWrapper_get_MaxLength(This,pLength)	\
    ( (This)->lpVtbl -> get_MaxLength(This,pLength) ) 

#define ITextBoxWrapper_put_MaxLength(This,length)	\
    ( (This)->lpVtbl -> put_MaxLength(This,length) ) 

#define ITextBoxWrapper_SelectAll(This)	\
    ( (This)->lpVtbl -> SelectAll(This) ) 

#define ITextBoxWrapper_Clear(This)	\
    ( (This)->lpVtbl -> Clear(This) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __ITextBoxWrapper_INTERFACE_DEFINED__ */


#ifndef __ICheckBoxWrapper_INTERFACE_DEFINED__
#define __ICheckBoxWrapper_INTERFACE_DEFINED__

/* interface ICheckBoxWrapper */
/* [helpstring][unique][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_ICheckBoxWrapper;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("E6F7A8B9-C0D1-4423-3E4F-5A6B7C8D9E0F")
    ICheckBoxWrapper : public IControlWrapper
    {
    public:
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Content( 
            /* [retval][out] */ BSTR *pContent) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Content( 
            /* [in] */ BSTR content) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsChecked( 
            /* [retval][out] */ CheckState *pState) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_IsChecked( 
            /* [in] */ CheckState state) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsThreeState( 
            /* [retval][out] */ VARIANT_BOOL *pThreeState) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_IsThreeState( 
            /* [in] */ VARIANT_BOOL threeState) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct ICheckBoxWrapperVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            ICheckBoxWrapper * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            ICheckBoxWrapper * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            ICheckBoxWrapper * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            ICheckBoxWrapper * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            ICheckBoxWrapper * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            ICheckBoxWrapper * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            ICheckBoxWrapper * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Name)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Name )( 
            ICheckBoxWrapper * This,
            /* [retval][out] */ BSTR *pName);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_ControlType)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ControlType )( 
            ICheckBoxWrapper * This,
            /* [retval][out] */ BSTR *pType);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsValid)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsValid )( 
            ICheckBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pValid);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Width)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Width )( 
            ICheckBoxWrapper * This,
            /* [retval][out] */ DOUBLE *pWidth);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Width)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Width )( 
            ICheckBoxWrapper * This,
            /* [in] */ DOUBLE width);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Height)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Height )( 
            ICheckBoxWrapper * This,
            /* [retval][out] */ DOUBLE *pHeight);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Height)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Height )( 
            ICheckBoxWrapper * This,
            /* [in] */ DOUBLE height);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEnabled )( 
            ICheckBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_IsEnabled)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEnabled )( 
            ICheckBoxWrapper * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Visibility)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Visibility )( 
            ICheckBoxWrapper * This,
            /* [retval][out] */ LONG *pVisibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Visibility)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Visibility )( 
            ICheckBoxWrapper * This,
            /* [in] */ LONG visibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, Focus)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Focus )( 
            ICheckBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pSuccess);
        
        DECLSPEC_XFGVIRT(ICheckBoxWrapper, get_Content)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Content )( 
            ICheckBoxWrapper * This,
            /* [retval][out] */ BSTR *pContent);
        
        DECLSPEC_XFGVIRT(ICheckBoxWrapper, put_Content)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Content )( 
            ICheckBoxWrapper * This,
            /* [in] */ BSTR content);
        
        DECLSPEC_XFGVIRT(ICheckBoxWrapper, get_IsChecked)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsChecked )( 
            ICheckBoxWrapper * This,
            /* [retval][out] */ CheckState *pState);
        
        DECLSPEC_XFGVIRT(ICheckBoxWrapper, put_IsChecked)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsChecked )( 
            ICheckBoxWrapper * This,
            /* [in] */ CheckState state);
        
        DECLSPEC_XFGVIRT(ICheckBoxWrapper, get_IsThreeState)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsThreeState )( 
            ICheckBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pThreeState);
        
        DECLSPEC_XFGVIRT(ICheckBoxWrapper, put_IsThreeState)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsThreeState )( 
            ICheckBoxWrapper * This,
            /* [in] */ VARIANT_BOOL threeState);
        
        END_INTERFACE
    } ICheckBoxWrapperVtbl;

    interface ICheckBoxWrapper
    {
        CONST_VTBL struct ICheckBoxWrapperVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ICheckBoxWrapper_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define ICheckBoxWrapper_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define ICheckBoxWrapper_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define ICheckBoxWrapper_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define ICheckBoxWrapper_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define ICheckBoxWrapper_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define ICheckBoxWrapper_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define ICheckBoxWrapper_get_Name(This,pName)	\
    ( (This)->lpVtbl -> get_Name(This,pName) ) 

#define ICheckBoxWrapper_get_ControlType(This,pType)	\
    ( (This)->lpVtbl -> get_ControlType(This,pType) ) 

#define ICheckBoxWrapper_get_IsValid(This,pValid)	\
    ( (This)->lpVtbl -> get_IsValid(This,pValid) ) 

#define ICheckBoxWrapper_get_Width(This,pWidth)	\
    ( (This)->lpVtbl -> get_Width(This,pWidth) ) 

#define ICheckBoxWrapper_put_Width(This,width)	\
    ( (This)->lpVtbl -> put_Width(This,width) ) 

#define ICheckBoxWrapper_get_Height(This,pHeight)	\
    ( (This)->lpVtbl -> get_Height(This,pHeight) ) 

#define ICheckBoxWrapper_put_Height(This,height)	\
    ( (This)->lpVtbl -> put_Height(This,height) ) 

#define ICheckBoxWrapper_get_IsEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsEnabled(This,pEnabled) ) 

#define ICheckBoxWrapper_put_IsEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsEnabled(This,enabled) ) 

#define ICheckBoxWrapper_get_Visibility(This,pVisibility)	\
    ( (This)->lpVtbl -> get_Visibility(This,pVisibility) ) 

#define ICheckBoxWrapper_put_Visibility(This,visibility)	\
    ( (This)->lpVtbl -> put_Visibility(This,visibility) ) 

#define ICheckBoxWrapper_Focus(This,pSuccess)	\
    ( (This)->lpVtbl -> Focus(This,pSuccess) ) 


#define ICheckBoxWrapper_get_Content(This,pContent)	\
    ( (This)->lpVtbl -> get_Content(This,pContent) ) 

#define ICheckBoxWrapper_put_Content(This,content)	\
    ( (This)->lpVtbl -> put_Content(This,content) ) 

#define ICheckBoxWrapper_get_IsChecked(This,pState)	\
    ( (This)->lpVtbl -> get_IsChecked(This,pState) ) 

#define ICheckBoxWrapper_put_IsChecked(This,state)	\
    ( (This)->lpVtbl -> put_IsChecked(This,state) ) 

#define ICheckBoxWrapper_get_IsThreeState(This,pThreeState)	\
    ( (This)->lpVtbl -> get_IsThreeState(This,pThreeState) ) 

#define ICheckBoxWrapper_put_IsThreeState(This,threeState)	\
    ( (This)->lpVtbl -> put_IsThreeState(This,threeState) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __ICheckBoxWrapper_INTERFACE_DEFINED__ */


#ifndef __IComboBoxWrapper_INTERFACE_DEFINED__
#define __IComboBoxWrapper_INTERFACE_DEFINED__

/* interface IComboBoxWrapper */
/* [helpstring][unique][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_IComboBoxWrapper;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("F7A8B9C0-D1E2-4534-4F5A-6B7C8D9E0F1A")
    IComboBoxWrapper : public IControlWrapper
    {
    public:
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_SelectedIndex( 
            /* [retval][out] */ LONG *pIndex) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_SelectedIndex( 
            /* [in] */ LONG index) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_SelectedText( 
            /* [retval][out] */ BSTR *pText) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_ItemCount( 
            /* [retval][out] */ LONG *pCount) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_PlaceholderText( 
            /* [retval][out] */ BSTR *pText) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_PlaceholderText( 
            /* [in] */ BSTR text) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsEditable( 
            /* [retval][out] */ VARIANT_BOOL *pEditable) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_IsEditable( 
            /* [in] */ VARIANT_BOOL editable) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE AddItem( 
            /* [in] */ BSTR text) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE RemoveAt( 
            /* [in] */ LONG index) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Clear( void) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE GetAt( 
            /* [in] */ LONG index,
            /* [retval][out] */ BSTR *pText) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IComboBoxWrapperVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IComboBoxWrapper * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IComboBoxWrapper * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IComboBoxWrapper * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IComboBoxWrapper * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IComboBoxWrapper * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IComboBoxWrapper * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IComboBoxWrapper * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Name)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Name )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ BSTR *pName);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_ControlType)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ControlType )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ BSTR *pType);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsValid)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsValid )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pValid);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Width)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Width )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ DOUBLE *pWidth);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Width)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Width )( 
            IComboBoxWrapper * This,
            /* [in] */ DOUBLE width);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Height)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Height )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ DOUBLE *pHeight);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Height)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Height )( 
            IComboBoxWrapper * This,
            /* [in] */ DOUBLE height);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEnabled )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_IsEnabled)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEnabled )( 
            IComboBoxWrapper * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Visibility)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Visibility )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ LONG *pVisibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Visibility)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Visibility )( 
            IComboBoxWrapper * This,
            /* [in] */ LONG visibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, Focus)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Focus )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pSuccess);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, get_SelectedIndex)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_SelectedIndex )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ LONG *pIndex);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, put_SelectedIndex)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_SelectedIndex )( 
            IComboBoxWrapper * This,
            /* [in] */ LONG index);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, get_SelectedText)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_SelectedText )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ BSTR *pText);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, get_ItemCount)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ItemCount )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ LONG *pCount);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, get_PlaceholderText)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_PlaceholderText )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ BSTR *pText);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, put_PlaceholderText)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_PlaceholderText )( 
            IComboBoxWrapper * This,
            /* [in] */ BSTR text);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, get_IsEditable)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEditable )( 
            IComboBoxWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEditable);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, put_IsEditable)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEditable )( 
            IComboBoxWrapper * This,
            /* [in] */ VARIANT_BOOL editable);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, AddItem)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *AddItem )( 
            IComboBoxWrapper * This,
            /* [in] */ BSTR text);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, RemoveAt)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *RemoveAt )( 
            IComboBoxWrapper * This,
            /* [in] */ LONG index);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, Clear)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Clear )( 
            IComboBoxWrapper * This);
        
        DECLSPEC_XFGVIRT(IComboBoxWrapper, GetAt)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *GetAt )( 
            IComboBoxWrapper * This,
            /* [in] */ LONG index,
            /* [retval][out] */ BSTR *pText);
        
        END_INTERFACE
    } IComboBoxWrapperVtbl;

    interface IComboBoxWrapper
    {
        CONST_VTBL struct IComboBoxWrapperVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IComboBoxWrapper_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IComboBoxWrapper_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IComboBoxWrapper_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IComboBoxWrapper_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IComboBoxWrapper_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IComboBoxWrapper_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IComboBoxWrapper_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IComboBoxWrapper_get_Name(This,pName)	\
    ( (This)->lpVtbl -> get_Name(This,pName) ) 

#define IComboBoxWrapper_get_ControlType(This,pType)	\
    ( (This)->lpVtbl -> get_ControlType(This,pType) ) 

#define IComboBoxWrapper_get_IsValid(This,pValid)	\
    ( (This)->lpVtbl -> get_IsValid(This,pValid) ) 

#define IComboBoxWrapper_get_Width(This,pWidth)	\
    ( (This)->lpVtbl -> get_Width(This,pWidth) ) 

#define IComboBoxWrapper_put_Width(This,width)	\
    ( (This)->lpVtbl -> put_Width(This,width) ) 

#define IComboBoxWrapper_get_Height(This,pHeight)	\
    ( (This)->lpVtbl -> get_Height(This,pHeight) ) 

#define IComboBoxWrapper_put_Height(This,height)	\
    ( (This)->lpVtbl -> put_Height(This,height) ) 

#define IComboBoxWrapper_get_IsEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsEnabled(This,pEnabled) ) 

#define IComboBoxWrapper_put_IsEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsEnabled(This,enabled) ) 

#define IComboBoxWrapper_get_Visibility(This,pVisibility)	\
    ( (This)->lpVtbl -> get_Visibility(This,pVisibility) ) 

#define IComboBoxWrapper_put_Visibility(This,visibility)	\
    ( (This)->lpVtbl -> put_Visibility(This,visibility) ) 

#define IComboBoxWrapper_Focus(This,pSuccess)	\
    ( (This)->lpVtbl -> Focus(This,pSuccess) ) 


#define IComboBoxWrapper_get_SelectedIndex(This,pIndex)	\
    ( (This)->lpVtbl -> get_SelectedIndex(This,pIndex) ) 

#define IComboBoxWrapper_put_SelectedIndex(This,index)	\
    ( (This)->lpVtbl -> put_SelectedIndex(This,index) ) 

#define IComboBoxWrapper_get_SelectedText(This,pText)	\
    ( (This)->lpVtbl -> get_SelectedText(This,pText) ) 

#define IComboBoxWrapper_get_ItemCount(This,pCount)	\
    ( (This)->lpVtbl -> get_ItemCount(This,pCount) ) 

#define IComboBoxWrapper_get_PlaceholderText(This,pText)	\
    ( (This)->lpVtbl -> get_PlaceholderText(This,pText) ) 

#define IComboBoxWrapper_put_PlaceholderText(This,text)	\
    ( (This)->lpVtbl -> put_PlaceholderText(This,text) ) 

#define IComboBoxWrapper_get_IsEditable(This,pEditable)	\
    ( (This)->lpVtbl -> get_IsEditable(This,pEditable) ) 

#define IComboBoxWrapper_put_IsEditable(This,editable)	\
    ( (This)->lpVtbl -> put_IsEditable(This,editable) ) 

#define IComboBoxWrapper_AddItem(This,text)	\
    ( (This)->lpVtbl -> AddItem(This,text) ) 

#define IComboBoxWrapper_RemoveAt(This,index)	\
    ( (This)->lpVtbl -> RemoveAt(This,index) ) 

#define IComboBoxWrapper_Clear(This)	\
    ( (This)->lpVtbl -> Clear(This) ) 

#define IComboBoxWrapper_GetAt(This,index,pText)	\
    ( (This)->lpVtbl -> GetAt(This,index,pText) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IComboBoxWrapper_INTERFACE_DEFINED__ */


#ifndef __ISliderWrapper_INTERFACE_DEFINED__
#define __ISliderWrapper_INTERFACE_DEFINED__

/* interface ISliderWrapper */
/* [helpstring][unique][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_ISliderWrapper;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("A8B9C0D1-E2F3-4645-5A6B-7C8D9E0F1A2B")
    ISliderWrapper : public IControlWrapper
    {
    public:
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Value( 
            /* [retval][out] */ DOUBLE *pValue) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Value( 
            /* [in] */ DOUBLE value) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Minimum( 
            /* [retval][out] */ DOUBLE *pMin) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Minimum( 
            /* [in] */ DOUBLE min) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Maximum( 
            /* [retval][out] */ DOUBLE *pMax) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Maximum( 
            /* [in] */ DOUBLE max) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_StepFrequency( 
            /* [retval][out] */ DOUBLE *pStep) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_StepFrequency( 
            /* [in] */ DOUBLE step) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Orientation( 
            /* [retval][out] */ Orientation *pOrientation) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Orientation( 
            /* [in] */ Orientation orientation) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct ISliderWrapperVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            ISliderWrapper * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            ISliderWrapper * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            ISliderWrapper * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            ISliderWrapper * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            ISliderWrapper * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            ISliderWrapper * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            ISliderWrapper * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Name)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Name )( 
            ISliderWrapper * This,
            /* [retval][out] */ BSTR *pName);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_ControlType)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ControlType )( 
            ISliderWrapper * This,
            /* [retval][out] */ BSTR *pType);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsValid)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsValid )( 
            ISliderWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pValid);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Width)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Width )( 
            ISliderWrapper * This,
            /* [retval][out] */ DOUBLE *pWidth);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Width)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Width )( 
            ISliderWrapper * This,
            /* [in] */ DOUBLE width);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Height)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Height )( 
            ISliderWrapper * This,
            /* [retval][out] */ DOUBLE *pHeight);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Height)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Height )( 
            ISliderWrapper * This,
            /* [in] */ DOUBLE height);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEnabled )( 
            ISliderWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_IsEnabled)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEnabled )( 
            ISliderWrapper * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Visibility)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Visibility )( 
            ISliderWrapper * This,
            /* [retval][out] */ LONG *pVisibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Visibility)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Visibility )( 
            ISliderWrapper * This,
            /* [in] */ LONG visibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, Focus)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Focus )( 
            ISliderWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pSuccess);
        
        DECLSPEC_XFGVIRT(ISliderWrapper, get_Value)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Value )( 
            ISliderWrapper * This,
            /* [retval][out] */ DOUBLE *pValue);
        
        DECLSPEC_XFGVIRT(ISliderWrapper, put_Value)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Value )( 
            ISliderWrapper * This,
            /* [in] */ DOUBLE value);
        
        DECLSPEC_XFGVIRT(ISliderWrapper, get_Minimum)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Minimum )( 
            ISliderWrapper * This,
            /* [retval][out] */ DOUBLE *pMin);
        
        DECLSPEC_XFGVIRT(ISliderWrapper, put_Minimum)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Minimum )( 
            ISliderWrapper * This,
            /* [in] */ DOUBLE min);
        
        DECLSPEC_XFGVIRT(ISliderWrapper, get_Maximum)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Maximum )( 
            ISliderWrapper * This,
            /* [retval][out] */ DOUBLE *pMax);
        
        DECLSPEC_XFGVIRT(ISliderWrapper, put_Maximum)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Maximum )( 
            ISliderWrapper * This,
            /* [in] */ DOUBLE max);
        
        DECLSPEC_XFGVIRT(ISliderWrapper, get_StepFrequency)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_StepFrequency )( 
            ISliderWrapper * This,
            /* [retval][out] */ DOUBLE *pStep);
        
        DECLSPEC_XFGVIRT(ISliderWrapper, put_StepFrequency)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_StepFrequency )( 
            ISliderWrapper * This,
            /* [in] */ DOUBLE step);
        
        DECLSPEC_XFGVIRT(ISliderWrapper, get_Orientation)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Orientation )( 
            ISliderWrapper * This,
            /* [retval][out] */ Orientation *pOrientation);
        
        DECLSPEC_XFGVIRT(ISliderWrapper, put_Orientation)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Orientation )( 
            ISliderWrapper * This,
            /* [in] */ Orientation orientation);
        
        END_INTERFACE
    } ISliderWrapperVtbl;

    interface ISliderWrapper
    {
        CONST_VTBL struct ISliderWrapperVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ISliderWrapper_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define ISliderWrapper_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define ISliderWrapper_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define ISliderWrapper_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define ISliderWrapper_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define ISliderWrapper_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define ISliderWrapper_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define ISliderWrapper_get_Name(This,pName)	\
    ( (This)->lpVtbl -> get_Name(This,pName) ) 

#define ISliderWrapper_get_ControlType(This,pType)	\
    ( (This)->lpVtbl -> get_ControlType(This,pType) ) 

#define ISliderWrapper_get_IsValid(This,pValid)	\
    ( (This)->lpVtbl -> get_IsValid(This,pValid) ) 

#define ISliderWrapper_get_Width(This,pWidth)	\
    ( (This)->lpVtbl -> get_Width(This,pWidth) ) 

#define ISliderWrapper_put_Width(This,width)	\
    ( (This)->lpVtbl -> put_Width(This,width) ) 

#define ISliderWrapper_get_Height(This,pHeight)	\
    ( (This)->lpVtbl -> get_Height(This,pHeight) ) 

#define ISliderWrapper_put_Height(This,height)	\
    ( (This)->lpVtbl -> put_Height(This,height) ) 

#define ISliderWrapper_get_IsEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsEnabled(This,pEnabled) ) 

#define ISliderWrapper_put_IsEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsEnabled(This,enabled) ) 

#define ISliderWrapper_get_Visibility(This,pVisibility)	\
    ( (This)->lpVtbl -> get_Visibility(This,pVisibility) ) 

#define ISliderWrapper_put_Visibility(This,visibility)	\
    ( (This)->lpVtbl -> put_Visibility(This,visibility) ) 

#define ISliderWrapper_Focus(This,pSuccess)	\
    ( (This)->lpVtbl -> Focus(This,pSuccess) ) 


#define ISliderWrapper_get_Value(This,pValue)	\
    ( (This)->lpVtbl -> get_Value(This,pValue) ) 

#define ISliderWrapper_put_Value(This,value)	\
    ( (This)->lpVtbl -> put_Value(This,value) ) 

#define ISliderWrapper_get_Minimum(This,pMin)	\
    ( (This)->lpVtbl -> get_Minimum(This,pMin) ) 

#define ISliderWrapper_put_Minimum(This,min)	\
    ( (This)->lpVtbl -> put_Minimum(This,min) ) 

#define ISliderWrapper_get_Maximum(This,pMax)	\
    ( (This)->lpVtbl -> get_Maximum(This,pMax) ) 

#define ISliderWrapper_put_Maximum(This,max)	\
    ( (This)->lpVtbl -> put_Maximum(This,max) ) 

#define ISliderWrapper_get_StepFrequency(This,pStep)	\
    ( (This)->lpVtbl -> get_StepFrequency(This,pStep) ) 

#define ISliderWrapper_put_StepFrequency(This,step)	\
    ( (This)->lpVtbl -> put_StepFrequency(This,step) ) 

#define ISliderWrapper_get_Orientation(This,pOrientation)	\
    ( (This)->lpVtbl -> get_Orientation(This,pOrientation) ) 

#define ISliderWrapper_put_Orientation(This,orientation)	\
    ( (This)->lpVtbl -> put_Orientation(This,orientation) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __ISliderWrapper_INTERFACE_DEFINED__ */


#ifndef __IProgressWrapper_INTERFACE_DEFINED__
#define __IProgressWrapper_INTERFACE_DEFINED__

/* interface IProgressWrapper */
/* [helpstring][unique][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_IProgressWrapper;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("B9C0D1E2-F3A4-4756-6B7C-8D9E0F1A2B3C")
    IProgressWrapper : public IControlWrapper
    {
    public:
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Value( 
            /* [retval][out] */ DOUBLE *pValue) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Value( 
            /* [in] */ DOUBLE value) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Minimum( 
            /* [retval][out] */ DOUBLE *pMin) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Minimum( 
            /* [in] */ DOUBLE min) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Maximum( 
            /* [retval][out] */ DOUBLE *pMax) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Maximum( 
            /* [in] */ DOUBLE max) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsIndeterminate( 
            /* [retval][out] */ VARIANT_BOOL *pIndeterminate) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_IsIndeterminate( 
            /* [in] */ VARIANT_BOOL indeterminate) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_ShowPaused( 
            /* [retval][out] */ VARIANT_BOOL *pPaused) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_ShowPaused( 
            /* [in] */ VARIANT_BOOL paused) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_ShowError( 
            /* [retval][out] */ VARIANT_BOOL *pError) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_ShowError( 
            /* [in] */ VARIANT_BOOL error) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IProgressWrapperVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IProgressWrapper * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IProgressWrapper * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IProgressWrapper * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IProgressWrapper * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IProgressWrapper * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IProgressWrapper * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IProgressWrapper * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Name)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Name )( 
            IProgressWrapper * This,
            /* [retval][out] */ BSTR *pName);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_ControlType)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ControlType )( 
            IProgressWrapper * This,
            /* [retval][out] */ BSTR *pType);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsValid)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsValid )( 
            IProgressWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pValid);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Width)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Width )( 
            IProgressWrapper * This,
            /* [retval][out] */ DOUBLE *pWidth);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Width)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Width )( 
            IProgressWrapper * This,
            /* [in] */ DOUBLE width);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Height)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Height )( 
            IProgressWrapper * This,
            /* [retval][out] */ DOUBLE *pHeight);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Height)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Height )( 
            IProgressWrapper * This,
            /* [in] */ DOUBLE height);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEnabled )( 
            IProgressWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_IsEnabled)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEnabled )( 
            IProgressWrapper * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Visibility)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Visibility )( 
            IProgressWrapper * This,
            /* [retval][out] */ LONG *pVisibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Visibility)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Visibility )( 
            IProgressWrapper * This,
            /* [in] */ LONG visibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, Focus)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Focus )( 
            IProgressWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pSuccess);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, get_Value)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Value )( 
            IProgressWrapper * This,
            /* [retval][out] */ DOUBLE *pValue);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, put_Value)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Value )( 
            IProgressWrapper * This,
            /* [in] */ DOUBLE value);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, get_Minimum)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Minimum )( 
            IProgressWrapper * This,
            /* [retval][out] */ DOUBLE *pMin);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, put_Minimum)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Minimum )( 
            IProgressWrapper * This,
            /* [in] */ DOUBLE min);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, get_Maximum)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Maximum )( 
            IProgressWrapper * This,
            /* [retval][out] */ DOUBLE *pMax);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, put_Maximum)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Maximum )( 
            IProgressWrapper * This,
            /* [in] */ DOUBLE max);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, get_IsIndeterminate)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsIndeterminate )( 
            IProgressWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pIndeterminate);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, put_IsIndeterminate)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsIndeterminate )( 
            IProgressWrapper * This,
            /* [in] */ VARIANT_BOOL indeterminate);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, get_ShowPaused)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ShowPaused )( 
            IProgressWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pPaused);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, put_ShowPaused)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_ShowPaused )( 
            IProgressWrapper * This,
            /* [in] */ VARIANT_BOOL paused);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, get_ShowError)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ShowError )( 
            IProgressWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pError);
        
        DECLSPEC_XFGVIRT(IProgressWrapper, put_ShowError)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_ShowError )( 
            IProgressWrapper * This,
            /* [in] */ VARIANT_BOOL error);
        
        END_INTERFACE
    } IProgressWrapperVtbl;

    interface IProgressWrapper
    {
        CONST_VTBL struct IProgressWrapperVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IProgressWrapper_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IProgressWrapper_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IProgressWrapper_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IProgressWrapper_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IProgressWrapper_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IProgressWrapper_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IProgressWrapper_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IProgressWrapper_get_Name(This,pName)	\
    ( (This)->lpVtbl -> get_Name(This,pName) ) 

#define IProgressWrapper_get_ControlType(This,pType)	\
    ( (This)->lpVtbl -> get_ControlType(This,pType) ) 

#define IProgressWrapper_get_IsValid(This,pValid)	\
    ( (This)->lpVtbl -> get_IsValid(This,pValid) ) 

#define IProgressWrapper_get_Width(This,pWidth)	\
    ( (This)->lpVtbl -> get_Width(This,pWidth) ) 

#define IProgressWrapper_put_Width(This,width)	\
    ( (This)->lpVtbl -> put_Width(This,width) ) 

#define IProgressWrapper_get_Height(This,pHeight)	\
    ( (This)->lpVtbl -> get_Height(This,pHeight) ) 

#define IProgressWrapper_put_Height(This,height)	\
    ( (This)->lpVtbl -> put_Height(This,height) ) 

#define IProgressWrapper_get_IsEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsEnabled(This,pEnabled) ) 

#define IProgressWrapper_put_IsEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsEnabled(This,enabled) ) 

#define IProgressWrapper_get_Visibility(This,pVisibility)	\
    ( (This)->lpVtbl -> get_Visibility(This,pVisibility) ) 

#define IProgressWrapper_put_Visibility(This,visibility)	\
    ( (This)->lpVtbl -> put_Visibility(This,visibility) ) 

#define IProgressWrapper_Focus(This,pSuccess)	\
    ( (This)->lpVtbl -> Focus(This,pSuccess) ) 


#define IProgressWrapper_get_Value(This,pValue)	\
    ( (This)->lpVtbl -> get_Value(This,pValue) ) 

#define IProgressWrapper_put_Value(This,value)	\
    ( (This)->lpVtbl -> put_Value(This,value) ) 

#define IProgressWrapper_get_Minimum(This,pMin)	\
    ( (This)->lpVtbl -> get_Minimum(This,pMin) ) 

#define IProgressWrapper_put_Minimum(This,min)	\
    ( (This)->lpVtbl -> put_Minimum(This,min) ) 

#define IProgressWrapper_get_Maximum(This,pMax)	\
    ( (This)->lpVtbl -> get_Maximum(This,pMax) ) 

#define IProgressWrapper_put_Maximum(This,max)	\
    ( (This)->lpVtbl -> put_Maximum(This,max) ) 

#define IProgressWrapper_get_IsIndeterminate(This,pIndeterminate)	\
    ( (This)->lpVtbl -> get_IsIndeterminate(This,pIndeterminate) ) 

#define IProgressWrapper_put_IsIndeterminate(This,indeterminate)	\
    ( (This)->lpVtbl -> put_IsIndeterminate(This,indeterminate) ) 

#define IProgressWrapper_get_ShowPaused(This,pPaused)	\
    ( (This)->lpVtbl -> get_ShowPaused(This,pPaused) ) 

#define IProgressWrapper_put_ShowPaused(This,paused)	\
    ( (This)->lpVtbl -> put_ShowPaused(This,paused) ) 

#define IProgressWrapper_get_ShowError(This,pError)	\
    ( (This)->lpVtbl -> get_ShowError(This,pError) ) 

#define IProgressWrapper_put_ShowError(This,error)	\
    ( (This)->lpVtbl -> put_ShowError(This,error) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IProgressWrapper_INTERFACE_DEFINED__ */


#ifndef __ITextBlockWrapper_INTERFACE_DEFINED__
#define __ITextBlockWrapper_INTERFACE_DEFINED__

/* interface ITextBlockWrapper */
/* [helpstring][unique][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_ITextBlockWrapper;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("C0D1E2F3-A4B5-4867-7C8D-9E0F1A2B3C4D")
    ITextBlockWrapper : public IControlWrapper
    {
    public:
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Text( 
            /* [retval][out] */ BSTR *pText) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Text( 
            /* [in] */ BSTR text) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_TextWrapping( 
            /* [retval][out] */ TextWrapping *pWrapping) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_TextWrapping( 
            /* [in] */ TextWrapping wrapping) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_TextAlignment( 
            /* [retval][out] */ TextAlignment *pAlignment) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_TextAlignment( 
            /* [in] */ TextAlignment alignment) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_FontSize( 
            /* [retval][out] */ DOUBLE *pSize) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_FontSize( 
            /* [in] */ DOUBLE size) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_MaxLines( 
            /* [retval][out] */ LONG *pLines) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_MaxLines( 
            /* [in] */ LONG lines) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsTextSelectionEnabled( 
            /* [retval][out] */ VARIANT_BOOL *pEnabled) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_IsTextSelectionEnabled( 
            /* [in] */ VARIANT_BOOL enabled) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct ITextBlockWrapperVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            ITextBlockWrapper * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            ITextBlockWrapper * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            ITextBlockWrapper * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            ITextBlockWrapper * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            ITextBlockWrapper * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            ITextBlockWrapper * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            ITextBlockWrapper * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Name)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Name )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ BSTR *pName);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_ControlType)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ControlType )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ BSTR *pType);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsValid)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsValid )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pValid);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Width)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Width )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ DOUBLE *pWidth);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Width)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Width )( 
            ITextBlockWrapper * This,
            /* [in] */ DOUBLE width);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Height)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Height )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ DOUBLE *pHeight);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Height)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Height )( 
            ITextBlockWrapper * This,
            /* [in] */ DOUBLE height);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEnabled )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_IsEnabled)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEnabled )( 
            ITextBlockWrapper * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Visibility)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Visibility )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ LONG *pVisibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Visibility)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Visibility )( 
            ITextBlockWrapper * This,
            /* [in] */ LONG visibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, Focus)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Focus )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pSuccess);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, get_Text)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Text )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ BSTR *pText);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, put_Text)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Text )( 
            ITextBlockWrapper * This,
            /* [in] */ BSTR text);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, get_TextWrapping)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_TextWrapping )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ TextWrapping *pWrapping);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, put_TextWrapping)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_TextWrapping )( 
            ITextBlockWrapper * This,
            /* [in] */ TextWrapping wrapping);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, get_TextAlignment)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_TextAlignment )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ TextAlignment *pAlignment);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, put_TextAlignment)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_TextAlignment )( 
            ITextBlockWrapper * This,
            /* [in] */ TextAlignment alignment);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, get_FontSize)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_FontSize )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ DOUBLE *pSize);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, put_FontSize)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_FontSize )( 
            ITextBlockWrapper * This,
            /* [in] */ DOUBLE size);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, get_MaxLines)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_MaxLines )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ LONG *pLines);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, put_MaxLines)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_MaxLines )( 
            ITextBlockWrapper * This,
            /* [in] */ LONG lines);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, get_IsTextSelectionEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsTextSelectionEnabled )( 
            ITextBlockWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(ITextBlockWrapper, put_IsTextSelectionEnabled)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsTextSelectionEnabled )( 
            ITextBlockWrapper * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        END_INTERFACE
    } ITextBlockWrapperVtbl;

    interface ITextBlockWrapper
    {
        CONST_VTBL struct ITextBlockWrapperVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ITextBlockWrapper_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define ITextBlockWrapper_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define ITextBlockWrapper_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define ITextBlockWrapper_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define ITextBlockWrapper_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define ITextBlockWrapper_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define ITextBlockWrapper_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define ITextBlockWrapper_get_Name(This,pName)	\
    ( (This)->lpVtbl -> get_Name(This,pName) ) 

#define ITextBlockWrapper_get_ControlType(This,pType)	\
    ( (This)->lpVtbl -> get_ControlType(This,pType) ) 

#define ITextBlockWrapper_get_IsValid(This,pValid)	\
    ( (This)->lpVtbl -> get_IsValid(This,pValid) ) 

#define ITextBlockWrapper_get_Width(This,pWidth)	\
    ( (This)->lpVtbl -> get_Width(This,pWidth) ) 

#define ITextBlockWrapper_put_Width(This,width)	\
    ( (This)->lpVtbl -> put_Width(This,width) ) 

#define ITextBlockWrapper_get_Height(This,pHeight)	\
    ( (This)->lpVtbl -> get_Height(This,pHeight) ) 

#define ITextBlockWrapper_put_Height(This,height)	\
    ( (This)->lpVtbl -> put_Height(This,height) ) 

#define ITextBlockWrapper_get_IsEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsEnabled(This,pEnabled) ) 

#define ITextBlockWrapper_put_IsEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsEnabled(This,enabled) ) 

#define ITextBlockWrapper_get_Visibility(This,pVisibility)	\
    ( (This)->lpVtbl -> get_Visibility(This,pVisibility) ) 

#define ITextBlockWrapper_put_Visibility(This,visibility)	\
    ( (This)->lpVtbl -> put_Visibility(This,visibility) ) 

#define ITextBlockWrapper_Focus(This,pSuccess)	\
    ( (This)->lpVtbl -> Focus(This,pSuccess) ) 


#define ITextBlockWrapper_get_Text(This,pText)	\
    ( (This)->lpVtbl -> get_Text(This,pText) ) 

#define ITextBlockWrapper_put_Text(This,text)	\
    ( (This)->lpVtbl -> put_Text(This,text) ) 

#define ITextBlockWrapper_get_TextWrapping(This,pWrapping)	\
    ( (This)->lpVtbl -> get_TextWrapping(This,pWrapping) ) 

#define ITextBlockWrapper_put_TextWrapping(This,wrapping)	\
    ( (This)->lpVtbl -> put_TextWrapping(This,wrapping) ) 

#define ITextBlockWrapper_get_TextAlignment(This,pAlignment)	\
    ( (This)->lpVtbl -> get_TextAlignment(This,pAlignment) ) 

#define ITextBlockWrapper_put_TextAlignment(This,alignment)	\
    ( (This)->lpVtbl -> put_TextAlignment(This,alignment) ) 

#define ITextBlockWrapper_get_FontSize(This,pSize)	\
    ( (This)->lpVtbl -> get_FontSize(This,pSize) ) 

#define ITextBlockWrapper_put_FontSize(This,size)	\
    ( (This)->lpVtbl -> put_FontSize(This,size) ) 

#define ITextBlockWrapper_get_MaxLines(This,pLines)	\
    ( (This)->lpVtbl -> get_MaxLines(This,pLines) ) 

#define ITextBlockWrapper_put_MaxLines(This,lines)	\
    ( (This)->lpVtbl -> put_MaxLines(This,lines) ) 

#define ITextBlockWrapper_get_IsTextSelectionEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsTextSelectionEnabled(This,pEnabled) ) 

#define ITextBlockWrapper_put_IsTextSelectionEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsTextSelectionEnabled(This,enabled) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __ITextBlockWrapper_INTERFACE_DEFINED__ */


#ifndef __IListViewWrapper_INTERFACE_DEFINED__
#define __IListViewWrapper_INTERFACE_DEFINED__

/* interface IListViewWrapper */
/* [helpstring][unique][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_IListViewWrapper;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("D1E2F3A4-B5C6-4978-8D9E-0F1A2B3C4D5E")
    IListViewWrapper : public IControlWrapper
    {
    public:
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_SelectedIndex( 
            /* [retval][out] */ LONG *pIndex) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_SelectedIndex( 
            /* [in] */ LONG index) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_ItemCount( 
            /* [retval][out] */ LONG *pCount) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_SelectionMode( 
            /* [retval][out] */ SelectionMode *pMode) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_SelectionMode( 
            /* [in] */ SelectionMode mode) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE AddItem( 
            /* [in] */ BSTR text) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE RemoveAt( 
            /* [in] */ LONG index) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Clear( void) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE ScrollIntoView( 
            /* [in] */ LONG index) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IListViewWrapperVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IListViewWrapper * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IListViewWrapper * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IListViewWrapper * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IListViewWrapper * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IListViewWrapper * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IListViewWrapper * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IListViewWrapper * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Name)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Name )( 
            IListViewWrapper * This,
            /* [retval][out] */ BSTR *pName);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_ControlType)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ControlType )( 
            IListViewWrapper * This,
            /* [retval][out] */ BSTR *pType);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsValid)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsValid )( 
            IListViewWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pValid);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Width)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Width )( 
            IListViewWrapper * This,
            /* [retval][out] */ DOUBLE *pWidth);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Width)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Width )( 
            IListViewWrapper * This,
            /* [in] */ DOUBLE width);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Height)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Height )( 
            IListViewWrapper * This,
            /* [retval][out] */ DOUBLE *pHeight);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Height)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Height )( 
            IListViewWrapper * This,
            /* [in] */ DOUBLE height);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEnabled )( 
            IListViewWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_IsEnabled)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEnabled )( 
            IListViewWrapper * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Visibility)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Visibility )( 
            IListViewWrapper * This,
            /* [retval][out] */ LONG *pVisibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Visibility)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Visibility )( 
            IListViewWrapper * This,
            /* [in] */ LONG visibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, Focus)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Focus )( 
            IListViewWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pSuccess);
        
        DECLSPEC_XFGVIRT(IListViewWrapper, get_SelectedIndex)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_SelectedIndex )( 
            IListViewWrapper * This,
            /* [retval][out] */ LONG *pIndex);
        
        DECLSPEC_XFGVIRT(IListViewWrapper, put_SelectedIndex)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_SelectedIndex )( 
            IListViewWrapper * This,
            /* [in] */ LONG index);
        
        DECLSPEC_XFGVIRT(IListViewWrapper, get_ItemCount)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ItemCount )( 
            IListViewWrapper * This,
            /* [retval][out] */ LONG *pCount);
        
        DECLSPEC_XFGVIRT(IListViewWrapper, get_SelectionMode)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_SelectionMode )( 
            IListViewWrapper * This,
            /* [retval][out] */ SelectionMode *pMode);
        
        DECLSPEC_XFGVIRT(IListViewWrapper, put_SelectionMode)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_SelectionMode )( 
            IListViewWrapper * This,
            /* [in] */ SelectionMode mode);
        
        DECLSPEC_XFGVIRT(IListViewWrapper, AddItem)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *AddItem )( 
            IListViewWrapper * This,
            /* [in] */ BSTR text);
        
        DECLSPEC_XFGVIRT(IListViewWrapper, RemoveAt)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *RemoveAt )( 
            IListViewWrapper * This,
            /* [in] */ LONG index);
        
        DECLSPEC_XFGVIRT(IListViewWrapper, Clear)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Clear )( 
            IListViewWrapper * This);
        
        DECLSPEC_XFGVIRT(IListViewWrapper, ScrollIntoView)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *ScrollIntoView )( 
            IListViewWrapper * This,
            /* [in] */ LONG index);
        
        END_INTERFACE
    } IListViewWrapperVtbl;

    interface IListViewWrapper
    {
        CONST_VTBL struct IListViewWrapperVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IListViewWrapper_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IListViewWrapper_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IListViewWrapper_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IListViewWrapper_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IListViewWrapper_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IListViewWrapper_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IListViewWrapper_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IListViewWrapper_get_Name(This,pName)	\
    ( (This)->lpVtbl -> get_Name(This,pName) ) 

#define IListViewWrapper_get_ControlType(This,pType)	\
    ( (This)->lpVtbl -> get_ControlType(This,pType) ) 

#define IListViewWrapper_get_IsValid(This,pValid)	\
    ( (This)->lpVtbl -> get_IsValid(This,pValid) ) 

#define IListViewWrapper_get_Width(This,pWidth)	\
    ( (This)->lpVtbl -> get_Width(This,pWidth) ) 

#define IListViewWrapper_put_Width(This,width)	\
    ( (This)->lpVtbl -> put_Width(This,width) ) 

#define IListViewWrapper_get_Height(This,pHeight)	\
    ( (This)->lpVtbl -> get_Height(This,pHeight) ) 

#define IListViewWrapper_put_Height(This,height)	\
    ( (This)->lpVtbl -> put_Height(This,height) ) 

#define IListViewWrapper_get_IsEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsEnabled(This,pEnabled) ) 

#define IListViewWrapper_put_IsEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsEnabled(This,enabled) ) 

#define IListViewWrapper_get_Visibility(This,pVisibility)	\
    ( (This)->lpVtbl -> get_Visibility(This,pVisibility) ) 

#define IListViewWrapper_put_Visibility(This,visibility)	\
    ( (This)->lpVtbl -> put_Visibility(This,visibility) ) 

#define IListViewWrapper_Focus(This,pSuccess)	\
    ( (This)->lpVtbl -> Focus(This,pSuccess) ) 


#define IListViewWrapper_get_SelectedIndex(This,pIndex)	\
    ( (This)->lpVtbl -> get_SelectedIndex(This,pIndex) ) 

#define IListViewWrapper_put_SelectedIndex(This,index)	\
    ( (This)->lpVtbl -> put_SelectedIndex(This,index) ) 

#define IListViewWrapper_get_ItemCount(This,pCount)	\
    ( (This)->lpVtbl -> get_ItemCount(This,pCount) ) 

#define IListViewWrapper_get_SelectionMode(This,pMode)	\
    ( (This)->lpVtbl -> get_SelectionMode(This,pMode) ) 

#define IListViewWrapper_put_SelectionMode(This,mode)	\
    ( (This)->lpVtbl -> put_SelectionMode(This,mode) ) 

#define IListViewWrapper_AddItem(This,text)	\
    ( (This)->lpVtbl -> AddItem(This,text) ) 

#define IListViewWrapper_RemoveAt(This,index)	\
    ( (This)->lpVtbl -> RemoveAt(This,index) ) 

#define IListViewWrapper_Clear(This)	\
    ( (This)->lpVtbl -> Clear(This) ) 

#define IListViewWrapper_ScrollIntoView(This,index)	\
    ( (This)->lpVtbl -> ScrollIntoView(This,index) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IListViewWrapper_INTERFACE_DEFINED__ */


#ifndef __IToggleSwitchWrapper_INTERFACE_DEFINED__
#define __IToggleSwitchWrapper_INTERFACE_DEFINED__

/* interface IToggleSwitchWrapper */
/* [helpstring][unique][oleautomation][dual][uuid][object] */ 


EXTERN_C const IID IID_IToggleSwitchWrapper;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("E2F3A4B5-C6D7-4089-9E0F-1A2B3C4D5E6F")
    IToggleSwitchWrapper : public IControlWrapper
    {
    public:
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_IsOn( 
            /* [retval][out] */ VARIANT_BOOL *pOn) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_IsOn( 
            /* [in] */ VARIANT_BOOL on) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_OnContent( 
            /* [retval][out] */ BSTR *pContent) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_OnContent( 
            /* [in] */ BSTR content) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_OffContent( 
            /* [retval][out] */ BSTR *pContent) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_OffContent( 
            /* [in] */ BSTR content) = 0;
        
        virtual /* [helpstring][propget][id] */ HRESULT STDMETHODCALLTYPE get_Header( 
            /* [retval][out] */ BSTR *pHeader) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Header( 
            /* [in] */ BSTR header) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IToggleSwitchWrapperVtbl
    {
        BEGIN_INTERFACE
        
        DECLSPEC_XFGVIRT(IUnknown, QueryInterface)
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IToggleSwitchWrapper * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            _COM_Outptr_  void **ppvObject);
        
        DECLSPEC_XFGVIRT(IUnknown, AddRef)
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IToggleSwitchWrapper * This);
        
        DECLSPEC_XFGVIRT(IUnknown, Release)
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IToggleSwitchWrapper * This);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfoCount)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IToggleSwitchWrapper * This,
            /* [out] */ UINT *pctinfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetTypeInfo)
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IToggleSwitchWrapper * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        DECLSPEC_XFGVIRT(IDispatch, GetIDsOfNames)
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IToggleSwitchWrapper * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        DECLSPEC_XFGVIRT(IDispatch, Invoke)
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IToggleSwitchWrapper * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Name)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Name )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ BSTR *pName);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_ControlType)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_ControlType )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ BSTR *pType);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsValid)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsValid )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pValid);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Width)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Width )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ DOUBLE *pWidth);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Width)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Width )( 
            IToggleSwitchWrapper * This,
            /* [in] */ DOUBLE width);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Height)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Height )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ DOUBLE *pHeight);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Height)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Height )( 
            IToggleSwitchWrapper * This,
            /* [in] */ DOUBLE height);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_IsEnabled)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsEnabled )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pEnabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_IsEnabled)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsEnabled )( 
            IToggleSwitchWrapper * This,
            /* [in] */ VARIANT_BOOL enabled);
        
        DECLSPEC_XFGVIRT(IControlWrapper, get_Visibility)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Visibility )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ LONG *pVisibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, put_Visibility)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Visibility )( 
            IToggleSwitchWrapper * This,
            /* [in] */ LONG visibility);
        
        DECLSPEC_XFGVIRT(IControlWrapper, Focus)
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Focus )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pSuccess);
        
        DECLSPEC_XFGVIRT(IToggleSwitchWrapper, get_IsOn)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_IsOn )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ VARIANT_BOOL *pOn);
        
        DECLSPEC_XFGVIRT(IToggleSwitchWrapper, put_IsOn)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_IsOn )( 
            IToggleSwitchWrapper * This,
            /* [in] */ VARIANT_BOOL on);
        
        DECLSPEC_XFGVIRT(IToggleSwitchWrapper, get_OnContent)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_OnContent )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ BSTR *pContent);
        
        DECLSPEC_XFGVIRT(IToggleSwitchWrapper, put_OnContent)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_OnContent )( 
            IToggleSwitchWrapper * This,
            /* [in] */ BSTR content);
        
        DECLSPEC_XFGVIRT(IToggleSwitchWrapper, get_OffContent)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_OffContent )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ BSTR *pContent);
        
        DECLSPEC_XFGVIRT(IToggleSwitchWrapper, put_OffContent)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_OffContent )( 
            IToggleSwitchWrapper * This,
            /* [in] */ BSTR content);
        
        DECLSPEC_XFGVIRT(IToggleSwitchWrapper, get_Header)
        /* [helpstring][propget][id] */ HRESULT ( STDMETHODCALLTYPE *get_Header )( 
            IToggleSwitchWrapper * This,
            /* [retval][out] */ BSTR *pHeader);
        
        DECLSPEC_XFGVIRT(IToggleSwitchWrapper, put_Header)
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE *put_Header )( 
            IToggleSwitchWrapper * This,
            /* [in] */ BSTR header);
        
        END_INTERFACE
    } IToggleSwitchWrapperVtbl;

    interface IToggleSwitchWrapper
    {
        CONST_VTBL struct IToggleSwitchWrapperVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IToggleSwitchWrapper_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IToggleSwitchWrapper_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IToggleSwitchWrapper_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IToggleSwitchWrapper_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IToggleSwitchWrapper_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IToggleSwitchWrapper_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IToggleSwitchWrapper_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IToggleSwitchWrapper_get_Name(This,pName)	\
    ( (This)->lpVtbl -> get_Name(This,pName) ) 

#define IToggleSwitchWrapper_get_ControlType(This,pType)	\
    ( (This)->lpVtbl -> get_ControlType(This,pType) ) 

#define IToggleSwitchWrapper_get_IsValid(This,pValid)	\
    ( (This)->lpVtbl -> get_IsValid(This,pValid) ) 

#define IToggleSwitchWrapper_get_Width(This,pWidth)	\
    ( (This)->lpVtbl -> get_Width(This,pWidth) ) 

#define IToggleSwitchWrapper_put_Width(This,width)	\
    ( (This)->lpVtbl -> put_Width(This,width) ) 

#define IToggleSwitchWrapper_get_Height(This,pHeight)	\
    ( (This)->lpVtbl -> get_Height(This,pHeight) ) 

#define IToggleSwitchWrapper_put_Height(This,height)	\
    ( (This)->lpVtbl -> put_Height(This,height) ) 

#define IToggleSwitchWrapper_get_IsEnabled(This,pEnabled)	\
    ( (This)->lpVtbl -> get_IsEnabled(This,pEnabled) ) 

#define IToggleSwitchWrapper_put_IsEnabled(This,enabled)	\
    ( (This)->lpVtbl -> put_IsEnabled(This,enabled) ) 

#define IToggleSwitchWrapper_get_Visibility(This,pVisibility)	\
    ( (This)->lpVtbl -> get_Visibility(This,pVisibility) ) 

#define IToggleSwitchWrapper_put_Visibility(This,visibility)	\
    ( (This)->lpVtbl -> put_Visibility(This,visibility) ) 

#define IToggleSwitchWrapper_Focus(This,pSuccess)	\
    ( (This)->lpVtbl -> Focus(This,pSuccess) ) 


#define IToggleSwitchWrapper_get_IsOn(This,pOn)	\
    ( (This)->lpVtbl -> get_IsOn(This,pOn) ) 

#define IToggleSwitchWrapper_put_IsOn(This,on)	\
    ( (This)->lpVtbl -> put_IsOn(This,on) ) 

#define IToggleSwitchWrapper_get_OnContent(This,pContent)	\
    ( (This)->lpVtbl -> get_OnContent(This,pContent) ) 

#define IToggleSwitchWrapper_put_OnContent(This,content)	\
    ( (This)->lpVtbl -> put_OnContent(This,content) ) 

#define IToggleSwitchWrapper_get_OffContent(This,pContent)	\
    ( (This)->lpVtbl -> get_OffContent(This,pContent) ) 

#define IToggleSwitchWrapper_put_OffContent(This,content)	\
    ( (This)->lpVtbl -> put_OffContent(This,content) ) 

#define IToggleSwitchWrapper_get_Header(This,pHeader)	\
    ( (This)->lpVtbl -> get_Header(This,pHeader) ) 

#define IToggleSwitchWrapper_put_Header(This,header)	\
    ( (This)->lpVtbl -> put_Header(This,header) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IToggleSwitchWrapper_INTERFACE_DEFINED__ */


EXTERN_C const CLSID CLSID_XamlHost;

#ifdef __cplusplus

class DECLSPEC_UUID("11111111-2222-3333-4444-555555555555")
XamlHost;
#endif

EXTERN_C const CLSID CLSID_XamlElement;

#ifdef __cplusplus

class DECLSPEC_UUID("22222222-3333-4444-5555-666666666666")
XamlElement;
#endif
#endif /* __WinUI3BridgeLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


