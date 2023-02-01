#!/bin/bash

OUTPUT="profiling.txt"

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
NUMERO_COLUNAS=$((NUMERO_COL_CATEGORICAL + $NUM_COL_NUMERICA + $NUMERO_COL_TEXTO))


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
	OUT_NUMERO_COLUNAS="identificamos que a base possui $NUMERO_COLUNAS (features)"
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
 

echo -e "$TABNAME: Analisando o output do processo, ilustrado na figura  abaixo, é possível identificar que a base conta com um total de $NUMERO_LINHAS linhas totais e $OUT_DUPLICATA considerando a sua chave. Além disso, $OUT_NUMERO_COLUNAS, $OUT_CATEGORICAL, $OUT_NUMERICA e $OUT_TEXTO.\n" >> $OUTPUT 

sed -i "s/DataFrame/$TABNAME/g" $FILE
wkhtmltopdf $FILE $TABNAME."pdf"

done
