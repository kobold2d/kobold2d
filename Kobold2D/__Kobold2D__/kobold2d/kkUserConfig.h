/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


/**! kkUserConfig.h
 This file contains Kobold2D compile time settings the user might want to enable or disable.
 For example you can disable support for AdMob if you don't use it, to save about 900 KB 
 of the app's size (archive build). */


#ifndef Kobold2D_Libraries_kkUserConfig_h
#define Kobold2D_Libraries_kkUserConfig_h

/** @def KK_ADMOB_SUPPORT_ENABLED
 If this macro is defined, then Google AdMob Ad Banners are supported.
 App will then be about 900 KB larger (archive build) with AdMob ad support enabled.
 
 Note: AdMob is NO LONGER SUPPORTED as of Kobold2D 2.1.
 */
#define KK_ADMOB_SUPPORT_ENABLED 0

/** @def KK_PIXELMASKSPRITE_USE_BITARRAY
If set to 1, KKPixelMaskSprite will use a BitArray instead of BOOL array. 
 BitArray uses 1/8th (12.5%) of the memory of the regular BOOL array, but is around 20-30% slower.
 */
#define KK_PIXELMASKSPRITE_USE_BITARRAY 0

#endif
