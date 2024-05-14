# Simple Arch Installer

Welcome to the Simple Arch Installer repository.

This is a super-simple script that automates manual steps for an Arch Linux install.

It's best used as reference architecture for your own script or if you want to see what a barebones automated Arch install looks like.

## Getting Started

**Caution:** This script should only be executed on a live iso or virtual environment as it automatically deletes and recreates all partitions on the target drive, thus wiping any data that may be stored.

Run the install script from an Arch iso environment simply by cloning this repository and running `bash src/installer.sh`.
