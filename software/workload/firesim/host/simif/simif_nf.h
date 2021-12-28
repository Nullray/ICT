// See LICENSE for license details.

#ifndef __SIMIF_NF_H
#define __SIMIF_NF_H

#include "simif.h"

class simif_nf_t: public virtual simif_t
{
  public:
    simif_nf_t(int argc, char** argv);
    virtual ~simif_nf_t() { }
    virtual ssize_t pull(size_t addr, char* data, size_t size);
    virtual ssize_t push(size_t addr, char* data, size_t size);
    uint32_t is_write_ready();
  private:
    volatile uintptr_t* dev_vaddr;
    const static uintptr_t dev_paddr = 0x43C00000; 
    char in_buf[CTRL_BEAT_BYTES];
    char out_buf[CTRL_BEAT_BYTES];
  protected:
    virtual void write(size_t addr, uint32_t data);
    virtual uint32_t read(size_t addr);
    virtual size_t pread(size_t addr, char* data, size_t size) {
      // Not supported
      return 0;
    }
};

#endif // __SIMIF_NF_H
