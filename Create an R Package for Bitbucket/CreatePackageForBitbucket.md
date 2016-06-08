# Create a Simple R Package using RcppArmadillo with Header File
Wayne Taylor  
October 29, 2014  

### Step 0: Install Git
Install Git, which can be downloaded from http://git-scm.com/download

IMPORTANT: For the Windows download during the installation you will be given the option to "Use Git from the Windows Command Prompt". Select this option.

In R Studio, under Tools > Global Options > Git/SVN enable version control and point to the Git .exe file: "~Git/bin/git.exe"

### Step 1: Create the Respository on Bitbucket
Login to Bitbucket and create a repository. I named the repository the same as the package and changed the access level to public.

The URL will be used when adding version control. In my example it is: https://wjtaylor@bitbucket.org/wjtaylor/testpackage.git

### Step 2: Clone the Project from the Git Repository

We need to set up the directory that will communicate with Bitbucket.

In R Studio, go to File > New Project > Version Control. Select "Git" and enter the URL of the Bitbucket repository.

For the "Project Directory Name", I use the name of the package.

In "Create project as subdirectory of:" I point to a new empty folder named the same as the package. "~/testPackage". Note this folder must be empty.

R Studio will create another subfolder of the same name as the package (as requested).

### Step 3: Create the Required R Files and Place into Project Directory
You need to create the usual R files required for any package. Here is an excellent reference that decribes package development: http://r-pkgs.had.co.nz/intro.html

For this example, I created the following folders/files

- `data` for the .rda data files
- `man` for the .rd documentation files
- `R` for the .r files
- `DESCRIPTION` file
- `NAMESPACE` file

Place the files in the same folder as the R Project file (here it is in ~/testPackage/testPackage). When you repoen the R Project file, you will be able to check and build the package under the "Build" tab.

Once satisfied with the package files, using the "Git" worktab you can now push and pull the files from the online repository.

### Step 4: Manage the Files for Version Control

Now that the files have been uploaded, make sure to make a copy of the current version of the project files.

Recall that there is there are two folders named "testPackage", one is a subfolder of the other.

Folders can be created above this subfolder to save copies of current versions of the package. For example, after the initial upload I copy them into a "testPackage/1.0-0" directory (or whatever the version number is in the "DESCRIPTION" file).

### Step 6: Pull the Files from Bitbucket

The files residing on Bitbucket can now be pulled into R Studio for use.

Make sure the `devtools` package is installed and loaded, and then execute the following:

```
install_bitbucket("wjtaylor/testpackage")
library(testPackage)
```

Since the repository is public, we do not need to use the `password` parameter.

The package should now work as expected.
