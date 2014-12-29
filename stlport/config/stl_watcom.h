// STLport configuration file
// It is internal STLport header - DO NOT include it directly
//
// Supported Watcom versions:
//
// __WATCOMC__ = 1100   Watcom 11c
// __WATCOMC__ = 1200   OpenWatcom 1.0
// __WATCOMC__ = 1210   OpenWatcom 1.1
// __WATCOMC__ = 1220   OpenWatcom 1.2
// __WATCOMC__ = 1230   OpenWatcom 1.3
//

#ifndef _STLP_NO_OWN_IOSTREAMS
#   define _STLP_NO_OWN_IOSTREAMS
#endif

// Configuration "cascade" for all supported versions
#if __WATCOMC__ < 1100
#   error "Watcom C++ older then 11c is not supported, sorry!"
#endif

#if __WATCOMC__ < 1200
// This one is present in 11, but apparently has bugs (with auto_ptr).
#define _STLP_NO_NEW_STYLE_CASTS 1
#endif

#if __WATCOMC__ < 1230
#   define _STLP_HAS_NO_NEW_C_HEADERS 1
#   define _STLP_HAS_NO_NAMESPACES 1
#   define _STLP_NO_RELOPS_NAMESPACE 1
#   define _STLP_NO_NEW_STYLE_HEADERS 1
#   define _STLP_NO_DEFAULT_NON_TYPE_PARAM 1
#   define _STLP_LIMITED_DEFAULT_TEMPLATES 1
#   define _STLP_STATIC_CONST_INIT_BUG 1
#endif

// Version specific quirks
#if __WATCOMC__ == 1230
#   define _STLP_NO_OLD_IOSTREAM_HEADERS 1
#   define _STLP_BROKEN_USING_DIRECTIVE 1
#endif

#define _STLP_LONG_LONG long long

#define _STLP_HAS_SPECIFIC_PROLOG_EPILOG 1
#define _STLP_NO_PARTIAL_SPECIALIZATION_SYNTAX 1
#define _STLP_NO_FUNCTION_TMPL_PARTIAL_ORDER 1
#define _STLP_NO_CLASS_PARTIAL_SPECIALIZATION 1
#define _STLP_DONT_SIMULATE_PARTIAL_SPEC_FOR_TYPE_TRAITS 1
#define _STLP_NO_MEMBER_TEMPLATE_KEYWORD 1
#define _STLP_NO_MEMBER_TEMPLATES 1
#define _STLP_NO_FRIEND_TEMPLATES 1
#define _STLP_NO_MEMBER_TEMPLATE_CLASSES 1
#define _STLP_NO_EXPLICIT_FUNCTION_TMPL_ARGS 1
#define _STLP_NO_EXCEPTION_HEADER 1
#define _STLP_NO_BAD_ALLOC 1
#define _STLP_NO_ARROW_OPERATOR 1
#define _STLP_NO_QUALIFIED_FRIENDS 1
#define _STLP_NO_NEW_IOSTREAMS 1
#define _STLP_NO_DEFAULT_FUNCTION_TMPL_ARGS 1
#define _STLP_NEED_TYPENAME 1
#define _STLP_NON_TYPE_TMPL_PARAM_BUG 1
#define _STLP_NONTEMPL_BASE_MATCH_BUG 1
#define _STLP_DEFAULT_CONSTRUCTOR_BUG 1
#define _STLP_NO_STRING_HEADER 1
#define _STLP_DONT_RETURN_VOID 1
#define _STLP_NO_CSTD_FUNCTION_IMPORTS 1



// bad_alloc exception class require base class derived
// from the native compiler class, for some unknown reason
// STLport does not define it wherever necessary...
#ifdef _STLP_NO_BAD_ALLOC
#   define  _STLP_EXCEPTION_BASE    exception
#endif

// On QNX, headers are supposed to be found in /usr/include,
// so default "../include" should work.
#ifndef __QNX__
#   define _STLP_NATIVE_INCLUDE_PATH ../h
#endif

// boris : is this true or just the header is not in /usr/include ?
#ifdef __QNX__
#   define _STLP_NO_TYPEINFO 1
#endif



// Inline replacements for locking calls under Watcom
// Define _STLP_NO_WATCOM_INLINE_INTERLOCK to keep using
// standard WIN32 calls
// Define _STL_MULTIPROCESSOR to enable lock
#if !defined(_STLP_NO_WATCOM_INLINE_INTERLOCK)

long    __stl_InterlockedIncrement( long *var );
long    __stl_InterlockedDecrement( long *var );

#ifdef _STL_MULTIPROCESSOR
// Multiple Processors, add lock prefix
#pragma aux __stl_InterlockedIncrement parm [ ecx ] = \
        ".586"                  \
        "mov eax, 1"            \
        "lock xadd [ecx], eax"       \
        "inc eax"               \
        value [eax];


#pragma aux __stl_InterlockedDecrement parm [ ecx ] = \
        ".586"                  \
        "mov eax, 0FFFFFFFFh"   \
        "lock xadd [ecx], eax"       \
        "dec eax"               \
        value [eax];
#else
// Single Processor, lock prefix not needed
#pragma aux __stl_InterlockedIncrement parm [ ecx ] = \
        ".586"                  \
        "mov eax, 1"            \
        "xadd [ecx], eax"       \
        "inc eax"               \
        value [eax];

#pragma aux __stl_InterlockedDecrement parm [ ecx ] = \
        ".586"                  \
        "mov eax, 0FFFFFFFFh"   \
        "xadd [ecx], eax"       \
        "dec eax"               \
        value [eax];
#endif // _STL_MULTIPROCESSOR

long    __stl_InterlockedExchange( long *Destination, long Value );

// xchg has auto-lock
#pragma aux __stl_InterlockedExchange parm [ecx] [eax] = \
        ".586"                  \
        "xchg eax, [ecx]"       \
        value [eax];
#else

#define __stl_InterlockedIncrement      InterlockedIncrement
#define __stl_InterlockedDecrement      InterlockedDecrement
#define __stl_InterlockedExchange       InterlockedExchange
#endif /* INLINE INTERLOCK */

#define _STLP_ATOMIC_INCREMENT(__x) __stl_InterlockedIncrement((long*)__x)
#define _STLP_ATOMIC_DECREMENT(__x) __stl_InterlockedDecrement((long*)__x)
#define _STLP_ATOMIC_EXCHANGE(__x, __y) __stl_InterlockedExchange((long*)__x, (long)__y)

// Get rid of Watcom's min and max macros
#undef min
#undef max

// for switches (-xs,  -xss,  -xst)
#if !(defined (__SW_XS) || defined (__SW_XSS) || defined(__SW_XST))
#   define _STLP_HAS_NO_EXCEPTIONS 1
#endif

#if defined ( _MT ) && !defined (_NOTHREADS) && !defined (_REENTRANT)
#   define _REENTRANT 1
#endif


