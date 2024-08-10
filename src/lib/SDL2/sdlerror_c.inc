// based on "sdl_error_c.h" (2.0.14)

{* This file defines a structure that carries language-independent
   error messages
*}

const
  ERR_MAX_STRLEN = 128;
  //ERR_MAX_ARGS   = 5; { Obsolete in 2.0.14? }

type
  PPSDL_Error = ^PSDL_Error;
  PSDL_Error = ^TSDL_Error;
  TSDL_Error = record
    {* This is a numeric value corresponding to the current error *}
    error: cint;
    str: String[ERR_MAX_STRLEN];
  end;

  { Seems the error structure has changed drastically by SDL2 ver. 2.0.14?!
    For ref. the old structure: (Can be deleted in later versions) }
  //TSDL_Error = record
  //  {* This is a numeric value corresponding to the current error *}
  //  error: cint;
  //
  //  {* This is a key used to index into a language hashtable containing
  //     internationalized versions of the SDL error messages.  If the key
  //     is not in the hashtable, or no hashtable is available, the key is
  //     used directly as an error message format string.
  //   *}
  //  key: String[ERR_MAX_STRLEN];
  //
  //  {* These are the arguments for the error functions *}
  //  argc: cint32;
  //  case cint32 of
  //       {* What is a character anyway?  (UNICODE issues) *}
  //    0: (value_c: Byte;);
  //    1: (value_ptr: Pointer;);
  //    2: (value_i: cint32;);
  //    3: (value_f: Double;);
  //    4: (buf: String[ERR_MAX_STRLEN];);
  //end;
