#! /bin/bash

#Requires latexpand and delatex (opendetex)
DETEX="delatex"
EXPAND="latexpand.pl"

echo -n "Looking for latexpand ..."
CHECK=`${EXPAND} --version`
if [ $? -ne 0 ]; then
	echo "Please install latexpand.pl in the path. https://gitlab.com/latexpand/latexpand"
	exit
fi
echo " found!"

echo -n "Looking for opendetex (2.8.5) ..."
CHECK=`$DETEX -v | grep version | awk '{print $3}'`
if [ "$CHECK" != "2.8.5" ]; then
	echo "Please install opendetex 2.8.5. https://github.com/pkubowicz/opendetex"
	exit
fi
echo " found!"

FULL_PATH_FILE_NAME="$1"
INPUT_DIR=`dirname $FULL_PATH_FILE_NAME`
FILE_NAME=`basename $FULL_PATH_FILE_NAME`

if [ "$INPUT_DIR" != "." ]; then
	#we have to cd to input dir and get rid of the dir from path
	echo "Moving to $INPUT_DIR ..."
	cd $INPUT_DIR
fi

NO_EXTENSION_FILE=$(echo "$FILE_NAME" | cut -f 1 -d '.')

if [ $# -eq 0 ]; then
	echo "Please provide the filename of the root texfile!"
	exit
fi

FILE_EXPANDED=`mktemp latex_one_file_A_expanded.XXXXXXX`
FILE_PREPROCESSING=`mktemp latex_one_file_B_prepr.XXXXXXX`
FILE_NO_LATEX=`mktemp latex_one_file_C_no_latex.XXXXXXX`
FILE_TEXT_FINAL=`mktemp latex_one_file_D_final.XXXXXXX`

${EXPAND} $FILE_NAME > $FILE_EXPANDED


echo "Ensuring that Introduction and Paragraph have a new line in $FILE_EXPANDED ..."
# cat ${FILE_EXPANDED} | sed '/\\section{.*}/{G;}'  | sed '/\\Paragraph{.*}/{G;}' | sed 's/\\numberofauthors{.*}//' | sed 's/ \\cite{.*}//g' | sed 's/~\\cite{.*}//g' | sed 's/\\bibliographystyle{.*}//' | sed 's/\\begin{thebibliography}{.*}//' > ${FILE_PREPROCESSING}
cat ${FILE_EXPANDED} | sed '/\\section{.*}/{G;}'  | sed '/\\Paragraph{.*}/{G;}' > ${FILE_PREPROCESSING} 
cat ${FILE_EXPANDED} > ${FILE_PREPROCESSING} 
sed -i '' 's/\\numberofauthors{.*}//' ${FILE_PREPROCESSING} 
sed -i '' 's/ \\cite{.*}//g' ${FILE_PREPROCESSING} 
sed -i '' 's/~\\cite{.*}//g' ${FILE_PREPROCESSING} 
sed -i '' 's/\\bibliographystyle{.*}//' ${FILE_PREPROCESSING} 
sed -i '' 's/\\begin{thebibliography}{.*}//' ${FILE_PREPROCESSING} 
sed -i '' 's/\\acmConference{.*}{.*}//' ${FILE_PREPROCESSING} 
sed -i '' 's/\\settopmatter{.*}//' ${FILE_PREPROCESSING} 
sed -E -i '' 's/(\\Paragraph{.*)}/\1\.}/g' ${FILE_PREPROCESSING}
sed -E -i '' 's/(\\section{.*)}/\1\.}/g' ${FILE_PREPROCESSING}
sed -E -i '' 's/(\\subsection{.*)}/\1\.}\\n/g' ${FILE_PREPROCESSING}
sed -E -i '' 's/(\\subsubsection{.*)}/\1\.}\\n/g' ${FILE_PREPROCESSING}
sed -E -i '' 's/\$([0-9]*)\$/\1/g' ${FILE_PREPROCESSING}
sed -E -i '' 's/\$([0-9\.]*\\%)\$/\1/g' ${FILE_PREPROCESSING}
sed -E -i '' 's/\$([a-zA-Z]*\\%)\$/\1/g' ${FILE_PREPROCESSING}
sed -E -i '' 's/(\\begin{.*})\[.*\]/\1/g' ${FILE_PREPROCESSING}

echo "======================="

#replace simple macros ?
echo "Replacing project-specific macros"
sed -i '' 's/\\layoutshort{}/KiWi/g' ${FILE_PREPROCESSING}
sed -i '' 's/\\layoutshort/KiWi/g' ${FILE_PREPROCESSING}
sed -i '' 's/\\layout{}/Key Weaving Storage Layout/g' ${FILE_PREPROCESSING}
sed -i '' 's/\\layout/Key Weaving Storage Layout/g' ${FILE_PREPROCESSING}
sed -i '' 's/\\algo{}/Lethe/g' ${FILE_PREPROCESSING}
sed -i '' 's/\\algo/Lethe/g' ${FILE_PREPROCESSING}
sed -i '' 's/\\compshort{}/FADE/g' ${FILE_PREPROCESSING}
sed -i '' 's/\\compshort/FADE/g' ${FILE_PREPROCESSING}
sed -i '' 's/\\comp{}/FADE/g' ${FILE_PREPROCESSING}
sed -i '' 's/\\comp/FADE/g' ${FILE_PREPROCESSING}
sed -i '' 's/\\dpl{}/DPL/g' ${FILE_PREPROCESSING}
sed -i '' 's/\\dpl/DPL/g' ${FILE_PREPROCESSING}
echo "======================="

echo "Delatex..."
delatex -r $FILE_PREPROCESSING > $FILE_NO_LATEX
echo "======================="

echo "Fixing new lines and saving to $FILE_NO_LATEX ... "
# cat ${FILE_NO_LATEX} | awk '/^$/ { print "\n"; } /./ { printf("%s ", $0); } END { print ""; }' | sed -n 's/ \+/ /gp' > $FILE_TEXT_FINAL
cat ${FILE_NO_LATEX} | awk '/^$/ { print "\n"; } /./ { printf("%s ", $0); } END { print ""; }' > $FILE_TEXT_FINAL
sed -i '' 's/ \{1,\}/ /g' $FILE_TEXT_FINAL
echo "======================="

echo "Outputing clean text in ${NO_EXTENSION_FILE}-only-text.txt ... "
cat -s $FILE_TEXT_FINAL > ${NO_EXTENSION_FILE}-only-text.txt
echo "======================="

rm $FILE_EXPANDED
rm $FILE_PREPROCESSING
rm $FILE_NO_LATEX
rm $FILE_TEXT_FINAL

exit

echo "Entering \"staging\" directory ..."
cd staging

FILE_NAME="$1"
NO_EXTENSION_FILE=$(echo "$FILE_NAME" | cut -f 1 -d '.')

FILE_NAME_STEP_1="${NO_EXTENSION_FILE}-step1.tex"
FILE_NAME_STEP_2="${NO_EXTENSION_FILE}-step2.tex"
NO_TEX_FILE="${NO_EXTENSION_FILE}.txt"
FIXED_FILE="${NO_EXTENSION_FILE}-pure.txt"

echo "Latex expand $1 ..."
if [ -f ${NO_EXTENSION_FILE}.bbl ]; then
	echo "(Trying to expand bbl as well)"
	LATEXPAND="${LATEXPAND} --expand-bbl ${NO_EXTENSION_FILE}.bbl"
fi	
${LATEXPAND} ${FILE_NAME} > ${FILE_NAME_STEP_1} 
echo

# cat $FILE_NAME_STEP_1
# exit

echo "Ensuring that Introduction and Paragraph have a new line in $FILE_NAME_STEP_1 ..."
cat ${FILE_NAME_STEP_1} | sed '/\\section{.*}/{G;}'  | sed '/\\Paragraph{.*}/{G;}' | sed 's/\\numberofauthors{.*}//' | sed 's/ \\cite{.*}//g' | sed 's/~\\cite{.*}//g' | sed 's/\\bibliographystyle{.*}//' | sed 's/\\begin{thebibliography}{.*}//' > ${FILE_NAME_STEP_2}
echo

# cat ${FILE_NAME_STEP_2}
# exit

echo "Detexing $FILE_NAME_STEP_2 ..."
${DETEX} -n ${FILE_NAME_STEP_2} > ${NO_TEX_FILE}
echo

echo "Dos2Unix ${NO_TEX_FILE} ..."
dos2unix ${NO_TEX_FILE}
echo

# cat ${NO_TEX_FILE}
# exit 

echo "Fixing new lines and saving to $FIXED_FILE ... "
cat ${NO_TEX_FILE} | awk '/^$/ { print "\n"; } /./ { printf("%s ", $0); } END { print ""; }' | sed -n 's/ \+/ /gp' > $FIXED_FILE
echo

#cat $FIXED_FILE

rm -rf $FILE_NAME_STEP_1 $FILE_NAME_STEP_2 $NO_TEX_FILE

cp $FIXED_FILE ../latest-pure-text.txt