/*
 ## Cypress USB 3.0 Platform source file (cyfxslfifosync.c)
 ## ===========================
 ##
 ##  Copyright Cypress Semiconductor Corporation, 2010-2011,
 ##  All Rights Reserved
 ##  UNPUBLISHED, LICENSED SOFTWARE.
 ##
 ##  CONFIDENTIAL AND PROPRIETARY INFORMATION
 ##  WHICH IS THE PROPERTY OF CYPRESS.
 ##
 ##  Use of this file is governed
 ##  by the license agreement included in the file
 ##
 ##     <install>/license/license.txt
 ##
 ##  where <install> is the Cypress software
 ##  installation root directory path.
 ##
 ## ===========================
*/

/* This file illustrates the Slave FIFO Synchronous mode example */

/*
   This example comprises of two USB bulk endpoints. A bulk OUT endpoint acts as the
   producer of data from the host. A bulk IN endpoint acts as the consumer of data to
   the host. Appropriate vendor class USB enumeration descriptors with these two bulk
   endpoints are implemented.

   The GPIF configuration data for the Synchronous Slave FIFO operation is loaded onto
   the appropriate GPIF registers. The p-port data transfers are done via the producer
   p-port socket and the consumer p-port socket.

   This example implements two DMA Channels in MANUAL mode one for P to U data transfer
   and one for U to P data transfer.

   The U to P DMA channel connects the USB producer (OUT) endpoint to the consumer p-port
   socket. And the P to U DMA channel connects the producer p-port socket to the USB 
   consumer (IN) endpoint.

   Upon every reception of data in the DMA buffer from the host or from the p-port, the
   CPU is signalled using DMA callbacks. There are two DMA callback functions implemented
   each for U to P and P to U data paths. The CPU then commits the DMA buffer received so
   that the data is transferred to the consumer.

   The DMA buffer size for each channel is defined based on the USB speed. 64 for full
   speed, 512 for high speed and 1024 for super speed. CY_FX_SLFIFO_DMA_BUF_COUNT in the
   header file defines the number of DMA buffers per channel.

   The constant CY_FX_SLFIFO_GPIF_16_32BIT_CONF_SELECT in the header file is used to
   select 16bit or 32bit GPIF data bus configuration.
 */

#include "cyu3system.h"
#include "cyu3os.h"
#include "cyu3dma.h"
#include "cyu3error.h"
#include "cyu3usb.h"
#include "cyu3i2c.h"
#include "cyu3gpif.h"
#include "cyu3gpio.h"
#include "cyu3utils.h"
#include "cyu3pib.h"
#include "pib_regs.h"

#include "cyfxslfifosync.h"

/* This file should be included only once as it contains
 * structure definitions. Including it in multiple places
 * can result in linker error. */
#include "cyfxgpif2config.h"


CyU3PThread slFifoAppThread;	        /* Slave FIFO application thread structure */
CyU3PDmaChannel glChHandleSlFifoUtoP;   /* DMA Channel handle for U2P transfer. */
CyU3PDmaChannel glChHandleSlFifoPtoU;   /* DMA Channel handle for P2U transfer. */

static volatile uint8_t glChannelsSuspended = 0;

uint32_t glDMARxCount = 0;              /* Counter to track the number of buffers received from USB. */
uint32_t glDMATxCount = 0;              /* Counter to track the number of buffers sent to USB. */
uint32_t glEp0RqtCount = 0;				/* Counter to track EP0 request count. */
uint32_t glInEpBadEvtCount = 0;			/* Counter to track IN EP events indicating bad link quality. */
uint32_t glOutEpBadEvtCount = 0;		/* Counter to track OUT EP events indicating bad link quality. */
uint32_t glEpResetEvtCount = 0;			/* Counter for endpoint resets triggered by bad link quality. */
CyBool_t glIsApplnActive = CyFalse;     /* Whether the application is active or not. */

/* Firmware ID variable that may be used to verify firmware version. */
static const uint8_t glFirmwareID[32] __attribute__ ((aligned (32))) = { 'L', 'i', 'n', 'o', 'S', 'P', 'A', 'D', ' ',
		((FIRMWARE_TIMESTAMP>>28)&0xF)+'0',
		((FIRMWARE_TIMESTAMP>>24)&0xF)+'0',
		((FIRMWARE_TIMESTAMP>>20)&0xF)+'0',
		((FIRMWARE_TIMESTAMP>>16)&0xF)+'0',
		((FIRMWARE_TIMESTAMP>>12)&0xF)+'0',
		((FIRMWARE_TIMESTAMP>>8)&0xF)+'0',
		((FIRMWARE_TIMESTAMP>>4)&0xF)+'0',
		(FIRMWARE_TIMESTAMP&0xF)+'0',
		'\0' };

static uint8_t glEp0Buffer[MAX_REQ_LENGTH] __attribute__ ((aligned (32)));

/* Debug information to be retrieved by vendor requests. */
typedef struct PibDebugCounters_t
{
	uint8_t thr0_wr_overrun_count, thr1_wr_overrun_count, thr2_wr_overrun_count, thr3_wr_overrun_count;
	uint8_t thr0_rd_underrun_count, thr1_rd_underrun_count, thr2_rd_underrun_count, thr3_rd_underrun_count;
	uint8_t thr0_direction_count, thr1_direction_count, thr2_direction_count, thr3_direction_count;
	uint8_t thr0_sck_inactive_count, thr1_sck_inactive_count, thr2_sck_inactive_count, thr3_sck_inactive_count;
	uint8_t thr0_adap_overrun_count, thr1_adap_overrun_count, thr2_adap_overrun_count, thr3_adap_overrun_count;
	uint8_t thr0_adap_underrun_count, thr1_adap_underrun_count, thr2_adap_underrun_count, thr3_adap_underrun_count;
	uint8_t thr0_rd_force_end_count, thr1_rd_force_end_count, thr2_rd_force_end_count, thr3_rd_force_end_count;
	uint8_t thr0_rd_burst_count, thr1_rd_burst_count, thr2_rd_burst_count, thr3_rd_burst_count;
	uint8_t other_pib_error_count, total_pib_error_count;
	uint8_t gpif_data_read_count, gpif_data_write_count, gpif_addr_read_count, gpif_addr_write_count;
	uint8_t gpif_invalid_state_count;
	uint8_t other_gpif_error_count, total_gpif_error_count;
	uint8_t pib_dll_unlock_event_count;
	uint8_t total_cb_call_count;
} PibDebugCounters_t;
static PibDebugCounters_t pibDebug __attribute__ ((aligned (32)));

/* Application Error Handler */
void
CyFxAppErrorHandler (
		CyU3PReturnStatus_t apiRetStatus    /* API return status */
    	)
{
    /* Application failed with the error code apiRetStatus */

    /* Add custom debug or recovery actions here */

    /* Loop Indefinitely */
    for (;;)
    {
        /* Thread sleep : 100 ms */
        CyU3PThreadSleep (100);
    }
}

/* This function initializes the debug module. The debug prints
 * are routed to the I2C and can be seen using a I2C console. */
void
CyFxSlFifoApplnDebugInit (void)
{
    struct CyU3PI2cConfig_t i2cConfig;
    struct CyU3PI2cPreamble_t i2cPreamble;
    CyU3PReturnStatus_t apiRetStatus = CY_U3P_SUCCESS;
    /* Initialize the I2C for printing debug messages */
    apiRetStatus = CyU3PI2cInit();
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        /* Error handling */
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Set UART configuration
     * 400kHz, no timeouts, DMA mode */
    CyU3PMemSet ((uint8_t *)&i2cConfig, 0, sizeof (i2cConfig));
    i2cConfig.bitRate = 400000;
    i2cConfig.busTimeout = 0xFFFFFFFFU;
    i2cConfig.dmaTimeout = 0xFFFF;
    i2cConfig.isDma = CyTrue;

    apiRetStatus = CyU3PI2cSetConfig (&i2cConfig, NULL);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Set the I2C transfer to a really large value. */
    CyU3PMemSet ((uint8_t *)&i2cPreamble, 0, sizeof (i2cPreamble));
    i2cPreamble.buffer[0] = 0xC5;
    i2cPreamble.length = 1;
    i2cPreamble.ctrlMask = 1;

    apiRetStatus = CyU3PI2cSendCommand (&i2cPreamble, 0xFFFFFFFF, CyFalse);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Initialize the debug module. */
    apiRetStatus = CyU3PDebugInit (CY_U3P_LPP_SOCKET_I2C_CONS, 8);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyFxAppErrorHandler(apiRetStatus);
    }
}

void
CyFxSlFifoApplnGpioInit (void)
{
    CyU3PGpioClock_t gpioClock;
    CyU3PGpioSimpleConfig_t gpioConfig;
    CyU3PReturnStatus_t apiRetStatus = CY_U3P_SUCCESS;

    /* Init the GPIO module */
    gpioClock.fastClkDiv = 2;
    gpioClock.slowClkDiv = 0;
    gpioClock.simpleDiv = CY_U3P_GPIO_SIMPLE_DIV_BY_2;
    gpioClock.clkSrc = CY_U3P_SYS_CLK;
    gpioClock.halfDiv = 0;

    apiRetStatus = CyU3PGpioInit(&gpioClock, NULL);
    if (apiRetStatus != 0)
    {
        /* Error Handling */
        CyU3PDebugPrint (4, "CyU3PGpioInit failed, error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Override GPIO 26 & 27 as these pins are associated with GPIF control signals.
     * The IOs cannot be selected as GPIO by CyU3PDeviceConfigureIOMatrix call
     * as they are part of the GPIF IOs. Override API call must be made with
     * caution as this will change the functionality of the pin. If the IO
     * line is used as part of GPIF and is connected to some external device,
     * then the line will no longer behave as a GPIF IO. Here CTL[9 & 10] lines
     * are not used and so it is safe to override.  */
    apiRetStatus = CyU3PDeviceGpioOverride (GPIO_0, CyTrue);
    if (apiRetStatus != 0)
    {
        /* Error Handling */
        CyU3PDebugPrint (4, "CyU3PDeviceGpioOverride failed, error code = %d\n",
                apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    apiRetStatus = CyU3PDeviceGpioOverride (GPIO_1, CyTrue);
    if (apiRetStatus != 0)
    {
        /* Error Handling */
        CyU3PDebugPrint (4, "CyU3PDeviceGpioOverride failed, error code = %d\n",
                apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Configure GPIOs 26 & 27 as outputs. */
    gpioConfig.outValue = CyFalse;
    gpioConfig.driveLowEn = CyTrue;
    gpioConfig.driveHighEn = CyTrue;
    gpioConfig.inputEn = CyFalse;
    gpioConfig.intrMode = CY_U3P_GPIO_NO_INTR;
    apiRetStatus = CyU3PGpioSetSimpleConfig(GPIO_0, &gpioConfig);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        /* Error handling */
        CyU3PDebugPrint (4, "CyU3PGpioSetSimpleConfig failed, error code = %d\n",
                apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    apiRetStatus = CyU3PGpioSetSimpleConfig(GPIO_1, &gpioConfig);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        /* Error handling */
        CyU3PDebugPrint (4, "CyU3PGpioSetSimpleConfig failed, error code = %d\n",
                apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Configure GPIOs used for SPI communication */
    /* Configure GPIO 53 as output(SPI_CLOCK). */
    gpioConfig.outValue    = CyFalse;
    gpioConfig.inputEn     = CyFalse;
    gpioConfig.driveLowEn  = CyTrue;
    gpioConfig.driveHighEn = CyTrue;
    gpioConfig.intrMode    = CY_U3P_GPIO_NO_INTR;

    apiRetStatus = CyU3PGpioSetSimpleConfig(FX3_SPI_CLK, &gpioConfig);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        /* Error handling */
        CyU3PDebugPrint (4, "CyU3PGpioSetSimpleConfig for GPIO Id %d failed, error code = %d\n",
                FX3_SPI_CLK, apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Configure GPIO 54 as output(SPI_SSN) */
    gpioConfig.outValue    = CyTrue;
    gpioConfig.inputEn     = CyFalse;
    gpioConfig.driveLowEn  = CyTrue;
    gpioConfig.driveHighEn = CyTrue;
    gpioConfig.intrMode    = CY_U3P_GPIO_NO_INTR;

    apiRetStatus = CyU3PGpioSetSimpleConfig(FX3_SPI_SS, &gpioConfig);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        /* Error handling */
        CyU3PDebugPrint (4, "CyU3PGpioSetSimpleConfig for GPIO Id %d failed, error code = %d\n",
                FX3_SPI_SS, apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Configure GPIO 55 as input(MISO) */
    gpioConfig.outValue    = CyFalse;
    gpioConfig.inputEn     = CyTrue;
    gpioConfig.driveLowEn  = CyFalse;
    gpioConfig.driveHighEn = CyFalse;
    gpioConfig.intrMode    = CY_U3P_GPIO_NO_INTR;

    apiRetStatus = CyU3PGpioSetSimpleConfig(FX3_SPI_MISO, &gpioConfig);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        /* Error handling */
        CyU3PDebugPrint (4, "CyU3PGpioSetSimpleConfig for GPIO Id %d failed, error code = %d\n",
                FX3_SPI_MISO, apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Configure GPIO 56 as output(MOSI) */
    gpioConfig.outValue    = CyFalse;
    gpioConfig.inputEn     = CyFalse;
    gpioConfig.driveLowEn  = CyTrue;
    gpioConfig.driveHighEn = CyTrue;
    gpioConfig.intrMode    = CY_U3P_GPIO_NO_INTR;

    apiRetStatus = CyU3PGpioSetSimpleConfig(FX3_SPI_MOSI, &gpioConfig);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        /* Error handling */
        CyU3PDebugPrint (4, "CyU3PGpioSetSimpleConfig for GPIO Id %d failed, error code = %d\n",
                FX3_SPI_MOSI, apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

}

/* This function pulls up/down the SPI Clock line. */
static CyU3PReturnStatus_t
CyFxSpiSetClockValue (
        CyBool_t isHigh        /* Cyfalse: Pull down the Clock line,
                                  CyTrue: Pull up the Clock line */
        )
{
    CyU3PReturnStatus_t status;

    status = CyU3PGpioSetValue (FX3_SPI_CLK, isHigh);

    return status;
}

/* This function pulls up/down the slave select line. */
static CyU3PReturnStatus_t
CyFxSpiSetSsnLine (
        CyBool_t isHigh        /* Cyfalse: Pull down the SSN line,
                                  CyTrue: Pull up the SSN line */
        )
{
    CyU3PReturnStatus_t status;

    CyU3PBusyWait (1);
    status = CyU3PGpioSetValue (FX3_SPI_SS, isHigh);
    CyU3PBusyWait (1);

    return status;
}

/* This function transmits the byte to the SPI slave device one bit a time.
   Most Significant Bit is transmitted first.
 */
static CyU3PReturnStatus_t
CyFxSpiWriteByte (
        uint8_t data)
{
    uint8_t i = 0;
    for (i = 0; i < 8; i++)
    {
        /* Most significant bit is transferred first. */
        CyU3PGpioSetValue (FX3_SPI_MOSI, ((data >> (7 - i)) & 0x01));

        CyU3PBusyWait (1);
        CyFxSpiSetClockValue (CyTrue);
        CyU3PBusyWait (1);
        CyFxSpiSetClockValue (CyFalse);
    }

    return CY_U3P_SUCCESS;
}

/* This function receives the byte from the SPI slave device one bit at a time.
   Most Significant Bit is received first.
 */
static CyU3PReturnStatus_t
CyFxSpiReadByte (
        uint8_t *data)
{
    uint8_t i = 0;
    CyBool_t temp = CyFalse;

    *data = 0;

    for (i = 0; i < 8; i++)
    {
        CyFxSpiSetClockValue (CyTrue);
        CyU3PBusyWait (1);

        CyU3PGpioGetValue (FX3_SPI_MISO, &temp);
        *data |= (temp << (7 - i));

        CyFxSpiSetClockValue (CyFalse);
        CyU3PBusyWait (1);
    }

    return CY_U3P_SUCCESS;
}

/* This function is used to transmit data to the SPI slave device. The function internally
   calls the CyFxSpiWriteByte function to write to the slave device.
 */
static CyU3PReturnStatus_t
CyFxSpiTransmitWords (
        uint8_t *data,
        uint32_t byteCount)
{
    uint32_t i = 0;
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    if ((!byteCount) || (!data))
    {
        return CY_U3P_ERROR_BAD_ARGUMENT;
    }

    for (i = 0; i < byteCount; i++)
    {
        status = CyFxSpiWriteByte (data[i]);

        if (status != CY_U3P_SUCCESS)
        {
            break;
        }
    }

    return status;
}

/* This function is used receive data from the SPI slave device. The function internally
   calls the CyFxSpiReadByte function to read data from the slave device.
 */
static CyU3PReturnStatus_t
CyFxSpiReceiveWords (
        uint8_t *data,
        uint32_t byteCount)
{
    uint32_t i = 0;
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    if ((!byteCount) || (!data))
    {
        return CY_U3P_ERROR_BAD_ARGUMENT;
    }

    for (i = 0; i < byteCount; i++)
    {
        status = CyFxSpiReadByte (&data[i]);

        if (status != CY_U3P_SUCCESS)
        {
            break;
        }
    }

    return status;
}

/* Wait for the status response from the SPI flash. */
static CyU3PReturnStatus_t
CyFxSpiWaitForStatus (
        void)
{
    uint8_t buf[2], rd_buf[2];
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    /* Wait for status response from SPI flash device. */
    do
    {
        buf[0] = 0x06;  /* Write enable command. */

        CyFxSpiSetSsnLine (CyFalse);
        status = CyFxSpiTransmitWords (buf, 1);
        CyFxSpiSetSsnLine (CyTrue);
        if (status != CY_U3P_SUCCESS)
        {
            CyU3PDebugPrint (2, "SPI WR_ENABLE command failed\n\r");
            return status;
        }

        buf[0] = 0x05;  /* Read status command */

        CyFxSpiSetSsnLine (CyFalse);
        status = CyFxSpiTransmitWords (buf, 1);
        if (status != CY_U3P_SUCCESS)
        {
            CyU3PDebugPrint (2, "SPI READ_STATUS command failed\n\r");
            CyFxSpiSetSsnLine (CyTrue);
            return status;
        }

        status = CyFxSpiReceiveWords (rd_buf, 2);
        CyFxSpiSetSsnLine (CyTrue);
        if(status != CY_U3P_SUCCESS)
        {
            CyU3PDebugPrint (2, "SPI status read failed\n\r");
            return status;
        }

    } while ((rd_buf[0] & 1)|| (!(rd_buf[0] & 0x2)));

    return CY_U3P_SUCCESS;
}

/* SPI read / write for programmer application. */
static CyU3PReturnStatus_t
CyFxSpiTransfer (
        uint16_t  pageAddress,
        uint16_t  byteCount,
        uint8_t  *buffer,
        CyBool_t  isRead)
{
    uint8_t location[4];
    uint32_t byteAddress = 0;
    uint16_t pageCount = DIV_PAGESIZE(byteCount);
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    if (byteCount == 0)
    {
        return CY_U3P_SUCCESS;
    }
    if (MOD_PAGESIZE(byteCount) != 0)
    {
        pageCount ++;
    }

    byteAddress  = MUL_PAGESIZE(pageAddress);
    CyU3PDebugPrint (2, "SPI access - addr: 0x%x, size: 0x%x, pages: 0x%x.\r\n",
            byteAddress, byteCount, pageCount);

    while (pageCount != 0)
    {
        location[1] = (byteAddress >> 16) & 0xFF;       /* MS byte */
        location[2] = (byteAddress >> 8) & 0xFF;
        location[3] = byteAddress & 0xFF;               /* LS byte */

        if (isRead)
        {
            location[0] = 0x03; /* Read command. */

            status = CyFxSpiWaitForStatus ();
            if (status != CY_U3P_SUCCESS)
                return status;

            CyFxSpiSetSsnLine (CyFalse);
            status = CyFxSpiTransmitWords (location, 4);
            if (status != CY_U3P_SUCCESS)
            {
                CyU3PDebugPrint (2, "SPI READ command failed\r\n");
                CyFxSpiSetSsnLine (CyTrue);
                return status;
            }

            status = CyFxSpiReceiveWords (buffer, SPI_PAGE_SIZE);
            if (status != CY_U3P_SUCCESS)
            {
                CyFxSpiSetSsnLine (CyTrue);
                return status;
            }

            CyFxSpiSetSsnLine (CyTrue);
        }
        else /* Write */
        {
            location[0] = 0x02; /* Write command */

            status = CyFxSpiWaitForStatus ();
            if (status != CY_U3P_SUCCESS)
                return status;

            CyFxSpiSetSsnLine (CyFalse);
            status = CyFxSpiTransmitWords (location, 4);
            if (status != CY_U3P_SUCCESS)
            {
                CyU3PDebugPrint (2, "SPI WRITE command failed\r\n");
                CyFxSpiSetSsnLine (CyTrue);
                return status;
            }

            status = CyFxSpiTransmitWords (buffer, SPI_PAGE_SIZE);
            if (status != CY_U3P_SUCCESS)
            {
                CyFxSpiSetSsnLine (CyTrue);
                return status;
            }

            CyFxSpiSetSsnLine (CyTrue);
        }

        /* Update the parameters */
        byteAddress  += SPI_PAGE_SIZE;
        buffer += SPI_PAGE_SIZE;
        pageCount --;

        CyU3PThreadSleep (10);
    }
    return CY_U3P_SUCCESS;
}

/* Function to erase SPI flash sectors. */
static CyU3PReturnStatus_t
CyFxSpiEraseSector (
     CyBool_t  isErase,
     uint8_t   sector,
     uint8_t  *wip)
{
    uint8_t  location[4], rdBuf[2];
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

    if ((!isErase) && (wip == NULL))
    {
        return CY_U3P_ERROR_BAD_ARGUMENT;
    }

    location[0] = 0x06;  /* Write enable. */

    CyFxSpiSetSsnLine (CyFalse);
    status = CyFxSpiTransmitWords (location, 1);
    CyFxSpiSetSsnLine (CyTrue);
    if (status != CY_U3P_SUCCESS)
        return status;

    if (isErase)
    {
        location[0] = 0xD8; /* Sector erase. */
        location[1] = sector;
        location[2] = 0;
        location[3] = 0;

        CyFxSpiSetSsnLine (CyFalse);
        status = CyFxSpiTransmitWords (location, 4);
        CyFxSpiSetSsnLine (CyTrue);
    }
    else
    {
        location[0] = 0x05; /* Read status */

        CyFxSpiSetSsnLine (CyFalse);
        status = CyFxSpiTransmitWords (location, 1);
        if (status != CY_U3P_SUCCESS)
        {
            CyFxSpiSetSsnLine (CyTrue);
            return status;
        }

        status = CyFxSpiReceiveWords (rdBuf, 2);
        CyFxSpiSetSsnLine (CyTrue);
        *wip = rdBuf[0] & 0x1;
    }

    return status;
}

/* DMA callback function to handle the produce events for U to P transfers. */
void
CyFxSlFifoUtoPDmaCallback (
        struct CyU3PDmaChannel   *chHandle,
        enum CyU3PDmaCbType_t  type,
        union CyU3PDmaCBInput_t *input
        )
{
    if (type == CY_U3P_DMA_CB_PROD_EVENT)
    {
        glDMARxCount++;
    }
    else if (type == CY_U3P_DMA_CB_CONS_SUSP) {
        glChannelsSuspended += 1;
    }
}

/* DMA callback function to handle the produce events for P to U transfers. */
void
CyFxSlFifoPtoUDmaCallback (
        struct CyU3PDmaChannel   *chHandle,
        enum CyU3PDmaCbType_t  type,
        union CyU3PDmaCBInput_t *input
        )
{
    if (type == CY_U3P_DMA_CB_PROD_EVENT)
    {
        glDMATxCount++;
    }
    else if (type == CY_U3P_DMA_CB_CONS_SUSP) {
        glChannelsSuspended += 1;
    }
}

/* Callback for USB 3.0 specific endpoint events. See GpifToUsb firmware example and
 * SDK troubleshooting guide.
 */
void
CyFxApplnEpCallback (
        CyU3PUsbEpEvtType evtype,
        CyU3PUSBSpeed_t   usbSpeed,
        uint8_t           epNum)
{
    if (epNum == CY_FX_EP_CONSUMER)
        glInEpBadEvtCount += 1;
    if (epNum == CY_FX_EP_PRODUCER)
        glOutEpBadEvtCount += 1;

    if (evtype == CYU3P_USBEP_SS_RESET_EVT)
    {
        glEpResetEvtCount += 1;
        CyU3PUsbStall (epNum, CyTrue, CyFalse);
    }
}


/* This function starts the slave FIFO loop application. This is called
 * when a SET_CONF event is received from the USB host. The endpoints
 * are configured and the DMA pipe is setup in this function. */
void
CyFxSlFifoApplnStart (
        void)
{
    uint16_t size = 0, burstLenProducer = 0, burstLenConsumer = 0;
    CyU3PEpConfig_t epCfg;
    CyU3PDmaChannelConfig_t dmaCfg;
    CyU3PReturnStatus_t apiRetStatus = CY_U3P_SUCCESS;
    CyU3PUSBSpeed_t usbSpeed = CyU3PUsbGetSpeed();

    /* First identify the usb speed. Once that is identified,
     * create a DMA channel and start the transfer on this. */

    /* Based on the Bus Speed configure the endpoint packet size */
    switch (usbSpeed)
    {
        case CY_U3P_FULL_SPEED:
            size = 64;
            burstLenProducer = 1;
            burstLenConsumer = 1;
            break;

        case CY_U3P_HIGH_SPEED:
            size = 512;
            burstLenProducer = 1;
            burstLenConsumer = 1;
            break;

        case  CY_U3P_SUPER_SPEED:
            size = 1024;
            burstLenProducer = BURST_LEN_PRODUCER;
            burstLenConsumer = BURST_LEN_CONSUMER;
            break;

        default:
            CyU3PDebugPrint (4, "Error! Invalid USB speed.\n");
            CyFxAppErrorHandler (CY_U3P_ERROR_FAILURE);
            break;
    }

    CyU3PMemSet ((uint8_t *)&epCfg, 0, sizeof (epCfg));
    epCfg.enable = CyTrue;
    epCfg.epType = CY_U3P_USB_EP_BULK;
    epCfg.burstLen = burstLenProducer;
    epCfg.pcktSize = size;

    /* Producer endpoint configuration */
    apiRetStatus = CyU3PSetEpConfig(CY_FX_EP_PRODUCER, &epCfg);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "CyU3PSetEpConfig failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler (apiRetStatus);
    }

    epCfg.burstLen = burstLenConsumer;
    /* Consumer endpoint configuration */
    apiRetStatus = CyU3PSetEpConfig(CY_FX_EP_CONSUMER, &epCfg);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "CyU3PSetEpConfig failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler (apiRetStatus);
    }

    /* Create a DMA AUTO channel for U2P transfer.
     * DMA size is set based on the USB speed. */
    CyU3PMemSet ((uint8_t *)&dmaCfg, 0, sizeof (dmaCfg));
	dmaCfg.size  = DMA_BUF_SIZE_U_2_P*size;
	dmaCfg.count = CY_FX_SLFIFO_DMA_BUF_COUNT_U_2_P;
	dmaCfg.prodSckId = CY_FX_PRODUCER_USB_SOCKET;
	dmaCfg.consSckId = CY_FX_CONSUMER_PPORT_SOCKET;
	dmaCfg.cb = CyFxSlFifoUtoPDmaCallback;
	dmaCfg.dmaMode = CY_U3P_DMA_MODE_BYTE;
    dmaCfg.notification = CY_U3P_DMA_CB_CONS_SUSP | CY_U3P_DMA_CB_PROD_EVENT;
	apiRetStatus = CyU3PDmaChannelCreate (&glChHandleSlFifoUtoP, CY_U3P_DMA_TYPE_AUTO_SIGNAL, &dmaCfg);
	if (apiRetStatus != CY_U3P_SUCCESS)
	{
	   CyU3PDebugPrint (4, "CyU3PDmaChannelCreate failed, Error code = %d\n", apiRetStatus);
	   CyFxAppErrorHandler(apiRetStatus);
	}

	/* Create a DMA AUTO channel for P2U transfer. */
	dmaCfg.size  = DMA_BUF_SIZE_P_2_U*size;
	dmaCfg.count = CY_FX_SLFIFO_DMA_BUF_COUNT_P_2_U;
	dmaCfg.prodSckId = CY_FX_PRODUCER_PPORT_SOCKET;
	dmaCfg.consSckId = CY_FX_CONSUMER_USB_SOCKET;
	dmaCfg.cb = CyFxSlFifoPtoUDmaCallback;
	apiRetStatus = CyU3PDmaChannelCreate (&glChHandleSlFifoPtoU, CY_U3P_DMA_TYPE_AUTO_SIGNAL, &dmaCfg);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "CyU3PDmaChannelCreate failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Register callback for event notifications indicating bad link quality. */
    CyU3PUsbRegisterEpEvtCallback (CyFxApplnEpCallback,
        CYU3P_USBEP_SS_RETRY_EVT|CYU3P_USBEP_SS_SEQERR_EVT|CYU3P_USBEP_SS_BTERM_EVT|CYU3P_USBEP_SS_RESET_EVT, 0x02, 0x02);

    /* Flush the Endpoint memory */
    CyU3PUsbFlushEp(CY_FX_EP_PRODUCER);
    CyU3PUsbFlushEp(CY_FX_EP_CONSUMER);

    /* Set DMA channel transfer size. */
    apiRetStatus = CyU3PDmaChannelSetXfer (&glChHandleSlFifoUtoP, CY_FX_SLFIFO_DMA_TX_SIZE);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "CyU3PDmaChannelSetXfer Failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }
    apiRetStatus = CyU3PDmaChannelSetXfer (&glChHandleSlFifoPtoU, CY_FX_SLFIFO_DMA_RX_SIZE);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "CyU3PDmaChannelSetXfer Failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Update the status flag. */
    glIsApplnActive = CyTrue;
}

/* This function stops the slave FIFO loop application. This shall be called
 * whenever a RESET or DISCONNECT event is received from the USB host. The
 * endpoints are disabled and the DMA pipe is destroyed by this function. */
void
CyFxSlFifoApplnStop (
        void)
{
    CyU3PEpConfig_t epCfg;
    CyU3PReturnStatus_t apiRetStatus = CY_U3P_SUCCESS;

    /* Update the flag. */
    glIsApplnActive = CyFalse;

    /* Flush the endpoint memory */
    CyU3PUsbFlushEp(CY_FX_EP_PRODUCER);
    CyU3PUsbFlushEp(CY_FX_EP_CONSUMER);

    /* Destroy the channel */
    CyU3PDmaChannelDestroy (&glChHandleSlFifoUtoP);
    CyU3PDmaChannelDestroy (&glChHandleSlFifoPtoU);

    /* Disable endpoints. */
    CyU3PMemSet ((uint8_t *)&epCfg, 0, sizeof (epCfg));
    epCfg.enable = CyFalse;

    /* Producer endpoint configuration. */
    apiRetStatus = CyU3PSetEpConfig(CY_FX_EP_PRODUCER, &epCfg);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "CyU3PSetEpConfig failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler (apiRetStatus);
    }

    /* Consumer endpoint configuration. */
    apiRetStatus = CyU3PSetEpConfig(CY_FX_EP_CONSUMER, &epCfg);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "CyU3PSetEpConfig failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler (apiRetStatus);
    }
}

void
SuspendBulkPipes ()
{
    uint16_t timeout = 1000;
    if (CyU3PUsbGetSpeed () != CY_U3P_SUPER_SPEED)
    {
		/* Suspend the Bulk pipes and wait until they suspend. */
		glChannelsSuspended = 0;
		//CyU3PDmaChannelSetSuspend (&glChHandleSlFifoUtoP, CY_U3P_DMA_SCK_SUSP_NONE, CY_U3P_DMA_SCK_SUSP_CUR_BUF);
		CyU3PDmaChannelSetSuspend (&glChHandleSlFifoPtoU, CY_U3P_DMA_SCK_SUSP_NONE, CY_U3P_DMA_SCK_SUSP_CUR_BUF);
		while ((glChannelsSuspended<1) && (timeout--))
			CyU3PThreadSleep (1);
    }
}

void
ReturnEp0Data (uint16_t wLength, uint16_t maxLength, uint8_t* buf)
{
	if (maxLength >= wLength)
	{
		SuspendBulkPipes();
		CyU3PUsbSendEP0Data (wLength, buf);
	}
	else if (wLength)
	{
		SuspendBulkPipes();
		CyU3PUsbSendEP0Data (maxLength, buf);
		/* Generate ZLP for short packets that fall on packet boundaries. */
		if ((CyU3PUsbGetSpeed() == CY_U3P_SUPER_SPEED && !(maxLength&0x1ff)) || !(maxLength&0x3f))
		{
			CyU3PUsbSendEP0Data (0, buf);
		}
	}
}

void
ReadGPIOs (uint8_t* buf)
{
    CyBool_t gpioState;
	CyU3PGpioSimpleGetValue (GPIO_0, &gpioState);
	if (gpioState)
	{
		buf[0] = 1;
	}
	else
	{
		buf[0] = 0;
	}

	CyU3PGpioSimpleGetValue (GPIO_1, &gpioState);
	if (gpioState)
	{
		buf[1] = 1;
	}
	else
	{
		buf[1] = 0;
	}
}

void
WriteGPIOs (uint16_t wIndex, uint16_t wValue)
{
	if ((wIndex&0x1) == 0)
	{
		if (wValue&0x1)
		{
			CyU3PGpioSimpleSetValue (GPIO_0, CyTrue);
		}
		else
		{
			CyU3PGpioSimpleSetValue (GPIO_0, CyFalse);
		}
	}
	if ((wIndex&0x2) == 0)
	{
		if (wValue&0x2)
		{
			CyU3PGpioSimpleSetValue (GPIO_1, CyTrue);
		}
		else
		{
			CyU3PGpioSimpleSetValue (GPIO_1, CyFalse);
		}
	}
}

/* Callback to handle the USB setup requests. */
CyBool_t
CyFxSlFifoApplnUSBSetupCB (
        uint32_t setupdat0,
        uint32_t setupdat1
    )
{
    /* Fast enumeration is used. Only requests addressed to the interface, class,
     * vendor and unknown control requests are received by this function. */

    uint8_t  bRequest, bReqType;
    uint8_t  bType, bTarget;
    uint16_t wValue, wIndex, wLength;
    uint16_t receiveCount, receiveTotal;
    CyBool_t isHandled = CyFalse;

    /* Decode the fields from the setup request. */
    bReqType = (setupdat0 & CY_U3P_USB_REQUEST_TYPE_MASK);
    bType    = (bReqType & CY_U3P_USB_TYPE_MASK);
    bTarget  = (bReqType & CY_U3P_USB_TARGET_MASK);
    bRequest = ((setupdat0 & CY_U3P_USB_REQUEST_MASK) >> CY_U3P_USB_REQUEST_POS);
    wValue   = ((setupdat0 & CY_U3P_USB_VALUE_MASK)   >> CY_U3P_USB_VALUE_POS);
    wIndex   = ((setupdat1 & CY_U3P_USB_INDEX_MASK)   >> CY_U3P_USB_INDEX_POS);
    wLength  = ((setupdat1 & CY_U3P_USB_LENGTH_MASK)   >> CY_U3P_USB_LENGTH_POS);

    if (bType == CY_U3P_USB_STANDARD_RQT)
    {
        /* Handle SET_FEATURE(FUNCTION_SUSPEND) and CLEAR_FEATURE(FUNCTION_SUSPEND)
         * requests here. It should be allowed to pass if the device is in configured
         * state and failed otherwise. */
        if ((bTarget == CY_U3P_USB_TARGET_INTF) && ((bRequest == CY_U3P_USB_SC_SET_FEATURE)
                    || (bRequest == CY_U3P_USB_SC_CLEAR_FEATURE)) && (wValue == 0))
        {
            if (glIsApplnActive)
                CyU3PUsbAckSetup ();
            else
                CyU3PUsbStall (0, CyTrue, CyFalse);

            isHandled = CyTrue;
        }

        /* CLEAR_FEATURE request for endpoint is always passed to the setup callback
         * regardless of the enumeration model used. When a clear feature is received,
         * the previous transfer has to be flushed and cleaned up. This is done at the
         * protocol level. Since this is just a loopback operation, there is no higher
         * level protocol. So flush the EP memory and reset the DMA channel associated
         * with it. If there are more than one EP associated with the channel reset both
         * the EPs. The endpoint stall and toggle / sequence number is also expected to be
         * reset. Return CyFalse to make the library clear the stall and reset the endpoint
         * toggle. Or invoke the CyU3PUsbStall (ep, CyFalse, CyTrue) and return CyTrue.
         * Here we are clearing the stall. */
        if ((bTarget == CY_U3P_USB_TARGET_ENDPT) && (bRequest == CY_U3P_USB_SC_CLEAR_FEATURE)
                && (wValue == CY_U3P_USBX_FS_EP_HALT))
        {
            if (glIsApplnActive)
            {
                if (wIndex == CY_FX_EP_PRODUCER)
                {
                    CyU3PDmaChannelReset (&glChHandleSlFifoUtoP);
                    CyU3PUsbFlushEp (CY_FX_EP_PRODUCER);
                    CyU3PUsbResetEp (CY_FX_EP_PRODUCER);
                    CyU3PDmaChannelSetXfer (&glChHandleSlFifoUtoP, CY_FX_SLFIFO_DMA_TX_SIZE);
                }

                if (wIndex == CY_FX_EP_CONSUMER)
                {
                    CyU3PDmaChannelReset (&glChHandleSlFifoPtoU);
                    CyU3PUsbFlushEp (CY_FX_EP_CONSUMER);
                    CyU3PUsbResetEp (CY_FX_EP_CONSUMER);
                    CyU3PDmaChannelSetXfer (&glChHandleSlFifoPtoU, CY_FX_SLFIFO_DMA_RX_SIZE);
                }

                CyU3PUsbStall (wIndex, CyFalse, CyTrue);
                isHandled = CyTrue;
            }
        }
    }
    else if (bType == CY_U3P_USB_VENDOR_RQT)
    {
    	isHandled = CyTrue;
    	if (!wLength)
    	{
			if (bRequest == CY_FX_RQT_SPI_FLASH_ERASE)
			{
				CyFxSpiEraseSector ((wValue) ? CyTrue : CyFalse, (wIndex & 0xFF), glEp0Buffer);
				CyU3PUsbAckSetup ();
			}
			else if (bRequest == 0x02)
			{
				/* Reset debug information. */
				memset (&pibDebug, 0, sizeof(pibDebug));
				CyU3PUsbAckSetup ();
			}
			else if (bRequest == 0x04)
			{
				/* Write GPIOs */
				WriteGPIOs (wIndex, wValue);
				CyU3PUsbAckSetup ();
			}
			else if (bRequest == 0x05)
			{
				/* Discard any data in FIFOs */
				CyU3PDmaChannelReset (&glChHandleSlFifoUtoP);
				CyU3PUsbFlushEp (CY_FX_EP_PRODUCER);
				CyU3PUsbResetEp (CY_FX_EP_PRODUCER);
				CyU3PDmaChannelSetXfer (&glChHandleSlFifoUtoP, CY_FX_SLFIFO_DMA_TX_SIZE);

				CyU3PDmaChannelReset (&glChHandleSlFifoPtoU);
				CyU3PUsbFlushEp (CY_FX_EP_CONSUMER);
				CyU3PUsbResetEp (CY_FX_EP_CONSUMER);
				CyU3PDmaChannelSetXfer (&glChHandleSlFifoPtoU, CY_FX_SLFIFO_DMA_RX_SIZE);

				CyU3PUsbAckSetup ();
			}
			else if (bRequest == 0x06)
			{
				CyU3PUsbAckSetup ();
				CyU3PThreadSleep (100);

				/* Put SPI flash in deep power down and reset */
				CyFxSpiSetSsnLine (CyFalse);
				CyFxSpiWriteByte (0xB9);
				CyFxSpiSetSsnLine (CyTrue);
				CyU3PBusyWait (3);

				CyU3PConnectState (CyFalse, CyFalse);
				CyU3PUsbStop ();
				CyU3PDeviceReset (CyFalse);
			}
			else if (bRequest == 0x09)
			{
				/* Reset DMA buffer transfer counts */
				glDMARxCount = 0;
				glDMATxCount = 0;
				glEp0RqtCount = 0;
				CyU3PUsbAckSetup ();
			}
			else if (bRequest == 0x11)
			{
				CyU3PUsbAckSetup ();
				CyU3PThreadSleep (100);

				/* Make sure the flash is ready. */
				CyFxSpiSetSsnLine (CyFalse);
				CyFxSpiWriteByte (0xAB);
				CyFxSpiSetSsnLine (CyTrue);
				CyU3PBusyWait (30);

				CyU3PConnectState (CyFalse, CyFalse);
				CyU3PUsbStop ();
				CyU3PDeviceReset (CyFalse);
			}
			else if (bRequest == 0x14)
			{
				/* Reset link quality counters. */
				glInEpBadEvtCount = 0;
				glOutEpBadEvtCount = 0;
				glEpResetEvtCount = 0;
				CyU3PUsbAckSetup ();
			}
			else
			{
				isHandled = CyFalse;
			}
    	}
    	else if (bReqType&0x80)
    	{
    		/* Device to host request. */
			if (bRequest == CY_FX_RQT_ID_CHECK)
			{
				ReturnEp0Data (wLength, 32, (uint8_t *)glFirmwareID);
			}
			else if (bRequest == CY_FX_RQT_SPI_FLASH_READ)
			{
				if (wLength > MAX_REQ_LENGTH)
				{
					isHandled = CyFalse;
				}
				else
				{
					CyFxSpiTransfer (wIndex, wLength, glEp0Buffer, CyTrue);
					ReturnEp0Data (wLength, MAX_REQ_LENGTH, glEp0Buffer);
				}
			}
			else if (bRequest == CY_FX_RQT_SPI_FLASH_ERASE)
			{
				CyFxSpiEraseSector ((wValue) ? CyTrue : CyFalse, (wIndex & 0xFF), glEp0Buffer);
				ReturnEp0Data (wLength, 1, glEp0Buffer);
			}
			else if (bRequest == CY_FX_RQT_SPI_FLASH_POLL)
			{
				CyFxSpiEraseSector (CyFalse, 0, glEp0Buffer);
				ReturnEp0Data (wLength, 1, glEp0Buffer);
			}
			else if (bRequest == 0x01)
			{
				/* Send debug information. */
				ReturnEp0Data (wLength, sizeof(pibDebug), (uint8_t *)&pibDebug);
			}
			else if (bRequest == 0x03)
			{
				/* Read GPIOs */
				ReadGPIOs (glEp0Buffer);
				ReturnEp0Data (wLength, 2, glEp0Buffer);
			}
			else if (bRequest == 0x04)
			{
				/* Write GPIOs, return old values. */
				ReadGPIOs (glEp0Buffer);
				WriteGPIOs (wIndex, wValue);
				ReturnEp0Data (wLength, 2, glEp0Buffer);
			}
			else if (bRequest == 0x07)
			{
				/* Wake the SPI flash and read its ID */
				CyFxSpiSetSsnLine (CyFalse);
				CyFxSpiWriteByte (0xAB);
				CyFxSpiSetSsnLine (CyTrue);
				CyU3PBusyWait (30);

				CyFxSpiSetSsnLine (CyFalse);
				CyFxSpiWriteByte (0x9f);
				CyFxSpiReceiveWords (glEp0Buffer, 3);
				CyFxSpiSetSsnLine (CyTrue);

				ReturnEp0Data (wLength, 3, glEp0Buffer);
			}
			else if (bRequest == 0x08)
			{
				/* Return DMA buffer transfer counts */
				glEp0Buffer[0] = glDMARxCount&0xff;
				glEp0Buffer[1] = (glDMARxCount>>8)&0xff;
				glEp0Buffer[2] = (glDMARxCount>>16)&0xff;
				glEp0Buffer[3] = (glDMARxCount>>24)&0xff;
				glEp0Buffer[4] = glDMATxCount&0xff;
				glEp0Buffer[5] = (glDMATxCount>>8)&0xff;
				glEp0Buffer[6] = (glDMATxCount>>16)&0xff;
				glEp0Buffer[7] = (glDMATxCount>>24)&0xff;
				glEp0Buffer[8] = glEp0RqtCount&0xff;
				glEp0Buffer[9] = (glEp0RqtCount>>8)&0xff;
				glEp0Buffer[10] = (glEp0RqtCount>>16)&0xff;
				glEp0Buffer[11] = (glEp0RqtCount>>24)&0xff;

				ReturnEp0Data (wLength, 12, glEp0Buffer);
			}
			else if (bRequest == 0x10)
			{
				/* Return firmware timestamp. */
				glEp0Buffer[0] = FIRMWARE_TIMESTAMP&0xff;
				glEp0Buffer[1] = (FIRMWARE_TIMESTAMP>>8)&0xff;
				glEp0Buffer[2] = (FIRMWARE_TIMESTAMP>>16)&0xff;
				glEp0Buffer[3] = (FIRMWARE_TIMESTAMP>>24)&0xff;

				ReturnEp0Data (wLength, 4, glEp0Buffer);
			}
			else if (bRequest == 0x12)
			{
				CyU3PUsbGetErrorCounts ((uint16_t*)&glEp0Buffer[0], (uint16_t*)&glEp0Buffer[2]);
				ReturnEp0Data (wLength, 4, glEp0Buffer);
			}
			else if (bRequest == 0x13)
			{
				/* Return link quality counters. */
				glEp0Buffer[0] = glInEpBadEvtCount&0xff;
				glEp0Buffer[1] = (glInEpBadEvtCount>>8)&0xff;
				glEp0Buffer[2] = (glInEpBadEvtCount>>16)&0xff;
				glEp0Buffer[3] = (glInEpBadEvtCount>>24)&0xff;
				glEp0Buffer[4] = glOutEpBadEvtCount&0xff;
				glEp0Buffer[5] = (glOutEpBadEvtCount>>8)&0xff;
				glEp0Buffer[6] = (glOutEpBadEvtCount>>16)&0xff;
				glEp0Buffer[7] = (glOutEpBadEvtCount>>24)&0xff;
				glEp0Buffer[8] = glEpResetEvtCount&0xff;
				glEp0Buffer[9] = (glEpResetEvtCount>>8)&0xff;
				glEp0Buffer[10] = (glEpResetEvtCount>>16)&0xff;
				glEp0Buffer[11] = (glEpResetEvtCount>>24)&0xff;

				ReturnEp0Data (wLength, 12, glEp0Buffer);
			}
			else
			{
				isHandled = CyFalse;
			}
    	}
    	else {
    		/* Host to device request. */
    		/* Check data length and receive data OR stall endpoint */
			receiveTotal = 0;
    		if (wLength <= MAX_REQ_LENGTH)
    		{
    			while (receiveTotal < wLength && CY_U3P_SUCCESS == CyU3PUsbGetEP0Data (wLength-receiveTotal, glEp0Buffer+receiveTotal, &receiveCount))
    			{
    				receiveTotal += receiveCount;
    			}
    		}

    		if (wLength == receiveTotal)
    		{
				if (bRequest == CY_FX_RQT_SPI_FLASH_WRITE)
				{
					CyFxSpiTransfer (wIndex, wLength, glEp0Buffer, CyFalse);
				}
				else {
					isHandled = CyFalse;
				}
    		}
    	}
    }

    return isHandled;
}

/* This is the callback function to handle the USB events. */
void
CyFxSlFifoApplnUSBEventCB (
    CyU3PUsbEventType_t evtype,
    uint16_t            evdata
    )
{
    switch (evtype)
    {
        case CY_U3P_USB_EVENT_SETCONF:
            /* Stop the application before (re-)starting. */
            if (glIsApplnActive)
            {
                CyFxSlFifoApplnStop ();
            }
            CyFxSlFifoApplnStart ();
            break;

        case CY_U3P_USB_EVENT_RESET:
        case CY_U3P_USB_EVENT_DISCONNECT:
            /* Stop the application. */
            if (glIsApplnActive)
            {
                CyFxSlFifoApplnStop ();
            }
            break;

        case CY_U3P_USB_EVENT_EP0_STAT_CPLT:
        	glEp0RqtCount++;
            /* Make sure the bulk pipe is resumed once the control transfer is done. */
            if (CyU3PUsbGetSpeed () != CY_U3P_SUPER_SPEED)
            {
                //CyU3PDmaChannelSetSuspend (&glChHandleSlFifoUtoP, CY_U3P_DMA_SCK_SUSP_NONE, CY_U3P_DMA_SCK_SUSP_NONE);
                //CyU3PDmaChannelResume (&glChHandleSlFifoUtoP, CyFalse, CyTrue);
                CyU3PDmaChannelSetSuspend (&glChHandleSlFifoPtoU, CY_U3P_DMA_SCK_SUSP_NONE, CY_U3P_DMA_SCK_SUSP_NONE);
                CyU3PDmaChannelResume (&glChHandleSlFifoPtoU, CyFalse, CyTrue);
            }
            break;

        default:
            break;
    }
}

/* Callback function to handle LPM requests from the USB 3.0 host. This function is invoked by the API
   whenever a state change from U0 -> U1 or U0 -> U2 happens. If we return CyTrue from this function, the
   FX3 device is retained in the low power state. If we return CyFalse, the FX3 device immediately tries
   to trigger an exit back to U0.

   For this application the FX3 is not allowed to go to low power states.
 */
CyBool_t
CyFxApplnLPMRqtCB (
        CyU3PUsbLinkPowerMode link_mode)
{
    return CyFalse;
}

/* Callback function for PIB error notification to aid debugging during FPGA<->FX3 firmware development. */
void
CyFxSlFifoApplnPIBEventCB (
	CyU3PPibIntrType cbType,
	uint16_t cbArg
	)
{
	pibDebug.total_cb_call_count += 1;
	if (cbType == CYU3P_PIB_INTR_DLL_UPDATE)
	{
		if (cbArg == 0)
		{
			pibDebug.pib_dll_unlock_event_count += 1;
		}
	}
	if (cbType == CYU3P_PIB_INTR_ERROR)
	{
		if (CYU3P_GET_PIB_ERROR_TYPE(cbArg) != CYU3P_PIB_ERR_NONE)
		{
			pibDebug.total_pib_error_count += 1;
			switch (CYU3P_GET_PIB_ERROR_TYPE(cbArg))
			{
			case CYU3P_PIB_ERR_THR0_WR_OVERRUN: pibDebug.thr0_wr_overrun_count += 1; break;
			case CYU3P_PIB_ERR_THR1_WR_OVERRUN: pibDebug.thr1_wr_overrun_count += 1; break;
			case CYU3P_PIB_ERR_THR2_WR_OVERRUN: pibDebug.thr2_wr_overrun_count += 1; break;
			case CYU3P_PIB_ERR_THR3_WR_OVERRUN: pibDebug.thr3_wr_overrun_count += 1; break;
			case CYU3P_PIB_ERR_THR0_RD_UNDERRUN: pibDebug.thr0_rd_underrun_count += 1; break;
			case CYU3P_PIB_ERR_THR1_RD_UNDERRUN: pibDebug.thr1_rd_underrun_count += 1; break;
			case CYU3P_PIB_ERR_THR2_RD_UNDERRUN: pibDebug.thr2_rd_underrun_count += 1; break;
			case CYU3P_PIB_ERR_THR3_RD_UNDERRUN: pibDebug.thr3_rd_underrun_count += 1; break;
			case CYU3P_PIB_ERR_THR0_DIRECTION: pibDebug.thr0_direction_count += 1; break;
			case CYU3P_PIB_ERR_THR1_DIRECTION: pibDebug.thr1_direction_count += 1; break;
			case CYU3P_PIB_ERR_THR2_DIRECTION: pibDebug.thr2_direction_count += 1; break;
			case CYU3P_PIB_ERR_THR3_DIRECTION: pibDebug.thr3_direction_count += 1; break;
			case CYU3P_PIB_ERR_THR0_SCK_INACTIVE: pibDebug.thr0_sck_inactive_count += 1; break;
			case CYU3P_PIB_ERR_THR1_SCK_INACTIVE: pibDebug.thr1_sck_inactive_count += 1; break;
			case CYU3P_PIB_ERR_THR2_SCK_INACTIVE: pibDebug.thr2_sck_inactive_count += 1; break;
			case CYU3P_PIB_ERR_THR3_SCK_INACTIVE: pibDebug.thr3_sck_inactive_count += 1; break;
			case CYU3P_PIB_ERR_THR0_ADAP_OVERRUN: pibDebug.thr0_adap_overrun_count += 1; break;
			case CYU3P_PIB_ERR_THR1_ADAP_OVERRUN: pibDebug.thr1_adap_overrun_count += 1; break;
			case CYU3P_PIB_ERR_THR2_ADAP_OVERRUN: pibDebug.thr2_adap_overrun_count += 1; break;
			case CYU3P_PIB_ERR_THR3_ADAP_OVERRUN: pibDebug.thr3_adap_overrun_count += 1; break;
			case CYU3P_PIB_ERR_THR0_ADAP_UNDERRUN: pibDebug.thr0_adap_underrun_count += 1; break;
			case CYU3P_PIB_ERR_THR1_ADAP_UNDERRUN: pibDebug.thr1_adap_underrun_count += 1; break;
			case CYU3P_PIB_ERR_THR2_ADAP_UNDERRUN: pibDebug.thr2_adap_underrun_count += 1; break;
			case CYU3P_PIB_ERR_THR3_ADAP_UNDERRUN: pibDebug.thr3_adap_underrun_count += 1; break;
			case CYU3P_PIB_ERR_THR0_RD_FORCE_END: pibDebug.thr0_rd_force_end_count += 1; break;
			case CYU3P_PIB_ERR_THR1_RD_FORCE_END: pibDebug.thr1_rd_force_end_count += 1; break;
			case CYU3P_PIB_ERR_THR2_RD_FORCE_END: pibDebug.thr2_rd_force_end_count += 1; break;
			case CYU3P_PIB_ERR_THR3_RD_FORCE_END: pibDebug.thr3_rd_force_end_count += 1; break;
			case CYU3P_PIB_ERR_THR0_RD_BURST: pibDebug.thr0_rd_burst_count += 1; break;
			case CYU3P_PIB_ERR_THR1_RD_BURST: pibDebug.thr1_rd_burst_count += 1; break;
			case CYU3P_PIB_ERR_THR2_RD_BURST: pibDebug.thr2_rd_burst_count += 1; break;
			case CYU3P_PIB_ERR_THR3_RD_BURST: pibDebug.thr3_rd_burst_count += 1; break;
			default: pibDebug.other_pib_error_count += 1; break;
			}
		}
		if (CYU3P_GET_GPIF_ERROR_TYPE(cbArg) != CYU3P_GPIF_ERR_NONE)
		{
			pibDebug.total_gpif_error_count += 1;
			switch (CYU3P_GET_GPIF_ERROR_TYPE(cbArg))
			{
			case CYU3P_GPIF_ERR_DATA_READ_ERR: pibDebug.gpif_data_read_count += 1; break;
			case CYU3P_GPIF_ERR_DATA_WRITE_ERR: pibDebug.gpif_data_write_count += 1; break;
			case CYU3P_GPIF_ERR_ADDR_READ_ERR: pibDebug.gpif_addr_read_count += 1; break;
			case CYU3P_GPIF_ERR_ADDR_WRITE_ERR: pibDebug.gpif_addr_write_count += 1; break;
			case CYU3P_GPIF_ERR_INVALID_STATE: pibDebug.gpif_invalid_state_count += 1; break;
			default: pibDebug.other_gpif_error_count += 1; break;
			}
		}
	}
}

/* This function initializes the GPIF interface and initializes
 * the USB interface. */
void
CyFxSlFifoApplnInit (void)
{
    CyU3PPibClock_t pibClock;
    CyU3PReturnStatus_t apiRetStatus = CY_U3P_SUCCESS;

    /* Initialize the p-port block. */
    pibClock.clkDiv = 4;
    pibClock.clkSrc = CY_U3P_SYS_CLK;
    pibClock.isHalfDiv = CyFalse;
    /* Disable DLL for sync GPIF */
    pibClock.isDllEnable = CyFalse;
    apiRetStatus = CyU3PPibInit(CyTrue, &pibClock);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "P-port Initialization failed, Error Code = %d\n",apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Load the GPIF configuration for Slave FIFO sync mode. */
    apiRetStatus = CyU3PGpifLoad (&CyFxGpifConfig);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "CyU3PGpifLoad failed, Error Code = %d\n",apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    CyU3PGpifSocketConfigure (0,CY_FX_PRODUCER_PPORT_SOCKET,6,CyFalse,1);

    CyU3PGpifSocketConfigure (3,CY_FX_CONSUMER_PPORT_SOCKET,6,CyFalse,1);

    /* Start the state machine. */
    apiRetStatus = CyU3PGpifSMStart (RESET,ALPHA_RESET);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "CyU3PGpifSMStart failed, Error Code = %d\n",apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Start the USB functionality. */
    apiRetStatus = CyU3PUsbStart();
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "CyU3PUsbStart failed to Start, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* The fast enumeration is the easiest way to setup a USB connection,
     * where all enumeration phase is handled by the library. Only the
     * class / vendor requests need to be handled by the application. */
    CyU3PUsbRegisterSetupCallback(CyFxSlFifoApplnUSBSetupCB, CyTrue);

    /* Setup the callback to handle the USB events. */
    CyU3PUsbRegisterEventCallback(CyFxSlFifoApplnUSBEventCB);

    /* Register a callback to handle LPM requests from the USB 3.0 host. */
    CyU3PUsbRegisterLPMRequestCallback(CyFxApplnLPMRqtCB);

    /* Register a callback for PIB interrupts to aid debugging.
     * Various event counts can be polled using EP0 control transfers. */
    CyU3PPibRegisterCallback(CyFxSlFifoApplnPIBEventCB, CYU3P_PIB_INTR_DLL_UPDATE|CYU3P_PIB_INTR_ERROR);

    /* Set the USB Enumeration descriptors */

    /* Super speed device descriptor. */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_DEVICE_DESCR, 0, (uint8_t *)CyFxUSB30DeviceDscr);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "USB set device descriptor failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* High speed device descriptor. */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_HS_DEVICE_DESCR, 0, (uint8_t *)CyFxUSB20DeviceDscr);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "USB set device descriptor failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* BOS descriptor */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_BOS_DESCR, 0, (uint8_t *)CyFxUSBBOSDscr);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "USB set configuration descriptor failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Device qualifier descriptor */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_DEVQUAL_DESCR, 0, (uint8_t *)CyFxUSBDeviceQualDscr);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "USB set device qualifier descriptor failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Super speed configuration descriptor */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_CONFIG_DESCR, 0, (uint8_t *)CyFxUSBSSConfigDscr);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "USB set configuration descriptor failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* High speed configuration descriptor */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_HS_CONFIG_DESCR, 0, (uint8_t *)CyFxUSBHSConfigDscr);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "USB Set Other Speed Descriptor failed, Error Code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Full speed configuration descriptor */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_FS_CONFIG_DESCR, 0, (uint8_t *)CyFxUSBFSConfigDscr);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "USB Set Configuration Descriptor failed, Error Code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* String descriptor 0 */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 0, (uint8_t *)CyFxUSBStringLangIDDscr);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "USB set string descriptor failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* String descriptor 1 */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 1, (uint8_t *)CyFxUSBManufactureDscr);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "USB set string descriptor failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* String descriptor 2 */
    apiRetStatus = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 2, (uint8_t *)CyFxUSBProductDscr);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "USB set string descriptor failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }

    /* Connect the USB Pins with super speed operation enabled. */
    apiRetStatus = CyU3PConnectState(CyTrue, CyTrue);
    if (apiRetStatus != CY_U3P_SUCCESS)
    {
        CyU3PDebugPrint (4, "USB Connect failed, Error code = %d\n", apiRetStatus);
        CyFxAppErrorHandler(apiRetStatus);
    }
}

/* Entry function for the slFifoAppThread. */
void
SlFifoAppThread_Entry (
        uint32_t input)
{
    /* Initialize the debug module */
    //CyFxSlFifoApplnDebugInit();

    /* Initialize GPIOs */
    CyFxSlFifoApplnGpioInit();

    /* Initialize the slave FIFO application */
    CyFxSlFifoApplnInit();

    for (;;)
    {
        CyU3PThreadSleep (1000);
        if (glIsApplnActive)
        {
            /* Print the number of buffers received so far from the USB host. */
            CyU3PDebugPrint (6, "Data tracker: buffers received: %d, buffers sent: %d.\n",
                    glDMARxCount, glDMATxCount);
        }
    }
}

/* Application define function which creates the threads. */
void
CyFxApplicationDefine (
        void)
{
    void *ptr = NULL;
    uint32_t retThrdCreate = CY_U3P_SUCCESS;

    /* Allocate the memory for the thread */
    ptr = CyU3PMemAlloc (CY_FX_SLFIFO_THREAD_STACK);

    /* Create the thread for the application */
    retThrdCreate = CyU3PThreadCreate (&slFifoAppThread,           /* Slave FIFO app thread structure */
                          "21:Slave_FIFO_sync",                    /* Thread ID and thread name */
                          SlFifoAppThread_Entry,                   /* Slave FIFO app thread entry function */
                          0,                                       /* No input parameter to thread */
                          ptr,                                     /* Pointer to the allocated thread stack */
                          CY_FX_SLFIFO_THREAD_STACK,               /* App Thread stack size */
                          CY_FX_SLFIFO_THREAD_PRIORITY,            /* App Thread priority */
                          CY_FX_SLFIFO_THREAD_PRIORITY,            /* App Thread pre-emption threshold */
                          CYU3P_NO_TIME_SLICE,                     /* No time slice for the application thread */
                          CYU3P_AUTO_START                         /* Start the thread immediately */
                          );

    /* Check the return code */
    if (retThrdCreate != 0)
    {
        /* Thread Creation failed with the error code retThrdCreate */

        /* Add custom recovery or debug actions here */

        /* Application cannot continue */
        /* Loop indefinitely */
        while(1);
    }
}

/*
 * Main function
 */
int
main (void)
{
    CyU3PIoMatrixConfig_t io_cfg;
    CyU3PReturnStatus_t status = CY_U3P_SUCCESS;
    CyU3PSysClockConfig_t clkCfg;

	/* setSysClk400 clock configurations */
	clkCfg.setSysClk400 = CyTrue;   /* FX3 device's master clock is set to a frequency > 400 MHz */
	clkCfg.cpuClkDiv = 2;           /* CPU clock divider */
	clkCfg.dmaClkDiv = 2;           /* DMA clock divider */
	clkCfg.mmioClkDiv = 2;          /* MMIO clock divider */
	clkCfg.useStandbyClk = CyFalse; /* device has no 32KHz clock supplied */
	clkCfg.clkSrc = CY_U3P_SYS_CLK; /* Clock source for a peripheral block  */

    /* Initialize the device */
    status = CyU3PDeviceInit (&clkCfg);
    if (status != CY_U3P_SUCCESS)
    {
        goto handle_fatal_error;
    }

    /* Initialize the caches. Enable instruction cache and keep data cache disabled.
     * The data cache is useful only when there is a large amount of CPU based memory
     * accesses. When used in simple cases, it can decrease performance due to large 
     * number of cache flushes and cleans and also it adds to the complexity of the
     * code. */
    status = CyU3PDeviceCacheControl (CyTrue, CyFalse, CyFalse);
    if (status != CY_U3P_SUCCESS)
    {
        goto handle_fatal_error;
    }

    /* Configure the IO matrix for the device. On LinoSPAD we use the SPI port
     * connected to the IO(53:56). We use I2C for printing debug information.
     * No other peripherals are available in 32 bit mode. */
    io_cfg.useUart   = CyFalse;
    io_cfg.useI2C    = CyTrue;
    io_cfg.useI2S    = CyFalse;
    io_cfg.useSpi    = CyFalse;
    io_cfg.isDQ32Bit = CyTrue;
    io_cfg.lppMode   = CY_U3P_IO_MATRIX_LPP_DEFAULT;
    /* 53-56 GPIOs are enabled and we override to CTL ports later. */
    io_cfg.gpioSimpleEn[0]  = 0;
    io_cfg.gpioSimpleEn[1]  = 0x01E00000;
    io_cfg.gpioComplexEn[0] = 0;
    io_cfg.gpioComplexEn[1] = 0;
    status = CyU3PDeviceConfigureIOMatrix (&io_cfg);
    if (status != CY_U3P_SUCCESS)
    {
        goto handle_fatal_error;
    }

    /* This is a non returnable call for initializing the RTOS kernel */
    CyU3PKernelEntry ();

    /* Dummy return to make the compiler happy */
    return 0;

handle_fatal_error:

    /* Cannot recover from this error. */
    while (1);
}

/* [ ] */

