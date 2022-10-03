# GCP Landing Zone - Terraform project creation module
This module creates the following:
* a project under the specified environment folder (`devqa`, `noncde`, `cde`, or `ops`)
* a dedicated service account for subsequent applicaiton deployment (in the LZ's automation project)
* a dedicated GCS bucket for storing project Terraform state (in the LZ's automation project)
* workload identity bindings for pipeline executions as the dedicated service account
* Google Cloud APIs enabled per the `project_services` variable
* project-level IAM and organization policies as defined in Terraform variables
To-Do:
* configure default network using the gcp-vpc shared module
* configure IAM access (compute image user) to gold image project
* configure IAM access to GCR

## Examples
Example parameters are in the examples/ folder.

## Project Naming
Once project names are set, THEY CANNOT BE CHANGED.  Thus it is important to understand the nuances to naming a project properly before creating one.

There are 2 ways to specify a project name.  Either through an explicit parameter, project_name, or having the module generate a standard project name for you via some parameters (geo_location, region, business_region, project_descriptor).  

Both example below result in the same project_name, pid-gcp-exbu-res01.

### Explicit Naming
```hcl
unit_name            = "exbu"
environment          = "dev"
project_name         = "pid-gcp-exbu-res01"
randomize_project_id = false
```

### Programatically Generated Naming
```hcl
unit_name = "exbu"
environment = "dev"
geo_location = "us"
region = "e"
business_region = "na"
project_descriptor = "res01"    # "res01" is the default for this parameter
randomize_project_id = false
```
NOTE: The unit_code and environment parameters are used in the programatic name generation, but are also required parameters for additional reasons other than naming.  See below for randomize_project_id.

### Randomized Project Name
By default, project names (generated or specified) have a random 4 digit hexadecimal identifier (ie, "-4e9f") appended to them resulting in something like "pid-gcp-exbu-res01-4e9f".  The original intent was to enable quick spin-up of many projects of the same base name.  If you do not want this (which is common), specify `ramdomize_project_id=false` in your project manifests.  This option works with both explicit and programatic project name generation.

### Project Descriptor
By default, GCP projects historically used a descriptor of "res01" which allowed for simple incrementing as new projects of similar base name were created (ie, pid-gcp-exbu-res01, pid-gcp-exbu-res02, and so on).  GCP LZ is enabling the customization of that suffix to be more functionally descriptive.  ie, setting project_descriptor to "poc-myapp" above would generate "pid-gcp-exbu-poc-myapp" then another manifest with project_descriptor of "dev-myapp" would generate "pid-gcp-exbu-dev-myapp" which would help quickly identify which project was the PoC vs Dev project. 

### Project Name Length
It is also important to note that GCP project names must be 30 characters or less, and the your organisations standard pid-goXXXXXX-UNIT- prefix uses 18 characters of that.  That leaves 12 characters for a combination of project_descriptor and randomization suffixes (and their seperating hyphen).  If using the randomization feature above, only 7 characters are left.