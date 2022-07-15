# helper func to get FI/FD/Clusters which do not have HLO
get_diff() {
    jq '.falcon_instance.functional_domains[].service_instances[] | select(.k8s_cluster_instance_name | index("sam-")) | select(.service_instance_id | index("hlo")) | select(.service_team == "argus") | {fi : .service_metadata.tfvars.environment, fd: .service_metadata.tfvars.functionaldomain, cluster : .k8s_cluster_instance_name}' $1 | jq -s > file1.json    
    jq '.falcon_instance.functional_domains[].service_instances[] | select(.k8s_cluster_instance_name | index("sam-")) | select(.service_instance_id | index("sam")) | select(.service_team == "sam") | {fi : .service_metadata.tfvars.environment, fd: .service_metadata.tfvars.functionaldomain, cluster : .k8s_cluster_instance_name}' $1 | jq -s > file2.json
    jq -n --slurpfile file1 file1.json --slurpfile file2 file2.json '$file2[0] - $file1[0]' > "${filename}1"
}

# create the json files to store these differences
for filename in hydrated_*.json; do
    get_diff "$filename"
    cat "${filename}1"
done

# iterate over the hydrated FI instance json files to find clusters not having HLO and adding them to Falcon_instance/FD_domain_instance.json
for filename in hydrated_*1; do
    pre="${filename%%.*}"
    pre1="${pre#*_}"
    fd_par_path="/Users/vkumar3/Documents/falcon-instance-definition/1.0/falcon-instances/${pre1}/functional-domain-instances"
    diff_file="${filename}"
    jq -r '.[] | .fi + " " + .fd + " " + .cluster' "$diff_file" \
    |    while IFS= read -r line; do
              linearray=($line)
          fi=${linearray[0]}
          fd=${linearray[1]}
          cluster=${linearray[2]}
          # echo $fi, $fd, $cluster
          fd_path="${fd_par_path}/${fd}_domain_instance.json"
          
          # service instance: "hlo+{suffix(cluster)}"
          num=$(echo $cluster | grep -Eo '[0-9]\-[0-9]+$')
          if [ -e ${num} ]
          then
              num=$(echo $cluster | grep -Eo '[0-9]+$')
          else
              echo $num
          fi
          # num=${cluster: -1}
          k8s_cluster_instance_name="$cluster"
          service_instance_name="hlo${num}"    
          service_type="hlo"
        
        # check if file to FD instance exists
        if [ -e ${fd_path} ]
        then
            tmp=$(mktemp)
            cat ${fd_path} | jq --arg k8s_cluster_instance_name $k8s_cluster_instance_name --arg service_instance_name $service_instance_name '.functional_domain[0].service_instances += [{"k8s_cluster_instance_name": $k8s_cluster_instance_name,"service_instance_name": $service_instance_name,"service_type": "hlo"}]'\
            > "$tmp" && mv "$tmp" ${fd_path}
            # sleep 1
        else
            echo ${fd_path}
        fi
    done
    
done
