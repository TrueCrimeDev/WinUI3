

/* this ALWAYS GENERATED file contains the IIDs and CLSIDs */

/* link this file in with the server and any clients */


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



#ifdef __cplusplus
extern "C"{
#endif 


#include <rpc.h>
#include <rpcndr.h>

#ifdef _MIDL_USE_GUIDDEF_

#ifndef INITGUID
#define INITGUID
#include <guiddef.h>
#undef INITGUID
#else
#include <guiddef.h>
#endif

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
        DEFINE_GUID(name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8)

#else // !_MIDL_USE_GUIDDEF_

#ifndef __IID_DEFINED__
#define __IID_DEFINED__

typedef struct _IID
{
    unsigned long x;
    unsigned short s1;
    unsigned short s2;
    unsigned char  c[8];
} IID;

#endif // __IID_DEFINED__

#ifndef CLSID_DEFINED
#define CLSID_DEFINED
typedef IID CLSID;
#endif // CLSID_DEFINED

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
        EXTERN_C __declspec(selectany) const type name = {l,w1,w2,{b1,b2,b3,b4,b5,b6,b7,b8}}

#endif // !_MIDL_USE_GUIDDEF_

MIDL_DEFINE_GUID(IID, LIBID_WinUI3BridgeLib,0xE8A9C4F1,0x3B2D,0x4A5E,0x9C,0x7F,0x1D,0x2E,0x3F,0x4A,0x5B,0x6C);


MIDL_DEFINE_GUID(IID, IID_IXamlHost,0xF1E2D3C4,0xB5A6,0x4978,0x8C,0x9D,0x0A,0x1B,0x2C,0x3D,0x4E,0x5F);


MIDL_DEFINE_GUID(IID, IID_IXamlElement,0xA2B3C4D5,0xE6F7,0x4089,0x9A,0x0B,0x1C,0x2D,0x3E,0x4F,0x5A,0x6B);


MIDL_DEFINE_GUID(IID, IID_IControlWrapper,0xB3C4D5E6,0xF7A8,0x4190,0x0B,0x1C,0x2D,0x3E,0x4F,0x5A,0x6B,0x7C);


MIDL_DEFINE_GUID(IID, IID_IButtonWrapper,0xC4D5E6F7,0xA8B9,0x4201,0x1C,0x2D,0x3E,0x4F,0x5A,0x6B,0x7C,0x8D);


MIDL_DEFINE_GUID(IID, IID_ITextBoxWrapper,0xD5E6F7A8,0xB9C0,0x4312,0x2D,0x3E,0x4F,0x5A,0x6B,0x7C,0x8D,0x9E);


MIDL_DEFINE_GUID(IID, IID_ICheckBoxWrapper,0xE6F7A8B9,0xC0D1,0x4423,0x3E,0x4F,0x5A,0x6B,0x7C,0x8D,0x9E,0x0F);


MIDL_DEFINE_GUID(IID, IID_IComboBoxWrapper,0xF7A8B9C0,0xD1E2,0x4534,0x4F,0x5A,0x6B,0x7C,0x8D,0x9E,0x0F,0x1A);


MIDL_DEFINE_GUID(IID, IID_ISliderWrapper,0xA8B9C0D1,0xE2F3,0x4645,0x5A,0x6B,0x7C,0x8D,0x9E,0x0F,0x1A,0x2B);


MIDL_DEFINE_GUID(IID, IID_IProgressWrapper,0xB9C0D1E2,0xF3A4,0x4756,0x6B,0x7C,0x8D,0x9E,0x0F,0x1A,0x2B,0x3C);


MIDL_DEFINE_GUID(IID, IID_ITextBlockWrapper,0xC0D1E2F3,0xA4B5,0x4867,0x7C,0x8D,0x9E,0x0F,0x1A,0x2B,0x3C,0x4D);


MIDL_DEFINE_GUID(IID, IID_IListViewWrapper,0xD1E2F3A4,0xB5C6,0x4978,0x8D,0x9E,0x0F,0x1A,0x2B,0x3C,0x4D,0x5E);


MIDL_DEFINE_GUID(IID, IID_IToggleSwitchWrapper,0xE2F3A4B5,0xC6D7,0x4089,0x9E,0x0F,0x1A,0x2B,0x3C,0x4D,0x5E,0x6F);


MIDL_DEFINE_GUID(CLSID, CLSID_XamlHost,0x11111111,0x2222,0x3333,0x44,0x44,0x55,0x55,0x55,0x55,0x55,0x55);


MIDL_DEFINE_GUID(CLSID, CLSID_XamlElement,0x22222222,0x3333,0x4444,0x55,0x55,0x66,0x66,0x66,0x66,0x66,0x66);

#undef MIDL_DEFINE_GUID

#ifdef __cplusplus
}
#endif



