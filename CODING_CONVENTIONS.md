Trinix Foundation Coding Style Guide for D
===================================================================


About
-----

These are the coding conventions used for all recent Trinix Foundation projects.  
Feel free to comment, raise issues, fork and/or adapt this document.


License
-------

This style guide is published under the terms of the [FreeBSD documentation license](http://www.freebsd.org/copyright/freebsd-doc-license.html).


D Style Guide
-------------

  1.  [Indentation](#d-1)
  2.  [Ending line](#d-2)
  3.  [Comments](#d-3)
  4.  [Maximum number of columns](#d-4)
  5.  [Includes](#d-5)
  6.  [Whitespace](#d-6)
      1. [Operators](#d-6-1)
      2. [Parenthesis and brackets](#d-6-2)
      3. [Pointers](#d-6-2)
      4. [Casts](#d-6-4)
      5. [`for` loops](#d-6-5)
  7.  [Braces](#d-7)
  8.  [Alignment](#d-8)
      1. [Assignments](#d-8-1)
      2. [Variable declarations](#d-8-2)
      3. [Single line conditionals](#d-8-3)
      4. [Array subscripting operator](#d-8-4)
  9.  [Case and symbols naming](#d-9)
  10. [Variable declaration](#d-10)
  11. [Templates](#d-111)
  12. [Structures and unions](#d-12)
  13. [Enumerated types](#d-13)
  14. [Aliases](#d-14)
  15. [New lines](#d-14)
  16. [Package files](#d-16)
  17. [Functions prototypes](#d-17)
  18. [Functions with no parameters](#d-18)
  19. [Inline functions](#d-19)
  20. [Dereferencing](#d-20)
  21. [Conditionals](#d-21)
  22. [Switch statements](#d-22)
  23. [Long `if/else if` statements](#d-23)
  24. [C++ compatibility](#d-24)
  25. [Inline documentation](#d-25)
  26. [Compilation](#d-26)

<a name="d-1"></a>
### 1. Indentation

Code should always be indented using four spaces.  Never use tabulations for indentation.

<a name="d-2"></a>
### 2. Ending line

Source and header files cannot end with a empty line.

<a name="d-3"></a>
### 3. Comments

Comments should always use the `/* */` notations.
Single line C++ style comments (`//`) are strictly prohibited.

A line of comment should whenever possible be no more that 80 columns.

When a comment consists of a single line, place the `/* */` on the same line.  
If the comments consists of multiple lines, place the `/* */` on a new line:

```D
/* Single line comment */

/*
 * Multiple
 * line
 * comment
 */
```

When using multiple line comments, always align the `*` signs, as in the above example.  
For documentation use the `/** */` notations.  
Between paragraphs let the one empty line.

```D
    /**
     * Brief summary of what
     * myfunc does, forming the summary section.
     *
     * First paragraph of synopsis description.
     *
     * Second paragraph of
     * synopsis description.
     *
     * Authors: John Doe
     * Date: December 14, 2014
     * Bugs: Not working properly
     * Deprecated: Use myfunc2() instead
     *
     * Examples:
     * --------------------
     * writeln("3"); // writes '3' to stdout
     * --------------------
     * 
     * History:
     *      o V1 is initial version
     *      o V2 added feature X
     *
     * TODO:
     *      o Make more todos
     *      o too much todo
     *
     * Params:
     *      x   =       is for this, use 3 'TABS' (4 spaces against TAB)
     *                  you can use multiple lines
     *      y   =       is for that
     *
     *      value<TAB>=<TAB><TAB>description
     *
     * Returns:
     *      0           Success
     *      -1          same rules as for Parameters
     *      42          Sense of universe
     *
     * Notes:
     *      o Today, is a very good day
     *
     * See_Also:
     *      foo, bar, http://www.digitalmars.com/d/phobos/index.html
     *
     * Throws: WriteException on failure.
     *
     */
     deprecated int myfunc() {
        return 42;
     }
```

<a name="d-4"></a>
### 4. Maximum number of columns

The number of columns for a single line is not limited.  
However, try whenever possible to wrap long lines in order to improve the overall readability.

<a name="d-5"></a>
### 5. Imports

Imports directives should always come second, before any other declaration and after module declaration:

```D
module Main;

import System;

int x;
```

Not:

```D
import System;

module Main;

int x;
```

<a name="d-6"></a>
### 6. Whitespace

<a name="d-6-1"></a>
#### 6.1 Operators

A single whitespace character should always be used around all operators and statements except unary operators,
and statements `assert`, `scope`, `cast`:

```D
x = 1 + 2 + 3;

x++;
~x;

if (!x) {
    /* .... */
}

assert(x, "this is ok");
scope(exit) x--;
```

Not:

```D
x=1+2+3;

x ++;
~ x;

if( ! x )
{
    /* .... */
}

assert (x, "this is ok");
scope ( exit ) x--;
```

<a name="d-6-2"></a>
#### 6.2 Parenthesis and brackets

A single whitespace character cannot be used inside parenthesis and brackets, and never before:

```D
x[0 .. $] = 0;

x[42] = 0;

x[i + 5 .. $ - 7] = 0;

foo(x);

if (!y) {
    /*  */
}
```

Not:

```D
x[ 0..$ ] = 0;

x[ 42 ] = 0;

x[i+5..$-7] = 0;

foo ( x );

if(y==0)
{
    /*  */
}
```

<a name="d-6-3"></a>
#### 6.3 Pointers

The pointer sign should always be a date type aligned, except in cast statement:

```D
int* x;

x = cast(int *)42;
```

Not:

```D
int *x;

x = cast(int*)42;
```

<a name="d-6-4"></a>
#### 6.4 Casts

No whitespace should be added after a cast. Dont use whitespace after the opening parenthesis and before the closing one:

```D
x = cast(char *)y;
```

Not:

```D
x = cast ( char * ) y;
```

<a name="d-6-5"></a>
#### 6.5 `for` loops

When using `for` or `foreach` loops, a single whitespace character should be used after the semicolons:

```D
for (int i = 0; i < 10; i++) {
    /* ... */
}

foreach (x; array) {
    /* ... */
}
```

Not:

```D
for(int i=0;i<10;i++)
{
    /* ... */
}

foreach(x;array)
{
    /* ... */
}
```

<a name="c-7"></a>
### 7. Braces

Braces cannot be be placed on an empty line.  
This apply for all constructs (functions, classes, methods, templates, conditions, loops, etc.).  
Code inside braces should be indented by four spaces:

```D
void Foo() {
    if (...) {
    	/* ... */
    } else if (...){
    	/* ... */
    } else {
    	/* ... */
    }
    
    for (...) {
    	/* ... */
    }
    
    while (...) {
    	/* ... */
    }
    
    do {
    	/* ... */
    } while (...);
}
```

Dont use braces for one line code.  
An exceptions can be made for very simple constructs:

```D
    if (...)
        x = 1;    
    else if (...) 
        x = 2;
```

<a name="d-8"></a>
### 8. Alignment

<a name="d-8-1"></a>
#### 8.1 Assignments

Always align consecutive assignments:

```D
x       = 1;
foo     = 2;
foobar += 2;
```

Not:

```D
x = 1;
foo = 2;
foobar += 2;
```

If using multiple lines in an assignment, aligns the extra lines to the equal sign:

```D
x      = 1;
foobar = x
       + 1
       + 2;
```

When using conditional assignment, aligns the `?` and `:` signs whenever possible.  
The `?` sign should be aligned by adding whitespaces after the closing parenthesis:

```D
x      = 1;
foobar = (x)      ? 2      : x + 3;
foo    = (foobar) ? foobar : x;
```

Not:

```D
x      = 1;
foobar = ( x ) ? 2 : x + 3;
foo    = ( foobar ) ? foobar : x;
```

<a name="d-8-2"></a>
#### 8.2. Variable declarations

Always aligns the names of variables:

```D
int   x;
ulong y;
float z;
```

Not:

```C
int x;
ulong              y;
float z;
```

<a name="d-8-3"></a>
#### 8.3. Single line conditionals

If using single line conditional statements (see above), dont use the opening/closing braces:

```D
if (x == 1)
    foobar = 1;
else if(foobar == 1)
    x = 0xFFFFFFFF;
else
    x = 0;
```

Not:

```D
if( x == 1 ) { foobar = 1; }
else if( foobar == 1 ) { x = 0xFFFFFFFF; }
else x = 0;
```

<a name="d-8-4"></a>
#### 8.4. Array subscripting operator

Align value when using the array subscripting operator:

```D
x[1]      = 0;
x[100]    = 0;
x[0 .. $] = 5;
```

Not:

```D
x[ 1 ] = 0;
x[ 100 ] = 0;
```

<a name="d-9"></a>
### 9. Case and symbols naming

Local variables should never start with an underscore, and should always start with a lowercase letter.  
camelCase is recommended for local variables only.

For global symbols (variables, functions, methods, classes, interfaces, module names, packages, ...), PascalCase is usually recommended.  
A single underscore may be used to denote private symbols, if they are not static.  


```D
class Foo : IEnumerable, ISerializable, Bar {
    private int _bar;
    
    @property ref int Bar() {
        return _bar;
    }
    
    void SomePublicFunction() {
    
    }

    private void SomePrivateFunction() {
    
    }
    
    static void SomeStaticFunction() {
    
    }
}
```

<a name="d-10"></a>
### 10. Variable declaration

Local variables should be declared with value only:

```D
void Foo() {
    int x = 4;
    int y = 8;
    
    x = 15;
    x = 16;
    
    Bar(23);
    Foobar(42);
}
```

Not:

```D
void foo( void )
{
    int x;
    int y;
    
    bar();
    
    x = 0;
    
    foobar();
    
    y = 0;
}
```

The same applies for `for` loops:

```D
for (int i = 0; i < 10; i++) {
    /* ... */
}
```

<a name="d-11"></a>
### 11. Templates

Template should be used at the same way as functions

```D
    template SomeTemplate() {
        /* ... */
    }
```

<a name="d-12"></a>
### 12. Structures and unions

Members of structures and unions should be properly aligned, as mentioned before:

```C
struct Foo {
	int   x;
	ulong y;
}

union Bar {
	int   x;
	ulong y;
}
```

When manually padding a struct, use one leading underscore for the member name, and a trailing number, prefaced with an underscore.  
Always use a `private byte` array to manually pad a structure:

```D
struct Foo {
	char s;
	private byte _pad_0[3];
	int  x;
}
```

<a name="d-13"></a>
### 13. Enumrated types

Enum values should be properly aligned, as mentioned before.  
A value could always be provided. Hexadecimal is usually preferred:

```D
enum {
	Foo    = 0x01,
	Bar    = 0x02,
	Foobar = 0x10
}
```

Acceptable:

```D
enum {
	Foo,
	Bar,
	Foobar = 0x10
}
```

<a name="d-14"></a>
### 14. Alias

Simple aliases are declared on a single line:

```D
alias int foo;
```

<a name="d-15"></a>
### 15. New lines

An empty line should be used to separate logical parts of the code, as well as to separate function calls and assignments:

```D
x = 0;
y = 0;

foo();

z = 2;
```

Not:

```D
x = 0;
y = 0;
foo();
y = 2;
```

<a name="d-16"></a>
### 16. package files

All dirctory shoud have a one package.d file for importing package as all

```D
module Foo;

public import Foo.Bar;
public import Foo.AClass;
public import Foo.SomethingElse;
```

<a name="d-17"></a>
### 17. Functions prototypes

Function prototypes should be declare in the *.di file manually or with autgenerated command
for distribution purpouse

<a name="d-18"></a>
### 18. Functions with no parameters

Functions without parameters cannot be declared as taking `void`:

```D
void foo();
```

Not:

```D
void foo( void );
```

<a name="d-19"></a>
### 19. Inline functions

Inline functions should generally be avoided, unless there's a very good and specific reason to make them inline.

<a name="d-20"></a>
### 20. Dereferencing

When using the dereference operator `*`, you dont need to use an extra set of parenthesis:

```D
*x = 1;
y  = *x;
```

Not:

```D
*(x) = 1;
y  = *(x);
```
It is waste of chars

<a name="d-21"></a>
### 21. Conditionals

Dont use braces with conditionals when u have one line code:

```D
if (x == 1)
    x = 2;
```

Not:

```D
if( x == 1 ) {x = 2;}

if( x == 1 ) {
    x = 2;
}

if( x == 1 )
{
    x = 2;
}
```

Don't use `else` clauses when not necessary:

```D
if (x == 0)
    return true;
    
return false;
```

Not:

```D
if( x == 0 )
{
    return true;
}
else
{
	return false;
}
```

Dont prefer testing with `==`, even with boolean values or 0 integers.  
For testing against objects use `is`:

```D
if (b) {
    /* ... */
}

if (!b || !c) {
    /* ... */
}

if (b is object) {
    /* ... */
}

if (b !is null) {
    /* ... */
}
```

Not:

```D
if( b == true ) {
    /* ... */
}

if( b == 0 ) {
    /* ... */
}
```

<a name="d-22"></a>
### 22. Switch statements

When using switch statements, separate each `case` by adding an empty line after the `case`.  
The `break` statement should be indented, in regard to the `case` statement.

```D
switch (x) {
    case 1:
        /* ... */
        break;
        
    default:
        /* ... */
        break;
}
```

<a name="d-23"></a>
### 23. Long `if`/`else if` statements

Very long `if`/`else if` statements should be wrapped the following way:

```D
if (x == 1 && y == 2
    && foobar == 3) {
   /* ... */
}
```

<a name="d-24"></a>
### 24. C++ compatibility

All headers should be compatible with C/C++, using `extern (C)`/`extern (C++)`:

```D
extern(C) int variable;
extern(C++) int variable2;
```

<a name="d-254"></a>
### 25. Inline documentation

Documented code should prefer [Apple's HeaderDoc](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html) syntax rather than JavaDoc.

<a name="d-26"></a>
### 26. Compilation

Always compiles your code with `-Werror` or similar, and always use the highest possible error reporting level.