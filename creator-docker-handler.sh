#!/usr/bin/env bash

declare -A REPOS
function create_repos_map {
    regex_local="(REPO_[A-Z]+)=(.*)"
    for i in $(< .env)
    do
        if [[ ${i} =~ $regex_local ]]
        then
            name="${BASH_REMATCH[1]}"
            path="${BASH_REMATCH[2]}"
            regex_docker=".*\\$\{${name}\}\:(.*)"
            for i in $(< docker-compose.yml)
            do
                if [[ ${i} =~ $regex_docker ]]
                then
                    docker_host="${BASH_REMATCH[1]}"
                    REPOS[${docker_host}]=${path}
                fi
            done
        fi
    done
}

function create_handler_file {
    file="phpstorm-url-handler"
    script_text=$(cat <<'EOF'
#!/usr/bin/env bash

declare -A REPOS
arg=${1}
pattern=".*file(:\/\/|\=)(.*)&line=(.*)"

EOF
    )
    echo "${script_text}" > ${file}

    for docker_host in "${!REPOS[@]}"
    do
        echo "REPOS["${docker_host}"]="${REPOS[$docker_host]} >> ${file}
    done

script_text=$(cat <<'EOF'
for docker_host in "${!REPOS[@]}"
do
    local_path=${REPOS[$docker_host]}
    arg="${arg/$docker_host/$local_path}"
done
EOF
    )
    echo "${script_text}" >> ${file}
    script_text=$(cat <<'EOF'
# Get the file path.
file=$(echo "${arg}" | sed -r "s/${pattern}/\2/")

# Get the line number.
line=$(echo "${arg}" | sed -r "s/${pattern}/\3/")

# Check if phpstorm|pstorm command exist.
if type phpstorm > /dev/null; then
    /usr/bin/env phpstorm --line "${line}" "${file}"
elif type pstorm > /dev/null; then
    /usr/bin/env pstorm --line "${line}" "${file}"
fi
EOF
    )
    echo "${script_text}" >> ${file}
}

create_repos_map
create_handler_file

sudo cp phpstorm-url-handler /usr/bin/phpstorm-url-handler
sudo desktop-file-install phpstorm-url-handler.desktop
sudo update-desktop-database
