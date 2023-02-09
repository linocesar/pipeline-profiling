#!/bin/bash

OUTPUT="profiling.txt"
DPI=300

if [ -f $OUTPUT ]; then
	rm $OUTPUT
fi

for FILE in $(ls -1v *.html); do

TABNAME=$(echo "$FILE" | sed "s/.html//g")

DATA=($(cat "$FILE" | grep -oP '(?<=<div class="pos-df-summary-source color-source">).*(?=</div>)'))

NUMERO_LINHAS=${DATA[0]}
NUMERO_DUPLICATAS=${DATA[1]}
NUMERO_COL_CATEGORICAL=${DATA[4]}
NUMERO_COL_NUMERICA=${DATA[5]}
NUMERO_COL_TEXTO=${DATA[6]}
NUMERO_COLUNAS=$(($NUMERO_COL_CATEGORICAL + $NUM_COL_NUMERICA + $NUMERO_COL_TEXTO))


if [ $NUMERO_LINHAS -eq 1 ]
then
	OUT_NUMERO_LINHAS="apenas 1 linha de dados"
else
	OUT_NUMERO_LINHAS="$NUMERO_LINHAS linhas totais"
fi


if [ $NUMERO_DUPLICATAS -eq 0 ]
then
	OUT_DUPLICATA="sem nenhum tipo de duplicidade"
else	
	if [ $NUMERO_DUPLICATAS -eq 1 ]
	then 
		OUT_DUPLICATA="apenas 1 duplicata" 
	else
		OUT_DUPLICATA="possui $NUMERO_DUPLICATAS duplicatas"
	fi
fi

if [ $NUMERO_COLUNAS -eq 1 ]
then
	OUT_NUMERO_COLUNAS="identificamos que a base possui apenas $NUMERO_COLUNAS coluna (features)"
else
	OUT_NUMERO_COLUNAS="identificamos que a base possui $NUMERO_COLUNAS colunas (features)"
fi


if [ $NUMERO_COL_NUMERICA -eq 0 ]
then
	OUT_NUMERICA="não existe nenhuma coluna numérica (inteiros ou ponto flutuante)"
else	
	if [ $NUMERO_COL_NUMERICA -eq 1 ]
	then 
		OUT_NUMERICA="existe apenas uma coluna numérica (inteiros ou ponto flutuante)" 
	else
		OUT_NUMERICA="existem $NUMERO_COL_NUMERICA colunas numéricas (inteiros ou ponto flutuante)"
	fi
fi


if [ $NUMERO_COL_CATEGORICAL -eq 0 ]
then
	OUT_CATEGORICAL="não foi encontrada nenhuma coluna com tipo de dado categórico (booleano ou data)"

else
	if [ $NUMERO_COL_CATEGORICAL -eq 1 ]
	then
		OUT_CATEGORICAL="onde apenas $NUMERO_COL_CATEGORICAL (uma) coluna pode ser do tipo booleano ou data (categórico)"
	else
		OUT_CATEGORICAL="onde $NUMERO_COL_CATEGORICAL colunas que podem ser do tipo booleano ou data (categórico)"
	fi
fi


if [ $NUMERO_COL_TEXTO -eq 0 ]
then
	OUT_TEXTO="não existe nenhuma coluna como texto (string)"
else	
	if [ $NUMERO_COL_TEXTO -eq 1 ]
	then 
		OUT_TEXTO="existe apenas $NUMERO_COL_TEXTO (uma) coluna como texto (string)" 
	else
		OUT_TEXTO="existem $NUMERO_COL_TEXTO colunas como texto (string)"
	fi
fi
 

echo -e "$TABNAME: Analisando o output do processo, ilustrado na figura abaixo, é possível identificar que a base conta com um total de $OUT_NUMERO_LINHAS e $OUT_DUPLICATA considerando a sua chave. Além disso, $OUT_NUMERO_COLUNAS, $OUT_CATEGORICAL, $OUT_NUMERICA e $OUT_TEXTO.\n" >> $OUTPUT 

sed -i "s/DataFrame/$TABNAME/g" $FILE

# dependência: sudo apt install wkhtmltopdf
wkhtmltopdf --background -q -d $DPI $FILE $TABNAME."pdf"

echo -e $TABNAME."pdf gerado com sucesso!"

# dependência: sudo apt install poppler-utils
pdftoppm -singlefile -q -tiffcompression jpeg -x 100 -y 50 -rx $DPI -ry $DPI -W 1470 -H 1240 -cropbox $TABNAME."pdf" $TABNAME -tiff

echo -e $TABNAME."tif gerado com sucesso!\n"

done

# arquivo final concatenado de pdfs 
#pdftk *.pdf profiling.pdf


# Organizar os arquivos em diretórios
DIR_PRINT="print"
DIR_PDF="pdf"

if [ ! -d "$DIR_PRINT" ]; then
	mkdir $DIR_PRINT
fi

if [ ! -d "$DIR_PDF" ]; then
	mkdir $DIR_PDF
fi

mv *.tif $DIR_PRINT
mv *.pdf $DIR_PDF

