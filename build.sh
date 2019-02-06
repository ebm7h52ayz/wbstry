#patches boiler plate together, adds scripts, and encodes images into output html
#ARGS: build.sh <args> ./<project_dir_to_build>/

##check project dir valid##
for last; do true; done

PROJECT_DIR="$last"
IS_MINI=false

for arg in "$@"
do
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
    then
      echo "./build.sh <args> ./<project_dir_to_build>/ > <outputfilename.html>"
      echo "--help, -h : dispaly this help menu"
      echo "--mini, -m : write minified jquery to output"
      exit 0
    fi
    if [ "$arg" == "--mini" ] || [ "$arg" == "-m" ]
    then
      IS_MINI=true
    fi
done

if [ ! -d "$PROJECT_DIR" ]; then
  # project file does not exsist
  echo "ERROR: failed to find project dir '$PROJECT_DIR'."
  exit 1
fi

JQ_BP="./rsc/jquery-3.3.1.js"
if [[ $IS_MINI == true ]]; then
  JQ_BP="./rsc/jquery-3.3.1.min.js"
fi

if [ ! -f "$JQ_BP" ]; then
  echo "ERROR: failed to find jquery boilerpalte '$JQ_BP'."
  exit 1
fi

PROJECT_BODY_FILE="${PROJECT_DIR}BODY.html"
if [ ! -f "$PROJECT_BODY_FILE" ]; then
  echo "ERROR: failed to find project body '$PROJECT_BODY_FILE'."
  exit 1
fi

PROJECT_CSS_FILE="${PROJECT_DIR}CSS.css"
if [ ! -f "$PROJECT_CSS_FILE" ]; then
  echo "ERROR: failed to find project css '$PROJECT_CSS_FILE'."
  exit 1
fi

PROJECT_INIT_FILE="${PROJECT_DIR}INIT.wbstry"
if [ ! -f "$PROJECT_INIT_FILE" ]; then
  echo "ERROR: failed to find project init script '$PROJECT_INIT_FILE'."
  exit 1
fi

##build outputfile##

function convertImages { # converts list of image file locations to standard object list of names and base64 encoded images
  # $1 array of relative paths and file names of images
  # loop over array
  # convert to base64
  # var images = [{name: "./<PATH_TO_FILENAME/<FILENAME>.png", code: "<BASE64_ENCODED_IMAGE_STRING>"}, {name: "./<PATH_TO_FILENAME/<FILENAME>.png", code: "<BASE64_ENCODED_IMAGE_STRING>"}, ]

  FILE_NAMES=()
  while read data; do
    FILE_NAMES+=($data)
  done

  JS_FILE_OBJECT_STRING='var images = [ '

  COUNT=0

  for i in "${FILE_NAMES[@]}"
  do
    COUNT=$(($COUNT+1))

    JS_FILE_OBJECT_STRING="${JS_FILE_OBJECT_STRING}{ image: \"$i\", code: \""$( base64 "$i")"\" }"

    if [[ ${#FILE_NAMES[@]} -gt "$COUNT" ]]; then
      JS_FILE_OBJECT_STRING="$JS_FILE_OBJECT_STRING, "
    fi
  done


  JS_FILE_OBJECT_STRING="$JS_FILE_OBJECT_STRING ];"

  echo "$JS_FILE_OBJECT_STRING"

}

function deScript { # converts .wbstry script to js/jqry
  # $1 <all wbstry script as a continuous input> "s0.wbstry+s1.wbstry+..."

  # returns decoded scrips as a string of js/jqry to add to output file including images
  :
}

HEADER='<!DOCTYPE html><html><head>'
JQ_HEADER=`cat $JQ_BP`; #inject jq
CSS_HEADER=`cat $PROJECT_CSS_FILE`; #inject css
SCRIPT_HEADER=`cat $PROJECT_INIT_FILE`;  #will use deScript function

JQ_HEADER="<script>$JQ_HEADER</script>"
CSS_HEADER="<style>$CSS_HEADER</style>"

# get all image files and build a JS map of them
find . -name '*' -exec file {} \; | grep -oP '^(.+)(?=: \w+ image)' | convertImages

SCRIPT_HEADER="<script>$SCRIPT_HEADER</script>"

HEADER="${HEADER}${JQ_HEADER}${CSS_HEADER}${SCRIPT_HEADER}</head>"

BODY=`cat $PROJECT_BODY_FILE`
BODY="<body>${BODY}</body></html>"
echo "${HEADER}${BODY}"
exit 0
