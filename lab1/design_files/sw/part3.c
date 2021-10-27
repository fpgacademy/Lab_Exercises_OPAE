// Copyright(c) 2017, Intel Corporation
//
// Redistribution  and  use  in source  and  binary  forms,  with  or  without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of  source code  must retain the  above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name  of Intel Corporation  nor the names of its contributors
//   may be used to  endorse or promote  products derived  from this  software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
// IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMEdesc.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
// LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#include <stdio.h>
#include <opae/mmio.h>

// Application Logic register addresses (offsets)
#define POLY_REG    0X10 << 2
#define LFSR_REG    0X12 << 2
#define CTRL_REG    0X14 << 2

int open_AFU (fpga_handle *);
void close_AFU (fpga_handle);

int main(int argc, char *argv[])
{
    fpga_handle handle = NULL;
    if (open_AFU (&handle) < 0)
        return -1;

    uint32_t data;
    (void) fpgaWriteMMIO32 (handle, 0, POLY_REG, 221);   // set polynomial
    (void) fpgaReadMMIO32 (handle, 0, POLY_REG, &data);  // set seed
    printf ("Polynomial set to: %d\n", data);
    
    (void) fpgaWriteMMIO32 (handle, 0, LFSR_REG, 0x1);
    (void) fpgaReadMMIO32 (handle, 0, LFSR_REG, &data);
    printf ("Seed set to: %d\n", data);

    bool found[256] = { false };
    bool stop = false;
    int length = 0;
    while (!stop) {
        if (found[data]) stop = true;
        else {
            ++length;
            found[data] = true;

            // get a new random integer from the LFSR // 
            (void) fpgaWriteMMIO32 (handle, 0, CTRL_REG, 0x1);  // step
            (void) fpgaWriteMMIO32 (handle, 0, CTRL_REG, 0x0);  // stop
            (void) fpgaReadMMIO32 (handle, 0, LFSR_REG, &data);
            printf ("LFSR: %d\n", data);
        }
    }
    printf("\nLength of random sequence: %d\n", length);

    close_AFU (handle);
    return 0;
}
