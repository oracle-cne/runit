#!/usr/bin/bash -x
# -----------------------------------------------------------------------------------
#  docker-images.sh
# =================
# shell routine to trigger docker builds
#
# Performs the following:
# 	1)  triggers docker builds
#
# Parameters :
#
# durai.vattakalvalasu.govindas@oracle.com
#
# -----------------------------------------------------------------------------------
# Modification History
# ====================
#
# Date          Name       Version          Description
# ----          ----       --------         -----------
# 05/09/2018    Durai G     1.0
# ------------------------------------------------------------------------------------
# Global vars/inits
JOB_NAME="`basename $0`"

usage() {
           echo
           echo "Usage list for $JOB_NAME"
           echo
           echo "Options:"
           echo
           echo "    --help                                                 - <help>"
           echo "    --app-name                                             - application name"
           echo "    --app-version                                          - version of application"
           echo "    --oracle-release-version                               - olcne release version"
           echo "    --app-container-name                                   - name for the application container"
           echo "    --app-container-version                                - version for the application container. Defaults to --app-version"
           echo "    --yum-package-list                                     - comma separated values of RPM package names."
           echo
           echo
           echo
}

get_params() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help) usage; exit 1;;
            --app-name) iapp_name="$2"; shift 2;;
            --app-version) iapp_version="$2"; shift 2;;
            --oracle-release-version) ioracle_release_version="$2"; shift 2;;
            --app-container-name) iapp_container_name="$2"; shift 2;;
            --app-container-version) iapp_container_version="$2"; shift 2;;
            --yum-package-list) iyum_package_list="$2"; shift 2;;
            *) echo -e "\n msg: ERROR - get_params - Insufficient parameters passed. Please validate the usage list.\n script_arguments: ${l_script_caller}\n"; usage; exit 1;;
        esac
    done
}

init_vars()
{
    l_app_name=${iapp_name}
    l_app_version=${iapp_version}
    l_oracle_release_version=${ioracle_release_version}
    l_app_container_name=${iapp_container_name}
    l_app_container_version=${iapp_container_version:-${l_app_version}}
    l_yum_package_list=${iyum_package_list}
    l_docker_registry_name=container-registry.oracle.com
    l_docker_registry_group=olcne
    l_docker_registry="${l_docker_registry_name}/${l_docker_registry_group}"
    l_tag_name="${l_docker_registry}/${l_app_container_name}:${l_app_container_version}"
    l_app_docker_file="olm/builds/Dockerfile"
}

val_params()
{
    if [[  ! "${l_app_name}" || \
        ! "${l_app_version}" || \
        ! "${l_oracle_release_version}" || \
        ! "${l_app_container_name}"  || \
        ! "${l_app_container_version}" || \
        ! "${l_yum_package_list}" ]]; then

        print_vars "app-name" "${l_app_name}"
        print_vars "app-version" "${l_app_version}"
        print_vars "oracle-release-version" "${l_oracle_release_version}"
        print_vars "app-container-name" "${l_app_container_name}"
        print_vars "app-container-version" "${l_app_container_version}"
        print_vars "yum-package-list" "${l_yum_package_list}"

        write_log "0" "parameters passed are insufficient." "ERROR"
        write_log "0" "script_arguments: ${l_script_caller}"
        usage
        exit 1
    fi

    write_log "0" "script_arguments: ${l_script_caller}"
}

print_vars()
{
    write_log 0 "$1: $2" "DEBUG"
}

val_return_code()
{
    if [[ ${1} -ne 0 ]]; then
        write_log "1" "$2 failed with exit code $1" "ERROR"
        exit 1
    fi
}

write_log()
{
    exit_code="${1}"
    message="${2}"
    context="${3}"
    l_exit_code=${exit_code:-"0"}
    l_context=${context:-"INFO"}
    l_caller=${FUNCNAME[1]}

   printf "%-5s %-5s %s %-5s %-20s %s\n" `date "+%D %T"`  "${l_exit_code}" "${l_context}" "${l_caller}" "${message}"
}

yum_download_package() {
  l_download_rpm_name="${1}"
  yum install --downloadonly --downloaddir=$(pwd) ${l_download_rpm_name}
  l_rc="$?"
  val_return_code "${l_rc}" "yum install --downloadonly --downloaddir=$(pwd) ${l_download_rpm_name}"
}

docker_build() {
  if [[ ! -f ${l_app_docker_file} ]]; then
    write_log "1" "FATAL: docker file ${l_app_docker_file} not found" "ERROR"
    exit 1
  fi

  if [[ -f .dockerignore ]]; then
    write_log "0" "found dockerignore file, about to execute echo \"!*.repo\" >> .dockerignore" "INFO"
    echo "!*.rpm" >> .dockerignore
    echo "!olcne_rpm_list.md" >> .dockerignore
  fi

  yum clean all
  rm -f *.rpm
  rm -f olcne_rpm_list.md

  IFS=',' read -a yum_olcne_packages <<< "${l_yum_package_list}"
  for package_name in "${yum_olcne_packages[@]}"; do
    yum_download_package ${package_name}

    if [[ ! -f `ls ${package_name}*.rpm` ]]; then
        val_return_code "1" "file ${package_name}*.rpm not found"
    else
        echo `ls ${package_name}*.rpm` >> olcne_rpm_list.md
    fi
  done

  docker build \
     --no-cache --pull \
     --build-arg https_proxy=${https_proxy} \
     -t ${l_tag_name} -f ${l_app_docker_file} .
}

docker_save_image(){
  mkdir -p ./oracle_docker
  docker save -o ./oracle_docker/${l_app_name}.tar ${l_tag_name}
}

sub_process() {
    docker_build
    l_rc="$?"
    val_return_code "${l_rc}" "docker_build"

    docker_save_image
    l_rc="$?"
    val_return_code "${l_rc}" "docker_save_image"
}

main()
{
    l_script_caller="\"$@\""
    get_params "$@"
    init_vars

    write_log "0" "BEGIN - execution of ${JOB_NAME}"
    val_params

    sub_process
    l_rc="$?"
    val_return_code "${l_rc}" "sub_process"

    write_log "0" "END - execution of ${JOB_NAME}"
}

# execution starts here
main "$@"
