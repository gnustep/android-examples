
#ifdef GNUSTEP

#include <pthread.h>
#include <unistd.h>

#include <android/log.h>

#include <Foundation/Foundation.h>

#include <QtAndroid>
#include <QAndroidJniEnvironment>

static const char *LOG_TAG = "GNUstep";

static int runLoggingThread();

@interface GSInitialize : NSObject
@end

@implementation GSInitialize

// this will be called automatically by the Objective-C runtime
+ (void)load
{
    __android_log_write(ANDROID_LOG_DEBUG, LOG_TAG, "Initialize GNUstep");

    // enable output of stdout and stderr via logcat to e.g. see messages from NSAssert()
	runLoggingThread();

	// initialize GNUstep
	QAndroidJniEnvironment qjniEnv;
	GSInitializeProcessAndroid(qjniEnv, QtAndroid::androidActivity().object());
}

@end


#pragma mark - Logging of stdout/stderr via logcat

// from https://stackoverflow.com/a/42715692/1534401
static int pfd[2];
static pthread_t loggingThread;

static void *loggingFunction(void *arg) {
    ssize_t readSize;
    char buf[128];

    while ((readSize = read(pfd[0], buf, sizeof buf - 1)) > 0) {
        if (buf[readSize - 1] == '\n') {
            --readSize;
        }

        buf[readSize] = 0;  // add null-terminator

        __android_log_write(ANDROID_LOG_INFO, LOG_TAG, buf); // Set any log level you want
    }

    return 0;
}

static int runLoggingThread() { // run this function to redirect your output to android log
    setvbuf(stdout, 0, _IOLBF, 0); // make stdout line-buffered
    setvbuf(stderr, 0, _IONBF, 0); // make stderr unbuffered

    /* create the pipe and redirect stdout and stderr */
    pipe(pfd);
    dup2(pfd[1], 1);
    dup2(pfd[1], 2);

    /* spawn the logging thread */
    if (pthread_create(&loggingThread, 0, loggingFunction, 0) == -1) {
        return -1;
    }

    pthread_detach(loggingThread);

    return 0;
}

#endif // GNUSTEP
