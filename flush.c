#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/fs.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
    int arg, descriptor, result;

    if (argc < 2 || !strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")) {
        fprintf(stderr, "\n");
        fprintf(stderr, "Usage: %s [ -h | --help ]\n", argv[0]);
        fprintf(stderr, "       %s BLOCK-DEVICE-OR-PARTITION ...\n", argv[0]);
        fprintf(stderr, "\n");
        return EXIT_FAILURE;
    }

    for (arg = 1; arg < argc; arg++) {

        do {
            descriptor = open(argv[arg], O_RDWR);
        } while (descriptor == -1 && errno == EINTR);
        if (descriptor == -1) {
            const int cause = errno;
            fprintf(stderr, "%s: Cannot open device: %s [%d].\n", argv[arg], strerror(cause), cause);
            return EXIT_FAILURE;
        }

        errno = 0;
        result = ioctl(descriptor, BLKFLSBUF);
        if (result && errno) {
            const int cause = errno;
            fprintf(stderr, "%s: Cannot flush device: %s [%d].\n", argv[arg], strerror(cause), cause);
            return EXIT_FAILURE;
        } else
        if (result)
            fprintf(stderr, "%s: Flush returned %d.\n", argv[arg], result);
        else
        if (errno) {
            const int cause = errno;
            fprintf(stderr, "%s: Flush returned zero, but with error: %s [%d]. Ignored.\n", argv[arg], strerror(cause), cause);
        }

        result = close(descriptor);
        if (result == -1) {
            const int cause = errno;
            fprintf(stderr, "%s: Error closing device: %s [%d].\n", argv[arg], strerror(cause), cause);
            return EXIT_FAILURE;
        }

        fprintf(stderr, "%s: Flushed.\n", argv[arg]);
    }

    return EXIT_SUCCESS;
}
