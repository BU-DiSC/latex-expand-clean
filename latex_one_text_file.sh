#! /bin/bash

DETEX="delatex"
FILE_NAME="$1"
NO_EXTENSION_FILE=$(echo "$FILE_NAME" | cut -f 1 -d '.')

if [ $# -eq 0 ]; then
	echo "Please provide the filename of the root texfile!"
	exit
fi

FILE_EXPANDED=`mktemp latex_one_file_A_expanded.XXXXXXX`
FILE_PREPROCESSING=`mktemp latex_one_file_B_prepr.XXXXXXX`
FILE_NO_LATEX=`mktemp latex_one_file_C_no_latex.XXXXXXX`
FILE_TEXT_FINAL=`mktemp latex_one_file_D_final.XXXXXXX`

latexpand.pl $FILE_NAME > $FILE_EXPANDED


echo "Ensuring that Introduction and Paragraph have a new line in $FILE_EXPANDED ..."
cat ${FILE_EXPANDED} | sed '/\\section{.*}/{G;}'  | sed '/\\Paragraph{.*}/{G;}' | sed 's/\\numberofauthors{.*}//' | sed 's/ \\cite{.*}//g' | sed 's/~\\cite{.*}//g' | sed 's/\\bibliographystyle{.*}//' | sed 's/\\begin{thebibliography}{.*}//' > ${FILE_PREPROCESSING}
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
sed -E -i '' 's/(\\Paragraph{.*)}/\1\.}/g' ${FILE_PREPROCESSING}
sed -E -i '' 's/(\\section{.*)}/\1\.}/g' ${FILE_PREPROCESSING}
sed -E -i '' 's/(\\subsection{.*)}/\1\.}/g' ${FILE_PREPROCESSING}
sed -E -i '' 's/(\\subsubsection{.*)}/\1\.}/g' ${FILE_PREPROCESSING}
sed -E -i '' 's/\$([0-9]*)\$/\1 /g' ${FILE_PREPROCESSING}
sed -E -i '' 's/\$([0-9\.]*\\%)\$/\1 /g' ${FILE_PREPROCESSING}
sed -E -i '' 's/\$([a-zA-Z]*\\%)\$/\1 /g' ${FILE_PREPROCESSING}
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

