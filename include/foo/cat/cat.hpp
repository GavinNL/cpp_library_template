#ifndef FOO_CAT_HPP_
#define FOO_CAT_HPP_

#include <iostream> // std::cout
#include <foo/cat/CAT_EXPORT.h>

namespace foo {

class CAT_EXPORT cat {
 public:
  static void say() {
#if (FOO_BAR_DEBUG)
    const char* m = "Baz.hpp (Debug)";
#else
    const char* m = "Baz.hpp (Not debug)";
#endif
    std::cout << m << std::endl;
    cpp_say();
  }

 private:
  static void cpp_say();
};

} // namespace foo

#endif // FOO_BAZ_HPP_
