/*
    Guess values for system-dependent variables and create STLPort configuration header.
    REXX script prepared for use with OS/2 OpenWatcom.

    Wojciech Gazda,
    Asua Programmers Group.

*/
"@echo off"

/* Load environment variables: */
/* CPP compiler flags          */
CXXFLAGS = VALUE("CXXFLAGS",,"OS2ENVIRONMENT");
LOGFILE  = "config.log"
n = SETLOCAL()

/* Defaults for configuration directives */
/*  --enable-namespaces     Use namespaces (default if posssible)
 *  --disable-namespaces    Don't use namespaces support"
 */
enable_namespaces="yes"
enable_namespaces_msg=""
/*
 *  --enable-exceptions     Use exceptions support (default if posssible)
 *  --disable-exceptions    Don't use exceptions support"
 */
enable_exceptions="yes"
enable_exceptions_msg=""
/*
 *  --enable-relops     Separate rel_ops namespace for relational operators (default if posssible)
 *  --disable-relops    No separate rel_ops namespace for relational operators"
 */
enable_relops="yes"
enable_relops_msg=""
/*
 *  --enable-new-style-headers  Use new-style headers (default)
 *  --disable-new-style-headers Don't use new-style headers"
 */
enable_new_style_headers="yes"
enable_new_style_headers_msg=""
/*
 *  --enable-new-iostreams  Use new iostreams (default)
 *  --disable-new-iostreams Don't use new iostreams"
 */
enable_new_iostreams="yes"
enable_new_iostreams_msg=""
/*
 *  --enable-sgi-allocators     set default parameter to SGI-style default alloc, not allocator<T>
 *  --disable-sgi-allocators    use allocator<T> if possible"
 */
enable_sgi_allcators="no"
/*
 *  --enable-malloc     set default alloc to malloc-based allocator ( malloc_alloc_template<instance_no>, alloc.h )
 *  --disable-malloc    choose (default) sgi node allocator (__alloc<threads,no>  alloc.h )"
 */
enable_malloc="no"
/*
 *  --enable-newalloc   set default alloc to new-based allocator ( new_alloc, alloc.h )
 *  --disable-newalloc  choose (default) sgi allocator (__alloc<threads,no>  alloc.h )"
 */
enable_newalloc="no"
/*
 *  --enable-defalloc   make HP-style defalloc.h included in alloc.h
 *  --disable-defalloc  leave defalloc.h alone"
 */
enable_defalloc="yes"
/*
 *  --enable-debugalloc     use debug versions of allocators
 *  --disable-debugalloc    not using debug allocators"
 */
enable_debugalloc="no"
/*
 *  --enable-abbrevs    use abbreviated class names internally for linker benefit (don't affect interface)
 *  --disable-abbrevs  don't use abbreviated names"
 */
enable_abbrevs="no"



/* Initialize files */
"del "LOGFILE "conftest.* confdefs.h 2>NUL"
'echo.>confdefs.h'

/* Print startup banner */
print("*** STLport configuration utility for OS/2 and OpenWatcom ***")
if(CXXFLAGS = "") then
do
    print("* Note: for best reliability - try CXXFLAGS = [TBD]")
    print("* Please don't forget specifying typical CXXFLAGS you'll be using -")
    print("* such as that enabling exceptions handling")
end
print("* Please stand by while exploring compiler capabilities...")
print("* Be patient - that may take a while...")
print("***")


/* Compiler linker and basic flags */
CXX      = "wpp386"
LINK     = "wlink"
CPPFLAGS = "-zq -xs -xr"
LDFLAGS  = "option q"

/* Create basic include path, this is in case STLPort has been added: */
/* on unconfigured compiler it prevents test programs from compiling. */
WATCOM = VALUE("WATCOM",,"OS2ENVIRONMENT")
if(WATCOM = "") then
do
    print("Missing WATCOM environment variable, check compiler installation...")
    exit 1
end

call VALUE "INCLUDE", WATCOM"\H;"WATCOM"\OS2\H" ,"OS2ENVIRONMENT"


/* ****** */
printnl("checking whether the C++ compiler ("CXX CPPFLAGS CXXFLAGS") works... ")
cnf('#include "confdefs.h"')
cnf('main(){return(0);}')
if(compile()) then
do
    print("failed");
    print("configure: error: installation or configuration problem: C++ compiler cannot create executables.")
    exit 1
end
print("OK")
"del conftest.* 2>NUL"


/* ****** */
sizeof_int = test_type_size("int")
dfs('#define SIZEOF_INT 'sizeof_int)
if(sizeof_int = "4") then
    dfs("#define _STLP_UINT32_T unsigned int")
else
do
    /* int is not 32bit, checking long */
    sizeof_long = test_type_size("long")
    dfs("#define SIZEOF_LONG "sizeof_long)
    if(sizeof_long = "4") then
        dfs("#define _STLP_UINT32_T unsigned long")
    else
    do
        /* long is not 32bit, checking short */
        sizeof_short = test_type_size("short")
        dfs("#define SIZEOF_SHORT "sizeof_short)
        if(sizeof_short = "4") then
            dfs("#define _STLP_UINT32_T unsigned short")
        else
        do
            print("configure: error: Cannot find any 32-bit integer type for your compiler")
            exit 1
        end
    end
end


/* ****** */
printnl("checking for basic STL compatibility... ")
cnf('#include "confdefs.h"')
cnf('template <class Arg1, class Arg2, class Result>')
cnf('struct binary_function {')
cnf('    typedef Arg1 first_argument_type;')
cnf('    typedef Arg2 second_argument_type;')
cnf('    typedef Result result_type;')
cnf('};')
cnf('template <class T>')
cnf('struct plus : public binary_function<T, T, T> {')
cnf('    T operator()(const T& x, const T& y) const;')
cnf('};')
cnf('template <class T>')
cnf('T plus<T>::operator()(const T& x, const T& y) const { return x + y; }')
cnf('plus<int> p;')
cnf('int main()')
cnf('{')
cnf('    return 0;')
cnf('}')
if(compile()) then
do
    print("failed");
    print("configure: error: Your compiler won't be able to compile this implementation. Sorry.")
    exit 1
end
print("OK")
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for namespaces support... ")
cnf('#include "confdefs.h"')
cnf('class test_class {};')
cnf('     namespace std {')
cnf('      using ::test_class;')
cnf('      template <class T> struct Class { typedef T my_type; };')
cnf('      typedef Class<int>::my_type int_type;')
cnf('	};')
cnf('    inline int ns_foo (std::int_type t) {')
cnf('      using namespace std;')
cnf('      int_type i =2;')
cnf('      return i+t;')
cnf('    }')
cnf('')
cnf('int main() {')
cnf('(void)ns_foo(1);')
cnf('; return 0; }')
_TEST_STD=""
_TEST_STD_BEGIN=""
_TEST_STD_END=""
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_HAS_NO_NAMESPACES 1')
    dfs('#define _STLP_NO_RELOPS_NAMESPACE 1')
    if(enable_namespaces = "yes")
        enable_namespaces_msg="Compiler restriction: no namespaces support used"
end
else
    print('OK')

    if(enable_namespaces = "yes") then
    do
        _TEST_STD="std"
        _TEST_STD_BEGIN="namespace "_TEST_STD" {"
        _TEST_STD_END="};"

        /* Some versions of Watcom express bug in template members declaration */
        printnl("checking for template members in namespace declaration bug... ")
        "del conftest.* 2>NUL"
        cnf('#include "confdefs.h"')
        cnf(_TEST_STD_BEGIN)
        cnf('')
        cnf('template <class T> struct Class { T foo(T arg); };')
        cnf('template <class T> T foo(T arg) { return arg; };')
        cnf('')
        cnf(_TEST_STD_END)
        cnf('')
        cnf('main() {')
        cnf('; return(0); }')
        if(compile()) then
        do
            print('failed')
            dfs('#define _STLP_TEMPLATE_MEMBERS_DECL_BUG 1')
        end
        else print('OK')
        enable_namespaces_msg="Config default: namespaces support enabled"

        /* Check for relational operators namespace */
        if(enable_relops = "no") then
        do
            enable_relops_msg = "Config arg --disable-relops: no std::rel_ops namespace by user request"
            dfs('#define _STLP_NO_RELOPS_NAMESPACE 1')
        end
        else
            enable_relops_msg = "Config default: Separate std::rel_ops namespace for relational operators"
    end
    else
    do
        /* Namespaces disabled by user request */
        enable_namespaces_msg="Config arg --disable-namespaces: code not put into namespace by user request"
        dfs('#define _STLP_HAS_NO_NAMESPACES 1')
        dfs('#define _STLP_NO_RELOPS_NAMESPACE 1')
    end
do
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for partial specialization syntax... ")
cnf('#include "confdefs.h"')
cnf('     template <class T> class fs_foo {};')
cnf('     template <> class fs_foo<int> {};')
cnf('int main() {')
cnf('    fs_foo<int> i;')
cnf('; return 0; }')
if(compile()) then
do
    print("failed");
    dfs("#define _STLP_NO_PARTIAL_SPECIALIZATION_SYNTAX 1")
    _FULL_SPEC=""
end
else
do
    print("OK")
    _FULL_SPEC="template <>"
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for bool keyword... ")
cnf('#include "confdefs.h"')
cnf('bool b_foo() { return true; }')
cnf('int main() {')
cnf('(void)b_foo();')
cnf('; return 0; }')
if(compile()) then
do
    print("failed");
    dfs("#define _STLP_NO_BOOL 1")

    /* bool keyword is unsupported */
    print("checking for yvals.h header... ")
    "del conftest.* 2>NUL"
    cnf('#include "confdefs.h"')
    cnf('#include <yvals.h>')
    cnf('    extern bool aaa=true;')
    cnf('int main() {')
    cnf('; return 0; }')
    if(compile()) then
    do
        print("failed")

        /* Check whether bool is reserved */
        print("checking whether bool is reserved word... ")
        "del conftest.* 2>NUL"
        cnf('#include "confdefs.h"')
        cnf('typedef int bool;')
        cnf('int main() {')
        cnf('; return 0; }')
        if(compile()) then
        do
            print("failed")
            dfs("#define _STLP_DONT_USE_BOOL_TYPEDEF 1")
        end
        else print("OK")
    end
    else
    do
        print("OK")
        dfs("#define _STLP_YVALS_H 1")
    end
end
else print("OK")
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for wchar_t type... ")
cnf('#include "confdefs.h"')
cnf('#include <wchar.h>')
cnf("      wchar_t wc_foo() { return 'a'; }")
cnf('int main() {')
cnf('(void)wc_foo();')
cnf('; return 0; }')
if(compile()) then
do
    print("failed")
    dfs("#define _STLP_NO_WCHAR_T 1")
end
else print("OK")
"del conftest.* 2>NUL"


/* ****** */
printnl("checking if wchar_t is unsigned short... ")
cnf('#include "confdefs.h"')
cnf('     # include <wchar.h>')
cnf('     template <class T> struct foo {};')
cnf('     '_FULL_SPEC' struct foo <wchar_t> {};')
cnf('     typedef unsigned short u__short;')
cnf('     '_FULL_SPEC' struct foo <u__short> {};')
cnf('     foo<wchar_t> f1;')
cnf('     foo<u__short> f2;')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('yes')
    dfs('#define _STLP_WCHAR_T_IS_USHORT 1')
end
else print('no');
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for long long type... ")
cnf('#include "confdefs.h"')
cnf('long long ll_foo() { return 0; }')
cnf('int main() {')
cnf('(void)ll_foo();')
cnf('; return 0; }')
if(compile()) then
    print('failed')
else
do
    print('OK')
    dfs('#define _STLP_LONG_LONG 1')
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for long double type... ")
cnf('#include "confdefs.h"')
cnf('long double ld_foo() { return 0; }')
cnf('int main() {')
cnf('(void)ld_foo();')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_LONG_DOUBLE 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for typename keyword... ")
cnf('#include "confdefs.h"')
cnf('')
cnf('template <class T1, class T2>')
cnf('struct pair {')
cnf('    typedef T1 first_type;')
cnf('    typedef T2 second_type;')
cnf('};')
cnf('')
cnf('template <class Arg, class Result>')
cnf('struct unary_function {')
cnf('    typedef Arg argument_type;')
cnf('    typedef Result result_type;')
cnf('};')
cnf('')
cnf('template <class Pair>')
cnf('struct select2nd : public unary_function<Pair, typename Pair::second_type> {')
cnf('  typedef typename Pair::first_type ignored_type;')
cnf('  const typename Pair::second_type& operator()(const typename Pair::second_type& x,')
cnf('						const ignored_type& ) const')
cnf('  {')
cnf('    return x;')
cnf('  }')
cnf('')
cnf('};')
cnf('')
cnf('int main() {')
cnf('')
cnf('	typedef pair<int,int> tn_p;')
cnf('	select2nd< tn_p > tn_s;')
cnf('	(void)tn_s(1,5);')
cnf('')
cnf('; return 0; }')
if(compile()) then
do
    print("failed")
    __TYPENAME=""
    dfs('#define _STLP_NEED_TYPENAME 1')
end
else
do
    print("OK")
    __TYPENAME="typename"
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for explicit keyword... ")
cnf('#include "confdefs.h"')
cnf('struct expl_Class { int a; explicit expl_Class(int t): a(t) {} };')
cnf('    expl_Class c(1);')
cnf('')
cnf('int main() {')
cnf('')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NEED_EXPLICIT 1')
end
else print("OK")
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for mutable keyword... ")
cnf('#include "confdefs.h"')
cnf('struct mut_Class { mutable int a; void update() const { a=0; }  };')
cnf('    mut_Class c;')
cnf('')
cnf('int main() {')
cnf('c.update()')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NEED_MUTABLE 1')
end
else print("OK")
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for new style casts... ")
cnf('#include "confdefs.h"')
cnf('struct ncast_Class {')
cnf('	int a; void update(int* i) { *i=a; }  };')
cnf('    ncast_Class c;')
cnf('')
cnf('int main() {')
cnf('')
cnf('  const int a(5);')
cnf('  c.update(const_cast<int*>(&a))')
cnf('')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define #define _STLP_NO_NEW_STYLE_CASTS 1')
end
else print("OK")
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for new-style C library headers... ")
cnf('#include "confdefs.h"')
cnf('     #include <cctype>')
cnf('     #include <cstddef>')
cnf('     #include <cstdio>')
cnf('     #include <cstdlib>')
cnf('     #include <cstring>')
cnf('     #include <cassert>')
cnf('     #include <climits>')
cnf('     #ifndef _STLP_NO_WCHAR_T')
cnf('     #include <cwchar>')
cnf('     #endif')
cnf('')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_HAS_NO_NEW_C_HEADERS 1')
    dfs('#define _STLP_NO_NEW_STYLE_HEADERS 1')
end
else
do
    print('OK')

    /* Check for header selection configuration option */
    if(enable_new_style_headers = "yes") then
        enable_new_style_headers_msg = "Config default: using new-style headers"
    else
    do
        dfs('#define _STLP_NO_NEW_STYLE_HEADERS 1')
        enable_new_style_headers_msg = "Config arg --disable-new-style-headers: not using new-style headers"
    end
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for new-style <new> header... ")
cnf('#include "confdefs.h"')
cnf('     #include <new>')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_NEW_NEW_HEADER 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for member template methods... ")
cnf('#include "confdefs.h"')
cnf('template <class Result>')
cnf('struct mt_foo {')
cnf('    typedef Result result_type;')
cnf('    template <class Arg> result_type operate(const Arg&) { return Result(); }')
cnf('};')
cnf('mt_foo<int> p;')
cnf('')
cnf('int main() {')
cnf('(void)p.operate((char*)"aaa");')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_MEMBER_TEMPLATES 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for friend templates... ")
cnf('#include "confdefs.h"')
cnf('')
cnf('template <class Result2> class foo;')
cnf('template <class Result>')
cnf('struct ft_foo {')
cnf('    typedef Result result_type;')
cnf('    template <class Result2> friend class foo;')
cnf('};')
cnf('ft_foo<int> p;')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_FRIEND_TEMPLATES 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for qualified friend templates... ")
cnf('#include "confdefs.h"')
cnf('')
cnf(_TEST_STD_BEGIN)
cnf('')
cnf('template <class Result2> class foo;')
cnf('template <class Result>')
cnf('struct ft_foo {')
cnf('    typedef Result result_type;')
cnf('    template <class Result2> friend class '_TEST_STD'::foo;')
cnf('};')
cnf('ft_foo<int> p;')
cnf(_TEST_STD_END)
cnf('')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_QUALIFIED_FRIENDS 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for member template keyword... ")
cnf('#include "confdefs.h"')
cnf('')
cnf('template <class Result>')
cnf('struct nt_foo {')
cnf('    typedef Result result_type;')
cnf('    template <class Arg> struct rebind {  typedef nt_foo<Arg> other; };')
cnf('};')
cnf('')
cnf('template <class _Tp, class _Allocator>')
cnf('struct _Traits')
cnf('{')
cnf('  typedef typename _Allocator:: template rebind<_Tp> my_rebind;')
cnf('  typedef typename my_rebind::other allocator_type;')
cnf('};')
cnf('')
cnf('nt_foo<char> p;')
cnf('_Traits< int, nt_foo<short> > pp;')
cnf('')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_MEMBER_TEMPLATE_KEYWORD 1')

    printnl("checking for member template classes... ")
    "del conftest.* 2>NUL"
    cnf('#include "confdefs.h"')
    cnf('')
    cnf('template <class Result>')
    cnf('struct nt_foo {')
    cnf('    typedef Result result_type;')
    cnf('    template <class Arg> struct rebind {  typedef nt_foo<Arg> other; };')
    cnf('};')
    cnf('')
    cnf('template <class _Tp, class _Allocator>')
    cnf('struct _Traits')
    cnf('{')
    cnf('  typedef typename _Allocator::rebind<_Tp> my_rebind;')
    cnf('  typedef typename my_rebind::other allocator_type;')
    cnf('};')
    cnf('')
    cnf('nt_foo<char> p;')
    cnf('_Traits< int, nt_foo<short> > pp;')
    cnf('')
    cnf('int main() {')
    cnf('; return 0; }')
    if(compile()) then
    do
        print('failed')
        dfs('#define _STLP_NO_MEMBER_TEMPLATE_CLASSES 1')
    end
    else print('OK')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for partial class specialization... ")
cnf('#include "confdefs.h"')
cnf('')
cnf('template <class Arg,class Result>')
cnf('struct ps_foo {')
cnf('    typedef Arg argument_type;')
cnf('    typedef Result result_type;')
cnf('};')
cnf('')
cnf('template<class Result>')
cnf('struct ps_foo<Result*,Result*> {')
cnf('	void bar() {}')
cnf('};')
cnf('')
cnf('template<class Result>')
cnf('struct ps_foo<int*,Result> {')
cnf('	void foo() {}')
cnf('};')
cnf('')
cnf('ps_foo<char*, char*> p;')
cnf('ps_foo<int*, int> p1;')
cnf('')
cnf('int main() {')
cnf('p.bar();')
cnf(' p1.foo();')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_CLASS_PARTIAL_SPECIALIZATION 1')
end
else
do
    print('OK')

    /* Partial class specialisation supported */
    printl("checking if explicit args accepted on constructors of partial specialized classes... ")
    "del conftest.* 2>NUL"
    cnf('#include "confdefs.h"')
    cnf('')
    cnf('template <class Arg,class Result>')
    cnf('struct ps_foo {')
    cnf('    typedef Arg argument_type;')
    cnf('    typedef Result result_type;')
    cnf('};')
    cnf('')
    cnf('template<class Result>')
    cnf('struct ps_foo<Result*,Result*> {')
    cnf('	ps_foo<Result*,Result*>() {}')
    cnf('	void bar() {}')
    cnf('};')
    cnf('')
    cnf('template<class Result>')
    cnf('struct ps_foo<int*,Result> {')
    cnf('	ps_foo<int*,Result*>() {}')
    cnf('	void bar() {}')
    cnf('')
    cnf('};')
    cnf('')
    cnf('ps_foo<char*, char*> p;')
    cnf('ps_foo<int*, int> p1;')
    cnf('')
    cnf('int main() {')
    cnf('p.bar();')
    cnf(' p1.foo();')
    cnf('; return 0; }')
    if(compile()) then
    do
        print('failed')

        printnl("checking if explicit args accepted on constructors of explicitly specialized classes... ")
        "del conftest.* 2>NUL"
        cnf('#include "confdefs.h"')
        cnf('')
        cnf('template <class Arg,class Result>')
        cnf('struct ps_foo {')
        cnf('    typedef Arg argument_type;')
        cnf('    typedef Result result_type;')
        cnf('    void bar() {}')
        cnf('};')
        cnf('')
        cnf('template<class Result>')
        cnf('struct ps_foo<int*,int> {')
        cnf('	ps_foo<Result*,Result*>() {}')
        cnf('	void foo() {}')
        cnf('};')
        cnf('')
        cnf('ps_foo<char*, char*> p;')
        cnf('ps_foo<int*, int> p1;')
        cnf('')
        cnf('int main() {')
        cnf('p.bar();')
        cnf(' p1.foo();')
        cnf('; return 0; }')
        if(compile()) then
            print('failed')
        else
        do
            print('OK')
            dfs('#define _STLP_PARTIAL_SPEC_NEEDS_TEMPLATE_ARGS 1')
        end
    end
    else
    do
        print('OK')
        dfs('#define _STLP_PARTIAL_SPEC_NEEDS_TEMPLATE_ARGS 1')
    end
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for partial template function ordering... ")
cnf('#include "confdefs.h"')
cnf('')
cnf('template <class Arg,class Result>')
cnf('Result po_foo (const Arg& a,const Result&){ return (Result)a.nothing; }')
cnf('')
cnf('template <class T>')
cnf('struct A {')
cnf('	T a;')
cnf('	A(int _a) : a(_a) {}')
cnf('};')
cnf('')
cnf('template<class T>')
cnf('T po_foo (const A<T>& a, const A<T>& b){ return a.a; }')
cnf('')
cnf('int main() {')
cnf('  A<int> po_a(0); A<int> po_b(1); (void)po_foo(po_b, po_a)')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_FUNCTION_TMPL_PARTIAL_ORDER 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for method specialization... ")
cnf('#include "confdefs.h"')
cnf('')
cnf('template <class Arg,class Result>')
cnf('struct ms_foo {')
cnf('    typedef Arg argument_type;')
cnf('    typedef Result result_type;')
cnf('    inline void bar();')
cnf('};')
cnf('')
cnf('template <class Arg,class Result>')
cnf('inline void ms_foo<Arg,Result>::bar() {}')
cnf('')
cnf('inline void ms_foo<int*,int>::bar() {}')
cnf('')
cnf('ms_foo<char*, char*> p;')
cnf('ms_foo<int*, int> p1;')
cnf('')
cnf('int main() {')
cnf('p.bar();')
cnf(' p1.bar();')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_METHOD_SPECIALIZATION 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for lrand48 function... ")
cnf('#include "confdefs.h"')
cnf('#include <stdlib.h>')
cnf('int main() {')
cnf('long i = lrand48();')
cnf('; return 0; }')
if(compile()) then
    print('failed')
else
do
    print('OK')
    dfs('#define _STLP_RAND48 1')
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for default template parameters... ")
cnf('#include "confdefs.h"')
cnf('template <class T> struct less {};')
cnf('     template <class T, class T1=less<T> > struct Class { T1 t1; };')
cnf('     Class<int> cl;')
cnf('     Class<int,less<short> > cl2;')
cnf('')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_LIMITED_DEFAULT_TEMPLATES 1')

    /* No default template parameters */
    printnl("checking for default type parameters... ")
    "del conftest.* 2>NUL"
    cnf('#include "confdefs.h"')
    cnf('')
    cnf('template <class T> struct less {')
    cnf('	typedef int int_t;')
    cnf('  };')
    cnf('')
    cnf('template <class T, class T1=less<int> >')
    cnf('struct Class {')
    cnf('private:')
    cnf('       int a;')
    cnf('public:')
    cnf('       typedef Class<T,T1> self;')
    cnf('       typedef '__TYPENAME' T1::int_t int_t;')
    cnf('       self foo (const Class<T,T1>& t) {')
    cnf('         if ( t.a==a ) return *this;')
    cnf('         else return t;')
    cnf('         }')
    cnf('};')
    cnf('')
    cnf('Class<int> cl;')
    cnf('Class<int,less<short> > cl2;')
    cnf('')
    cnf('int main() {')
    cnf('; return 0; }')
    if(compile()) then
        print('failed')
    else
    do
        print('OK')
        dfs('#define _STLP_DEFAULT_TYPE_PARAM 1')
    end
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
/*printnl("checking for default arguments in function template... ")*/
/*_STLP_NO_DEFAULT_FUNCTION_TMPL_ARGS*/

/* ****** */
printnl("checking for default non-type parameters... ")
cnf('#include "confdefs.h"')
cnf('')
cnf('template <class T, int N=0 >')
cnf('struct Class {')
cnf('private:')
cnf('       T* t;')
cnf('       enum { t1=N };')
cnf('public:')
cnf('       int get_n() { return N; }')
cnf('};')
cnf('')
cnf('Class<int> cl;')
cnf('Class<int, 2> cl2;')
cnf('')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_DEFAULT_NON_TYPE_PARAM 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for non-type parameter bug... ")
cnf('#include "confdefs.h"')
cnf('')
cnf('template <class T, int N>')
cnf('struct Class {')
cnf('private:')
cnf('       T* t;')
cnf('       enum { t1=N };')
cnf('public:')
cnf('       int get_n() { return N; }')
cnf('};')
cnf('')
cnf('template <class T, int N>')
cnf('int operator==(const Class<T,N>& , const Class<T,N>& ) { return 0; }')
cnf('')
cnf('Class<int, 1> cl;')
cnf('Class<int, 1> cl2;')
cnf('int i(cl==cl2);')
cnf('')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NON_TYPE_TMPL_PARAM_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for static data member templates... ")
cnf('#include "confdefs.h"')
cnf('template <class T> struct Class { static int a; };')
cnf('     template <class T> int Class<T>::a;')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_STATIC_TEMPLATE_DATA 1')

    /* No static data template member */
    printnl("checking for weak attribute... ")
    "del conftest.* 2>NUL"
    cnf('#include "confdefs.h"')
    cnf('int a_w __attribute__((weak));')
    cnf('int main() {')
    cnf('')
    cnf('; return 0; }')
    if(compile()) then
        print('failed')
    else
    do
        print('OK')
        dfs('#define _STLP_WEAK_ATTRIBUTE 1')
    end
end
else
do
    print('OK')

    /* Static template members allowed */
    printnl("checking for static array member size bug... ")
    "del conftest.* 2>NUL"
    cnf('#include "confdefs.h"')
    cnf('template <class T> struct Class { enum { sz=5 }; static int a[sz]; };')
    cnf('     template <class T> int Class<T>::a[Class<T>::sz];')
    cnf('int main() {')
    cnf('; return 0; }')
    if(compile()) then
    do
        print('failed')
        dfs('#define _STLP_STATIC_ARRAY_BUG 1')
    end
    else print('OK')
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for static data member const initializer bug... ")
cnf('#include "confdefs.h"')
cnf('template <class T> struct Class { static const int a = 1; };')
cnf('     template <class T> const int Class<T>::a;')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_STATIC_CONST_INIT_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl('checking for broken "using" directive... ')
cnf('#include "confdefs.h"')
cnf('namespace std {')
cnf('      template <class T> struct Class { typedef T my_type; };')
cnf('      typedef Class<int>::my_type int_type;')
cnf('      template <class T> void foo(T,int) {}')
cnf('      template <class T> void foo(T,int,int) {}')
cnf('	};')
cnf('   using std::Class;')
cnf('   using std::foo;')
cnf('')
cnf('int main() {')
cnf('(void)foo(1,1);')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_BROKEN_USING_DIRECTIVE 1')
end
else
do
    /* Check warnings, if there are any directive is broken TBD */
    if(check_warning()) then
    do
        print('failed')
        dfs('#define _STLP_BROKEN_USING_DIRECTIVE 1')
    end
    else print('OK')
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for exceptions support... ")
cnf('#include "confdefs.h"')
cnf('int ex_foo() {')
cnf('       try {')
cnf('         try { throw(1); }')
cnf('         catch (int a) { throw; }')
cnf('       } catch (...) {;}')
cnf('      return 0;')
cnf('    }')
cnf('int main() {')
cnf('(void)ex_foo();')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_HAS_NO_EXCEPTIONS 1')
    if(enable_exceptions = "yes") then
        enable_exceptions_msg="Compiler restriction: no exceptions support used"
end
else
do
    print('OK')

    if(enable_exceptions = "yes") then
    do

        /* Exception works, check features */
        /* ****** */
        printnl("checking if exceptions specification works... ")
        "del conftest.* 2>NUL"
        cnf('#include "confdefs.h"')
        cnf('template <class T> inline int ex_spec_foo(const T&) throw () { return 0;}')
        cnf('int main() {')
        cnf('(void)ex_spec_foo(5);')
        cnf('; return 0; }')
        if(compile()) then
        do
            print('failed')
            dfs('#define _STLP_NO_EXCEPTION_SPEC 1')
        end
        else print('OK')

        /* ****** */
        printnl("checking if return is required after throw... ")
        "del conftest.* 2>NUL"
        cnf('#line 2244 "configure"')
        cnf('#include "confdefs.h"')
        cnf('int ex_foo() {')
        cnf('       try {')
        cnf('         try { throw(1); }')
        cnf('         catch (int a) { throw; }')
        cnf('       } catch (...) {;}')
        cnf('      return 0;')
        cnf('    }')
        cnf('int main() {')
        cnf('(void)ex_foo();')
        cnf('; return 0; }')
        if(compile()) then
        do
            print('failed')
            dfs('#define _STLP_THROW_RETURN_BUG 1')
        end
        else
        do
            /* Check warnings */
            if(check_warning()) then
            do
                print('warnings')
                dfs('#define _STLP_THROW_RETURN_BUG 1')
            end
            else print('OK')
        end
        enable_exceptions_msg="Config default: exceptions enabled"
    end
    else
    do
        enable_exceptions_msg="Config arg --disable-exceptions: disabling exceptions by user request"
        dfs('#define _STLP_HAS_NO_EXCEPTIONS 1')
    end
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for native <string> header with basic_string defined... ")
cnf('#include "confdefs.h"')
cnf('     #include <string>')
cnf('     # if !defined (_STLP_HAS_NO_NAMESPACES)')
cnf('       using namespace '_TEST_STD';')
cnf('     # endif')
cnf('     basic_string<char, char_traits<char>, allocator<char> > bs;')
cnf('     string bd = bs;')
cnf('')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_STRING_HEADER 1')
end
else
do
    print('OK')

    /* ****** */
    printnl("checking for native <stdexcept> header... ")
    "del conftest.* 2>NUL"
    cnf('#include "confdefs.h"')
    cnf('     #include <stdexcept>')
    cnf('     # if !defined (_STLP_HAS_NO_NAMESPACES)')
    cnf('       using namespace '_TEST_STD';')
    cnf('     # endif')
    cnf('     string s;')
    cnf('     logic_error le(s);')
    cnf('     runtime_error re(s);')
    cnf('     domain_error de(s);')
    cnf('     invalid_argument ia(s);')
    cnf('     length_error lne(s);')
    cnf('     out_of_range or(s);')
    cnf('     range_error rne(s);')
    cnf('     overflow_error ove(s);')
    cnf('     underflow_error ue(s);')
    cnf('')
    cnf('int main() {')
    cnf('; return 0; }')
    if(compile()) then
    do
        print('failed')
        dfs('#define _STLP_NO_STDEXCEPT_HEADER 1')
    end
    else print('OK')
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for new iostreams... ")
cnf('#include "confdefs.h"')
cnf('     #include <iosfwd>')
cnf('     #include <iostream>')
cnf('     # if !defined (_STLP_HAS_NO_NAMESPACES)')
cnf('       using namespace '_TEST_STD';')
cnf('     # endif')
cnf('     template <class _Tp, class _Traits>')
cnf('     void outp(basic_ostream<_Tp,_Traits>& o, char* str) {')
cnf('         o<<str;')
cnf('        }')
cnf('')
cnf('int main() {')
cnf('	outp(cout, "Hello World\n")')
cnf('')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_HAS_NO_NEW_IOSTREAMS 1')
    dfs('#define _STLP_NO_NEW_IOSTREAMS 1')
end
else
do
    print('OK')

    # Check whether --enable-new-iostreams or --disable-new-iostreams was given.
    if(enable_new_iostreams = "yes") then
        enable_new_iostreams_msg = "Config default: using new iostreams"
    else
    do
        dfs('#define _STLP_NO_NEW_IOSTREAMS 1')
        enable_new_iostreams_msg = "Config arg --disable-new-iostreams: not using new iostreams"
    end
end
"del conftest.* 2>NUL"


/* ****** */
printnl('checking for <exception> header with class "exception" defined... ')
cnf('#include "confdefs.h"')
cnf('     #include <exception>')
cnf('     # if !defined (_STLP_HAS_NO_NAMESPACES)')
cnf('       using namespace '_TEST_STD';')
cnf('     # endif')
cnf('     class my_exception: public '_TEST_STD'::exception {};')
cnf('     my_exception mm;')
cnf('')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_EXCEPTION_HEADER 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl('checking for builtin constructor bug... ')
cnf('#include "confdefs.h"')
cnf('#ifdef __cplusplus')
cnf('extern "C" void exit(int);')
cnf('#endif')
cnf('# ifdef _STLP_USE_NEW_STYLE_HEADERS')
cnf('#  include <cassert>')
cnf('#  include <cstdio>')
cnf('#  include <cstring>')
cnf('#  include <new>')
cnf('# else')
cnf('#  include <assert.h>')
cnf('#  include <stdio.h>')
cnf('#  include <string.h>')
cnf('#  include <new.h>')
cnf('# endif')
cnf('int main(int, char**) {')
cnf('	int i;')
cnf('	double buf[1000];')
cnf('	char* pc = (char*)buf;')
cnf('	short* ps = (short*)buf;')
cnf('	int* pi = (int*)buf;')
cnf('	long* pl = (long*)buf;')
cnf('	double* pd = (double*)buf;')
cnf('	float* pf = (float*)buf;')
cnf('	for (i=0; i<100; i++) {')
cnf('	   	new(pc) char();')
cnf('        	assert(char()==0 && *pc==0);')
cnf('		sprintf(pc,"lalala\n");')
cnf('	        new (ps) short();')	
cnf('		assert(short()==0 && *ps ==0);')
cnf('		sprintf(pc,"lalala\n");')
cnf('	        new (pi) int();')
cnf('		assert(int()==0 && *pi == 0);')
cnf('		sprintf(pc,"lalala\n");')
cnf('	        new (pl) long();')	
cnf('		assert(long()==0 && *pl == 0);')
cnf('		sprintf(pc,"lalala\n");')
cnf('	        new (pf) float();')	
cnf('		assert(float()==0.0 && *pf == 0.0);')
cnf('		sprintf(pc,"lalala\n");')
cnf('	        new (pd) double();')	
cnf('		assert(double()==0.0 && *pd == 0.0);')
cnf('		sprintf(pc,"lalala\n");')
cnf('	}')
cnf('  return 0;')
cnf('}')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_DEFAULT_CONSTRUCTOR_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for trivial constructor bug... ")
cnf('#include "confdefs.h"')
cnf('struct output_iterator_tag {};')
cnf('     void tc_bug_foo(output_iterator_tag) {}')
cnf('     inline void tc_test_foo()  { tc_bug_foo(output_iterator_tag()); }')
cnf('int main() {')
cnf('tc_test_foo();')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_TRIVIAL_CONSTRUCTOR_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for trivial destructor bug... ")
cnf('#include "confdefs.h"')
cnf('struct output_iterator_tag {output_iterator_tag() {} };')
cnf('	output_iterator_tag* td_bug_bar ;')
cnf('')
cnf('int main() {')
cnf(' td_bug_bar->~output_iterator_tag();')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_TRIVIAL_DESTRUCTOR_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for explicit function template arguments... ")
cnf('#include "confdefs.h"')
cnf('  template <class T> class foo;')
cnf('       template<class T> bool operator==(const foo<T>& lhs,const foo<T>& rhs);')
cnf('      template <class T> class foo {')
cnf('	private:')
cnf('	  T bar;')
cnf('	friend bool operator== <> (const foo<T>&,const foo<T>&);')
cnf('     };')
cnf('     template<class T> bool operator==(const foo<T>& lhs,const foo<T>& rhs) {')
cnf('	return  lhs.bar==rhs.bar;')
cnf('     }')
cnf('int main() {')
cnf(' foo<int> f1, f2;')
cnf('      int ret= (f1==f2)')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_EXPLICIT_FUNCTION_TMPL_ARGS 1')
    _NULLARGS=""
end
else
do
    print('OK')
    _NULLARGS="<>"
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for template parameter baseclass matching... ")
cnf('#include "confdefs.h"')
cnf('struct output_iterator_tag {};')
cnf('     struct derived1_tag : public output_iterator_tag {};')
cnf('     struct derived2_tag : public derived1_tag {};')
cnf('     template<class T> struct output_iterator {')
cnf('	public:')
cnf('	output_iterator() {}')
cnf('	~output_iterator() {}')
cnf('	friend inline int operator== '_NULLARGS' (const output_iterator<T>&,')
cnf('                                      const output_iterator<T>&);')
cnf('	};')
cnf('     template<class T> inline int operator==(const output_iterator<T>&,')
cnf('                              	        const output_iterator<T>&) {')
cnf('       return 0;')
cnf('     }')
cnf('     template<class T> inline output_iterator_tag')
cnf('     iterator_category(const output_iterator<T>&) {return output_iterator_tag();}')
cnf('     template <class T>')
cnf('     struct derived_iterator : public output_iterator<T> {')
cnf('	public:')
cnf('	derived_iterator() {}')
cnf('	~derived_iterator() {}')
cnf('	};')
cnf('     template<class T> inline T select_foo(T t, output_iterator_tag) { return t;}')
cnf('     template<class T> inline int select_foo_2(T, T,')
cnf('                                             output_iterator_tag) { return 0;}')
cnf('     template<class T> inline T tbase_foo(T pm )  {')
cnf('	derived_iterator<T> di1, di2; int i( di1==di2 && pm);')
cnf('	return select_foo((int)1,iterator_category(derived_iterator<T>()));')
cnf('    }')
cnf('')
cnf('int main() {')
cnf(' (void)tbase_foo((int)1);')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_BASE_MATCH_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for non-template parameter baseclass matching... ")
cnf('#include "confdefs.h"')
cnf('struct output_iterator_tag {};')
cnf('     struct derived1_tag : public output_iterator_tag {};')
cnf('     struct derived2_tag : public derived1_tag {};')
cnf('     struct derived3_tag : public derived2_tag {};')
cnf('     template<class T> struct output_iterator {')
cnf('	public:')
cnf('	output_iterator() {}')
cnf('	~output_iterator() {}')
cnf('	};')
cnf('     template<class T> inline output_iterator_tag')
cnf('     iterator_category(const output_iterator<T>&) {return output_iterator_tag();}')
cnf('     template <class T>')
cnf('     struct derived_iterator : public output_iterator<T> {')
cnf('	public:')
cnf('	derived_iterator() {}')
cnf('	~derived_iterator() {}')
cnf('	};')
cnf('     template<class T> inline int select_foo_2(T, T,')
cnf('                                             output_iterator_tag) { return 0;}')
cnf('     template<class T> inline int select_foo_2(T, T,')
cnf('                                             derived1_tag) { return 0;}')
cnf('     template<class T> inline void nont_base_foo(T pm )  {')
cnf('	derived_iterator<T> di1, di2;')
cnf('	(void)select_foo_2(di1, (const derived_iterator<T>&)di2, derived3_tag());')
cnf('    }')
cnf('')
cnf('int main() {')
cnf(' nont_base_foo((int)1);')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NONTEMPL_BASE_MATCH_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for nested type parameters bug... ")
cnf('#include "confdefs.h"')
cnf('template<class T> struct nt_o { typedef int ii; inline ii foo(ii);};')
cnf('     template <class T> inline nt_o<T>::ii nt_o<T>::foo(ii) { return 0; }')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NESTED_TYPE_PARAM_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking if inherited template typedefs broken completely... ")
cnf('#include "confdefs.h"')
cnf('template <class Arg1, class Arg2, class Result>')
cnf('struct binary_function {')
cnf('    typedef Arg1 first_argument_type;')
cnf('    typedef Arg2 second_argument_type;')
cnf('    typedef Result result_type;')
cnf('};')
cnf('template <class T>')
cnf('struct equal_to : public binary_function<T, T, int> {')
cnf('    int operator()(const T& x, const T& y) const { return x == y; }')
cnf('};')
cnf('template <class Predicate>')
cnf('class binary_negate')
cnf('    : public binary_function<'__TYPENAME' Predicate::first_argument_type,')
cnf('			     '__TYPENAME' Predicate::second_argument_type,')
cnf('                             int> {')
cnf('protected:')
cnf('    Predicate pred;')
cnf('public:')
cnf('    binary_negate(const Predicate& x = Predicate()) : pred(x) {}')
cnf('    int operator() (const '__TYPENAME' Predicate::first_argument_type& x,')
cnf('		    const '__TYPENAME' Predicate::second_argument_type& y) const {')
cnf('	return !pred(x, y);')
cnf('    }')
cnf('};')
cnf('      typedef equal_to<int> eq_int;')
cnf('      typedef binary_negate<equal_to<int> > int_negate;')
cnf('      int_negate n;')
cnf('')
cnf('int main() {')
cnf('      (void)n(1,2);')
cnf('')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_BASE_TYPEDEF_BUG 1')
    dfs('#define _STLP_BASE_TYPEDEF_OUTSIDE_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking if inherited typedefs visible from outside... ")
cnf('#include "confdefs.h"')
cnf('template <class Arg1, class Arg2, class Result>')
cnf('struct binary_function {')
cnf('    typedef Arg1 first_argument_type;')
cnf('    typedef Arg1 second_argument_type;')
cnf('    typedef Result result_type;')
cnf('};')
cnf('')
cnf('template <class T>')
cnf('class plus : public binary_function<T, T, T> {')
cnf('public:')
cnf('    plus() {}')
cnf('    plus(const T&) {}')
cnf('    T operator()(const T& x, const T& y) const { return x + y; };')
cnf('};')
cnf('plus<int> p;')
cnf('plus<int>::first_argument_type a;')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_BASE_TYPEDEF_OUTSIDE_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking if private type static members initializable... ")
cnf('#include "confdefs.h"')
cnf('struct p_Class { private: struct str_ {')
cnf('	int a; str_(int i) : a(i) {}}; static str_ my_int;')
cnf('     };')
cnf('     p_Class::str_ p_Class::my_int(0);')
cnf('')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_UNINITIALIZABLE_PRIVATE 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for const member constructor bug... ")
cnf('#include "confdefs.h"')
cnf('template <class T1, class T2>')
cnf('struct pair {')
cnf('    T1 first;')
cnf('    T2 second;')
cnf('    pair(): first(T1()), second(T2()) {}')
cnf('    pair(const pair<T1,T2>& o) : first(o.first), second(o.second) {}')
cnf('};')
cnf('pair< const int, const int > p;')
cnf('')
cnf('int main() {')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_CONST_CONSTRUCTOR_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for loop inline problems... ")
cnf('#include "confdefs.h"')
cnf('inline int il_foo (int a) {')
cnf('      int i; for (i=0; i<a; i++) a+=a;  while (i>0) a-=3; return a; }')
cnf('int main() {')
cnf('(void)il_foo(0);')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_LOOP_INLINE_PROBLEMS 1')
end
else
do
    if(check_warning()) then
    do
        print('failed')
        dfs('#define _STLP_LOOP_INLINE_PROBLEMS 1')
    end
    else print('OK')
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking if arrow operator always get instantiated... ")
cnf('#include "confdefs.h"')
cnf('     template <class T> struct um_foo { T* ptr;')
cnf('	T* operator ->() { return &(operator*());}')
cnf('	T  operator *()  { return *ptr; }')
cnf('     };')
cnf('     template <class T>')
cnf('	int operator == ( const um_foo<T>& x, const um_foo<T>& y)')
cnf('	{')
cnf('    		return *x == *y;')
cnf('	}')
cnf('     struct um_tag { int a ; };')
cnf('     um_foo<um_tag> f;')
cnf('     um_foo<int> a;')
cnf('')
cnf('int main() {')
cnf('     int b(5); a.ptr=&b;')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_ARROW_OPERATOR 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for pointer-to-member parameter bug... ")
cnf('#include "confdefs.h"')
cnf('struct pmf_foo {')
cnf('	int bar() { return 0; };')
cnf('};')
cnf('template <class Class, class Result>')
cnf('class mem_fun_t {')
cnf('protected:')
cnf('    typedef Result (Class::*fun_type)(void);')
cnf('    fun_type ptr;')
cnf('public:')
cnf('    mem_fun_t() {}')
cnf('    mem_fun_t(fun_type p) : ptr(p) {}')
cnf('    Result operator()(Class* x) const { return (x->*ptr)();}')
cnf('};')
cnf('template <class Class, class Result>')
cnf('inline mem_fun_t <Class, Result>')
cnf('mem_fun(Result (Class::*ptr)(void)) {')
cnf('    return mem_fun_t<Class, Result>(ptr);')
cnf('}')
cnf('int main() {')
cnf('pmf_foo pmf; (void)mem_fun(&pmf_foo::bar)(&pmf)')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_MEMBER_POINTER_PARAM_BUG 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking if bad_alloc defined in <new>... ")
cnf('#include "confdefs.h"')
cnf('     #if !defined (_STLP_NO_NEW_STYLE_HEADERS)')
cnf('     #include <new>')
cnf('     #else')
cnf('     #include <new.h>')
cnf('     #endif')
cnf('     # if !defined (_STLP_HAS_NO_NAMESPACES)')
cnf('       using namespace '_TEST_STD';')
cnf('     # endif')
cnf('     bad_alloc badalloc_foo() { bad_alloc err; return err;}')
cnf('int main() {')
cnf('(void)badalloc_foo()')
cnf('; return 0; }')
if(compile()) then
do
    print('failed')
    dfs('#define _STLP_NO_BAD_ALLOC 1')
end
else print('OK')
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for __type_traits automatic specialization... ")
cnf('#include "confdefs.h"')
cnf('template <class T> int tt_foo(const T&) {')
cnf('	typedef __type_traits<T> traits;')
cnf('	return 0;')
cnf('     }')
cnf('int main() {')
cnf('(void)tt_foo(5)')
cnf('; return 0; }')
if(compile()) then
    print('failed')
else
do
    print('OK')
    dfs('#define _STLP_AUTOMATIC_TYPE_TRAITS 1')
end
"del conftest.* 2>NUL"


/* ****** */
printnl("checking for compiler version string... ")
cnf('#include "confdefs.h"')
cnf('#ifdef __cplusplus')
cnf('extern "C" void exit(int);')
cnf('#endif')
cnf('#include <stdio.h>')
cnf('main()')
cnf('{')
cnf('  FILE *f=fopen("conftest.dat", "w");')
cnf('  if (!f) exit(1);')
cnf('  fprintf(f, "%d\n", __WATCOMC__);')
cnf('  exit(0);')
cnf('}')
if(compile()) then
    print("failed")
else
do
    print('OK')
    compiler_ver = linein("conftest.dat")
    call stream "conftest.dat",'c','close'
    print("Compiler version: __WATCOMC__ = "compiler_ver)
    dfs('// __WATCOMC__ = 'compiler_ver)
end
"del conftest.* 2>NUL"



/* package options - exceptions */
print("***")
print("Setting implementation options...")
print("***")

print(enable_namespaces_msg)
print(enable_exceptions_msg)

if(enable_relops_msg <> "") then
    print(enable_relops_msg)

if(enable_new_style_headers_msg <> "") then
    print(enable_new_style_headers_msg)

if(enable_new_iostreams_msg <> "") then
    print(enable_new_iostreams_msg)


/* Select allocator */
if(enable_sgi_allocators = "yes") then
do
    dfs('#define _STLP_USE_RAW_SGI_ALLOCATORS 1'
    print("Config arg  --enable-sgi-allocators : SGI-style alloc as default allocator")
end
else if(enable_malloc = "yes") then
do
    dfs('#define _STLP_USE_MALLOC 1')
    print("Config arg  --enable-malloc: setting malloc_alloc as default alloc")
end
else if(enable_newalloc = "yes") then
do
    dfs('#define _STLP_USE_NEWALLOC 1')
    print("Config arg --enable-newalloc : setting new_alloc as default alloc")
end
else
    print("Config default: using allocator<T> as default allocator if possible")


/* HP style defalloc */
if(enable_defalloc = "yes") then
do
    dfs('#define _STLP_USE_DEFALLOC 1')
    print("Config default: including HP-style defalloc.h into alloc.h")
end
else
    print("Config arg --disable-defalloc: not including HP-style defalloc.h into alloc.h")


/* Debug allocators */
if(enable_debugalloc = "yes") then
do
    dfs('#define _STLP_DEBUG_ALLOC 1')
    print("Config arg --enable-debugalloc: use debug versions of allocators")
end


/* Abbreviated class names */
if(enable_abbrevs = "yes") then
do
    dfs('#define _STLP_USE_ABBREVS 1')
    print("Config arg --enable-abbrevs: using abbreviated class names internally")
end

dfs('#define __AUTO_CONFIGURED 1')

n = ENDLOCAL()
exit
/***************************************/
/* END - utility procedures start here */
/***************************************/

/********************************************************************
 * Function checks whether compiler issued warnings into the config.log
 * Not implemented yet.
 */
check_warning:
/*
check_warning () {
    warn_str=`tail -1 config.log | egrep -i "arning|\(W\)"`
    if test "$warn_str" = ""; then
      return 0
    else
     return 1
    fi
}
*/
RETURN "0"


/********************************************************************
 * Function compile a test program stored in the conftest.cpp file.
 * Program is linked into the conftest.exe and run.
 * In order to return successfull status following conditions must met:
 *  - exit status from compiler and linker must indicate success,
 *  - exit status from test program must be zero.
 */
compile:
    return_code = 0
    CXX" conftest.cpp "CPPFLAGS CXXFLAGS " 2>>"LOGFILE "1>>&2"
    if(RC = "0") then
    do
        LINK LDFLAGS" system os2v2 name conftest.exe file conftest.obj >>"LOGFILE
        if(RC = "0") then
        do
            "conftest.exe 2>>"LOGFILE "1>>&2"
            if(RC > "0") then return_code = 1
        end
        else return_code = 1
    end
    else return_code = 1
    if(return_code = "1") then call dump_program;
RETURN return_code


/********************************************************************
 * Write line into the conftest.cpp stream
 */
cnf:
    call lineout "conftest.cpp", arg(1)
    call lineout "conftest.cpp"
RETURN ""


/********************************************************************
 * Function prints parameter both to the screen and to the log file
 * Note: single expression only is accepted
 */
print:
    say arg(1);
    call lineout LOGFILE,arg(1)
    call stream LOGFILE,'c','close'
RETURN ""


/********************************************************************
 * Write line into the confdefs.h stream
 */
dfs:
    call lineout "confdefs.h", arg(1)
    call lineout "confdefs.h"
RETURN ""


/********************************************************************
 * Dump conftest.cpp into log file
 */
dump_program: PROCEDURE EXPOSE LOGFILE

    do until lines(conftest.cpp) = 0
        line = linein(conftest.cpp)
        call lineout LOGFILE,line
    end
    call stream "conftest.cpp",'c','close'
    call stream LOGFILE,'c','close'
RETURN


/********************************************************************
 * Function prints parameter both to the screen and to the log file
 * without new line appended to the end of stream.
 * Note: single expression only is accepted
 */
printnl:
    call charout ,arg(1)
    call charout LOGFILE,arg(1)
    call stream LOGFILE,'c','close'
RETURN ""


/********************************************************************
 * Function performs type size test returning size in bytes
 * or zero in case of failure.
 */
test_type_size: PROCEDURE EXPOSE LINK LDFLAGS CXX CPPFLAGS CXXFLAGS LOGFILE
    typename = arg(1)
    sizeof_type = 0

    printnl("checking size of "typename"... ")
    cnf('#include "confdefs.h"')
    cnf('#ifdef __cplusplus')
    cnf('extern "C" void exit(int);')
    cnf('#endif')
    cnf('#include <stdio.h>')
    cnf('main()')
    cnf('{')
    cnf('  FILE *f=fopen("conftest.dat", "w");')
    cnf('  if (!f) exit(1);')
    cnf('  fprintf(f, "%d\n", sizeof('typename'));')
    cnf('  exit(0);')
    cnf('}')
    if(compile()) then
    do
        print("failed")
        print("Configure: error: cannot compile "typename" size test program:")
    end
    else
    do
        sizeof_type = linein("conftest.dat")
        call stream "conftest.dat",'c','close'
        print(sizeof_type)
    end
    "del conftest.* 2>NUL"
RETURN sizeof_type

