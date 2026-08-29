// DarkswordBridge.h - wrapper exposing real symbols from external/darksword-kexploit/src/main.m
#ifndef DarkswordBridge_h
#define DarkswordBridge_h
#include <stdint.h>
#include <stddef.h>
void pe_init(void);
void pe_v1(void);
void pe_v2(void);
uint64_t early_kread64(uint64_t where);
void early_kread(uint64_t where, void *buf, size_t size);
void early_kwrite64(uint64_t where, uint64_t what);
extern uint64_t kernel_base;
extern uint64_t kernel_slide;
#endif
