#ifndef DarkswordBridge_h
#define DarkswordBridge_h
#include <stdint.h>
#include <stddef.h>

// From darksword_main.m
int darksword_main(void);
void pe_init(void);
void pe_v1(void);
uint64_t early_kread64(uint64_t where);
void early_kreadbuf(uint64_t where, void *buf, size_t size);
void early_kwrite64(uint64_t where, uint64_t what);
extern uint64_t kernel_base;
extern uint64_t kernel_slide;

// From darksword_exploit.c
int darksword_grant_mg(const char *mg_path);

#endif
