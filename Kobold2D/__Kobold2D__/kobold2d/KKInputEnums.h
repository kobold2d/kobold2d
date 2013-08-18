/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#ifndef Kobold2D_Libraries_KKInputEnums_h
#define Kobold2D_Libraries_KKInputEnums_h


/** @file KKInputEnums.h */

/** Direction bits for the swipe gesture relative are relative to the current device orientation. */
typedef enum
{
	KKSwipeGestureDirectionRight	= 1 << 0, /**< */
	KKSwipeGestureDirectionLeft		= 1 << 1, /**< */
	KKSwipeGestureDirectionUp		= 1 << 2, /**< */
	KKSwipeGestureDirectionDown		= 1 << 3, /**< */
} KKSwipeGestureDirection;

/** A touch can have just began, it can be moving, or it can be ended this frame. The kKKTouchPhaseAny can be used if want to include all three phases in a touch test.
 The KKTouchPhase enum values are equal to those in the UITouchPhase enum (except for any and lifted), that means they can be used interchangeably. */
typedef enum
{
	KKTouchPhaseBegan, /**< touch began this frame */
	KKTouchPhaseMoved, /**< touch has moved this frame */
	KKTouchPhaseStationary, /**< touch didn't move this frame */
	KKTouchPhaseEnded, /**< touch ended this frame */
	KKTouchPhaseCancelled, /**< touch was cancelled (ie incoming call, incoming SMS, etc) this frame */
	
	KKTouchPhaseAny, /**< used for certain tests to disregard the phase of the touch */
	
	KKTouchPhaseLifted,  /**< a touch is "lifted" if it is no longer associated with a finger on the screen */
} KKTouchPhase;


/** The modifier flags (bits) for special keyboard keys, like Shift, Control, Option, Command, Function, Help, etc. */
typedef enum {
    KKModifierAlphaShiftKeyMask         = 1 << 16, /**< Caps Lock */
    KKModifierShiftKeyMask              = 1 << 17, /**< */
    KKModifierControlKeyMask            = 1 << 18, /**< */
    KKModifierAlternateKeyMask          = 1 << 19, /**< Option */
    KKModifierCommandKeyMask            = 1 << 20, /**< */
    KKModifierNumericPadKeyMask         = 1 << 21, /**< Set if a numeric keypad key is pressed */
    KKModifierHelpKeyMask               = 1 << 22, /**< */
    KKModifierFunctionKeyMask           = 1 << 23, /**< Set if any function key (F1, F2, etc) is pressed */
    KKDeviceIndependentModifierFlagsMask    = 0xffff0000UL, /**< Keyboard modifier keys are bits 16 to 23. Sometimes other bits (0-15) may be set as well, depending on the device. According to Apple: "Used to retrieve only the device-independent modifier flags, allowing applications to mask off the device-dependent modifier flags, including event coalescing information."
															 Use the following code to mask out the device-dependent flags:
															 
															 UInt32 flags = eventModifierFlags & kKKDeviceIndependentModifierFlagsMask;
															 */
} KKModifierFlag;

/** The virtual key codes for all keyboard keys, including modifier keys like Control, Command, Shift, etc. */
typedef enum {
	KKKeyCode_A                    = 0x00, /**< */
	KKKeyCode_B                    = 0x0B, /**< */
	KKKeyCode_C                    = 0x08, /**< */
	KKKeyCode_D                    = 0x02, /**< */
	KKKeyCode_E                    = 0x0E, /**< */
	KKKeyCode_F                    = 0x03, /**< */
	KKKeyCode_G                    = 0x05, /**< */
	KKKeyCode_H                    = 0x04, /**< */
	KKKeyCode_I                    = 0x22, /**< */
	KKKeyCode_J                    = 0x26, /**< */
	KKKeyCode_K                    = 0x28, /**< */
	KKKeyCode_L                    = 0x25, /**< */
	KKKeyCode_M                    = 0x2E, /**< */
	KKKeyCode_N                    = 0x2D, /**< */
	KKKeyCode_O                    = 0x1F, /**< */
	KKKeyCode_P                    = 0x23, /**< */
	KKKeyCode_Q                    = 0x0C, /**< */
	KKKeyCode_R                    = 0x0F, /**< */
	KKKeyCode_S                    = 0x01, /**< */
	KKKeyCode_T                    = 0x11, /**< */
	KKKeyCode_U                    = 0x20, /**< */
	KKKeyCode_V                    = 0x09, /**< */
	KKKeyCode_W                    = 0x0D, /**< */
	KKKeyCode_X                    = 0x07, /**< */
	KKKeyCode_Y                    = 0x10, /**< */
	KKKeyCode_Z                    = 0x06, /**< */
	
	KKKeyCode_1                    = 0x12, /**< */
	KKKeyCode_2                    = 0x13, /**< */
	KKKeyCode_3                    = 0x14, /**< */
	KKKeyCode_4                    = 0x15, /**< */
	KKKeyCode_5                    = 0x17, /**< */
	KKKeyCode_6                    = 0x16, /**< */
	KKKeyCode_7                    = 0x1A, /**< */
	KKKeyCode_8                    = 0x1C, /**< */
	KKKeyCode_9                    = 0x19, /**< */
	KKKeyCode_0                    = 0x1D, /**< */
	
	KKKeyCode_KeypadDecimal        = 0x41, /**< */
	KKKeyCode_KeypadMultiply       = 0x43, /**< */
	KKKeyCode_KeypadPlus           = 0x45, /**< */
	KKKeyCode_KeypadClear          = 0x47, /**< */
	KKKeyCode_KeypadDivide         = 0x4B, /**< */
	KKKeyCode_KeypadEnter          = 0x4C, /**< */
	KKKeyCode_KeypadMinus          = 0x4E, /**< */
	KKKeyCode_KeypadEquals         = 0x51, /**< */
	KKKeyCode_Keypad0              = 0x52, /**< */
	KKKeyCode_Keypad1              = 0x53, /**< */
	KKKeyCode_Keypad2              = 0x54, /**< */
	KKKeyCode_Keypad3              = 0x55, /**< */
	KKKeyCode_Keypad4              = 0x56, /**< */
	KKKeyCode_Keypad5              = 0x57, /**< */
	KKKeyCode_Keypad6              = 0x58, /**< */
	KKKeyCode_Keypad7              = 0x59, /**< */
	KKKeyCode_Keypad8              = 0x5B, /**< */
	KKKeyCode_Keypad9              = 0x5C, /**< */
	
	KKKeyCode_RightBracket         = 0x1E, /**< */
	KKKeyCode_LeftBracket          = 0x21, /**< */
	KKKeyCode_Equal                = 0x18, /**< */
	KKKeyCode_Minus                = 0x1B, /**< */
	KKKeyCode_Quote                = 0x27, /**< */
	KKKeyCode_Grave                = 0x32, /**< */
	KKKeyCode_Semicolon            = 0x29, /**< */
	KKKeyCode_Comma                = 0x2B, /**< */
	KKKeyCode_Period               = 0x2F, /**< */
	KKKeyCode_Slash                = 0x2C, /**< */
	KKKeyCode_Backslash            = 0x2A, /**< */
	
	/* keycodes for keys that are independent of keyboard layout*/
	KKKeyCode_Escape                    = 0x35, /**< */
	KKKeyCode_Tab                       = 0x30, /**< */
	KKKeyCode_Space                     = 0x31, /**< */
	KKKeyCode_Return                    = 0x24, /**< */
	KKKeyCode_Help                      = 0x72, /**< */
	KKKeyCode_Home                      = 0x73, /**< */
	KKKeyCode_Delete                    = 0x33, /**< */
	KKKeyCode_End                       = 0x77, /**< */
	KKKeyCode_PageUp                    = 0x74, /**< */
	KKKeyCode_PageDown                  = 0x79, /**< */
	KKKeyCode_ForwardDelete             = 0x75, /**< */
	KKKeyCode_LeftArrow                 = 0x7B, /**< */
	KKKeyCode_RightArrow                = 0x7C, /**< */
	KKKeyCode_DownArrow                 = 0x7D, /**< */
	KKKeyCode_UpArrow                   = 0x7E, /**< */
	KKKeyCode_VolumeUp                  = 0x48, /**< */
	KKKeyCode_VolumeDown                = 0x49, /**< */
	KKKeyCode_Mute                      = 0x4A, /**< */
	
	KKKeyCode_F1                        = 0x7A, /**< */
	KKKeyCode_F2                        = 0x78, /**< */
	KKKeyCode_F3                        = 0x63, /**< */
	KKKeyCode_F4                        = 0x76, /**< */
	KKKeyCode_F5                        = 0x60, /**< */
	KKKeyCode_F6                        = 0x61, /**< */
	KKKeyCode_F7                        = 0x62, /**< */
	KKKeyCode_F8                        = 0x64, /**< */
	KKKeyCode_F9                        = 0x65, /**< */
	KKKeyCode_F10                       = 0x6D, /**< */
	KKKeyCode_F11                       = 0x67, /**< */
	KKKeyCode_F12                       = 0x6F, /**< */
	KKKeyCode_F13                       = 0x69, /**< */
	KKKeyCode_F14                       = 0x6B, /**< */
	KKKeyCode_F15                       = 0x71, /**< */
	KKKeyCode_F16                       = 0x6A, /**< */
	KKKeyCode_F17                       = 0x40, /**< */
	KKKeyCode_F18                       = 0x4F, /**< */
	KKKeyCode_F19                       = 0x50, /**< */
	KKKeyCode_F20                       = 0x5A, /**< */
	
	KKKeyCode_Command                   = 0x37, /**< */
	KKKeyCode_Shift                     = 0x38, /**< */
	KKKeyCode_CapsLock                  = 0x39, /**< */
	KKKeyCode_Option                    = 0x3A, /**< */
	KKKeyCode_Control                   = 0x3B, /**< */
	KKKeyCode_RightShift                = 0x3C, /**< */
	KKKeyCode_RightOption               = 0x3D, /**< */
	KKKeyCode_RightControl              = 0x3E, /**< */
	KKKeyCode_Function                  = 0x3F, /**< */
	
	/* ISO keyboards only*/
	KKKeyCode_ISO_Section               = 0x0A, /**< ISO keyboards only */
	
	/* JIS keyboards only*/
	KKKeyCode_JIS_Yen                   = 0x5D, /**< JIS keyboards only (this one and following) */
	KKKeyCode_JIS_Underscore            = 0x5E, /**< */
	KKKeyCode_JIS_KeypadComma           = 0x5F, /**< */
	KKKeyCode_JIS_Eisu                  = 0x66, /**< */
	KKKeyCode_JIS_Kana                  = 0x68, /**< */
	
} KKKeyCode;

/** The "virtual keyCodes" for mouse buttons. These are left, right and other. The "other" buttons may include multiple keys which,
 if supported by the hardware and driver, you can identify with kKKMouseButtonOther and an optional offset, eg "kKKMouseButtonOther + 2" for
 a fifth mouse button. Note that any of the "other" mouse buttons are non-standard and typically require non-Apple mice to work. You can not
 rely on any of the "other" buttons being available at all.
 
 Mouse double-clicks are an offset (kKKMouseButtonDoubleClickOffset) to the button codes. Double-clicks are treated as separate buttons by
 KKInput for your convenience, ie you don't have to test for two consecutive mouse button presses.
 */
typedef enum {
	KKMouseButtonLeft, /**< */
	KKMouseButtonRight, /**< */
	KKMouseButtonOther, /**< Third mouse button, and other mouse buttons by adding offset: kKKMouseButtonOther + n */
	
	KKMouseButtonDoubleClickOffset = 0x1F, /**< Mouse button double clicks are treated as seperate key codes with this offset: kKKMouseButtonLeft + kKKMouseButtonDoubleClickOffset == kKKMouseButtonDoubleClickLeft */
	KKMouseButtonDoubleClickLeft = KKMouseButtonDoubleClickOffset, /**< */
	KKMouseButtonDoubleClickRight, /**< */
	KKMouseButtonDoubleClickOther, /**< */
} KKMouseButtonCode;



#endif
