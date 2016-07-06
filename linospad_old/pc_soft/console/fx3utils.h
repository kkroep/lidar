#ifndef FX3UTILS_H
#define FX3UTILS_H

#define FX3_DEFAULT_VID                 0x04b4
#define FX3_DEFAULT_PID                 0x00f1

#define FX3_BOOTLOADER_VID              0x04b4
#define FX3_BOOTLOADER_PID              0x00f3

//Vendor commands in FX3 firmware
#define FX3_GET_PIB_DEBUG_INFO          0x01
#define FX3_RESET_PIB_DEBUG_INFO        0x02
#define FX3_GET_GPIO_STATE              0x03
#define FX3_SET_GPIO_STATE              0x04
#define FX3_RESET_STREAM_ENDPOINTS      0x05
#define FX3_REBOOT_TO_BOOTLOADER        0x06            //Will reconnect with bootloader
#define FX3_READ_FLASH_ID               0x07
#define FX3_GET_TRANSFER_COUNTS         0x08
#define FX3_RESET_TRANSFER_COUNTS       0x09
#define FX3_GET_FIRMWARE_TIMESTAMP      0x10
#define FX3_REBOOT_FX3                  0x11            //Will reconnect device
#define FX3_GET_RESET_USB_ERROR_COUNT   0x12
#define FX3_GET_LINK_QUALITY_COUNTS     0x13
#define FX3_RESET_LINK_QUALITY_COUNTS   0x14

//Cypress' vendor commands to write to flash are implemented
#define FX3_RAM_WRITE                   0xA0            //Not implemented. Use in bootloader mode.
#define FX3_ID_CHECK                    0xB0
#define FX3_SPI_FLASH_WRITE             0xC2
#define FX3_SPI_FLASH_READ              0xC3
#define FX3_SPI_FLASH_ERASE             0xC4
#define FX3_SPI_FLASH_POLL              0xC5            //Own command

#define FX3_MAX_FWIMG_SIZE              (256 * 1024)    // Maximum size of the firmware binary.
#define FX3_MAX_WRITE_SIZE              (2 * 1024)      // Max. size of data that can be written through one vendor command.

#define FX3_DEFAULT_SPI_FLASH_ID        0x202015
#define FX3_SPI_PAGE_SIZE               256             // Page size for SPI flash memory.
#define FX3_SPI_SECTOR_SIZE             (64 * 1024)     // Sector size for SPI flash memory.

#define FX3_PROG_TIMEOUT                5000            // Timeout for each vendor command is set to 5 seconds.

int fx3_read_firmware_image( const char *filename, unsigned char *buf, unsigned int *filesize );
int fx3_ram_write( FX3Stream& fx3, unsigned char *buf, unsigned int ramAddress, int len );
void fx3_download( FX3Stream& fx3, unsigned char *fwBuf, unsigned int filesize );
int fx3_spi_erase_sector( FX3Stream& fx3, unsigned short nsector );
int fx3_spi_write( FX3Stream& fx3, unsigned char *buf, int len );

#endif //FX3UTILS_H

