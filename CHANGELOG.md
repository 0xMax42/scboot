# Changelog

All notable changes to this project will be documented in this file.

## [unreleased]

### 🚀 Features

- *(scripts)* Add scboot CLI and improve signing workflows - ([a6d4c7e](https://git.0xmax42.io/SimDev/scboot/commit/a6d4c7e6d19493973c5ee4c157c9c8d024b5d305))
- *(config)* Add dkms signing configuration and english comments - ([409bce0](https://git.0xmax42.io/SimDev/scboot/commit/409bce0fc3d5030c1bc4ded92e18e8799616b438))
- *(systemd)* Add scboot reload units for config changes - ([c5bedb4](https://git.0xmax42.io/SimDev/scboot/commit/c5bedb4babc5666a42e1d6df27ec7b028291eeba))
- *(hooks)* Update apt hooks to use new resign helpers - ([276dca5](https://git.0xmax42.io/SimDev/scboot/commit/276dca50db39f44603593d6db277a2f58c624630))

### 🐛 Bug Fixes

- *(makefile)* Preserve subdirectories when building files - ([f67e3fa](https://git.0xmax42.io/SimDev/scboot/commit/f67e3fa5e8da769a6083f2360ab7944cd4b94dcf))
- *(scripts)* Use DER certificate path for dkms signing - ([fe07dad](https://git.0xmax42.io/SimDev/scboot/commit/fe07dadf21f190521cc242fb16f47f1890328973))
- *(makefile)* Run clean before build target - ([eb60e36](https://git.0xmax42.io/SimDev/scboot/commit/eb60e36cda89747da3b4a0d0392e00c8aa2d33f8))
- *(makefile)* Correct kernel signing template variable name - ([773ee5c](https://git.0xmax42.io/SimDev/scboot/commit/773ee5ced6458ccd42e30c39c55c11987bc615f1))
- *(makefile)* Copy config files into build directory - ([4ad047f](https://git.0xmax42.io/SimDev/scboot/commit/4ad047faabe23c47c5fc1d4ccef883080f1a8f6b))
- *(makefile)* Update uninstall targets for new files and dirs - ([988aa9d](https://git.0xmax42.io/SimDev/scboot/commit/988aa9df10a29932f916a099695cba33e93833ec))
- *(scripts)* Read VERSION from script directory - ([48a43c4](https://git.0xmax42.io/SimDev/scboot/commit/48a43c4a288fd99cd4c2e2c880ae3541ffe85c51))
- *(build)* Update changelog generation script URL - ([3912df1](https://git.0xmax42.io/SimDev/scboot/commit/3912df13ba30c8c54bf8916c0e74f91167400ba8))

### 🚜 Refactor

- *(hooks)* Use secureboot sign macros in apt post invoke hooks - ([2c5246f](https://git.0xmax42.io/SimDev/scboot/commit/2c5246fb5f8e542c2e2d7fff802073cad4ee89f2))
- *(scripts)* Extract shared logging and config loader lib - ([3130993](https://git.0xmax42.io/SimDev/scboot/commit/31309934d60e2b77143b58fea87087046300017c))
- *(build)* Remove git-cliff installation script - ([52e831d](https://git.0xmax42.io/SimDev/scboot/commit/52e831d93ca607eec3346a266df409627d8d3d8e))

### 🎨 Styling

- *(makefile)* Remove verbose output from clean target - ([1a55eda](https://git.0xmax42.io/SimDev/scboot/commit/1a55eda0c80f847157523ba02b92238918113a36))

### ⚙️ Miscellaneous Tasks

- *(debian)* Mark scboot package as architecture independent - ([5133e1f](https://git.0xmax42.io/SimDev/scboot/commit/5133e1f2e11be8124eac9ca904812792a25b44de))
- Add makefile for build and install workflow - ([a8d022e](https://git.0xmax42.io/SimDev/scboot/commit/a8d022e401ac7679bd065cf197c4a265689fce95))
- Add debcrafter manifest for debian stable image - ([f3e109f](https://git.0xmax42.io/SimDev/scboot/commit/f3e109fa73314a9dc3c89dcbe4b259c2c823dda3))
- Update gitignore for build artifacts - ([4ac19ac](https://git.0xmax42.io/SimDev/scboot/commit/4ac19acd975bef5170b5e30f0ef14b19f56b45e8))
- *(debian)* Update packaging metadata and add copyright info - ([8df5448](https://git.0xmax42.io/SimDev/scboot/commit/8df54480bd779a83ab6f7fc2bd1e073c6fb1fdfe))
- *(workflows)* Update release and deb upload pipelines - ([b2aa85a](https://git.0xmax42.io/SimDev/scboot/commit/b2aa85a1e5bc69c035e6dbba42296b9e35423b15))
- Remove deprecated packaging and release automation files - ([35829af](https://git.0xmax42.io/SimDev/scboot/commit/35829af89ff961e710d95a18cb768b13b82cef08))
- *(ci)* Restrict release workflow to main branch only - ([7c1b9ae](https://git.0xmax42.io/SimDev/scboot/commit/7c1b9aefe520dbbcb70f4cfb2b45e69b945201a6))

## [0.5.4](https://git.0xmax42.io/SimDev/scboot/compare/v0.5.3..v0.5.4) - 2025-06-27

### 🚜 Refactor

- *(build)* Replace manual git-cliff with external changelog script - ([95a8ba3](https://git.0xmax42.io/SimDev/scboot/commit/95a8ba32b87f7dfa71eebd92098ffc57f1f29f39))

## [0.5.3](https://git.0xmax42.io/SimDev/scboot/compare/v0.5.2..v0.5.3) - 2025-06-15

### 🐛 Bug Fixes

- *(hooks)* Correct escape character in find command - ([d30ae24](https://git.0xmax42.io/SimDev/scboot/commit/d30ae2446be4dd629cde051c00d7a2052a813540))

## [0.5.2](https://git.0xmax42.io/SimDev/scboot/compare/v0.5.1..v0.5.2) - 2025-06-15

### 🐛 Bug Fixes

- *(hooks)* Correct kernel resign command in post-invoke hook - ([93259c1](https://git.0xmax42.io/SimDev/scboot/commit/93259c1614ce9fcbd3eedf99265434be9b50ad29))

## [0.5.1](https://git.0xmax42.io/SimDev/scboot/compare/v0.5.0..v0.5.1) - 2025-06-15

### 🚜 Refactor

- *(scripts)* Improve kernel signing process robustness - ([7f81fd7](https://git.0xmax42.io/SimDev/scboot/commit/7f81fd7fb7dadfde9fe9122feaac513f594e4cc6))

## [0.5.0](https://git.0xmax42.io/SimDev/scboot/compare/v0.4.0..v0.5.0) - 2025-06-15

### 🐛 Bug Fixes

- *(scripts)* Improve kernel signing process and hash handling - ([09255d4](https://git.0xmax42.io/SimDev/scboot/commit/09255d418cd3306eb1f7728b05e89c1c1d104daf))
- *(build)* Remove empty line from changelog - ([67d9cbc](https://git.0xmax42.io/SimDev/scboot/commit/67d9cbc6ff7ad7de8dfd05f874af8a0e5c395293))

## [0.4.0](https://git.0xmax42.io/SimDev/scboot/compare/v0.3.2..v0.4.0) - 2025-06-14

### 🚀 Features

- *(postinst)* Enhance secure boot integration - ([3a84e0e](https://git.0xmax42.io/SimDev/scboot/commit/3a84e0e02d796d943e0a435312d8e4bd60bfc851))

### ⚙️ Miscellaneous Tasks

- *(postrm)* Clean up symlinks and configuration on removal - ([a4c99ab](https://git.0xmax42.io/SimDev/scboot/commit/a4c99abf38b51fccfb4d3a39a4c77f7ef0c9a6f8))
- *(workflows)* Update action to specific version - ([14757ca](https://git.0xmax42.io/SimDev/scboot/commit/14757ca66a167858c3eac50f32f732f228249a2d))

## [0.3.2](https://git.0xmax42.io/SimDev/scboot/compare/v0.3.1..v0.3.2) - 2025-06-14

### ⚙️ Miscellaneous Tasks

- *(workflows)* Simplify release workflow with auto-changelog - ([d5f9a5d](https://git.0xmax42.io/SimDev/scboot/commit/d5f9a5dd434068ea150c0a58b562a1b8e0389383))

## [0.3.1](https://git.0xmax42.io/SimDev/scboot/compare/v0.3.0..v0.3.1) - 2025-06-14

### 🚀 Features

- *(debian)* Add load_config script to scboot installation - ([937f5d1](https://git.0xmax42.io/SimDev/scboot/commit/937f5d1a9590d6e129b550ad3765866fbf5f129b))

## [0.3.0](https://git.0xmax42.io/SimDev/scboot/compare/v0.2.0..v0.3.0) - 2025-06-14

### 🚀 Features

- *(scripts)* Centralize configuration management for secure boot - ([8430ee8](https://git.0xmax42.io/SimDev/scboot/commit/8430ee876915ca6925f56ad133a229137b827be7))

### 🐛 Bug Fixes

- *(config)* Update secure boot paths for consistency - ([1a7537d](https://git.0xmax42.io/SimDev/scboot/commit/1a7537dac98b16db1918d594af082cbff4de6e33))

## [0.2.0](https://git.0xmax42.io/SimDev/scboot/compare/v0.1.3..v0.2.0) - 2025-06-14

### 🚀 Features

- *(package)* Add shim-scboot as a dependency - ([7018ac1](https://git.0xmax42.io/SimDev/scboot/commit/7018ac1f3cfe326e182a26a8ce60c37cbe0e56be))

## [0.1.3](https://git.0xmax42.io/SimDev/scboot/compare/v0.1.2..v0.1.3) - 2025-06-14

### ⚙️ Miscellaneous Tasks

- *(hooks)* Update secure boot hook and script permissions - ([fac9bce](https://git.0xmax42.io/SimDev/scboot/commit/fac9bcedfcaa06b29aee777ad41101b8a1be3b15))

## [0.1.2](https://git.0xmax42.io/SimDev/scboot/compare/v0.1.1..v0.1.2) - 2025-06-14

### 🚜 Refactor

- *(build)* Improve tag handling and changelog generation - ([4488006](https://git.0xmax42.io/SimDev/scboot/commit/44880060a4d05a240294cef6f2be42f6b7be9d86))

## [0.1.1](https://git.0xmax42.io/SimDev/scboot/compare/v0.1.0..v0.1.1) - 2025-06-14

### 🚀 Features

- *(workflows)* Trigger build on release publication - ([ac98b91](https://git.0xmax42.io/SimDev/scboot/commit/ac98b9196be87479b1e72fc22c2e26f82ad20b1a))

## [0.1.0] - 2025-06-14

### 🚀 Features

- *(ci)* Add workflow for building and publishing Debian packages - ([bf1489a](https://git.0xmax42.io/SimDev/scboot/commit/bf1489a40db4590ccd3f9941cdf0e6c3af079b67))
- *(build)* Add scripts for Debian package build and git-cliff install - ([36a5ac5](https://git.0xmax42.io/SimDev/scboot/commit/36a5ac55286754c8552ef3e3814c9e183f7a0cb7))
- *(debian)* Update maintainer, dependencies, and architecture - ([011ebf2](https://git.0xmax42.io/SimDev/scboot/commit/011ebf2dd00ffa84218d3694599178d9f37b916f))
- *(packaging)* Add Secure Boot tools for GRUB and kernel resigning - ([8fbf51b](https://git.0xmax42.io/SimDev/scboot/commit/8fbf51bce1d80f864532564d9f66601729983942))
- *(vscode)* Customize activity bar and Peacock theme - ([6bc5e47](https://git.0xmax42.io/SimDev/scboot/commit/6bc5e47bbc148a9beea8bd3abfccf9fe3308813f))

### ⚙️ Miscellaneous Tasks

- *(workflows)* Add --locked flag to git-cliff installation - ([276c0de](https://git.0xmax42.io/SimDev/scboot/commit/276c0de8f65ecdd20f0d43c8fb872ad4928cd8fc))
- *(config)* Add debian changelog generation configuration - ([9955d9d](https://git.0xmax42.io/SimDev/scboot/commit/9955d9d313168b578c4047044e6b802a0997deac))
- *(gitignore)* Add changelog file to ignored paths - ([1b67f0d](https://git.0xmax42.io/SimDev/scboot/commit/1b67f0d7c81300a60cda18e170c048aa34286aee))
- *(gitignore)* Update ignored files for Debian build artifacts - ([320637d](https://git.0xmax42.io/SimDev/scboot/commit/320637d299c458b0af2be73acc9d9a20121e1b9f))
- *(workflows)* Add automated release and changelog generation - ([061a670](https://git.0xmax42.io/SimDev/scboot/commit/061a67036ff0b10f7bee3962dd32aac8986606e9))
- *(gitignore)* Add entries to ignore build and environment files - ([a866364](https://git.0xmax42.io/SimDev/scboot/commit/a866364e5f5febe87ac1c966dac12a13646dabbc))


