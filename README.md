# KallistiOS Rust Container

This project aims to containerize the Rust toolchain used for KallistiOS. For more information on this project, please check out [dreamcast.rs](https://dreamcast.rs).

## Prerequisites

This tool assumes that your have either [podman](https://podman.io) or [Docker](https://www.docker.com) installed on your system. This project defaults to using `podman` for the container engine but the script can be updated to use Docker by changing the `CONTAINER_ENGINE` variable to `docker` in the `dc-rust` script.

## Setup

After downloading or cloning this repository, add the following line to your `.bashrc` file:

```bash
source /path/to/this/project/environ.sh
```

Restart your terminal or run `source ~/.bashrc` to pick up the new changes. This will add the `dc-rust` binary to your executable path and allow you to use the tool from anywhere.

## Building the image

Run `dc-rust build-image`. This will use the available `Dockerfile` within this repository to compile the GCC toolchain and build the required Rust libraries needed for developing with Rust. This process may take a while to complete, so please be patient. Once this completes, there should be a `dreamcast-rs/dreamcast-rs` image available in your container engine of choice.

## Compiling `kos-ports`

Developers will most likely want to take advantage of the many software libraries available for KallistiOS. These ports are easily accessible in the `kos-ports` repository. This tool expects that `kos-ports` is available on the host machine. This will allow easy portability between different containers.

### Check out the repository

Choose a folder on your machine, preferably in your `$HOME` directory. Check out `kos-ports` with the following command:

```bash
git clone https://github.com/KallistiOS/kos-ports /path/to/your/directory/kos-ports
```

Once the check out is complete, add the following line to your `.bashrc`:

```bash
export KOS_RUST_PORTS_DIR=/path/to/your/directory/kos-ports
```

Either restart your terminal or run `source ~/.bashrc` to pick up the changes. This variable will provide the path to `kos-ports` within the `dc-rust` tool.

### Compile

Run `dc-rust compile-ports`. This will start up the image and compile all of the available `kos-ports` libraries and save the results on your host machine.

## Running the development environment

Since our toolchain is contained within the `dreamcast-rs` image, we need some way to interact with it. The `devenv` command handles creating a new container with a persistent filesystem that can be used for development purposes. To enter the development environment, just run `dc-rust devenv` once the image and `kos-ports` have been compiled and the script will handle setting up the container and attaching the terminal to the running system. Once inside of the development environment, standard wrappers like `kos-cargo` and `kos-rustc` will be available.

**NOTE:** When using `dc-rust devenv`, your `$HOME` directory will be mounted to the container by default. If you would like to change this behaviour, please update the `dc-rust` script _before_ running `devenv` for the first time. Also, make sure the `KOS_RUST_PORTS_DIR` environment variable is available before running `devenv` for the first time as the container must have the directories mounted upon creation of the container.

If for any reason, you need to rebuild the container, you must delete the existing one first:

```bash
podman|docker container rm dreamcast-rs-container
```

