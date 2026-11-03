# GNU gperf

Builds [GNU gperf 3.3](https://www.gnu.org/software/gperf/), registered as
`3.3.0` for semantic versioning. Requires C/C++ compilers and make.

```sh
ttrek install gperf -y
ttrek run gperf --version
```

Fontconfig uses this perfect hash function generator while building. It is
listed as a recipe dependency so ttrek installs it before configuring
Fontconfig; font rendering does not require running gperf.
