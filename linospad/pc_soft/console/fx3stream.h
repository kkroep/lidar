#ifndef FX3STREAM_H
#define FX3STREAM_H

#include <iostream>
#include <iomanip>
#include <vector>
#include <cstdint>
#include <cstring>
using namespace std;

#include <libusb-1.0/libusb.h>

#define FX3_DEBUG 0                             //Print debug messages in addition to error messages
#define FX3_PRINT_DATA 0                        //Whether to print received data

//FX3 stream handling
#define FX3_DEFAULT_TIMEOUT 2000                //Default timeout for transfers (NUM_TRANSFERS*TRANSFER_SIZE)
#define FX3_IN_EP 0x81                          //Endpoint to receive data from
#define FX3_OUT_EP 0x01                         //Endpoint to send data to
#define FX3_NUM_TRANSFERS 32                    //Transfers to submit concurrently
#define FX3_TRANSFER_SIZE (8*1024)              //Size of transfer (FX3 buffer size, 1 burst)

//FPGA side stream handling
#define FX3_FPGA_MAX_ADR 0xff                   //Maximum module address (depends on FPGA firmware)
#define FX3_FPGA_MAX_LEN 0xffffff               //Maximum message length to FPGA module (split longer messages)
#define FX3_FPGA_HEADER(adr, length) ((uint32_t)((((adr)&0xff)<<24)|((length)&0xffffff)))

class FX3Stream {
private:
    unsigned short vid, pid;
    libusb_device_handle* devhandle;
    bool interfaceClaimed;
    int inPktSize, outPktSize;
    int error;
    
    vector<libusb_transfer*> transfers;
    vector<unsigned char*> recvBufs;
    void allocTransfers();
    void freeTransfers();

    unsigned char intBuf[FX3_TRANSFER_SIZE];
    int storedBytes, consumedBytes; //in intBuf
    unsigned char* extBuf;
    int64_t totalBytes, submittedBytes, transferredBytes; //ongoing transfer
    int shortPackets;
    
    static void printTransfer(libusb_transfer *transfer);

    static void receiveCallback( libusb_transfer* transfer );
    
    static void sendCallback( libusb_transfer* transfer );   
public:
    operator bool();
    
    FX3Stream();

    FX3Stream( unsigned short vid, unsigned short pid );
    
    ~FX3Stream();
    
    void init( unsigned short vid, unsigned short pid );
    
    void release();
    
    void clearInternalBuffer();
    
    int64_t receive( int64_t maxWords, uint32_t* data, unsigned timeout = FX3_DEFAULT_TIMEOUT, bool shortOK = false );
    
    //Byte based interface (will always transfer full words)
    int64_t receive( int64_t maxBytes, unsigned char* data, unsigned timeout = FX3_DEFAULT_TIMEOUT, bool shortOK = false );
    
    int64_t send( int64_t words, uint32_t* data, unsigned timeout = FX3_DEFAULT_TIMEOUT );
    
    //Byte based interface (will always transfer full words)
    int64_t send( int64_t bytes, unsigned char* data, unsigned timeout = FX3_DEFAULT_TIMEOUT );
    
    //Convenience function to send single word (command) to module
    void sendWord( uint8_t adr, uint32_t data, unsigned timeout = FX3_DEFAULT_TIMEOUT );
    
    //Control transfer to the FX3
    int controlTransfer( unsigned reqType, unsigned req, unsigned value, unsigned index,
        unsigned char* data, unsigned length, unsigned timeout = FX3_DEFAULT_TIMEOUT );
    
    //Reset FPGA system and clear error condition
    void reset();

    //Reinitialize USB connection
    void reinit();
};

#endif //FX3STREAM_H
