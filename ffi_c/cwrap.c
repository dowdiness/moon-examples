// cwrap.c
#include "cmd/main/mymath.h"
#include <moonbit.h>

#include <string.h> // for strlen
#include <stdio.h> // for snprintf

// This function is responsible for correctly converting a char* to a moonbit_string_t with a GC header
moonbit_string_t cstr_to_moonbit_str(char *ptr) {
  if (ptr == NULL) {
    return moonbit_make_string(0, 0);
  }
  int32_t len = strlen(ptr);
  // moonbit_make_string allocates a MoonBit string object with a GC header
  moonbit_string_t ms = moonbit_make_string(len, 0);
  for (int i = 0; i < len; i++) {
    ms[i] = (uint16_t)ptr[i]; // Assuming ASCII compatibility
  }
  // Note: Whether to free(ptr) depends on the C library's API contract.
  // If the memory returned by version() needs to be freed by the caller, it should be freed here.
  return ms;
}

// The mymath library should provide a function to free Complex, let's assume it's free_complex
// void free_complex(Complex* c);

// We need a void* version of the finalizer for the MoonBit GC to use
void free_complex_finalizer(void* obj) {
    // The layout of a MoonBit external object is { void (*finalizer)(void*); T data; }
    // We need to extract the real Complex pointer from obj
    // Assuming the MoonBit Complex wrapper has only one field
    Complex* c_obj = *((Complex**)obj);
    free_complex(c_obj); // Call the real finalizer, if provided by the mymath library
    // free(c_obj); // If it was allocated with standard malloc
}

// Define what the MoonBit Complex wrapper looks like in C
typedef struct {
  Complex* val;
} MoonBit_Complex;

// Function to create the MoonBit wrapper object
MoonBit_Complex* new_mbt_complex(Complex* c_complex) {
  // `moonbit_make_external_obj` is the key
  // It creates a GC-managed external object and registers its finalizer.
  MoonBit_Complex* mbt_complex = moonbit_make_external_object(
      &free_complex_finalizer,
      sizeof(MoonBit_Complex)
  );
  mbt_complex->val = c_complex;
  return mbt_complex;
}

moonbit_string_t ccomplex_to_moonbit_str(MoonBit_Complex *mbt_ptr) {
  if (mbt_ptr == NULL || mbt_ptr->val == NULL) {
    return moonbit_make_string(0, 0);
  }

  // Unwrap to get the actual C Complex pointer
  Complex* ptr = mbt_ptr->val;
  double real = ptr->real;
  double img = ptr->img;

  // Allocate sufficient buffer for formatting complex numbers
  // Format: "real+imagi" or "real-imagi"
  // Each double can be up to ~24 chars in scientific notation, plus formatting
  char buffer[128];
  int written;

  // Format the complex number nicely
  if (isnan(img) || img >= 0) {
    written = snprintf(buffer, sizeof(buffer), "%.8f+%.8fi", real, img);
  } else {
    written = snprintf(buffer, sizeof(buffer), "%.8f-%.8fi", real, -img);
  }

  // Check if snprintf was successful
  if (written < 0 || written >= sizeof(buffer)) {
    // Fallback: return an error string
    const char* err_msg = "(formatting error)";
    int32_t err_len = strlen(err_msg);
    moonbit_string_t ms = moonbit_make_string(err_len, 0);
    for (int32_t i = 0; i < err_len; i++) {
      ms[i] = (uint16_t)err_msg[i];
    }
    return ms;
  }

  // Get actual string length (excluding null terminator)
  int32_t str_len = strlen(buffer);

  // Create MoonBit string with correct length
  moonbit_string_t ms = moonbit_make_string(str_len, 0);

  // Copy each character, converting char to uint16_t
  for (int32_t i = 0; i < str_len; i++) {
    ms[i] = (uint16_t)buffer[i];
  }

  return ms;
}

// Wrapper for init_n_complexes that works with MoonBit_Complex
// This modifies the existing MoonBit_Complex objects in the array
// by updating their underlying C Complex* pointers
void init_n_moonbit_complexes(int n, MoonBit_Complex** complex_array) {
  if (complex_array == NULL) return;
  for (int i = 0; i < n; i++) {
      if (complex_array[i] != NULL && complex_array[i]->val != NULL) {
          // Free the old Complex* and allocate a new one
          // The finalizer will handle freeing when the MoonBit object is GC'd
          free_complex(complex_array[i]->val);
      }
      // Create new Complex and assign it
      Complex* c = new_complex((double)0, (double)(0));
      if (complex_array[i] == NULL) {
          // If slot is NULL, create new wrapper
          complex_array[i] = new_mbt_complex(c);
      } else {
          // If wrapper exists, just update the pointer
          complex_array[i]->val = c;
      }
  }
}

// Wrapper for for_each_complex that works with MoonBit_Complex
// This function receives MoonBit_Complex** array and a callback that expects MoonBit_Complex*
// But needs to call the C for_each_complex with Complex** and callback expecting Complex*
void for_each_moonbit_complex(
    int n,
    MoonBit_Complex** mbt_arr,
    int (*mbt_call_back)(MoonBit_Complex*)
) {
    if (mbt_arr == NULL || mbt_call_back == NULL) return;

    // Simply iterate and call the MoonBit callback directly with MoonBit_Complex*
    for (int i = 0; i < n; i++) {
        if (mbt_arr[i] != NULL) {
            mbt_call_back(mbt_arr[i]);
        }
    }
}
