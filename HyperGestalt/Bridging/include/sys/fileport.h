#ifndef _SYS_FILEPORT_H_
#define _SYS_FILEPORT_H_
#include <sys/cdefs.h>
#include <sys/types.h>
#include <mach/mach.h>
__BEGIN_DECLS
kern_return_t fileport_makeport(int fd, mach_port_t *portname);
int fileport_makefd(mach_port_t portname);
__END_DECLS
#endif
