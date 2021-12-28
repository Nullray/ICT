// See LICENSE for license details.

#include "simif_nf.h"
#include <cassert>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#define read_reg(r) (dev_vaddr[r])
#define write_reg(r, v) (dev_vaddr[r] = v)

simif_nf_t::simif_nf_t(int argc, char** argv) {
  int fd = open("/dev/mem", O_RDWR|O_SYNC);
  assert(fd != -1);

  int host_prot = PROT_READ | PROT_WRITE;
  int flags = MAP_SHARED;
  uintptr_t pgsize = sysconf(_SC_PAGESIZE);
  assert(dev_paddr % pgsize == 0);

  dev_vaddr = (uintptr_t*)mmap(0, pgsize, host_prot, flags, fd, dev_paddr);
  assert(dev_vaddr != MAP_FAILED);
}

void simif_nf_t::write(size_t addr, uint32_t data) {
  write_reg(addr, data);
  __sync_synchronize();
}

uint32_t simif_nf_t::read(size_t addr) {
  __sync_synchronize();
  return read_reg(addr);
}

ssize_t simif_nf_t::pull(size_t addr, char* data, size_t size) {
#ifdef SIMULATION_XSIM
  return -1; // TODO
#else
  return -1;
#endif
}

ssize_t simif_nf_t::push(size_t addr, char* data, size_t size) {
#ifdef SIMULATION_XSIM
  return -1; // TODO
#else
  return -1;
#endif
}

uint32_t simif_nf_t::is_write_ready() {
    uint64_t addr = 0x4;
#ifdef SIMULATION_XSIM
    /*uint64_t cmd = addr;
    char * buf = (char*)&cmd;
    ::write(driver_to_xsim_fd, buf, 8);

    int gotdata = 0;
    while (gotdata == 0) {
        gotdata = ::read(xsim_to_driver_fd, buf, 8);
        if (gotdata != 0 && gotdata != 8) {
            printf("ERR GOTDATA %d\n", gotdata);
        }
    }
    return *((uint64_t*)buf);*/
#else
    uint32_t value;
    //int rc = fpga_pci_peek(pci_bar_handle, addr, &value);
    //check_rc(rc, NULL);
    return 1;
#endif
}