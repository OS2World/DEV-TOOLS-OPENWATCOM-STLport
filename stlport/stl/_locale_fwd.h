# ifndef _STLP_INTERNAL_LOCALEFWD
#  define _STLP_INTERNAL_LOCALEFWD

// This file provides forward declarations of the locale class and
// it's most important facets.

//#ifndef _STLP_CHAR_TRAITS_H
//# include <stl/char_traits.h>
//#endif

_STLP_BEGIN_NAMESPACE

class locale;

# ifdef _STLP_NO_EXPLICIT_FUNCTION_TMPL_ARGS
template <class _Facet>
struct _Use_facet {
  const locale& __loc;
  _Use_facet(const locale& __p_loc) : __loc(__p_loc) {}
  inline const _Facet& operator *() const;
};
# define use_facet *_Use_facet
# else
template <class _Facet> inline const _Facet& use_facet(const locale&);
# endif

_STLP_END_NAMESPACE

#endif

// Local Variables:
// mode:C++
// End:
