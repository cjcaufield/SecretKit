#ifndef SECRETKIT_DEBUG_HPP
#define SECRETKIT_DEBUG_HPP

#include "Platform.h"

#ifdef DEBUG

    #ifdef __APPLE__

        #if TARGET_OS_IPHONE
            #include <signal.h>
            #define SECRETKIT_ASSERT(b) { if (!(b)) raise(SIGINT); }

        #elif TARGET_IPHONE_SIMULATOR
            #include <signal.h>
            #define SECRETKIT_ASSERT(b) { if (!(b)) raise(SIGINT); }

        #elif TARGET_OS_MAC
            #include <signal.h>
            #define SECRETKIT_ASSERT(b) { if (!(b)) raise(SIGINT); }

        #endif

    #elif __linux

        #define SECRETKIT_ASSERT(b) { if (!(b)) kill(getpid(), SIGINT); }

    #endif

#else // RELEASE

    #define SECRETKIT_ASSERT(b) // nothing

#endif

#define SECRETKIT_NEVER SECRETKIT_ASSERT(false)

#endif // SECRETKIT_DEBUG_HPP
