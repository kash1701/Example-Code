# Create a Simple R Package using RcppArmadillo with Header File
Wayne Taylor  
October 23, 2014  

### Step 1: Create the Required R Files
First, you need to create the usual R files required for any package.  Here is an excellent reference that decribes package development: http://r-pkgs.had.co.nz/intro.html

For this example, I created the following folders/files

- `data` for the .rda data files
- `man` for the .rd documentation files
- `R` for the .r files
- `DESCRIPTION` file
- `NAMESPACE` file

### Step 2: Create the Project File
In R Studio, go to File > New Project > Existing Directory and select the folder that contains the project files.
In my example, I used the folder name `testPackage`. It will create the R Project file using the folder name.

Note that my folder `testPackage` is placed within another folder of the same name.  This will be important later on for version updating.

Next to the usual "Environment" and "History" tabs, there is now a "Build" tab. In this tab, run the "Check" function to verify that the project has all of the correct components.

### Step 3: Create the Respository on Bitbucket
Once the package has been built and tested, it is ready to be pushed to Bitbucket. At this point, you can delete the R Project file since its only purpose was to check the package.

Login to Bitbucket and create a repository.  I named the repository the same as the package (`testPackage`) and changed the access level to public.

Once created, you will see under "Command Line" the "I have an existing project" item. This will show the path for where the files will be pushed to.
In this example, it is https://wjtaylor@bitbucket.org/wjtaylor/testpackage.git

### Step 4: Add Version Control and Push to Bitbucket
Download the git GUI. More information can be found here: http://git-scm.com/

Once downloaded, you will need to add a respository, this will be the directory containing all of the project files/folders.

When that repository is opened in the git GUI, you should see all the files in the project (including those in the project subdirectories). They will be listed in the "Unstaged Changes" section.

There are five action buttons available. The help documentation is not very helpful at explaining exactly what they do but here are my best guesses:

- Rescan: Updates the "Unstaged Changes" section with any changes that have been made in the local repository
- Stage Changes: Moves the files from the "Unstaged Changes" to the "Staged Changes"
- Sign Off: Adds a message to show who signed off on the changes.
- Commit: Commits to the changes. Once committed, only changes to the directory will appear during a "Rescan"
- Push: Push the files to Bitbucket (or another repository site)

To use the GUI, work down the buttons from top to bottom: after rescanning, staging changes, signing off, and committ the changes, select the "Push" button.

In the "Destination Repositoty" box, enter the Bitbucket path.  In my example it is https://wjtaylor@bitbucket.org/wjtaylor/testpackage.git

It will ask for the login password to Bitbucket, and then after a second it should show that it was a success.

Back in Bitbucket, you should see the files have been uploaded. Also notice that in the "Overview" pane the destination path is readily available.

### Step 5: Manage the Files for Version Control

Now that the files have been uploaded, make sure to make a copy of the current version of the project files.

Recall I used a directory structure of "testPackage/testPackage/[project files]". In the first directory, I create a folder named the same version as in the DESCRIPTION file (here 1.0-0) and copy the files into this folder.
Thus the upper folder "testPackage" now has two subfolders: "1.0-0" containing a copy of the current version of the program, and "testPackage", which is the subdirectory linked to version control. This way the changes are always made in the same spot, and you will not need to create a new repository link for the git GUI.

### Step 6: Pull the Files from Bitbucket

The files residing on Bitbucket can now be pulled into R Studio for use.

Make sure the `devtools` package is installed and loaded, and then execute the following:

```
install_bitbucket("wjtaylor/testpackage")
library(testPackage)
```

Since the repository is public, we do not need to use the `password` parameter.

The package should now work as expected.
