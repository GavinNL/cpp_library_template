#ifndef FOO_CAT_HPP_
#define FOO_CAT_HPP_

#include <iostream> // std::cout
#include <foo/cat/CAT_EXPORT.h>

namespace foo {



class CAT_EXPORT cat
{
    public:
        cat();
        ~cat();

        void call_bar();

};

} // namespace foo

#endif // FOO_BAZ_HPP_
