# README

## Installation Instructions
* Download and install Intel Threading Building Blocks (TBB) from https://software.intel.com/en-us/intel-tbb
* Export install path under TBB_HOME
```
$ export TBB_HOME=/opt/intel/tbb/
```
* Compile the driver
```
$ make
```
* Set LD_LIBRARY_PATH
```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD:$TBB_HOME/lib/intel64_lin/gcc4.7
```
* Reserve hugepages if required.
If test data size is less than 4KB, hugepages need not be reserved.
If test data size is greater than 4KB, less than 2MB, at-least 1 2MB hugepage needs to be reserved.
```
echo 2 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
```
If test data size is greater than 2MB, less than 1GB, at-least 1 1GB hugepage needs to be set.
```
echo 2 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
```
* Execute the host application to transfer 100MB in 1MB portions from host memory to the FPGA pattern checker:
```
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TBB_HOME/lib/intel64_lin/gcc4.7 sh -c "./fpga_dma_st_test -l off -s 104857600 -p 1048576 -r mtos -t fixed"
```
* Execute the host application to transfer 100MB in 1MB portions from the FPGA pattern generator to host memory:
```
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TBB_HOME/lib/intel64_lin/gcc4.7 sh -c "./fpga_dma_st_test -l off -s 104857600 -p 1048576 -r stom -t fixed"
```
* Execute the host application to transfer 100MB in 1MB portions from host memory back to host memory in loopback mode:
```
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TBB_HOME/lib/intel64_lin/gcc4.7 sh -c "./fpga_dma_st_test -l on -s 104857600 -p 1048576 -t fixed"
```
Note: Above examples require reserving at-least two 1GB hugepages.

* Usage
```
Usage:
     fpga_dma_st_test [-h] [-B <bus>] [-D <device>] [-F <function>] [-S <segment>]
                       -l <loopback on/off> -s <data size (bytes)> -p <payload size (bytes)>
                       -r <transfer direction> -t <transfer type> [-f <decimation factor>]

         -h,--help           Print this help
         -B,--bus            Set target bus number
         -D,--device         Set target device number
         -F,--function       Set target function number
         -S,--segment        Set PCIe segment
         -l,--loopback       Loopback mode\n"
            on               Turn on channel loopback. Channels are launched from independent threads.
            off              Turn off channel loopback. Must specify channel using -r/--direction.
         -s,--data_size      Total data size
         -p,--payload_size   Payload size (per DMA transaction)
         -m,--multi_threaded Multi-threaded
            on               Operate each channel from a separate thread
            off              Operate both channels from the same thread
         -r,--direction      Transfer direction
            mtos             Memory to stream
            stom             Stream to memory
         -t,--type           Transfer type
            fixed            Deterministic length transfer
            packet           Packet transfer (uses SOP and EOP markers)
         -f,--decim_factor   Optional decimation factor
```
* Sweep payloads and profile the driver
```
$ chmod 777 ./profile
$ ./profile
-----------------------------------------------
		simplex simplex duplex  duplex
payload         mtos    stom    mtos    stom
-----------------------------------------------
128B            216     231     197     199
1.375KB         2415    2552    1842    2014
4KB             6450    6755    3668    4422
8KB             6808    6858    5142    6099
16KB            6853    6907    4845    6166
32KB            6868    6928    5459    6205
64KB            6875    6940    5301    6198
128KB           6874    6943    5572    6205
256KB           6870    6937    4858    6197
512KB           6862    6945    5606    6200
1024KB          6868    6940    5606    6206
```
* View bandwidth results in gnuplot (optional)
```
$ gnuplot -p plot.gnu
```

## Streaming DMA AFU
The streaming DMA AFU implements read-master and
write-master DMA channels.
The read-master DMA issues reads on the Avalon-MM port and
writes on the Avalon-ST port. The write-master DMA issues
reads on the Avalon-MM port and writes on the Avalon-ST port.
In the reference configuration provided, Avalon-ST port of the read
master DMA drives a pattern checker and Avalon-ST port of the 
write master DMA is driven from a pattern generator. Refer to the
Streaming DMA user guide for a detailed description of the
hardware architecture.

The reference AFU is wired in the topology shown below.
```
                            /|------> Pattern checker
Memory to Stream DMA ----> | |
                            \|----
                                 |
                                Decimator
                                 |
                            /|<--- 
Stream to Memory DMA <---- | |
                            \|<----- Pattern generator


```
The loopback between memory to stream and stream to memory
channels can be turned on/off from the test application
by setting the -l/--loopback flag to on/off. When
the loopback is turned on, traffic runs through 
a decimator between the channels. This module 
recieves a stream of data and removes a 
programmable number of beats before forwarding the data.
The number of beats to remove is called the decimation factor so
a value of 0 means no removal, 1 means every
other beat is removed, 2 means one beat out of three is removed, etc....
The module *always* forwards beats with SOP 
or EOP set so that packet boundaries do notice
get filtered out. Decimation factor can be specified
using -f/--decim_factor flag. Default is 0 (all traffic
is forwarded).

Note: For this release, we recommend testing with decimation factor = 1
and integral multiples of 2 for data size in loopback mode.

## Software Driver Use Model

### Streams, Packets and Buffers
The application transmits or recieves streams of packetized data
from a streaming port. A *stream* is a series of packets. 
A packet consists of one or more *buffers*. The beginning and end of a packet 
is specified using markers on the first and last buffer.

The DMA driver exposes APIs for transferring *buffers*.
A buffer is a physically contiguous region of memory where
the DMA engine can transfer data. This means that the maximum
size amount of data that can be 
transferred using a buffer (referred to as *payload*)
is either a page (4KB) or a hugepage (2MB or 1GB).
If the application wishes to transfer more data, it must
do so using a series of buffers. The DMA engine can support
a maximum payload of 1GB. The buffer must be
pinned (page-locked) in host memory. 
Application may allocate or pin a buffer
using fpgaPrepareBuffer().

### Describing a DMA Transfer
Application uses a *DMA transfer atttribute object* to describe a data transfer
from/into the buffer. The DMA transfer attribute describes 
physical address of the buffer where the application data is located,
direction of DMA transfer, packet markers (if any) and application
notification callback on completion of buffer transfer.
Application creates a DMA transfer object using fpgaDMATransferInit()
and sets transfer attributes using fpgaDMATransferSet\*() APIs.
Application submits a buffer for DMA transfer using
fpgaDMATransfer(). Once fpgaDMATransfer() returns, 
the transfer attribute object may be reused for issuing subsequent transfers.
The transfer attribute object is destroyed using fpgaDMATransferDestroy().

The driver supports synchronous (blocking) and asynchronous
(non-blocking) transfers. Asynchronous transfers
return immediately to the caller. Application is notified using
a callback mechanism. The callback informs
the actual number of bytes transferred and whether an 
*end of packet* marker was signaled by hardware. 
Synchronous transfers return to 
the application after the DMA transfer is complete. 
Application queries actual number of transferred bytes
and end of packet marker for the buffer using fpgaDMAGet\*() APIs.
If no callback was specified in the DMA transfer 
attribute object, a synchronous transfer is inferred.

### Deterministic and Non-deterministic Transfers
The driver supports deterministic and non-determinstic
length transfers. In deterministic length transfers, the application
exactly knows the total number of bytes that will be transferred. 
The application calculates the exact number of buffers required
to perform the transfer and provides them to the driver.
In other applications however, the amount of data recieved
from the accelerator cannot be predetermined. In this scenario,
the application may constantly send empty buffers, which will be filled
by the accelerator. For each buffer written to host memory,
the driver notifies the actual number of bytes transferred
and *end of packet* status. The application may accumulate
bytes transferred in each buffer to obtain the total number of 
bytes transferred.

Normally, the application sends a never ending stream of
packets. When the packet ends early, leftover empty buffers
that remain in the driver are used for the following
packet. However, if the application wishes to discard any
pending buffers, the driver provides a mechanism. See 
fpgaDMAInvalidate() in fpga_dma.h.

### Transfer Ordering
The driver processes DMA transfers issued on a channel in the issue order.
It does not offer any ordering guarantee on transfers issued across 
independent channels.

### DMA Channel Discovery
Each master appears to the software application as a DMA channel.
The application enumerates total available channels in the AFU using
fpgaCountDMAChannels(). The desired channel referenced by its
index (starting at index 0) must be opened using fpgaDMAOpen() 
before use. The application may query the channel type (
memory to stream/TX or stream to memory/RX) using 
fpgaGetDMAChannelType(). The application closes a
channel using fpgaDMAClose().
Every channel can be independently opened and operated upon.

### Thread Safety
Operations on DMA transfer attribute object are guaranteed to be thread-safe.

## Examples

The first example demonstrates channel enumeration, open and close.
Error checking has been omitted for brevity.

```
fpga_dma_handle_t dma_h;

// Enumerate DMA handles
uint64_t ch_count;
fpgaCountDMAChannels(afc_h, &ch_count);
	
// open a DMA channel
fpga_dma_handle_t dma_h;
fpgaDMAOpen(afc_h, 0 /*channel index*/, &dma_h);

// Query channel type (TX/RX)
fpga_dma_channel_type_t ch_type;
fpgaGetDMAChannelType(dma_h, &ch_type);

fpgaDMAClose(dma_h);
```

The second example shows a simple non-blocking deterministic-length memory-to-stream transfer for a 4KB buffer.

```
// callback
void transferCompleteCb(void *ctx, fpga_dma_transfer_status_t status) {
	cout << "eop arrived = " << status.eop_arrived << endl;
	cout << "bytes transferred = " << status.bytes_transferred << endl;	
}

void *buf_va;
uint64_t buf_size = 4*1024; //bytes
uint64_t buf_wsid;
uint64_t buf_ioa;

// allocate and pin buffer
fpgaPrepareBuffer(afc_h, buf_size, (void **)&buf_va, &buf_wsid, 0);

// obtain buffer physical address
fpgaGetIOAddress(afc_h, buf_wsid, &buf_ioa /* physical address */);

// create a transfer attribute object
fpga_dma_transfer_t transfer;
fpgaDMATransferInit(&transfer);

// set transfer attributes
fpgaDMATransferSetSrc(transfer, buf_ioa /* buffer address must be physical address */);
fpgaDMATransferSetDst(transfer, (uint64_t)0); //dst address is don't care for memory to stream transfers
fpgaDMATransferSetLen(transfer, buf_size);
fpgaDMATransferSetTransferType(transfer, HOST_MM_TO_FPGA_ST);
fpgaDMATransferSetRxControl(transfer, RX_NO_PACKET);
fpgaDMATransferSetLast(transfer, true); // mark this buffer as final in this packet
fpgaDMATransferSetTransferCallback(transfer, transferCompleteCb, NULL /* context */);
fpgaDMATransfer(dma_h, transfer);

// destroy transfer
fpgaDMATransferDestroy(&transfer);
```
The third example demonstrates a non-deterministic-length stream-to-memory transfer.
Accelerator signals end of packet on the third buffer. Application discards remaining
buffers.

```
static uint64_t total_bytes = 0;
// callback
void transferCompleteCb(void *ctx, fpga_dma_transfer_status_t status) {
	fpga_dma_handle_t dma_h = (fpga_dma_handle_t*)ctx;

	total_bytes += status.bytes_transferred;
	if (status.eop_arrived) {
		// invalidate leftover buffers
		fpgaDMAInvalidate(dma_h);
	}	
}

#define MAX_BUFS 10
// create a transfer attribute object
fpga_dma_transfer_t transfer;

for(int i = 0; i < MAX_BUFS; i++) {
	fpgaDMATransferInit(&transfer);

	// set transfer attributes
	fpgaDMATransferSetSrc(transfer, (uint64_t)0); //src address is don't care for stream to memory transfers
	fpgaDMATransferSetDst(transfer, buf_ioa /* buffer address must be physical address */);
	fpgaDMATransferSetLen(transfer, buf_size);
	fpgaDMATransferSetTransferType(transfer, FPGA_ST_TO_HOST_MM);
	fpgaDMATransferSetRxControl(transfer, END_ON_EOP);
	if(i == MAX_BUFS - 1)
		fpgaDMATransferSetLast(transfer, true); // mark this buffer as final in this packet
	else 
		fpgaDMATransferSetLast(transfer, false);
	fpgaDMATransferSetTransferCallback(transfer, transferCompleteCb, dma_h /* context */);
	fpgaDMATransfer(dma_h, transfer);
}
fpgaDMATransferDestroy(&transfer);

```

## DMA Hardware Architecture
The streaming DMA AFU uses a prefetcher frontend and modular
scatter gather DMA IP core to facilitate data movement.
The purpose of the DCP mSGDMA frontend is to move control/status data movements
from being host driven to shared memory between the host and DMA hardware.
Host processors are not efficient at rapidly accessing control/status registers
 across a high latency link like PCIe so this optimization will allow the host 
 to simply access its own memory to control the DMA engine.  By offloading the 
control plane into hardware, the host will be able to request smaller 
DMA transfers without impacting performance.

The descriptor format is 512-bit so that each descriptor operation is 1CL in length. 
The following table shows the format of the descriptor.

Table: Descriptor format:

| Address | Offset 7              | Offset 6          | Offset 5          | Offset 4   | Offset 3                       | Offset 2        | Offset 1               | Offset 0    |
|---------|-----------------------|-------------------|-------------------|------------|--------------------------------|-----------------|------------------------|-------------|
| 0x0     |                          Control[31:0]                                     | N/A                            | Owned by HW     | Block Size[7:0]        | Format[7:0] |
| 0x8     |                                                                       Source[63:0]                                                                                   | 
| 0x10    |                                                                     Destination[63:0]                                                                                | 
| 0x18    | N/A                   | N/A               | N/A               | N/A        |                                          Length[31:0]                                   |
| 0x20    |                Write Stride[15:0]         |           Read Stride[15:0]    | Write Burst[7:0]               | Read Burst[7:0] |              Sequence Number [15:0]  |
| 0x28    | N/A                   | Early Termination | EOP Arrived       | Error[7:0] |                              Actual Bytes Transferred[31:0]                             |
| 0x30    | N/A                   | N/A               | N/A               | N/A        | N/A                            | N/A             | N/A                    | N/A         |
| 0x38    |                                                                   Next Descriptor[63:0]                                                                              |


Using the new descriptor format, chains are formed across descriptor blocks. 
Within each descriptor block is one or more descriptors. 
The first descriptor in the descriptor block must define the 
block size field and set the format field accordingly. 
The block size field is stored by subtracting 1, so for example 
if there are 6 descriptors in the block, then the first descriptor 
in the block must set the block size to 5.  Other descriptors in the 
block will have their block size field ignored by the hardware.

The format field is encoded with bit offset 0 representing 
the first descriptor in the block and bit offset 1 representing 
the last descriptor in the block.  Software is required to set 
format to 2’b01 in the first descriptor and 2’b10 last descriptor 
of the block.  In the event the block is only one descriptor in size, 
software sets the format to 2’b11.  All other descriptors within the 
block have the format field set to 2’b00.
The first descriptor in a block sets the next descriptor 
field to the beginning of the next block.  The fetch unit will ignore 
this field for all other descriptors in the block except the first block. 

Since descriptors are placed in shared memory and 
accessed by both the host driver and hardware, 
ownership is set within the descriptors.  When the fetch 
engine loads a new descriptor block (set by next descriptor 
field of the first descriptor in the previous block) the 
descriptor is inspected to ensure that the owned by hardware bit is set. 
When this bit is set the DMA owns the descriptor, otherwise the hardware 
assumes it has hit the end of the descriptor chain.  At this point the 
fetch engine either stops fetching waiting for the host driver to instruct 
the fetch engine of a new block location to read from, or optionally enters 
a timeout loop retrying to fetch the same descriptor using a pre-programmed 
timeout period. 

When the DMA engine completes transfers the descriptor 
is written back by the store engine which writes back transfer response 
information and sets the owned by hardware bit to 0 (i.e. owned by software). 
When the host sees the owned by hardware bit set to 0 it then knows it is 
safe for the user application to either consume the data contained in the 
destination buffer or reuse the source buffer for another transfer. 

The current implementation uses a 4CL fetch (256B) and 1CL store (64B) transfer size. 
To optimize efficiency software ensures that descriptor blocks start on 256-byte boundaries.
The hardware can tolerate down to 64-byte alignment but no less than that.
The descriptor store engine only supports 1CL sized store operations which 
from a bus efficiency perspective is less optimal than 4CL, but it also reduces 
the turnaround time of a transfer as seen by software. 

Since the DMA is primarily controlled through shared memory, 
the need to access the control and status port isrelatively infrequent. 
But the fetch engine must be informed where it needs to find the first 
descriptor block in memory and provide a means for the driver to clear interrupts. 
The following table shows the memory map of the 64-bit control and status slave port.

Control and status registers are described below.

| Byte Offset | Access | Register               | Description                                                                                                                                                                                                         |
|-------------|--------|------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0x0         | R/W    | Control                | Various control bits, see bitfields below                                                                                                                                                                           |
| 0x8         | R/W    | Set Start Location     | 64-bit address that the fetch engine reads from.  Set this before enabling the fetch engine or write to it when fetch engine is idle and the timeout polling feature is disabled to start the fetch engine back up. |
| 0x10        | R      | Current Fetch Location | Current location the fetch engine is reading a descriptor from.  If the fetch engine is sitting idle, then this value represents the last location descriptor location that was read.                               |
| 0x18        | R      | Current Store Location | Current location the store engine is writing a descriptor to.  If the store engine is waiting for a new descriptor writeback request, then this value represents the last location that was stored to.              |
| 0x20        | R/Wclr | Status                 | Various status bits, see bitfields below                                                                                                                                                                            |
| 0x28        | R      | FIFO Fill Levels       | Fill levels of the three internal FIFOs inside the fetch and store engines.  See bitfields below.                                                                                                                   |
| 0x30        | N/A    | N/A                    | Reads will return the status value, writes have no effect.                                                                                                                                                          |
| 0x38        | N/A    | N/A                    | Reads will return the status value, writes have no effect.                                                                                                                                                          |

Control register are described below.

| Bit Offset | Access | Field          | Description                                                                                                                                                                                                                                                                                                                                                      |
|------------|--------|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0          | R/W    | Enable         | When set the fetch engine will load descriptors from memory and store the overwrite completed descriptors when the transfer is complete.  You must ensure a value start location is set (byte offset 8 in previous table) before setting this bit.  The default value after reset is 0.                                                                          |
| 1          | R/W    | Flush          | Used to flush descriptors previously buffered by this IP.  Before flushing you must disable this IP (bit offset 0 above) and wait for the outstanding descriptor fetches status bit to be set to 0 before deasserting the flush bit.  The driver can disable the engine and enable the flush at the same time.  The default value after reset is 0.              |
| 2          | R/W    | IRQ Mask       | When the interrupt interface is exposed in hardware this bit will mask the interrupt output.  This mask only applies to the output so if the driver enables this bit there is a possibility that past interrupt events will still be captured, and the driver will need to resolve those (clear the interrupt most likely).  The default value after reset is 0. |
| 3          | R/W    | Timeout Enable | This bit controls whether the fetch engine periodically polls host memory for new descriptors or if it simply stops.  When set the Timeout field is used to determine how often the fetch engine checks host memory for newly added descriptor groups.  The default value after reset is 0.                                                                      |
| 15-4       | N/A    | N/A            | Reading will return zeros, writes have no effect                                                                                                                                                                                                                                                                                                                 |
| 31-16      | R/W    | Timeout        | Timeout value in clock ticks -1.  The default value after reset is 0xFF which maps to 256 clock ticks before the fetch engine attempts to reattempt a descriptor fetch.  This feature is only used when Timeout Enable is set to 1.                                                                                                                              |
| 63-32      | N/A    | N/A            | Reading will return zeros, writes have no effect                                                                                                                                                                                                                                                                                                                 |

Status register is described below.

| Bit Offset | Access | Field                          | Description                                                                                                                                                                                                                                                                                                                                    |
|------------|--------|--------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0          | R/Wclr | IRQ                            | When set there is an unmasked interrupt being asserted by this frontend block.  Writing a 1 to this bit will clear the interrupt.                                                                                                                                                                                                              |
| 1          | R      | Fetch Idle                     | Set when the fetch engine is disabled or if the fetch engine reaches the end of the descriptor chain and the Timeout Enable field of the control register is 0.                                                                                                                                                                                |
| 15-2       | N/A    | N/A                            | Reading will return zeros, writes have no effect                                                                                                                                                                                                                                                                                               |
| 31-16      | R      | Outstanding Descriptor Fetches | This value represents how many descriptors the fetch engine has read that have not returned.  As the fetch engine issues reads this value increases, when the reads return it decreases.  Since the fetch engine fetches four descriptors at a time and discards invalid descriptors this counter increases by 4 and decreases by 1 at a time. |
| 63-32      | N/A    | N/A                            | Reading will return zeros, writes have no effect                                                                                                                                                                                                                                                                                               |

Fifo levels are described below.

| Bit Offset | Access | Field                      | Description                                                                                                                                                                                                                                                                                                                                                                                                            |
|------------|--------|----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 15-0       | R      | Fetch Descriptor Watermark | Number of descriptors sitting in the fetch descriptor buffer that have not been sent to the DMA dispatcher.  If you set the Flush control bit this value will automatically return to 0.                                                                                                                                                                                                                               |
| 31-16      | R      | Store Descriptor Watermark | Number of descriptors sitting in the store descriptor buffer.  These as descriptors that were previously buffered in the fetch buffer but have been sent to the DMA dispatcher but have not been written back to host memory.  Each descriptor in this buffer is paired with a response and written to host memory simultaneous (merged).  If you set the Flush control bit this value will automatically return to 0. |
| 47-32      | R      | Store Response Watermark   | Number of responses sitting in the store response buffer that have not been written back to host memory yet.  Each response in this buffer is paired with a descriptor and written to host memory simultaneously (merged).  If you set the Flush control bit this value will automatically return to 0.                                                                                                                |
| 63-48      | N/A    | N/A                        | Reading will return zeros, writes have no effect                                                                                                                                                                                                                                                                                                                                                                       |

Interrupts are an optional feature of this IP block 
and are set any time the DMA completes a transfer and
 any of the interrupt masks for that transfer allow an
 interrupt to be generated. 
The interrupt generation mechanism is 
the same as the previous DMA implementation 
except that the interrupt information is passed 
to this frontend block so that interrupts are issued 
when the descriptor writeback occurs and not when the event 
occurred in the dispatcher block. This makes sure the host is 
interrupted when the descriptor writeback occurs and not earlier than that.

Since this frontend module will not monitor write responses, 
the driver will need to ensure this race condition is taken care of. 
Since descriptors are written back to host memory after transfer completion, 
the driver simply walks the descriptor chain and synchronization can be 
performed by inspecting the owned by hardware bits. 
As a result, it should be safe to combine all the interrupts 
from all DMA channels using a logical OR and using that to the 
schedule descriptor chain walks. Alternatively, since synchronization 
information is already being sent to the host memory when the descriptor 
writeback occurs, the driver may be able to omit interrupts completely 
and just go to sleep when it reaches the end of the completed descriptor chain.

### DMA Driver Internal Architecture
The DMA driver implements several data structures to manage
transactions. Each channel implements an independent copy of 
these data structures. Some of the most important ones are highlighted here.
Refer fpga_dma_st_internal.h for additional details.

The dma channel is represented by a handle `(struct fpga_dma_handle)`.
The handle book-keeps metadata associated with the channel
such as memory-mapped addresses of DMA CSRs, descriptor, prefetcher
frontend control and status registers, channel type etc.
The handle also tracks metadata associated with the list of blocks
in `msgdma_block_mem_t *block_mem`. 

Each block consists of
one or more descriptors. Since the block must be 
accessed from hardware, it must be allocated using a pinned
buffer that maps to a page or a hugepage. The maximum number of descriptors within a
block is a compile-time parameter in Makefile (`FPGA_DMA_BLOCK_SIZE`).
The metadata for a block consists of 
the virtual address (`block_va`), workspace ID (`block_wsid`)
and physical address (`block_iova`) of the pinned buffer.

One of the key design goals of this architecture is to amortize
the cost of a descriptor fetch over PCIe
by grouping descriptor reads together. 
Group size is configurable using the compile parameter (`BLOCK_SIZE`) in Makefile.
DMA fetches the block only when the block is fully populated. 
However, if the application is latency-sensitive,
it may instruct the driver to flush the block sooner
by marking the transfer as the last transfer
in the packet (see fpgaDMASetLast in fpga_dma.h).

Each channel has a set of software queues to 
manage transactions in flight.

* `ingress_queue`: Stores transfers submitted from application on this channel.
* `pending_queue`: Stores transfers pending hardware completion on the channel.
* `free_desc`: Pool of hardware descriptors available to software, in first-in first-out order.
 The driver assigns a transfer to a free descriptor from this pool.
* `invalid_desc_queue`: List of unused descriptors within a block.
The reason for using this queue will be explained later.

All queues are thread-safe data structures implemented using
 concurrent_bounded_queue from Intel TBB library.

The hardware descriptor is represented using
`struct msgdma_hw_desc_t`. Contents of this struct are
directly accessible from hardware, and follows `Table: Descriptor format`
described above.
The driver also book-keeps a pointer to the hardware
descriptor in `struct msgdma_hw_descp`, which is useful to
manage free descriptors, in addition to tracking debug
information such as the block number associated with the descriptor
and its index within that block.

The driver also uses an internal data structure called
a software descriptor (`struct msgdma_sw_desc`) to associate
the transfer submitted from application (`struct fpga_dma_transfer`) with a
free hardware descriptor (`msgdma_hw_descp_t *hw_descp`), track it's progress etc.

The lifecycle of a transfer is described below.
* Application submits a DMA transfer object on a DMA handle.
* The driver creates an internal software descriptor (`init_sw_desc`), copies transfer attributes such as src, dst and len from the
transfer object to internal copy within the software descriptor, initializes a semaphore (`sw_desc->tf_status`) in `TRANSFER_PENDING`
state (locked).
* The driver pushes the software descriptor to `ingress_queue`. The software descriptor is processed later in worker thread.
* For a non blocking transfer, the driver returns immediately.
* For a blocking transfer, the driver waits until the semaphore is unlocked from worker thread.
* The worker thread `dispatcherWorker` pops software descriptor from `ingress_queue`.
* `dispatcherWorker` retrieves a pointer to an available hardware descriptor by popping from the free pool (`free_desc`).
* `dispatcherWorker` assigns the free hardware descriptor to the software descriptor (see `assign_hw_desc`). Assignment
means that transfer attributes (src, dst, len etc) are populated on the next available hardware descriptor
within that block. The `owned_by_hw` bit of each descriptor, except the first one in the block, is set. 
For the first descriptor, `owned_by_hw` bit is set only when one of the following
conditions are met:
   * The block is full OR
   * The transfer was marked as the last transfer using fpgaDmaSetLast (i.e. the application indicated immediate dispatch of a partially full block).
* All valid descriptors (i.e. descriptors with owned_by_hw set) are pushed to `pending_queue` where they await completion from the DMA engine.
* Unused hardware descriptors (i.e. descriptors with owned_by_hw set reset in a partially full block) are removed from the free pool, 
then pushed to `invalid_desc_queue`. This is done to prevent assignment of unused descriptors remaining in a partial full block
to subsequent transfers. The DMA hardware, by design, can only process descriptors from the beginning of a block. Therefore, any unused
descriptors leftover from the middle of a block cannot be assigned to subsequent transfers submitted from application layer.
* A second worker thread `completionWorker` polls `owned_by_hw` bit of pending software descriptors from the front of `pending_queue`.
* Once the DMA marks a hardware descriptor complete, it is returned to free pool. Unused descriptors from `invalid_desc_queue` are returned to free pool
if the block was partially full.
This ensures that the ordering of free hardware descriptors in free descriptor queue (`free_desc_queue`) is always preserved.
* Callback on the transfer is invoked. 
* Finally semaphore `sw_desc->tf_status` is released signaling completion to the application.

## ASE Simulation
ASE simulation is supported.
