#!/bin/bash
# @brief:    Quick lab setup - Fetch shared notebook resources from a git project 
#            and create a conda computing environment (conda) for running them.";
#
#    setup-gitenv.sh [-h] [-v] [-t] [-p <prj>] [-r <rep>] [-d <dir>] 
#                   [-e <env>] [-y <yaml>] [-u] [-c] [-a]
#
# @description:
# 1. Fetch a project from a Git repository.
# 2. Assuming YAML configuration files are shared with the project, create the
#    conda environment necessary to run the resources in the project.
#
# @notes:
# 1. This script is intended to run in a (Linux based) "datalab environment". 
# It can actually be run in any other environment. It only requests that:
#    - git (https://git-scm.com/) is installed,
#    - conda (https://docs.conda.io/en/latest/), or miniconda (https://docs.conda.io/en/latest/miniconda.html) 
#      is installed 
# 2. This script shall be launched inline from a shell terminal running bash (commonly installed
# on all Unix/Linux servers/machines). 
# 3. On Windows, consider using shells provided by Cygwin (https://www.cygwin.com/) or Putty 
# (http://www.putty.org/).
# 4. To launch the command, run on the shell command line:
#            bash setup-datalab-start.sh <arguments>
# with your own arguments/instructions.
# @date:     20/10/2020
# @credit:   ESTAT B1 <mailto:ESTAT-Methodology@ec.europa.eu>
# @author:   grazzja, 

## Change the default parameters if needed...

DEFREP="https://github.com/eurostat"
DEFPRJ="statistics-coded"
DEFYML="environment.yml"
# DEFPRJ=("statistics-coded" "PRost")

DEFDIR=$HOME/Examples/projects
DEFENV=ex
DEFBRC=master

## Here we start...

# checking the environment

PROGRAM=`basename $0`
TODAY=`date +'%y%m%d'` # `date +%Y-%m-%d`
BASHVERS=${BASH_VERSION%.*} # 4.4 in the datalab at the time of development

case "$(uname -s)" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MSYS*)      MACHINE=Msys;;
    MINGW*)     MACHINE=MinGw;;
    Windows*)   MACHINE=Windows;;
    SunOS*)     MACHINE=SunOS;;
    *)          MACHINE="UNKNOWN:${OSTYPE}"
esac
# checking the requirements

hash cat 2>/dev/null ||  { echo >&2 " !!! Command CAT required but not installed - Aborting !!! "; exit 1; }
hash awk 2>/dev/null || { echo >&2 " !!! Command AWK required but not installed - Aborting !!! "; exit 1; }
hash find 2>/dev/null || { echo >&2 " !!! Command FIND required but not installed - Aborting !!! "; exit 1; }
hash read 2>/dev/null || { echo >&2 " !!! Command READ required but not installed - Aborting !!! "; exit 1; }
#hash wget 2>/dev/null || { echo >&2 " !!! Command WGET required but not installed - Aborting !!! "; exit 1; }
hash curl 2>/dev/null || { echo >&2 " !!! Command CURL required but not installed - Aborting !!! "; exit 1; }

hash git 2>/dev/null || { echo >&2 " !!! Software GIT required but not installed - Aborting !!! "; exit 1; }
#hash conda 2>/dev/null || { echo >&2 " !!! Software CONDA not installed - Ignoring CONDA commands !!! "; }

# machine dependent (or not) options for FIND command
if [ "${MACHINE}" == "Mac" ]; then 
    OPTFIND=-E #BSD predicate
    OPTREGEX=
else
    OPTFIND=
    OPTREGEX=("-regextype" "posix-extended") #"-regextype posix-awk"  #
fi
OPTDEPTH=("-depth") # declared as an array: see http://mywiki.wooledge.org/BashFAQ/050 for case 

# utilities

function usage() { 
    ! [ -z "$1" ] && echo "$1";
    echo "";
    echo "=================================================================================";
    echo "${PROGRAM} : Quick lab setup - Fetch shared notebook resources from a git";  
    echo "             project and create a conda computing environment (conda) for running"; 
    echo "             them.";
    echo "Run: ${PROGRAM} -help for further help. Exiting program...";
    echo "=================================================================================";
    echo "";
    exit 1; 
}

function help() {
    ! [ -z "$1" ] && echo "$1";
    echo "";
    echo "=================================================================================";
    echo "${PROGRAM} : Quick lab setup - Fetch shared notebook resources from a git project";  
    echo "             and create a conda computing environment (conda) for running them.";
    echo "=================================================================================";
    echo "";
    echo "Syntax";
    echo "------";
    echo "    ${PROGRAM} [-h] [-v] [-t] [-p <proj>] [-r <repo>] [-b <branch>] [-d <folder>]";
    echo "                [-e <envir>] [-y <yaml>] [-u] [-c] [-a]";
    echo "";
    echo "Arguments";
    echo "---------";
    echo "";
    echo " -p <proj> : (opt.) name of the git project to clone/copy; def.: $DEFPRJ.";
    echo " -r <repo> : (opt.) name of the (remote) repository server (e.g., on github) where the";
    echo "              project <prj> is distributed; def.: $DEFREP.";
    echo " -b <branch> : branch of the project <prj> to clone/copy; def.: $DEFBRC.";
    echo " -d <folder> : name of the local directory where to clone/copy the project <prj>; def.:";
    echo "              $DEFDIR.";
    echo " -e <envir> : name of the conda environment that will be created; def.: $DEFENV.";
    echo " -y <yaml> : name of the YAML configuration file that is distributed with the project";
    echo "              <prj> and that will be used to create the conda environment <env>; def.:";
    echo "              $DEFYML.";
    echo " -c        : flag set to force the copy of the project <prj> instead of its cloning; when";
    echo "              set, git versioning and synchronisation of <prj> are deactivated.";
    echo " -u        : flag set to automatically update the local project <prj>; changes are pulled";
    echo "              from the remote project when git synchronisation is still active.";
    echo " -a        : flag set to activate the conda environment <env>.";
    echo " -h        : display this help.";
    echo " -v        : verbose mode (all kind of useless comments...).";
    echo " -t        : test the process; launch with your arguments to see the list of operations";
    echo "              that will actually be run; recommended.";
    echo "";
    echo "All arguments above are optional.";
    echo "";
    echo "Note";
    echo "----";
    echo "Note the syntax with long option names:"
    echo "    ${PROGRAM} [--prj <prj>] [--rep <repo>] [--branch <branch>] [-dir <folder>] ";
    echo "                [--env <envir>] [--yaml <yaml>] [-copy] [-update]";
    echo "                [--verb] [--help] [--test]";
    echo "";
    echo " European Commission  -  DG ESTAT  -  B1 unit: Methodology & Innovation  -  2020 ";
    echo "=================================================================================";
    exit 1;
}

## basic checks: command error or help
# [ $# -eq 0 ] && usage
[ $# -eq 1 ] && [ $1 = "--help" ] && help

## Some useful internal paramaters/functions

function absolute_path() { # work with folders and files
    # arguments: 1:relative path
    # returns: absolute path
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

function is_contained () {
    # arguments: 1:value 2:list
    # returns:  0 when the value $1 appears (i.e., is contained) in the list $2
    #           1 otherwise
    local e match=$1
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}

function starts_with () {
    # argument: 1:value - 2:prefixes
    # returns:  0 when the value starts with any of the patterns in prefixes
    local prefix value=$1
    shift
    for prefix; do
        case $value in
            "$prefix"*) return 0
        esac
    done
    return 1
}

function ends_with () {
    # argument: 1:value - 2:suffixes
    # returns:  0 when the value ends with any of the patterns in prefixes
    local suffix value=$1
    shift
    for suffix; do
        case $value in
            *"$suffix") return 0
        esac
    done
    return 1
}

function increment_name() {
    name=$1
    base=${name%%*([0-9])}
    digits=${name#$base} # ${name%%{name%%*([0-9])}
    if [ -z $digits ]; then
        digits=0
    fi
    digits=$((digits+1))
    echo $base$digits
}

function testecho() {
    echo -e "\n* Run command: \"$@\"..."
}

## Define/parse the script paramaters

# set the default values

HELP=0
VERB=0
TESTECHO=

PRJ=
REP=
DIR=
ENV=
YML=
BRC=

COPY=0
UPDATE=0
ACTIVATE=0

# we use getopt to pass the arguments
# options are:  [--verb] [--help] [--test] [--prj <Git_project>] [--rep <Git_repository>] [--branch <Git_branch>] 
#               [-dir <local_directory>] [--env <conda_environment>] [--yaml <yaml_configuration>] [-copy] [-update]

# option strings
SHORT=htvp:r:d:e:b:y::uc
LONG=test,help,verb,proj:,repo:,dir:,env:,branch:,yaml::,update,copy

# read the options
PARSED=$(getopt --options $SHORT --long $LONG --name "${PROGRAM}" -- "$@")
eval set -- "$PARSED"
while true ; do
    case "$1" in
        -h|--help) HELP=1
            shift;;
        -t|--test) TESTECHO=testecho
            shift;;
        -v|--verb) VERB=1
            shift;;
        -p|--proj) PRJ=$2; 
            shift 2;;
        -r|--repo) REP=$2; 
            shift 2;;
        -d|--dir) DIR=$2; 
            shift 2;;
        -e|--env) ENV=$2; 
            shift 2;;
        -y|--yml) 
            case "$2" in
                 "") YML="*.yml";; 
                 *) YML=$2;; 
            esac; shift 2 ;;
        -b|branch) BRC=$2;
            shift 2;;
        -c|--copy) COPY=1;
            shift;;
        -u|--update) UPDATE=1;
            shift;;
        --) shift; break ;;
        *) echo -e "\n!!! Unexpected option: \"$1\" - this should not happen - Aborting !!!"; exit 1;;
    esac
done

# further checks (possible after the shifts above)
[ $# -ne 0 ] && usage "!!! Non recognised input argument \"$@\" - Aborting !!!"

#while getopts :p:r:w:d:e:ufhtvc OPTION; do
#    case $OPTION in
#    p) PRJ=$OPTARG;;
#    h) HELP=1;;
#    -) ...;;
#    \?) usage "!!! option $OPTARG not allowed - Exiting !!!";;
#    esac
#done
#shift $((OPTIND-1))  

# help announcement (if not done already above)	
[ $HELP -eq 1 ] && help

# retrieve the remote REPository server
if [ -z "$REP" ]; then
    REP=$DEFREP
fi

function check_repo_domain() {
    # argument: 1:repository name
    # note: 0 is the normal bash "success" return value
    local prefix domains=("http" "https" "ftp" "ssh")
    return $(starts_with $1 ${domains[@]})
}

function check_repo_exists() {
    # argument: 1:repository
    # see: https://stackoverflow.com/questions/12199059/how-to-check-if-an-url-exists-with-the-shell-and-probably-curl
    [[ $(curl  --silent --head --fail $1) ]] && return 0
    # or: [[ $(wget -S --max-redirect=0 --spider $1  2>/dev/null | grep 'HTTP/1.1 200 OK') ]] && return 0
    return 1
    # or: if [[ `curl  --silent --head --fail $1` ]]; then
    # or: if curl --output /dev/null --silent --head --fail "$1"; then return 0;
    #     else return 1; fi
}

$(check_repo_domain $REP) || usage "!!! Protocol of remote repository \"$REP\" not recognised - Aborting !!!"
$(check_repo_exists $REP) || usage "!!! Remote repository \"$REP\" does not exist - Aborting !!!"

# retrieve the project
if [ -z "$PRJ" ]; then
    PRJ=$DEFPRJ
fi
if ! $(check_repo_domain $PRJ); then
    PRJ=${PRJ##*/}
fi
  
SRC=$REP/$PRJ
$(check_repo_exists $SRC) || usage "!!! Online project \"$SRC\" does not exist - Aborting !!!"

# retrieve the directory
if [ -z "$DIR" ]; then
    DIR=$DEFDIR
fi

# retrieve the environment name
if [ -z "$ENV" ]; then
    ENV=${DEFENV}-${PRJ##*/}
fi

# retrieve the YML configuration filename
if [ -z "$YML" ]; then
    YML=$DEFYML
fi

# retrieve the branch name
if [ -z "$BRC" ]; then
    BRC=$DEFBRC
fi

# verbose announcements	
([ $VERB -eq 1 ] || ! [ -z $TESTECHO ]) && ( echo -e "\n# Setup parameters...";    \
                                echo "  - source repository:        \"$REP\"";         \
                                #echo "  - source repository:        \"$SRC";         \
                                echo "  - source project:           \"$PRJ\"";         \
                                echo "  - project branch:           \"$BRC\"";         \
                                echo "  - destination directory:    \"$DIR\"";         \
                                echo "  - conda environment:        \"$ENV\"";         \
                                echo "  - conda configuration file: \"$YML\"" )

## Start operations

# check directory: create if it does not exist
if ! [ -d $DIR ]; then
    # directory does not exist and shall be created
    ([ $VERB -eq 1 ] || ! [ -z $TESTECHO ]) && echo -e "\n* Creating directory \"$DIR\"..."
    $TESTECHO mkdir -p $DIR
fi

function find_git_project() {
    # arguments: 1:project to find - 2:folder to explore (def.: current directory) 
    # see: https://stackoverflow.com/questions/2180270/check-if-current-directory-is-a-git-repository
    local dir=${2:-./}
    folder=$(find ${OPTFIND} $dir ${OPTDEPTH[@]} ${OPTREGEX[@]} -name $1 -type d)
    [ -z $folder ] && return 1
    $(check_git_dir $folder) || echo ""
    [ $VERB -eq 1 ] && git status
    echo $folder
}

# check whether the destination project already exists in local
if ! [ -d $DIR/$PRJ ]; then
    # if not, first check whether the file is actually... somewhere else in local
    prj=$(find_git_project $PRJ .) # $DIR
    if [ -z $prj ]; then 
        # if not, create the project from scratch
        prj=$DIR/$PRJ
        $TESTECHO create_git_project $COPY $REP $PRJ $BRC $DIR
        ([ $VERB -eq 1 ] || ! [ -z $TESTECHO ]) && echo -e "\n! git project repository created: \"$prj\" !"
    else
        # otherwise... proceed
        ([ $VERB -eq 1 ] || ! [ -z $TESTECHO ]) && echo -e "\n! git project repository found: \"$prj\" !"
    fi
else
    # else, proceed
    prj=$DIR/$PRJ
    ([ $VERB -eq 1 ] || ! [ -z $TESTECHO ]) && echo -e "\n! Project directory defined as: \"$prj\" !"
fi

function check_git_dir() { 
    # argument: 1:folder (def.: current directory) 
    # see: https://stackoverflow.com/questions/2180270/check-if-current-directory-is-a-git-repository
    local dir=${1:-./}
    # [ -d $dir ] || usage "!!! Directory $dir does not exist on disk - Exiting !!!"
    cd $dir
    [[ -e .git && -d .git ]] || return 1
    o=$(git rev-parse --is-inside-work-tree 2>/dev/null)
    [[ "$o" = "true" || "$o" == "false" ]] && return 0
    return 1
}

function create_git_project(){
    local option=$1 rep=$2 prj=$3 branch=${4:-master} dir=${5:-./}
    # [ -d $dir ] || usage "!!! Directory $dir does not exist on disk - Exiting !!!"
    verb=$([ $VERB -eq 1 ] && echo "--verbose" || echo "")
    # option=0,1 both clone/copy cases
    git clone --depth=1 --branch=$branch $verb $rep/$prj.git $dir/$prj
    # option=1 only copy case
    #cd $dir && git archive --format=tar --remote=$rep/$prj $branch | tar -xf - 
    if [ $option -eq 1 ]; then
        rm -fr $dir/.git
    fi
    [ $VERB -eq 1 ] && git status
    return 0
}

function update_git_project() {
    # arguments: 1:folder (def.: current directory) - 2:branch (def.: master)
    # see: https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
    local dir=${1:-./}
    # [ -d $dir ] || usage "!!! Directory $dir does not exist on disk - Exiting !!!"
    $(check_git_dir $dir) || return 0 # nothing to do, not a git file
    cd $dir
    git remote update # or git fetch
    upstream=${2:-'@{u}'}
    local=$(git rev-parse @)
    remote=$(git rev-parse "$upstream")
    base=$(git merge-base @ "$upstream")
    [ $VERB -eq 1 ] && git status
    if [ $local = $remote ]; then
        # nothing to do
        return 0 # up-to-date
    elif [ $local = $base ]; then
        git pull origin upstream
        return 1 # need to pull
    elif [ $remote = $base ]; then
        # do nothing
        return 2 # need to push
    else
        # do nothing
        return 3 # diverged
    fi
}

# check whether an update is requested
if [ $UPDATE -eq 0 ]; then 
    # not requested: break...
    ([ $VERB -eq 1 ] || ! [ -z $TESTECHO ]) && echo -e "\n! Leaving directory \"$prj\" unchanged !"     
# else, check whether the project is a git repository and shall remain so
elif ($(check_git_dir $prj) && [ $COPY -eq 0 ]); then  
    # normally update the git
    $TESTECHO update_git_project $prj $BRC
else
    # otherwise, remove everything and create a copy
    ([ $VERB -eq 1 ] || ! [ -z $TESTECHO ]) && echo -e "\n* Removing repository \"$prj\"..."
    $TESTECHO rm -fr $prj 
    ([ $VERB -eq 1 ] || ! [ -z $TESTECHO ]) && echo -e "\n* Creating repository \"$prj\"..."
    $TESTECHO create_git_project 1 $REP $(basename $prj) $BRC $(dirname $prj)
fi

# check whether conda is actually available
hash conda 2>/dev/null || { echo >&2 -e "\n! Software CONDA not installed - Ignoring CONDA commands !"; exit 0; }

function find_conda_yml() {
    # arguments: 1:yaml file to find - 2:folder to explore (def.: current directory)
    local yml dir file
    # yml=$(starts_with $1 . && echo \*.yml || echo $1)
    yml=$1
    dir=${2:-./}
    file=$(find $OPTFIND $dir ${OPTDEPTH[@]} ${OPTREGEX[@]} -name "$yml" -type f)
    echo $file
}

# retrieve the YAML file
yml=$(find_conda_yml $YML $prj)
[ -z $yml ] && { echo >&2 -e "\n! No YAML configuration file found - Ignoring CONDA commands !"; exit 0; }
# in case there is more than one file... then we arbitrarly decide to pick up the first one in the list...
ayml=($(echo $yml | tr ";" "\n"))
yml=${ayml[0]}
([ $VERB -eq 1 ] || ! [ -z $TESTECHO ]) && echo -e "\n! YAML configuration file found: \"$yml\" !"

function check_env_exists() {
    # argument: 1:conda env name
    local envs
    envs=$(conda env list | awk '/^[^#]/ {print $1}')
    $(is_contained $1 $envs) && return 0
    return 1
}

# check whether the conda environment already exists, in which case update the name
env=$(check_env_exists $ENV && increment_name $ENV || echo $ENV)
([ $VERB -eq 1 ] || ! [ -z $TESTECHO ]) && echo -e "\n! conda environment defined as: \"$yml\" !"

function create_conda_env() {
    # arguments: 1:conda env name - 2:yaml file (def.: "")
    [ $# -eq 1 ] && conda create $1 || (cd `dirname $2` && conda env create --name $1 --file `basename $2`)
}

function update_conda_env() {
    # arguments: 1:conda env name - 2:yaml file (def.: "")
    conda remove --name $1 --all
    $(create_conda_env $@) && return 0
    return 1
}

# create/update the conda environment
if ([ "$env" == "$ENV" ] && [ $UPDATE -eq 0 ]); then
    $TESTECHO create_conda_env $env $yml
else
    $TESTECHO update_conda_env $env $yml
fi

# display the list of available environments
([ $VERB -eq 1 ] || ! [ -z $TESTECHO ]) && $TESTECHO conda env list
