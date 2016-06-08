# Create a Simple R Package using RcppArmadillo with Header File
Wayne Taylor  
March 5, 2015  

### Step 1: Create the Package Skeleton
  - Make sure the following packages are loaded: tools, devtools, Rcpp, RcppArmadillo
  - Run `RcppArmadillo.package.skeleton("testPackageRcpp",example_code = FALSE)` to create the skeleton files
  - Note that this is analagous to the process described in the "Writing a package that uses Rcpp" vignette
  
### Step 2: Add a .cpp Function
  - Add your first `.cpp` function to the "src" folder.
  - If you do not plan to use a custom header file, make sure that you are not `using namespace` for anything other than `Rcpp`. The reason being that the "RcppExports.cpp" file is overwritten each time a check is done on the package. See http://stackoverflow.com/questions/21944695/rcpparmadillo-and-arma-namespace for more details
  - Add the complementary "Rd" help file

### Step 3: Read the "Rcpp Attributes" vignette for complete details
 - See section 3.5. There are ways to customize this a bit more, but for our purposes we need a simple header file in order to call `.cpp` files from within other `.cpp` files
 - In additon, the header file allows us to use `using namespace arma;` since the RcppExports file is rewritten each time the package is checked

### Step 4: Create the Header File
 - In the main directory, create the folder `inst` and within this folder create another folder `include`. Within the `include` folder place the `.H` header file.
 - Add `PKG_CPPFLAGS += -I../inst/include/` to both of the two `Makevars` files to include the customized headers.
 - I follow a similar header file format to that of what would be automatically created from Rcpp attributes (again, see section 3.5 of the Rcpp Attributes pdf)

```
#ifndef __testPackageRcpp_h__
#define __testPackageRcpp_h__

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace arma;
using namespace Rcpp;

List rwishart_rcpp(int const& nu, mat const& V);

#endif
```

- Now, the `rwishart_rcpp.cpp` file only needs the following at the top: `#include "testPackageRcpp.h"`.
- It will include everything in the header file, INCLUDING the `using namespace` arguments, this means that the `using namespace` arguments will not have to be redclared within each `.cpp` file.

### Step 5: Check the Package
  - Delete the `testPackageRcpp-package.Rd` file in the `man` folder
  - Delete the `Read-and-delete-me` file in the main folder
  - At this point, the package should pass the check

Below are additional references for header files:

  - http://stackoverflow.com/questions/1653958/why-are-ifndef-and-define-used-in-c-header-files
  - http://stackoverflow.com/questions/21593/what-is-the-difference-between-include-filename-and-include-filename
  - http://stackoverflow.com/questions/13995266/using-3rd-party-header-files-with-rcpp
