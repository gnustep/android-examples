
#include <pthread.h>
#include <unistd.h>

#include <android/log.h>

#include <Foundation/Foundation.h>

static const char *LOG_TAG = "GNUstep";

static int runLoggingThread();

@interface GSInitialize : NSObject
@end

@implementation GSInitialize

// this will be called automatically by the Objective-C runtime
+ (void)load
{
    __android_log_write(ANDROID_LOG_DEBUG, LOG_TAG, "Run logging thread");

    runLoggingThread();
}

JNIEXPORT void JNICALL
Java_com_example_helloobjectivec_MainActivity_initializeGNUstep(JNIEnv *env, jobject this, jobject context)
{
    __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, "Initializing GNUstep...");

    // initialize GNUstep
    GSInitializeProcessAndroid(env, context);

    // set supported languages in GNUstep (required for Android)
    [NSUserDefaults setUserLanguages:@[@"en"]];
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
