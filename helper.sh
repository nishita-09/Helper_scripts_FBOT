# helper func to get FI/FD/Clusters which do not have HLO
# argument 1: BOMS folder path (within spinnaker) Eg: Users/npattanayak/tutorial-environment/spinnaker/lib/fire/1.0.0/boms/
cd $1 
rm dev.csv stage.csv perf.csv test.csv prod.csv esvc.csv
get_diff() {
    jq '.falcon_instance.functional_domains[].service_instances[] | select(.k8s_cluster_instance_name | index("sam-")) | select(.service_instance_id | index("hlo")) | select(.service_team == "argus") | {fi : .service_metadata.tfvars.environment, fd: .service_metadata.tfvars.functionaldomain, cluster : .k8s_cluster_instance_name}' $1 | jq -s > file1.json    
    jq -n --slurpfile file1 file1.json '$file1[0]' > "${filename}1"
}

# create the json files to store these differences
for filename in hydrated_*.json; do
    get_diff "$filename"
done

# iterate over the hydrated FI instance json files to find clusters not having HLO and adding them to Falcon_instance/FD_domain_instance.json
for filename in hydrated_*1; do
    pre="${filename%%.*}"     # extracts filename without extension
    fi1="${pre#*_}"           # extracts FI
    echo $fi1
    diff_file="${filename}"   
    jq -r '.[] | .fi + " " + .fd + " " + .cluster' "$diff_file" \
    |    while IFS= read -r line; do
            linearray=($line)
            env=${linearray[0]}
            fd=${linearray[1]}
            cluster=${linearray[2]}
            if echo $env | grep -q "stage"; then
                echo $fi1,$fd >> stage.csv
            fi
            if echo $env | grep -q "prod"; then
                echo $fi1,$fd >> prod.csv
            fi
            if echo $env | grep -q "esvc"; then
                echo $fi1,$fd >> esvc.csv
            fi
            if echo $env | grep -q "dev"; then
                echo $fi1,$fd >> dev.csv
            fi
            if echo $env | grep -q "test"; then
                echo $fi1,$fd >> test.csv
            fi
            if echo $env | grep -q "perf"; then
                echo $fi1,$fd >> perf.csv
            fi
        done
    
done

