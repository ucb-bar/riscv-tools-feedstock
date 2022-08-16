About ucb-bar-riscv-tools
=========================

Home: https://github.com/abejgonzalez/ucb-bar-riscv-tools

Package license: 

Feedstock license: [BSD-3-Clause](https://github.com/conda-forge/new-2-feedstock/blob/master/LICENSE.txt)

Summary: 

Current build status
====================


<table>
</table>

Current release info
====================

| Name | Downloads | Version | Platforms |
| --- | --- | --- | --- |
| [![Conda Recipe](https://img.shields.io/badge/recipe-ucb--bar--riscv--tools-green.svg)](https://anaconda.org/ucb-bar/ucb-bar-riscv-tools) | [![Conda Downloads](https://img.shields.io/conda/dn/ucb-bar/ucb-bar-riscv-tools.svg)](https://anaconda.org/ucb-bar/ucb-bar-riscv-tools) | [![Conda Version](https://img.shields.io/conda/vn/ucb-bar/ucb-bar-riscv-tools.svg)](https://anaconda.org/ucb-bar/ucb-bar-riscv-tools) | [![Conda Platforms](https://img.shields.io/conda/pn/ucb-bar/ucb-bar-riscv-tools.svg)](https://anaconda.org/ucb-bar/ucb-bar-riscv-tools) |

Installing ucb-bar-riscv-tools
==============================

Installing `ucb-bar-riscv-tools` from the `ucb-bar` channel can be achieved by adding `ucb-bar` to your channels with:

```
conda config --add channels ucb-bar
conda config --set channel_priority strict
```

Once the `ucb-bar` channel has been enabled, `ucb-bar-riscv-tools` can be installed with `conda`:

```
conda install ucb-bar-riscv-tools
```

or with `mamba`:

```
mamba install ucb-bar-riscv-tools
```

It is possible to list all of the versions of `ucb-bar-riscv-tools` available on your platform with `conda`:

```
conda search ucb-bar-riscv-tools --channel ucb-bar
```

or with `mamba`:

```
mamba search ucb-bar-riscv-tools --channel ucb-bar
```

Alternatively, `mamba repoquery` may provide more information:

```
# Search all versions available on your platform:
mamba repoquery search ucb-bar-riscv-tools --channel ucb-bar

# List packages depending on `ucb-bar-riscv-tools`:
mamba repoquery whoneeds ucb-bar-riscv-tools --channel ucb-bar

# List dependencies of `ucb-bar-riscv-tools`:
mamba repoquery depends ucb-bar-riscv-tools --channel ucb-bar
```




Updating ucb-bar-riscv-tools-feedstock
======================================

If you would like to improve the ucb-bar-riscv-tools recipe or build a new
package version, please fork this repository and submit a PR. Upon submission,
your changes will be run on the appropriate platforms to give the reviewer an
opportunity to confirm that the changes result in a successful build. Once
merged, the recipe will be re-built and uploaded automatically to the
`ucb-bar` channel, whereupon the built conda packages will be available for
everybody to install and use from the `ucb-bar` channel.
Note that all branches in the conda-forge/ucb-bar-riscv-tools-feedstock are
immediately built and any created packages are uploaded, so PRs should be based
on branches in forks and branches in the main repository should only be used to
build distinct package versions.

In order to produce a uniquely identifiable distribution:
 * If the version of a package **is not** being increased, please add or increase
   the [``build/number``](https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html#build-number-and-string).
 * If the version of a package **is** being increased, please remember to return
   the [``build/number``](https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html#build-number-and-string)
   back to 0.

Feedstock Maintainers
=====================

* [@abejgonzalez](https://github.com/abejgonzalez/)

