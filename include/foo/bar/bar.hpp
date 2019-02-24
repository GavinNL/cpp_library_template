#ifndef FOO_BAR_HPP_
#define FOO_BAR_HPP_

#include <iostream> // std::cout
#include <foo/bar/BAR_EXPORT.h>

namespace foo {

class BAR_EXPORT bar {
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
