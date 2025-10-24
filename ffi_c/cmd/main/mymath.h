// mymath.h

// --- Basic Functions ---
void print_version();
int version_major();
int is_normal(double input);

// --- Floating-Point Calculations ---
float sinf(float input);
float cosf(float input);
float tanf(float input);
double sin(double input);
double cos(double input);
double tan(double input);

// --- Strings and Pointers ---
int parse_int(char* str);
char* version();
int tan_with_errcode(double input, double* output);

// --- Array Operations ---
int sin_array(int input_len, double* inputs, double* outputs);
int cos_array(int input_len, double* inputs, double* outputs);
int tan_array(int input_len, double* inputs, double* outputs);

// --- Structs and Complex Types ---
typedef struct {
  double real;
  double img;
} Complex;

Complex* new_complex(double r, double i);
void multiply(Complex* a, Complex* b, Complex** result);
void init_n_complexes(int n, Complex** complex_array);

void free_complex(Complex* c);

// --- Function Pointers ---
void for_each_complex(int n, Complex** arr, int (*call_back)(Complex*));

double length(Complex* a);
