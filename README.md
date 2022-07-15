# Helper_scripts_FBOT
## Onboarding_clusters.sh
  This is only required if you want HLO to be onboarded to new fkp clusters
  Contains jquery to find the FI/FD/cluster combinations which do not have HLO instance.

## helper.sh   
  **Diff function** : Contains Jquery to get the list of all FI/FD/cluster combinations with HLO instance from hydrated BOM files, in separate files.
  Iteration over the newly created files, to extract FI and its environment, accordingly save FI,FD in csv format for each environment, whose path is to be used as argument to Generator.sh
  ```
  ./helper.sh
  ```
  
## Generator.sh
  Invoke FBot generator to create vmf-in and vmf-out files for every FI/FD (provision and deploy yaml)
   ```
   ./Generator.sh <path to list of FI/FD created using helper.sh>
   ```
   local spinnaker repo path can be changed inside Generator.sh script, since the first invocation may take 15-20 mins, since it checks out sfcd/spinnaker repo and sometimes gets stuck.

  
