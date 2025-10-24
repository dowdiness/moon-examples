// mymath.c - Implementation of mymath library functions

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mymath.h"

#define VERSION_MAJOR 1
#define VERSION_MINOR 5
#define VERSION_PATCH 0

// --- Basic Functions ---
void print_version() {
    printf("mymath version %d.%d.%d\n", VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH);
}

int version_major() {
    return VERSION_MAJOR;
}

int is_normal(double input) {
    return isnormal(input) ? 1 : 0;
}

// --- Floating-Point Calculations ---
float sinf_impl(float input) {
    return sinf(input);
}

float cosf_impl(float input) {
    return cosf(input);
}

float tanf_impl(float input) {
    return tanf(input);
}

double sin_impl(double input) {
    return sin(input);
}

double cos_impl(double input) {
    return cos(input);
}

double tan_impl(double input) {
    return tan(input);
}

// --- Strings and Pointers ---
int parse_int(char* str) {
    if (str == NULL) return 0;
    return atoi(str);
}

char* version() {
    static char version_str[32];
    snprintf(version_str, sizeof(version_str), "%d.%d.%d",
             VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH);
    return version_str;
}

int tan_with_errcode(double input, double* output) {
    if (output == NULL) return -1;
    *output = tan(input);
    return 0;
}

// --- Array Operations ---
int sin_array(int input_len, double* inputs, double* outputs) {
    if (inputs == NULL || outputs == NULL) return -1;
    for (int i = 0; i < input_len; i++) {
        outputs[i] = sin(inputs[i]);
    }
    return 0;
}

int cos_array(int input_len, double* inputs, double* outputs) {
    if (inputs == NULL || outputs == NULL) return -1;
    for (int i = 0; i < input_len; i++) {
        outputs[i] = cos(inputs[i]);
    }
    return 0;
}

int tan_array(int input_len, double* inputs, double* outputs) {
    if (inputs == NULL || outputs == NULL) return -1;
    for (int i = 0; i < input_len; i++) {
        outputs[i] = tan(inputs[i]);
    }
    return 0;
}

// --- Structs and Complex Types ---
Complex* new_complex(double r, double i) {
    Complex* c = (Complex*)malloc(sizeof(Complex));
    if (c != NULL) {
        c->real = r;
        c->img = i;
    }
    return c;
}

void multiply(Complex* a, Complex* b, Complex** result) {
    if (a == NULL || b == NULL || result == NULL) return;

    *result = (Complex*)malloc(sizeof(Complex));
    if (*result != NULL) {
        (*result)->real = a->real * b->real - a->img * b->img;
        (*result)->img = a->real * b->img + a->img * b->real;
    }
}

void init_n_complexes(int n, Complex** complex_array) {
    if (complex_array == NULL) return;
    for (int i = 0; i < n; i++) {
        complex_array[i] = new_complex(0.0, 0.0);
    }
}

// --- Function Pointers ---
void for_each_complex(int n, Complex** arr, int (*call_back)(Complex*)) {
    if (arr == NULL || call_back == NULL) return;
    for (int i = 0; i < n; i++) {
        if (arr[i] != NULL) {
            call_back(arr[i]);
        }
    }
}

void free_complex(Complex* c) {
    free(c);
}

double length(Complex* a) {
    return sizeof(a);
}
