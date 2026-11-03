# Fontconfig

Builds [Fontconfig 2.18.3](https://gitlab.freedesktop.org/fontconfig/fontconfig)
with the registry's FreeType and Expat. The gperf recipe supplies its code
generator. Building requires C/C++ compilers, make, CMake, pkg-config, and
Python 3.

```sh
ttrek install fontconfig -y
ttrek run fc-match sans-serif
```

Installs the library, headers, tools, and font configuration under the project
prefix. Standard system and user font directories are discovered without
changing `/etc/fonts`. Documentation, translations, and installation-time
font cache generation are disabled; caches are created when fonts are used.

Shared libraries are the default; `useFlags: ["+static"]` or
`ttrek gen-script -static fontconfig` selects static archives.
