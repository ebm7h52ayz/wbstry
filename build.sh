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

PROJECT_INIT_FILE="${PROJECT_DIR}INIT.js"
if [ ! -f "$PROJECT_INIT_FILE" ]; then
  echo "ERROR: failed to find project init script '$PROJECT_INIT_FILE'."
  exit 1
fi

##build outputfile##

function convertImages { # converts list of image file locations to standard object list of names and base64 encoded images
  # $1 array of relative paths and file names of images
  # loop over array
  # convert to base64

  FILE_NAMES=()
  while read data; do
    FILE_NAMES+=($data)
  done

  JS_FILE_OBJECT_STRING='const imageContainer = { allImages: ['

  COUNT=0

  for i in "${FILE_NAMES[@]}"
  do
    COUNT=$(($COUNT+1))

    IMAGE_SIZE=$( file "$i" | grep -oP '(?<=,)(\s*\d+\s*x\s*\d+\s*)(?=,)')
    IMAGE_X=`expr "$IMAGE_SIZE" : '^[[:space:]]*\(.[0-9]*\)[[:space:]]*[x]'`
    IMAGE_Y=`expr "$IMAGE_SIZE" : '.*x[[:space:]]*\(..[0-9]*.\)[[:space:]]*.*'`

    JS_FILE_OBJECT_STRING="${JS_FILE_OBJECT_STRING}{ name: '$i', code: '"$( base64 -w 0 "$i")"', x: '"$IMAGE_X"', y: '"$IMAGE_Y"' }"

    if [[ ${#FILE_NAMES[@]} -gt "$COUNT" ]]; then
      JS_FILE_OBJECT_STRING="$JS_FILE_OBJECT_STRING, "
    fi

    if [[ ${#FILE_NAMES[@]} -eq "$COUNT" ]]; then
      JS_FILE_OBJECT_STRING="$JS_FILE_OBJECT_STRING
    ],
      [Symbol.iterator]() {
          const images = Object.values(this.allImages)
          let imageIndex = 0;

          return {
          next() {
            const endOfImages = !(imageIndex < images.length);
            if (endOfImages) {
              return {
                value: undefined,
                done: true
              };
            }
            imageIndex++;
            return {
              value: { name: images[imageIndex-1].name, code: images[imageIndex-1].code, x: images[imageIndex-1].x, y: images[imageIndex-1].y },
              done: false
            }
          }
          };
        }"
    fi
  done

  JS_FILE_OBJECT_STRING="$JS_FILE_OBJECT_STRING };"

  echo "$JS_FILE_OBJECT_STRING"

}

function deScript { # converts .wbstry script to js/jqry
  # $1 <all wbstry script as a continuous input> "s0.wbstry+s1.wbstry+..."

  # returns decoded scrips as a string of js/jqry to add to output file including images
  :
}

HEADER='<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
'
JQ_HEADER=`cat $JQ_BP`; #inject jq

CSS_HEADER=`cat $PROJECT_CSS_FILE`; #inject css

IMAGE_OBJECT_HEADER=`find . -name '*' -exec file {} \; | grep -oP '^(.+)(?=: \w+ image)' | convertImages`; # get all image files and build a map of them

SCRIPT_HEADER=`cat $PROJECT_INIT_FILE`; #js/jqry boilerpalte will use deScript function

SCRIPT_CONTENT=`cat ./project_bp/scn0/scn0.js` #user gen'd script for pages, maybe load from object like images? will use deScript function

##format output html tags##

JQ_HEADER="
<script>
$JQ_HEADER
</script>
"
CSS_HEADER="
<style>
$CSS_HEADER
</style>
"

IMAGE_OBJECT_HEADER="
<script>
$IMAGE_OBJECT_HEADER
</script>
"

SCRIPT_HEADER="
<script>
$SCRIPT_HEADER
</script>
"

HEADER="${HEADER}${JQ_HEADER}${CSS_HEADER}${IMAGE_OBJECT_HEADER}${SCRIPT_HEADER}
</head>
"

SCRIPT_CONTENT="
<script>
$SCRIPT_CONTENT
</script>
"

BODY=`cat $PROJECT_BODY_FILE`
BODY="
<body>
${BODY}
$SCRIPT_CONTENT
</body>
</html>"

##outup final html##
echo "${HEADER}${BODY}"
exit 0
