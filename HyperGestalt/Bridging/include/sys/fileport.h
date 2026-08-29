#ifndef _SYS_FILEPORT_H_
#define _SYS_FILEPORT_H_
#include <mach/mach.h>
typedef mach_port_t fileport_t;
kern_return_t fileport_makeport(int fd, mach_port_t *portname);
int fileport_makefd(mach_port_t portname);
#endif
