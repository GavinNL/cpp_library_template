from conans import ConanFile, CMake


class CppLibraryTemplateConan(ConanFile):
    name = "cpp_library_template"
    version = "0.1"
    license = "<Put the package license here>"
    author = "GavinNL"
    url = "http://github.com/GavinNL/cpp_library_template"
    description = "<Description of Hello here>"
    topics = ("<Put some tag here>", "<here>", "<and here>")
    settings = "os", "compiler", "build_type", "arch"
    generators = "cmake"
    exports_sources = "*"

    options = {
        "shared": [True, False]
        }

    default_options = [
        "shared=True"
        ]


    def _configure_cmake(self):
        cmake = CMake(self)
        cmake.definitions["SOME_DEFINITION"] = True
        cmake.configure()

        return cmake


    def build(self):
        cmake = self._configure_cmake()
        cmake.build()

    def package(self):
        cmake = self._configure_cmake()
        cmake.install()
        #self.copy("*")
        #self.copy("*.h", dst="include", src="src")
        #self.copy("*.lib", dst="lib", keep_path=False)
        #self.copy("*.dll", dst="bin", keep_path=False)
        #self.copy("*.dylib*", dst="lib", keep_path=False)
        #self.copy("*.so", dst="lib", keep_path=False)
        #self.copy("*.a", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["hello"]
