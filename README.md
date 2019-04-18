# A VLE toolchain without a clunky IDE

Build a baremetal VLE toolchain from NXP's S32 Design Studio source code release.

- builds both a working compiler as well as a Python-enabled gdb.
- uses multi-stage builds to ensure the docker container doesn't communicate with
  external hosts after initial installation (Hence Docker >= 17.05 required)

Use ``build.sh`` to build the toolchain in the Docker container and ``get_toolchain.sh``
to copy the tarball out of the container after the build.
