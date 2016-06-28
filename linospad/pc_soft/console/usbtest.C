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

FX3Stream fx3;
unsigned char recvdata[20480];
unsigned char senddata[20480];

void fun0() {
    senddata[0] = 0x10;
    senddata[1] = 0x00;
    senddata[2] = 0x00;
    senddata[3] = 0x0f;
//    fx3.sendData(68, senddata);
    fx3.reset();
    fx3.send(68, senddata );
    cout << "Receiving 64 bytes" << endl;
    unsigned int recv = 0;
    while( recv < 64 ) {
        recv += fx3.receive(64-recv, recvdata);
    }
}

void fun1() {
    unsigned int numSamples = 256;
    unsigned char* recvdata = new unsigned char [17*4*numSamples];
    fx3.sendWord( 2, 0x00000000|numSamples ); //store
    fx3.sendWord( 2, 0x10000000|numSamples ); //read
    cout << "Receiving " << 17*4*numSamples << " bytes" << endl;
    if( 17*4*numSamples != fx3.receive(17*4*numSamples, recvdata) ) {
        cout << "Error receiving data" << endl;
    }
    delete [] recvdata;
}

#define RAM_WRITE                     (0xA0)
#define ID_CHECK                      (0xB0)
#define SPI_FLASH_WRITE               (0xC2)
#define SPI_FLASH_READ                (0xC3)
#define SPI_FLASH_ERASE               (0xC4)
#define SPI_FLASH_POLL                (0xC5)

#define MAX_FWIMG_SIZE	(256 * 1024)		// Maximum size of the firmware binary.
#define MAX_WRITE_SIZE	(2 * 1024)		// Max. size of data that can be written through one vendor command.

#define SPI_PAGE_SIZE	(256)			// Page size for SPI flash memory.
#define SPI_SECTOR_SIZE	(64 * 1024)		// Sector size for SPI flash memory.

#define VENDORCMD_TIMEOUT	(5000)		// Timeout for each vendor command is set to 5 seconds.
#define GETHANDLE_TIMEOUT	(5)		// Timeout (in seconds) for getting a FX3 flash programmer handle.

// Round n up to a multiple of v.
#define ROUND_UP(n,v)	((((n) + ((v) - 1)) / (v)) * (v))

#define GET_LSW(v)	((unsigned short)((v) & 0xFFFF))
#define GET_MSW(v)	((unsigned short)((v) >> 16))

static int filesize;

static int ram_write(unsigned char *buf, unsigned int ramAddress, int len)
{
	int r;
	int index = 0;
	int size;

	while ( len > 0 ) {
		size = (len > MAX_WRITE_SIZE) ? MAX_WRITE_SIZE : len;
		r = fx3.controlTransfer(0x40, RAM_WRITE, GET_LSW(ramAddress), GET_MSW(ramAddress),
				&buf[index], size, VENDORCMD_TIMEOUT);
		if ( r != size ) {
			printf("Vendor write to FX3 RAM failed\n");
			return -1;
		}

		ramAddress += size;
		index      += size;
		len        -= size;
	}

	return 0;
}

static int read_firmware_image(const char *filename, unsigned char *buf)
{
	FILE* fd;
	struct stat filestat;

	// Verify that the file size does not exceed our limits.
	if ( stat (filename, &filestat) != 0 ) {
		printf("Failed to stat file %s\n", filename);
		return -1;
	}

	filesize = filestat.st_size;
	if ( filesize > MAX_FWIMG_SIZE ) {
		printf("File size exceeds maximum firmware image size\n");
		return -2;
	}

	fd = fopen(filename, "rb");
	if ( fd < 0 ) { 
		printf("File not found\n");
		return -3;
	}
	fread(buf, 1, 2, fd);		/* Read first 2 bytes, must be equal to 'CY'	*/
	if ( strncmp((char *)buf,"CY",2) ) {
		printf("Image does not have 'CY' at start. aborting\n");
		return -4;
	}
	fread(buf, 1, 1, fd);		/* Read 1 byte. bImageCTL	*/
	if ( buf[0] & 0x01 ) {
		printf("Image does not contain executable code\n");
		return -5;
	}

	fread(buf, 1, 1, fd);		/* Read 1 byte. bImageType	*/
	if ( !(buf[0] == 0xB0) ) {
		printf("Not a normal FW binary with checksum\n");
		return -6;
	}

	// Read the complete firmware binary into a local buffer.
	fseek(fd, 0, SEEK_SET);
	fread(buf, 1, filesize, fd);

	fclose(fd);
	return 0;
}

static int spi_write(unsigned char *buf, int len)
{
	int r = 0;
	int index = 0;
	int size;
	unsigned short page_address = 0;

	while ( len > 0 ) {
		size = ( len > MAX_WRITE_SIZE ) ? MAX_WRITE_SIZE : len;
		r = fx3.controlTransfer(0x40, SPI_FLASH_WRITE, 0, page_address, &buf[index], size, VENDORCMD_TIMEOUT);
		if ( r != size ) {
			printf("Write to SPI flash failed\n");
			return -1;
		}
		index += size;
		len   -= size;
		page_address += (size / SPI_PAGE_SIZE);
	}

	return 0;
}

static int spi_erase_sector(unsigned short nsector)
{
	unsigned char stat;
	int           timeout = 10;
	int r;

	r = fx3.controlTransfer(0x40, SPI_FLASH_ERASE, 1, nsector, NULL, 0, VENDORCMD_TIMEOUT);
	if (r != 0) {
		printf("SPI sector erase failed\n");
		return -1;
	}

	// Wait for the SPI flash to become ready again.
	do {
		r = fx3.controlTransfer(0xC0, SPI_FLASH_POLL, 0, 0, &stat, 1, VENDORCMD_TIMEOUT);
		if (r != 1) {
			printf("SPI status read failed\n");
			return -2;
		}
		sleep (1);
		timeout--;
	} while ( (stat != 0) && (timeout > 0) );

	if (stat != 0) {
		printf("Timed out on SPI status read\n");
		return -3;
	}

	printf("Erased sector %d of SPI flash\n", nsector);
	return 0;
}

void fun2() {
    Gtk::FileChooserDialog dlg(ControlCenter::getInstance(), "Select image file");
    dlg.add_button(Gtk::Stock::CANCEL, Gtk::RESPONSE_CANCEL);
    dlg.add_button(Gtk::Stock::OK, Gtk::RESPONSE_OK);
    int result = dlg.run();
    if( result != Gtk::RESPONSE_OK ) {
        return;
    }
    string filename = dlg.get_filename();
    
	// Allocate memory for holding the firmware binary.
	unsigned char* fwBuf = (unsigned char *)calloc (1, MAX_FWIMG_SIZE);
	if ( fwBuf == 0 ) {
		printf("Failed to allocate buffer to store firmware binary\n");
		return;
	}

	if ( read_firmware_image(filename.c_str(), fwBuf) ) {
		printf("File %s does not contain valid FX3 firmware image\n", filename.c_str());
		free(fwBuf);
		return;
	}

	filesize = ROUND_UP(filesize, SPI_PAGE_SIZE);

	// Erase as many SPI sectors as are required to hold the firmware binary.
	for (int i = 0; i < ((filesize + SPI_SECTOR_SIZE - 1) / SPI_SECTOR_SIZE); i++) {
		int r = spi_erase_sector(i);
		if (r != 0) {
			printf("Failed to erase SPI flash\n");
			free(fwBuf);
			return;
		}
	}

	int r = spi_write(fwBuf, filesize);
	if (r != 0) {
		printf("SPI write failed\n");
	} else {
		printf("Completed writing into SPI FLASH\n");
	}

	free(fwBuf);
}

void fun3() {
	unsigned char stat;
	int r = fx3.controlTransfer(0xC0, SPI_FLASH_POLL, 0, 0, &stat, 1, VENDORCMD_TIMEOUT);
	if (r != 1) {
		printf("SPI status read failed\n");
		return;
	}
	cout << "Status: " << setw(2) << setfill('0') << hex << (unsigned)stat << dec << endl;
}

void fun4() {
    unsigned char buf[3];
    int r = fx3.controlTransfer(0xC0, 0x07, 0, 0, buf, 3, VENDORCMD_TIMEOUT);
    if ( r != 3 ) {
        printf("Flash ID read failed\n");
        return;
    }
    cout << "Got: ";
    cout << setw(2) << setfill('0') << hex << (unsigned)buf[0] << dec;
    cout << setw(2) << setfill('0') << hex << (unsigned)buf[1] << dec;
    cout << setw(2) << setfill('0') << hex << (unsigned)buf[2] << dec;
    cout << endl;
}

void fun5() {
    unsigned char buf[256];
    int r = fx3.controlTransfer(0xC0, SPI_FLASH_READ, 0, 0, buf, 256, VENDORCMD_TIMEOUT);
    if ( r != 256 ) {
        printf("Read from SPI flash failed\n");
        return;
    }
    cout << "Got: " << buf << endl;
}

void fun6() {
    unsigned char buf[32];
    int r = fx3.controlTransfer(0xC0, ID_CHECK, 0, 0, buf, 32, VENDORCMD_TIMEOUT);
    if ( r != 32 ) {
        printf("System ID read failed\n");
        return;
    }
    cout << "Got: " << buf << endl;
}

void fun7() {
    Gtk::FileChooserDialog dlg(ControlCenter::getInstance(), "Select image file");
    dlg.add_button(Gtk::Stock::CANCEL, Gtk::RESPONSE_CANCEL);
    dlg.add_button(Gtk::Stock::OK, Gtk::RESPONSE_OK);
    int result = dlg.run();
    if( result != Gtk::RESPONSE_OK ) {
        return;
    }
    string filename = dlg.get_filename();

	unsigned char *fwBuf;
	unsigned int  *data_p;
	unsigned int i, checksum;
	unsigned int address, length;
	int r, index;

	fwBuf = (unsigned char *)calloc (1, MAX_FWIMG_SIZE);
	if ( fwBuf == 0 ) {
		printf("Failed to allocate buffer to store firmware binary\n");
		return;
	}

	// Read the firmware image into the local RAM buffer.
	r = read_firmware_image(filename.c_str(), fwBuf);
	if ( r != 0 ) {
		printf("Failed to read firmware file %s\n", filename.c_str());
		free(fwBuf);
		return;
	}

	// Run through each section of code, and use vendor commands to download them to RAM.
	index    = 4;
	checksum = 0;
	while ( index < filesize ) {
		data_p  = (unsigned int *)(fwBuf + index);
		length  = data_p[0];
		address = data_p[1];
		if (length != 0) {
			for (i = 0; i < length; i++)
				checksum += data_p[2 + i];
			r = ram_write(fwBuf + index + 8, address, length * 4);
			if (r != 0) {
				printf("Failed to download data to FX3 RAM\n");
				free(fwBuf);
				return;
			}
		} else {
			if (checksum != data_p[2]) {
				printf ("Checksum error in firmware binary\n");
				free(fwBuf);
				return;
			}

			r = fx3.controlTransfer(0x40, RAM_WRITE, GET_LSW(address), GET_MSW(address), NULL,
					0, VENDORCMD_TIMEOUT);
			if ( r != 0 )
				printf("Ignored error in control transfer: %d\n", r);
			break;
		}

		index += (8 + length * 4);
	}

	free(fwBuf);
	return;
}

void fun8() {
    unsigned counts[3];
    fx3.controlTransfer( 0xC0, 0x08, 0x00, 0x00, (unsigned char*)counts, 12 );
    cout << "EP0: " << counts[2] << endl;
    cout << "TX: " << counts[1] << ", RX: " << counts[0] << endl;
}

void fun9() {
    fx3.sendWord( 13, (7<<8)|1 ); //enable with clockdiv = 1 (25MHz)
    fx3.sendWord( 13, 0x10000000|(1<<12)|0 ); //write 1 byte, read 0 bytes
    fx3.sendWord( 13, 0x9F ); //Read ID command
    fx3.sendWord( 13, 0x10000000|(1<<12)|0 ); //write 1 byte, read 0 bytes
    fx3.sendWord( 13, 0x9F ); //Read ID command
    fx3.sendWord( 13, 0x10000000|(1<<12)|0 ); //write 1 byte, read 0 bytes
    fx3.sendWord( 13, 0x9F ); //Read ID command
    fx3.sendWord( 13, 0x10000000|(1<<12)|4 ); //write 1 byte, read 4 bytes
    fx3.sendWord( 13, 0x9F ); //Read ID command
    if( 4 != fx3.receive(4, recvdata) ) {
        cout << "Error receiving data" << endl;
    }
    fx3.sendWord( 13, 0x10000000|(1<<12)|4 ); //write 1 byte, read 4 bytes
    fx3.sendWord( 13, 0x05 ); //Read status register command
    if( 4 != fx3.receive(4, recvdata) ) {
        cout << "Error receiving data" << endl;
    }
}

void fun10() {
    fx3.sendWord( 15, 0x00000000 );
    if( 4 != fx3.receive(4, recvdata) ) {
        cout << "Error receiving data" << endl;
    }
}

void fun11() {
    fx3.controlTransfer( 0x40, 0x04, 0x02, ~0x02, 0, 0 );
}

void fun12() {
    fx3.controlTransfer( 0x40, 0x04, 0x00, ~0x02, 0, 0 );
}

void fun13() {
    unsigned short state;
    if( 2 != fx3.controlTransfer( 0xC0, 0x03, 0x00, 0x00, (unsigned char*)&state, 2 ) ) {
        cout << "Data length error" << endl;
    }
    cout << setw(4) << setfill('0') << hex << state << dec << endl;
}

void fun14() {
    fx3.controlTransfer( 0x40, 0x06, 0x00, 0x00, 0, 0 );
}

void fun15() {
    fx3.receive(4096, recvdata);
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
    cc.connectButton( 0, 0, "test system reset", sigc::ptr_fun( fun0 ) );
    cc.connectButton( 0, 1, "read 1024 raw samples", sigc::ptr_fun( fun1 ) );
    cc.connectButton( 0, 2, "write image to fx3 spi flash", sigc::ptr_fun( fun2 ) );
    cc.connectButton( 0, 3, "read spi status", sigc::ptr_fun( fun3 ) );
    cc.connectButton( 1, 0, "read spi flash id", sigc::ptr_fun( fun4 ) );
    cc.connectButton( 1, 1, "read spi page", sigc::ptr_fun( fun5 ) );
    cc.connectButton( 1, 2, "read fx3 system id", sigc::ptr_fun( fun6 ) );
    cc.connectButton( 1, 3, "write image to fx3 ram", sigc::ptr_fun( fun7 ) );
    cc.connectButton( 2, 0, "read dma transfer counts", sigc::ptr_fun( fun8 ) );
    cc.connectButton( 2, 1, "read S6 flash ID", sigc::ptr_fun( fun9 ) );
    cc.connectButton( 2, 2, "read FPGA ID", sigc::ptr_fun( fun10 ) );
    cc.connectButton( 2, 3, "put gpio 1 high", sigc::ptr_fun( fun11 ) );
    cc.connectButton( 3, 0, "put gpio 1 low", sigc::ptr_fun( fun12 ) );
    cc.connectButton( 3, 1, "read gpio state", sigc::ptr_fun( fun13 ) );
    cc.connectButton( 3, 2, "reset fx3 to usb loader", sigc::ptr_fun( fun14 ) );
    cc.connectButton( 3, 3, "receive 4096 bytes", sigc::ptr_fun( fun15 ) );
    return true;
}

