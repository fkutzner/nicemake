#include <teststaticlib/Static.h>


#include <ModernThirdParty.h>
#include <TraditionalThirdParty.h>

#if !defined(HAVE_MODERN_TPL)
  #error "Missing imported compiler flags of modern-thirdparty-lib"
#endif

#if !defined(HAVE_TRADITIONAL_TPL)
  #error "Missing imported compiler flags of traditional-thirdparty-lib"
#endif

int getMagicNumberStatic() {
  return 100 * (getMagicNumTraditional() + getMagicNumModern());
}
