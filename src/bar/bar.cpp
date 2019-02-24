#include <foo/bar/bar.hpp>

namespace foo {

void bar::cpp_say() {
#if (FOO_BAZ_DEBUG)
  const char* m = "Baz.cpp (Debug)";
#else
  const char* m = "Baz.cpp (Not debug)";
#endif
  std::cout << m << std::endl;
}

} // namespace foo
