
print_float (Int32.to_float 1234567890l); print_newline ();
print_float (Int32.to_float (-1234567890l)); print_newline ();
print_float (Int32.to_float 0l); print_newline ();
print_float (Int32.to_float (Int32.mul (1000l) (300l))); print_newline ();
print_float (Int32.to_float (Int32.mul (1000l) (-300l))); print_newline ();
print_float (Int32.to_float (Int32.mul (-1000l) (300l))); print_newline ();
print_float (Int32.to_float (Int32.mul (-1000l) (-300l))); print_newline ();

print_float (Int64.to_float 1234567890L); print_newline ();
print_float (Int64.to_float (-1234567890L)); print_newline ();
print_float (Int64.to_float 0L); print_newline ();
print_float (Int64.to_float (Int64.mul (1000L) (300L))); print_newline ();
print_float (Int64.to_float (Int64.mul (1000L) (-300L))); print_newline ();
print_float (Int64.to_float (Int64.mul (-1000L) (300L))); print_newline ();
print_float (Int64.to_float (Int64.mul (-1000L) (-300L))); print_newline ();

print_int (Int32.compare (-1999l) (234l)); print_newline();
print_int (Int32.compare (-1999l) (-234l)); print_newline();
print_int (Int32.compare (1999l) (1999l)); print_newline();
print_int (Int32.compare (-1999l) (-1999l)); print_newline();
print_int (Int32.compare (1999l) (-234l)); print_newline();
print_int (Int32.compare (1999l) (234l)); print_newline();

print_int (Int64.compare (-1999L) (234L)); print_newline();
print_int (Int64.compare (-1999L) (-234L)); print_newline();
print_int (Int64.compare (1999L) (1999L)); print_newline();
print_int (Int64.compare (-1999L) (-1999L)); print_newline();
print_int (Int64.compare (1999L) (-234L)); print_newline();
print_int (Int64.compare (1999L) (234L)); print_newline();

print_int (Int32.compare Int32.max_int Int32.min_int); print_newline();
print_int (Int64.compare Int64.max_int Int64.min_int); print_newline();
