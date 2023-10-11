%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>


#define MAX 1000

struct TablaDeID {
    char id[256];
    int numero;
};

struct TablaDeID tabla[MAX];
int consecutivo = 0;

int Mostrar () {
	for (int i = 0; i < consecutivo; i++) {
		printf("Id%d=%s \n", i+1,tabla[i].id );
	}
}

int Encontrar(char *n) {
    char n_lower[MAX]; 

    
    for (int i = 0; n[i]; i++) {
        n_lower[i] = tolower(n[i]);
    }
    n_lower[strlen(n)] = '\0';

    for (int i = 0; i < consecutivo; i++) {
        char tabla_lower[MAX];

        for (int j = 0; tabla[i].id[j]; j++) {
            tabla_lower[j] = tolower(tabla[i].id[j]);
        }
        tabla_lower[strlen(tabla[i].id)] = '\0';

        if (strcmp(n_lower, tabla_lower) == 0) {
            // Coinciden en minúsculas
            strcpy(tabla[i].id, n);
            return tabla[i].numero;
        }
    }
    return -1; // No encontrado en la tabla
}

int Add(char *n) {
    if (consecutivo >= MAX) {
        exit(1);
    }

    strcpy(tabla[consecutivo].id, n); // Copia lo que esté en n, en el id con indice consecutivo
    tabla[consecutivo].numero = consecutivo + 1;
    consecutivo++;

    return consecutivo;
}

char *Mayuscula(const char *n) {
    char *N = (char *)malloc(strlen(n)+1);
    strcpy(N, n);
    for (int i = 0; N[i]; i++) {
        N[i] = toupper(N[i]);
    }
    return N;
}

int numErrores = 0;

%}

%option noyywrap
%option case-insensitive

%%

[ \t\r\n]+  {printf("%s", yytext); } 

(select|where|group|by|order|create|drop|table|insert|delete|update|max|min|avg|count|into|values|from|set|asc|desc|integer|decimal|varchar|or|and)   {
  char *reservada = Mayuscula(yytext);
  printf("%s ", reservada);
  free(reservada);
}

\'[^\']+\'|\´[^\´]+\´|\‘[^\’]+\’|\’[^\’]+\’|\"[^\"]+\"	{ printf("cadena=%s ", yytext); }

[a-zA-ZáéíóúÁÉÍÓÚñÑ][a-zA-ZáéíóúÁÉÍÓÚñÑ0-9]*	{
    int num = Encontrar(yytext);
    if (num == -1) {
        num = Add(yytext);
    }
    printf("id%d=%s ", num, yytext);
}

[0-9]+"."[0-9]+  { printf("decimal=%s " , yytext); return decimal; }
[0-9]+	{ printf("entero=%s ", yytext); return entero; }

[+]	{ printf("suma=%s ", yytext); }
[-]	{ printf("resta=%s ", yytext); }
[*]	{ printf("asterisco=%s ", yytext); }
[/] { printf("div=%s ", yytext); }
"==" { printf("igualdad= %s ", yytext); }

"=" { printf("asignac= %s ", yytext); }
[;] { printf("puntcoma=%s ", yytext); }
[,]	{ printf("coma=%s ", yytext); }
[)]	{ printf("parcierr=%s ", yytext); }
[(]	{ printf("parabre=%s ", yytext); }

"<" { printf("menor= %s ", yytext); }
">" { printf("mayor= %s ", yytext); }
"<>" { printf("diferencia= %s ", yytext); }
">=" { printf("mayorigual= %s ", yytext); }
"<=" { printf("menorigual= %s ", yytext); }

[0-9]+[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9.]+ {
    printf("ERROR= %s ", yytext);
    numErrores++;
}

. {
    printf("ERROR= %s ", yytext);  // Sin espacio en blanco después de ERROR=
    numErrores = numErrores + 1;
}


%%

int main(int argc, char *argv[]) {

    ++argv, --argc; /* skip over program name */
    if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
    else
        yyin = stdin;

    yylex();
	printf("\n");
	printf ("%d identificadores \n", consecutivo);	
	Mostrar();
	printf("\n");
	printf("%d errores léxicos\n", numErrores);
	return 0;
}
