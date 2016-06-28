#include <fstream>
#include <cstdio>
#include <string>
#include <unistd.h>
using namespace std;

#include "fx3stream.h"
#include "fx3utils.h"


int fx3_read_firmware_image( const char *filename, unsigned char *buf, unsigned int *filesize ) {
    ifstream fd(filename, ios::binary);
    if ( !fd ) {
        printf("File not found\n");
        return -3;
    }
    
    fd.seekg( 0, fd.end );
    *filesize = fd.tellg();
    fd.seekg( 0, fd.beg );
    
    if ( *filesize > FX3_MAX_FWIMG_SIZE ) {
        printf("File size exceeds maximum firmware image size\n");
        return -2;
    }
    
    fd.read( (char *)buf, 2 ); /* Read first 2 bytes, must be equal to 'CY' */
    if( string((char *)buf,2) != "CY" ) {
        printf("Image does not have 'CY' at start. aborting\n");
        return -4;
    }
    fd.read( (char *)buf, 1 ); /* Read 1 byte. bImageCTL */
    if( buf[0] & 0x01 ) {
        printf("Image does not contain executable code\n");
        return -5;
    }
    
    fd.read( (char *)buf, 1 ); /* Read 1 byte. bImageType */
    if( !(buf[0] == 0xB0) ) {
        printf("Not a normal FW binary with checksum\n");
        return -6;
    }
    
    // Read the complete firmware binary into a local buffer.
    fd.seekg( 0, fd.beg );
    fd.read( (char *)buf, *filesize );
    
    fd.close();
    return 0;
}

int fx3_ram_write( FX3Stream& fx3, unsigned char *buf, unsigned int ramAddress, int len ) {
    int r;
    int index = 0;
    
    while ( len > 0 ) {
        int size = (len > FX3_MAX_WRITE_SIZE) ? FX3_MAX_WRITE_SIZE : len;
        r = fx3.controlTransfer(0x40, FX3_RAM_WRITE, ramAddress&0xffff, ramAddress>>16, &buf[index], size, FX3_PROG_TIMEOUT);
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

void fx3_download( FX3Stream& fx3, unsigned char *fwBuf, unsigned int filesize ) {
    // Run through each section of code, and use vendor commands to download them to RAM.
    int r;
    unsigned int index = 4, checksum = 0, *data_p, address, length, i;
    while ( index < filesize ) {
        data_p  = (unsigned int *)(fwBuf + index);
        length  = data_p[0];
        address = data_p[1];
        if (length != 0) {
            for (i = 0; i < length; i++)
                checksum += data_p[2 + i];
            r = fx3_ram_write( fx3, fwBuf + index + 8, address, length * 4 );
            if (r != 0) {
                printf("Failed to download data to FX3 RAM\n");
                return;
            }
        } else {
            if (checksum != data_p[2]) {
                printf ("Checksum error in firmware binary\n");
                return;
            }

            r = fx3.controlTransfer(0x40, FX3_RAM_WRITE, address&0xffff, address>>16, NULL, 0, FX3_PROG_TIMEOUT);
            if ( r != 0 )
                printf("Ignored error in control transfer: %d\n", r);
            break;
        }
        
        index += (8 + length * 4);
    }
}

int fx3_spi_write( FX3Stream& fx3, unsigned char *buf, int len ) {
    int r = 0;
    int index = 0;
    int size;
    unsigned short page_address = 0;
    
    while ( len > 0 ) {
        size = ( len > FX3_MAX_WRITE_SIZE ) ? FX3_MAX_WRITE_SIZE : len;
        r = fx3.controlTransfer(0x40, FX3_SPI_FLASH_WRITE, 0, page_address, &buf[index], size, FX3_PROG_TIMEOUT);
        if ( r != size ) {
            printf("Write to SPI flash failed\n");
            return -1;
        }
        index += size;
        len   -= size;
        page_address += (size / FX3_SPI_PAGE_SIZE);
    }
    
    return 0;
}

int fx3_spi_erase_sector( FX3Stream& fx3, unsigned short nsector ) {
    unsigned char stat;
    int timeout = 10;
    int r;
    
    r = fx3.controlTransfer(0x40, FX3_SPI_FLASH_ERASE, 1, nsector, NULL, 0, FX3_PROG_TIMEOUT);
    if (r != 0) {
        printf("SPI sector erase failed\n");
        return -1;
    }
    
    // Wait for the SPI flash to become ready again.
    do {
        r = fx3.controlTransfer(0xC0, FX3_SPI_FLASH_POLL, 0, 0, &stat, 1, FX3_PROG_TIMEOUT);
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

