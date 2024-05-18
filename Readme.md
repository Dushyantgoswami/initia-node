# Initia Node Installation Guide

This README provides instructions for cloning the Initia Node repository, setting up the environment, and verifying the installation. Follow these steps to ensure a successful setup.

## Prerequisites

Before running the script, ensure you have the following:

- Git installed on your system.
- Necessary permissions to execute scripts.

## Installation Steps

### 1. Clone the Repository

First, clone the Initia Node repository from GitHub:

```sh
git clone https://github.com/Dushyantgoswami/initia-node.git
```

### 2. Change to the Repository Directory

Navigate into the cloned repository:

```sh
cd initia-node

### 3. Set Script Permissions

Ensure the install_initia.sh script has execute permissions:

```sh
chmod +x install_initia.sh


### 4. Run the Installation Script

Execute the script to install and set up Initia Node. Replace node_name with your desired node name:

```sh
./install_initia.sh node_name


## Script Functionality

The `install_initia.sh` script will:

- Handle all necessary installations and setup procedures.
- Verify the versions of Go and Make as specified in the script.

## Verifying Installation

After the script completes, verify that Go and Make are correctly installed and set to the specified versions by running:

```sh
go version
make --version

## Troubleshooting

If you encounter any issues during the installation, check the following:

- Verify that you have internet connectivity.
- Ensure that you have the necessary permissions to execute scripts.
- Review any error messages output by the script for additional troubleshooting steps.

For further assistance, please refer to the [Initia Node repository](https://github.com/Dushyantgoswami/initia-node) or contact the repository maintainers.

## Conclusion

By following the steps outlined in this README, you should have a fully functional Initia Node installation. For any additional information or updates, visit the official repository.

