/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


/**! kkARCSupport.h
 This file contains macros for compatibility with ARC. The main purpose is to write
 code that compiles and works correctly both with and without ARC, by utilizing the KK_ARC_ENABLED
 macro. In addition certain LLVM 3.0 ARC keywords like __bridge and __unsafe_unretained are defined
 if the compiler is not LLVM 3.0 (ie. code is built with Xcode 4.1 or earlier). This allows you to
 use these ARC specific keywords without breaking the build for older Xcode versions and compilers
 without (full) ARC support (eg LLVM 1.0, LLVMGCC42, GCC 4.2).
 */


// define some LLVM3 macros if the code is compiled with a different compiler (ie LLVMGCC42)
#ifndef __has_feature
#define __has_feature(x) 0
#endif
#ifndef __has_extension
#define __has_extension __has_feature // Compatibility with pre-3.0 compilers.
#endif


#if !defined(__clang__) || __clang_major__ < 3

#ifndef __bridge
#define __bridge
#endif
#ifndef __bridge_retained
#define __bridge_retained
#endif
#ifndef __bridge_transfer
#define __bridge_transfer
#endif
#ifndef __autoreleasing
#define __autoreleasing
#endif
#ifndef __strong
#define __strong
#endif
#ifndef __weak
#define __weak
#endif
#ifndef __unsafe_unretained
#define __unsafe_unretained
#endif

#endif // __clang_major__ < 3


/** @def KK_ARC_ENABLED
 This macro is defined if the current compiler supports automatic reference counting (ARC).
 By default, ARC is enabled if you're running Xcode 4.2 with the LLVM 3.0 compiler (default).
 ARC is disabled if you are running Xcode 4.1 or earlier, or selected a different compiler (not recommended).
 
 This macro controls the inclusion of ARC specific code to make the Kobold2D Libraries compatible with ARC,
 for example by replacing NSAutoreleasePool with the @autoreleasepool keyword.
 */
#if __has_feature(objc_arc) && __clang_major__ >= 3
#define KK_ARC_ENABLED 1
#endif // __has_feature(objc_arc)
