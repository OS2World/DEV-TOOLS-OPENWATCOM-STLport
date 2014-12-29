// -*- C++ -*- Time-stamp: <04/01/16 21:32:26 ptr>

#include <iostream>
#include <string>

#ifdef MAIN
#   define string_mt_test main
#endif

#if defined(_STLP_PTHREADS) || defined(_STLP_WIN32THREADS) \
    || (defined(_STLP_OS2THREADS) && defined(__WATCOMC__))

#ifdef _STLP_PTHREADS
# include <pthread.h>
#endif

#ifdef _STLP_WIN32THREADS
# include <windows.h>
#endif

#ifdef _STLP_OS2THREADS
#  define INCL_DOSPROCESS
#  include <os2.h>
#  include <process.h>
#endif

#if !defined (STLPORT) || defined(__STL_USE_NAMESPACES)
using namespace std;
#endif

const char *refstr = "qyweyuewunfkHBUKGYUGL,wehbYGUW^(@T@H!BALWD:h^&@#*@(#:JKHWJ:CND";

string func( const string& par )
{
  string tmp( par );

  return tmp;
}


#if defined (_STLP_PTHREADS)
void *f( void * )
#elif defined (_STLP_WIN32THREADS)
DWORD __stdcall f (void *)
#elif defined (_STLP_OS2THREADS)
void FAR f(void FAR *)
#endif
{
  string s( refstr );

  for ( int i = 0; i < 2000000; ++i ) {
    string sx = func( s );
    if(sx != refstr)
    {
        cout << "String got corrupted in a thread." << endl;
        break;
    }
  }

#if !defined (_STLP_OS2THREADS)
    return 0;
#endif
}

int string_mt_test( int, char ** )
{
    const int nth = 2;

    cout<<"Running string_mt test..."<<endl;

#if defined(_STLP_PTHREADS)
    pthread_t t[nth];

    for ( int i = 0; i < nth; ++i ) {
      pthread_create( &t[i], 0, f, 0 );
    }

    for ( int i = 0; i < nth; ++i ) {
      pthread_join( t[i], 0 );
    }
#endif // _STLP_PTHREADS

#if defined (_STLP_WIN32THREADS)
    HANDLE t[nth];

    int i; // VC6 not support in-loop scope of cycle var
    for ( i = 0; i < nth; ++i ) {
      t[i] = CreateThread(NULL, 0, f, 0, 0, NULL);
    }

    for ( i = 0; i < nth; ++i ) {
      WaitForSingleObject(t[i], INFINITE);
    }
#endif

#if defined (_STLP_OS2THREADS)
    ULONG tid;
    int t[nth];
    int i;

    for ( i = 0; i < nth; ++i ) {
      t[i] = _beginthread(f, NULL, 8192, NULL);
    }

    for ( i = 0; i < nth; ++i ) {
      tid = (ULONG)t[i];
      DosWaitThread(&tid, DCWW_WAIT);
    }
#endif // _STL_OS2THREADS
    return 0;
}
#else // !_STLP_PTHREADS && !_STLP_WIN32THREADS && !_STLP_OS2THREADS


int string_mt_test( int, char ** )
{
  return -1;
}


#endif // _STLP_PTHREADS || _STLP_WIN32THREADS
