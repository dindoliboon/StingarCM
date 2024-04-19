#### :warning: This repository has been archived.

---

# StingarCM

## Description

Controller module to interface with [Community Honey Network server](https://communityhoneynetwork.readthedocs.io).

## Installing

The easiest way to get StingarCM is using the [PowerShell Gallery](https://powershellgallery.com/packages/StingarCM/)!

### Inspecting the module

Best practice is that you inspect modules prior to installing them. You can do this by saving the module to a local path:

``` PowerShell
Save-Module -Name StingarCM -Path .
```

### Installing the module

Once you trust a module, you can install it using:

``` PowerShell
Install-Module -Name StingarCM -Scope CurrentUser
```

### Updating StingarCM

Once installed from the PowerShell Gallery, you can update it using:

``` PowerShell
Update-Module -Name StingarCM -Scope CurrentUser
```

### Uninstalling StingarCM

To uninstall StingarCM:

``` PowerShell
Uninstall-Module -Name StingarCM
```

## Building from source

This module can be loaded as-is by importing `StingarCM.psd1`. This is mainly intended for development purposes.

To speed up module load time and minimize the amount of files that need to be signed, distributed and installed, this module contains a build script that will package up the module into three files:

- StingarCM.psd1
- StingarCM.psm1
- LICENSE.md

To build the module, make sure you have the following pre-req modules:

- [Pester 4.1.1](https://www.powershellgallery.com/packages/Pester/4.1.1)
- [InvokeBuild 3.2.1](https://www.powershellgallery.com/packages/InvokeBuild/3.2.1)
- [PowerShellGet 1.6.0](https://www.powershellgallery.com/packages/PowerShellGet/1.6.0)
- [ModuleBuilder 1.0.0](https://www.powershellgallery.com/packages/ModuleBuilder/1.0.0)

Clone the module and start the build using:

```PowerShell
git clone https://github.com/dindoliboon/StingarCM.git
cd ./StingarCM
Invoke-Build
```

This will package all code into files located in `./bin`. That folder is now ready to be installed, copy to any path listed in your `$env:PSModulePath` environment variable and you are good to go!

## Usage

Step 1: Load the module into your current environment.

``` PowerShell
Import-Module -Name StingarCM
```

Step 2: Connect to the CIF server and export the attack data to multiple CSV files. If this is your first time running the command, you will be prompted several questions on how to connect to your CIF server.

``` PowerShell
Invoke-ExportAttackData -ConfigurationName 'aFriendlyName' -Path '/Users/myuser/stingar_data' -Verbose
```

Step 3: Read the generated CSV files and create a block list file containing attack IPs:

``` PowerShell
Invoke-NewBlockList -ConfigurationName 'aFriendlyName' -Path '/Users/myuser/stingar_data' -Verbose
```

Step 4: Expose the block list files cif-attack-ip-blocklist-##.txt to your firewall. The easiest way is to use a web server such as IIS and point it to the block list folder.

Step 5: On your firewall, create entries to use the block list URLs.

## Release History

A detailed release history is contained in the [changelog](CHANGELOG.md).
