Travis CI integration for FPC / Lazarus
=======================================

[![Build Status](https://travis-ci.org/nielsAD/travis-lazarus.svg?branch=master)](https://travis-ci.org/nielsAD/travis-lazarus)

[Travis CI](https://travis-ci.org/) currently has no official support for [FreePascal](http://freepascal.org/). This repository demonstrates how FPC and [Lazarus](http://www.lazarus-ide.org/) projects can be used in combination with Travis. There is support for building with multiple Lazarus releases on both Travis' `Linux` and `Mac OSX` platforms. Support for Windows (both `win32` and `win64`) is done using [Wine](https://www.winehq.org/).

Files
-----
`./.travis.install.py` Sets up the environment by downloading and installing the proper FreePascal and Lazarus versions. Run this script in Travis' `install` phase.

`./.travis.yml` Custom Travis setup. Refer to their [documentation](http://docs.travis-ci.com/user/customizing-the-build/) for more information.

`./my_lazarus_test*` Toy project demonstrating a possible test setup.

How to use
----------
- [Set up Travis CI for your repository](http://docs.travis-ci.com/user/for-beginners/)
- Add `.travis.install.py` to your repository and run it in the `install` phase.
  - Execute the following command inside your repository:

    ```shell
    git submodule add https://github.com/nielsAD/travis-lazarus.git travis-lazarus
    ```
  - Add the following lines to your `.travis.yml` file:

    ```yaml
    sudo: true
    install: ./travis-lazarus/.travis.install.py
    ```
- **[OPTIONAL]** Modify settings to customize build versions.
  - Add (multiple) `LAZ_VER` entries to the `env` table, for example:

    ```yaml
    env:
      - LAZ_VER=1.2.6
      - LAZ_VER=1.4.4
    ```
  - Set the `os` field to specify the target operating system(s):

    ```yaml
    os:
      - linux
      - osx
    ```
  - Add Windows builds using Wine (_although a good indicator, success with Wine does not guarantee success with Windows, and vice versa!!_):

    ```yaml
    matrix:
      include:
        - os: linux
          env: LAZ_VER=1.4.4 LAZ_ENV=wine WINEARCH=win32 LAZ_OPT="--os=win32 --cpu=i386"
        - os: linux
          env: LAZ_VER=1.4.4 LAZ_ENV=wine WINEARCH=win64 LAZ_OPT="--os=win64 --cpu=x86_64"
    ```
    Note that your run script should take into account that it should run with Wine, for example using `$LAZ_ENV lazbuild $LAZ_OPT`. This also requires a virtual display server, as explained in the next step.
  - Add a virtual display server if you cannot run headless (_required for Wine_):

    ```yaml
    env:
      global:
        - DISPLAY=:99.0
    before_install: - sh -e /etc/init.d/xvfb start || true
    ```
  - Other optional environment variables:
    - `LAZ_REL` release platform (use with `LAZ_VER`):
      - Linux: `i386` or `amd64`
      - Mac OSX: `i386` or `powerpc`
      - Wine: `32` or `64`
    - `LAZ_TMP_DIR` temporary directory.
