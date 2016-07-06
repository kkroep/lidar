#include <iostream>
#include <cstdlib>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <ctime>
#include <cstring>
using namespace std;

#include "ccframework.h"
#include "fx3stream.h"
#include "fx3utils.h"

static FX3Stream fx3;

static unsigned char recvdata[20480];
static unsigned char senddata[20480];

void fun0() {
    unsigned id;
    if ( 4 != fx3.controlTransfer(0xC0, FX3_GET_FIRMWARE_TIMESTAMP, 0, 0, (unsigned char*)&id, 4) ) {
        cout << "Error receiving data" << endl;
        return;
    }
    cout << "FX3 timestamp: " << hex << id << dec << endl;
}

void fun1() {
    fx3.sendWord( 15, 0x00000000 );
    unsigned id;
    if( 4 != fx3.receive(4, (unsigned char*)&id) ) {
        cout << "Error receiving data" << endl;
        return;
    }
    cout << "FPGA timestamp: " << hex << id << dec << endl;
}

void fun2() {
    unsigned char buf[3];
    if ( 3 != fx3.controlTransfer(0xC0, FX3_READ_FLASH_ID, 0, 0, buf, 3) ) {
        cout << "Error receiving data" << endl;
        return;
    }
    cout << "FX3 flash id: ";
    cout << setw(2) << setfill('0') << hex << (unsigned)buf[0] << dec;
    cout << setw(2) << hex << (unsigned)buf[1] << dec;
    cout << setw(2) << hex << (unsigned)buf[2] << dec;
    cout << setfill(' ') << endl;
}

void fun3() {
    unsigned char buf[4];
    fx3.sendWord( 13, (7<<8)|1 ); //enable with clockdiv = 1 (25MHz)
    fx3.sendWord( 13, 0x10000000|(1<<12)|0 ); //write 1 byte, read 0 bytes
    fx3.sendWord( 13, 0x9F ); //Read ID command
    fx3.sendWord( 13, 0x10000000|(1<<12)|0 ); //write 1 byte, read 0 bytes
    fx3.sendWord( 13, 0x9F ); //Read ID command
    fx3.sendWord( 13, 0x10000000|(1<<12)|4 ); //write 1 byte, read 4 bytes
    fx3.sendWord( 13, 0x9F ); //Read ID command
    if( 4 != fx3.receive(4,buf) ) {
        cout << "Error receiving data" << endl;
        return;
    }
    cout << "FPGA flash id: ";
    cout << setw(2) << setfill('0') << hex << (unsigned)buf[0] << dec;
    cout << setw(2) << hex << (unsigned)buf[1] << dec;
    cout << setw(2) << hex << (unsigned)buf[2] << dec;
    cout << setfill(' ') << endl;
}

void fun4() {
    fx3.controlTransfer( 0x40, FX3_REBOOT_TO_BOOTLOADER, 0, 0, 0, 0 );
}

void fun5() {
    Gtk::FileChooserDialog dlg(ControlCenter::getInstance(), "Select image file");
    dlg.add_button(Gtk::Stock::CANCEL, Gtk::RESPONSE_CANCEL);
    dlg.add_button(Gtk::Stock::OK, Gtk::RESPONSE_OK);
    int result = dlg.run();
    if( result != Gtk::RESPONSE_OK ) {
        return;
    }
    string filename = dlg.get_filename();
    
    unsigned char *fwBuf;
    int r;

    fwBuf = (unsigned char *)calloc (1, FX3_MAX_FWIMG_SIZE);
    if ( fwBuf == 0 ) {
        printf("Failed to allocate buffer to store firmware binary\n");
        return;
    }
    
    // Read the firmware image into the local RAM buffer.
    unsigned int filesize;
    r = fx3_read_firmware_image(filename.c_str(), fwBuf, &filesize);
    if ( r != 0 ) {
        printf("Failed to read firmware file %s\n", filename.c_str());
        free(fwBuf);
        return;
    }
    
    fx3_download( fx3, fwBuf, filesize );
    
    free(fwBuf);
    return;
}

void fun6() {
    Gtk::FileChooserDialog dlg(ControlCenter::getInstance(), "Select image file");
    dlg.add_button(Gtk::Stock::CANCEL, Gtk::RESPONSE_CANCEL);
    dlg.add_button(Gtk::Stock::OK, Gtk::RESPONSE_OK);
    int result = dlg.run();
    if( result != Gtk::RESPONSE_OK ) {
        return;
    }
    string filename = dlg.get_filename();
    
    // Allocate memory for holding the firmware binary.
    unsigned char* fwBuf = (unsigned char *)calloc (1, FX3_MAX_FWIMG_SIZE);
    if ( fwBuf == 0 ) {
        printf("Failed to allocate buffer to store firmware binary\n");
        return;
    }
    
    unsigned int filesize;
    if ( fx3_read_firmware_image(filename.c_str(), fwBuf, &filesize) ) {
        printf("File %s does not contain valid FX3 firmware image\n", filename.c_str());
        free(fwBuf);
        return;
    }

    filesize = ((filesize+FX3_SPI_PAGE_SIZE-1)/FX3_SPI_PAGE_SIZE) * FX3_SPI_PAGE_SIZE;

    // Erase as many SPI sectors as are required to hold the firmware binary.
    for( unsigned int i = 0; i < ((filesize + FX3_SPI_SECTOR_SIZE - 1) / FX3_SPI_SECTOR_SIZE); i++ ) {
        int r = fx3_spi_erase_sector(fx3, i);
        if (r != 0) {
            printf("Failed to erase SPI flash\n");
            free(fwBuf);
            return;
        }
    }

    int r = fx3_spi_write(fx3, fwBuf, filesize);
    if (r != 0) {
        printf("SPI write failed\n");
    } else {
        printf("Completed writing into SPI FLASH\n");
    }

    free(fwBuf);
}

void fun7() {
    fx3.controlTransfer( 0x40, FX3_REBOOT_FX3, 0, 0, 0, 0 );
}

//Sink then source 1GB of data
void fun8() {
    const libusb_version* v = libusb_get_version();
    cout << "libusb version: " << v->major << '.' << v->minor << '.' << v->micro << '.' << v->nano << endl;
    
    int64_t received;
    unsigned numWords = 1024*1024*1024/4;
    uint32_t* buffer = new uint32_t[numWords+numWords/FX3_FPGA_MAX_LEN+2];
    if( !buffer ) {
        cout << "Error allocating memory." << endl;
        return;
    }
    
    fun10();
    
    buffer[0] = FX3_FPGA_HEADER(0xC,numWords+1>FX3_FPGA_MAX_LEN?FX3_FPGA_MAX_LEN:numWords+1);
    buffer[1] = numWords-1;
    for( unsigned word = 0, i = 2; i < numWords+numWords/FX3_FPGA_MAX_LEN+2; ++i ) {
        if( !(i&FX3_FPGA_MAX_LEN) ) {
            buffer[i] = FX3_FPGA_HEADER(0xC,numWords-word>FX3_FPGA_MAX_LEN?FX3_FPGA_MAX_LEN:numWords-word);
        }
        else {
            buffer[i] = word;
            word += 1;
        }
    }
    
    fx3.sendWord(0xC, 0x30000000); //reset counts
    fx3.sendWord(0xC, 0x80000000); //sink data
    
    fx3.send( numWords+numWords/FX3_FPGA_MAX_LEN+2, buffer );
    
    fx3.sendWord(0xC, 0x00000000);
    fx3.sendWord(0xC, 0x10000000);
    fx3.sendWord(0xC, 0x20000000);
    received = fx3.receive(3,buffer);
    if( received != 3 ) { cout << "Error getting statistics, only " << received*4 << " bytes received." << endl; }
    cout << "Sink error count: " << buffer[0] << ", First error at: " << buffer[1] << endl;
    cout << "Num cycles: " << buffer[2] << ", " << buffer[2]/100000000.0 << " seconds at 100MHz." << endl;

    fun11();
    
    fx3.sendWord(0xC, 0x30000000); //reset counts
    fx3.sendWord(0xC, 0x80000001); //source data

    numWords -= 1;
    fx3.sendWord(0xC, numWords);
    numWords += 1;
    received = fx3.receive(numWords, buffer);
    cout << "Expected " << numWords*4 << " bytes, received " << received*4 << " bytes." << endl;
    for( unsigned i = 0; i < numWords; ++i ) {
        if( buffer[i] != i-1 ) {
            cout << "First error at " << i << endl;
            break;
        }
    }

    fx3.sendWord(0xC, 0x20000000);
    received = fx3.receive(1,buffer);
    if( received != 1 ) { cout << "Error getting statistics." << endl; }
    cout << "Num cycles: " << buffer[0] << ", " << buffer[0]/100000000.0 << " seconds at 100MHz." << endl;
    
    fun11();
    fun10();
    
    delete[] buffer;
}

void fun9() {
    unsigned counts[3];
    fx3.controlTransfer( 0xC0, FX3_GET_TRANSFER_COUNTS, 0, 0, (unsigned char*)counts, 12 );
    cout << "EP0: " << counts[2] << endl;
    cout << "TX: " << counts[1] << ", RX: " << counts[0] << endl;
    fx3.controlTransfer( 0xC0, FX3_RESET_TRANSFER_COUNTS, 0, 0, 0, 0 );
}

void fun10() {
    unsigned char buffer[4];
    if( fx3.controlTransfer( 0xC0, FX3_GET_RESET_USB_ERROR_COUNT, 0, 0, buffer, 4 ) == 4 ) {
        cout << "Phy/link error counts: ";
        for( unsigned i = 0; i < 2; ++i ) {
            cout << setw(5) << (unsigned)((unsigned short*)buffer)[i] << ", ";
        }
        cout << endl;
    }
    else {
        cout << "Error getting phy/link info." << endl;
    }
}

void fun11() {
    const char* desc[] = {
        "wr_overrun: ",
        "rd_underrun: ",
        "direction: ",
        "inactive: ",
        "adap_overrun: ",
        "adap_underrun: ",
        "rd_force_end: ",
        "rd_burst_count: ",
        "other, total: ",
        "gpif_data_ read, write: ",
        "gpif_addr_ read, write: ",
        "gpif_invalid: ",
        "gpif_other: ",
        "gpif_total: ",
        "unlock_dll: ",
        "total: "
    };
    unsigned char buffer[43];
    if( fx3.controlTransfer( 0xC0, FX3_GET_PIB_DEBUG_INFO, 0, 0, buffer, 43 ) == 43 ) {
        cout << "PIB info: ";
        for( unsigned i = 0; i < 32; i+=4 ) {
            cout << desc[i/4];
            cout << setw(3) << (unsigned)((unsigned char*)buffer)[i] << ", ";
            cout << setw(3) << (unsigned)((unsigned char*)buffer)[i+1] << ", ";
            cout << setw(3) << (unsigned)((unsigned char*)buffer)[i+2] << ", ";
            cout << setw(3) << (unsigned)((unsigned char*)buffer)[i+3];
            cout << endl;
        }
        for( unsigned i = 32; i < 38; i+=2 ) {
            cout << desc[8+(i-32)/2];
            cout << setw(3) << (unsigned)((unsigned char*)buffer)[i] << ", ";
            cout << setw(3) << (unsigned)((unsigned char*)buffer)[i+1];
            cout << endl;
        }
        for( unsigned i = 38; i < 43; i+=1 ) {
            cout << desc[i-27];
            cout << setw(3) << (unsigned)((unsigned char*)buffer)[i];
            cout << endl;
        }
    }
    else {
        cout << "Error getting debug info." << endl;
    }
    fx3.controlTransfer( 0x40, FX3_RESET_PIB_DEBUG_INFO, 0, 0, 0, 0 );
}

void fun12() {
    fx3.sendWord(0,0);
    uint32_t buffer[5];
    uint32_t received = fx3.receive( 5, buffer, 200 );
    if( received != 5 ) {
        cout << "Stats read error." << endl;
        return;
    }
    fx3.sendWord(0,0xf0000000);
    cout << "Read: words: " << buffer[4] << ", single: " << (buffer[2]>>16) << ", burst: " << (buffer[2]&0xffff) << endl;
    cout << "Write: words: " << buffer[3] << ", single: " << (buffer[1]>>16) << ", burst: " << (buffer[1]&0xffff) << ", pktend: " << buffer[0] << endl;
}

void fun13() {
    unsigned counts[3];
    fx3.controlTransfer( 0xC0, FX3_GET_LINK_QUALITY_COUNTS, 0, 0, (unsigned char*)counts, 12 );
    cout << "Resets: " << counts[2] << endl;
    cout << "OUT: " << counts[1] << ", IN: " << counts[0] << endl;
    fx3.controlTransfer( 0xC0, FX3_RESET_LINK_QUALITY_COUNTS, 0, 0, 0, 0 );
}

void fun14() {
    uint32_t buffer[32];
    
    buffer[0] = FX3_FPGA_HEADER(0xE,16);
    for( uint32_t i = 0; i < 16; ++i ) {
        buffer[i+1] = i*0x11111111;
    }
    
    fx3.send( 17, buffer );
    
    uint32_t received = fx3.receive( 32, buffer, 200 );
    for( uint32_t i = 0; i < received; ++i ) {
        cout << hex << buffer[i] << dec << endl;
    }
}

//Reset FPGA and wait for ID
void fun15() {
    fx3.reset();
    fx3.sendWord(0xf, 0);
    unsigned int recv = 0;
    while( recv < 4 ) {
        recv += fx3.receive(4-recv, recvdata);
    }
}

bool appSetup( int argc, char* argv[] ) {
    for( unsigned i = 0; i < 20480; ++i ) {
        senddata[i] = i&0xff;
    }
    
    unsigned vid = 0x04b4, pid = 0x00f1;
    if( argc > 2 ) {
        vid = strtoul( argv[1], NULL, 0 );
        pid = strtoul( argv[2], NULL, 0 );
    }

    fx3.init( vid, pid );
    if( !fx3 ) {
        cerr << "Could not connect to FX3" << endl;
        cerr << "Try " << argv[0] << " [VID] [PID]" << endl;
        return false;
    }
    
    ControlCenter& cc = ControlCenter::getInstance();
    cc.set_title("ControlCenter");
    cc.connectButton( 0, 0, "read FX3 timestamp", sigc::ptr_fun( fun0 ) );
    cc.connectButton( 0, 1, "read FPGA timestamp", sigc::ptr_fun( fun1 ) );
    cc.connectButton( 0, 2, "read FX3 flash id", sigc::ptr_fun( fun2 ) );
    cc.connectButton( 0, 3, "read FPGA flash id", sigc::ptr_fun( fun3 ) );
    cc.connectButton( 1, 0, "reset FX3 to bootloader", sigc::ptr_fun( fun4 ) );
    cc.connectButton( 1, 1, "load FX3 image to ram", sigc::ptr_fun( fun5 ) );
    cc.connectButton( 1, 2, "write FX3 image to flash", sigc::ptr_fun( fun6 ) );
    cc.connectButton( 1, 3, "reset FX3", sigc::ptr_fun( fun7 ) );
    cc.connectButton( 2, 0, "send/receive 1 GB", sigc::ptr_fun( fun8 ) );
    cc.connectButton( 2, 1, "read/reset transfer counts", sigc::ptr_fun( fun9 ) );
    cc.connectButton( 2, 2, "read/reset phy/lnk error counts", sigc::ptr_fun( fun10 ) );
    cc.connectButton( 2, 3, "read/reset pib debug counts", sigc::ptr_fun( fun11 ) );
    cc.connectButton( 3, 0, "read/reset fpga fx3 debug counts", sigc::ptr_fun( fun12 ) );
    cc.connectButton( 3, 1, "read/reset link quality counts", sigc::ptr_fun( fun13 ) );
    cc.connectButton( 3, 2, "test echo", sigc::ptr_fun( fun14 ) );
    cc.connectButton( 3, 3, "reset fpga", sigc::ptr_fun( fun15 ) );
    return true;
}

