#include "fx3stream.h"

void FX3Stream::allocTransfers() {
    while( transfers.size() < FX3_NUM_TRANSFERS ) {
        libusb_transfer* transfer = libusb_alloc_transfer(0);
        unsigned char* buf = (unsigned char*)malloc( FX3_TRANSFER_SIZE*sizeof(unsigned char) );
        if( !transfer || !buf ) {
            cerr << "Error allocating transfer." << endl;
            error = 1;
            return;
        }
        transfers.push_back(transfer);
        recvBufs.push_back(buf);
    }
}

void FX3Stream::freeTransfers() {
    for( unsigned i = 0; i < transfers.size(); ++i ) {
        libusb_free_transfer( transfers[i] );
        free( recvBufs[i] );
    }
    transfers.clear();
    recvBufs.clear();
}

void FX3Stream::printTransfer(libusb_transfer *transfer) {
    cerr << "Transfer: ";
    if( transfer->endpoint & 0x80 ) {
        cerr << "IN";
    }
    else {
        cerr << "OUT";
    }
    if( transfer->length != transfer->actual_length ) {
        cerr << ", SHORT";
    }
    cerr << ", requested: " << transfer->length << ", actual: " << transfer->actual_length << ", code: ";
    switch(transfer->status) {
    case LIBUSB_TRANSFER_COMPLETED: cerr << "COMPLETED" << endl; break;
    case LIBUSB_TRANSFER_ERROR: cerr << "ERROR" << endl; break;
    case LIBUSB_TRANSFER_TIMED_OUT: cerr << "TIMED_OUT" << endl; break;
    case LIBUSB_TRANSFER_CANCELLED: cerr << "CANCELLED" << endl; break;
    case LIBUSB_TRANSFER_STALL: cerr << "STALL" << endl; break;
    case LIBUSB_TRANSFER_NO_DEVICE: cerr << "NO_DEVICE" << endl; break;
    case LIBUSB_TRANSFER_OVERFLOW: cerr << "OVERFLOW" << endl; break;
    default: cerr << "UNKNOWN" << endl; break;
    }
}

void FX3Stream::receiveCallback(libusb_transfer *transfer) {
    FX3Stream* fx3 = (FX3Stream*)transfer->user_data;
    if( transfer->status != LIBUSB_TRANSFER_COMPLETED ) {
        if( FX3_DEBUG ) {
            printTransfer(transfer);
        }
        switch(transfer->status) {
        case LIBUSB_TRANSFER_TIMED_OUT: fx3->error = LIBUSB_ERROR_TIMEOUT; break;
        default: fx3->error = -1; break;
        }
    }
    fx3->submittedBytes -= transfer->length;

    if( fx3->transferredBytes + transfer->actual_length < fx3->totalBytes ) {
        //should have a full packet as requested
        if( transfer->length != transfer->actual_length ) {
            if( FX3_DEBUG && transfer->status == LIBUSB_TRANSFER_COMPLETED ) printTransfer(transfer);
            fx3->shortPackets += 1;
        }

        memcpy( &fx3->extBuf[fx3->transferredBytes], transfer->buffer, transfer->actual_length );
        fx3->transferredBytes += transfer->actual_length;
    }
    else {
        //receive remaining bytes and put extra ones in internal buffer
        uint64_t rem = fx3->totalBytes-fx3->transferredBytes;
        memcpy( &fx3->extBuf[fx3->transferredBytes], transfer->buffer, rem );
        fx3->transferredBytes = fx3->totalBytes;
        memcpy( fx3->intBuf, transfer->buffer + fx3->totalBytes-fx3->transferredBytes, transfer->actual_length - rem );
        fx3->storedBytes = transfer->actual_length - rem;
    }

    if( !fx3->error && fx3->transferredBytes+fx3->submittedBytes < fx3->totalBytes ) {
        int64_t remainingBytes = fx3->totalBytes-(fx3->transferredBytes+fx3->submittedBytes);
        uint32_t size = FX3_TRANSFER_SIZE;
        if( remainingBytes < FX3_TRANSFER_SIZE  ) { //request full packets
            size = ((remainingBytes+fx3->inPktSize-1)/fx3->inPktSize)*fx3->inPktSize;
        }
        libusb_fill_bulk_transfer( transfer, fx3->devhandle, FX3_IN_EP, transfer->buffer,
                                   size, FX3Stream::receiveCallback, fx3, transfer->timeout );
        fx3->error = libusb_submit_transfer( transfer );
        if( fx3->error ) {
            cerr << "Error submitting transfer: " << libusb_error_name(fx3->error) << endl;
        }
        fx3->submittedBytes += size;
    }
}

void FX3Stream::sendCallback(libusb_transfer *transfer) {
    FX3Stream* fx3 = (FX3Stream*)transfer->user_data;
    if( transfer->status != LIBUSB_TRANSFER_COMPLETED ) {
        if( FX3_DEBUG ) {
            printTransfer(transfer);
        }
        switch(transfer->status) {
        case LIBUSB_TRANSFER_TIMED_OUT: fx3->error = LIBUSB_ERROR_TIMEOUT; break;
        default: fx3->error = -1; break;
        }
    }
    if( transfer->length != transfer->actual_length ) {
        if( FX3_DEBUG && transfer->status == LIBUSB_TRANSFER_COMPLETED ) printTransfer(transfer);
        fx3->shortPackets += 1;
    }
    fx3->submittedBytes -= transfer->length;
    fx3->transferredBytes += transfer->actual_length;
    if( !fx3->error && fx3->transferredBytes+fx3->submittedBytes < fx3->totalBytes ) {
        int64_t remainingBytes = fx3->totalBytes-(fx3->transferredBytes+fx3->submittedBytes);
        if( remainingBytes > FX3_TRANSFER_SIZE ) {
            libusb_fill_bulk_transfer( transfer, fx3->devhandle, FX3_OUT_EP, &fx3->extBuf[fx3->transferredBytes+fx3->submittedBytes],
                    FX3_TRANSFER_SIZE, FX3Stream::sendCallback, fx3, transfer->timeout );
            fx3->submittedBytes += FX3_TRANSFER_SIZE;
        }
        else {
            libusb_fill_bulk_transfer( transfer, fx3->devhandle, FX3_OUT_EP, &fx3->extBuf[fx3->transferredBytes+fx3->submittedBytes],
                    remainingBytes, FX3Stream::sendCallback, fx3, transfer->timeout );
            fx3->submittedBytes += remainingBytes;
        }
        fx3->error = libusb_submit_transfer( transfer );
        if( fx3->error ) {
            cerr << "Error submitting transfer: " << libusb_error_name(fx3->error) << endl;
        }
    }
}

FX3Stream::FX3Stream()
    : vid(0), pid(0), devhandle(0), interfaceClaimed(false), inPktSize(0), outPktSize(0), error(0), storedBytes(0), consumedBytes(0)
{}

FX3Stream::FX3Stream(unsigned short vid, unsigned short pid)
    : vid(vid), pid(pid), devhandle(0), interfaceClaimed(false), inPktSize(0), outPktSize(0), error(0), storedBytes(0), consumedBytes(0)
{
    init( vid, pid );
}

FX3Stream::~FX3Stream() {
    release();
}

FX3Stream::operator bool() {
    return error == 0;
}

void FX3Stream::init(unsigned short vid, unsigned short pid) {
    this->vid = vid;
    this->pid = pid;
    error = libusb_init(0);
    if( error < 0 ) {
        cerr << "Error initialising libusb: " << libusb_error_name(error) << endl;
        return;
    }
    if( FX3_DEBUG ) {
        libusb_set_debug(0,LIBUSB_LOG_LEVEL_WARNING);
    }
    devhandle = libusb_open_device_with_vid_pid(0, vid, pid);
    if( !devhandle ) {
        cerr << "Error opening the device" << endl;
        error = 1;
        return;
    }
    error = libusb_reset_device( devhandle );
    if( error < 0 ) {
        cerr << "Error resetting the device: " << libusb_error_name(error) << endl;
        return;
    }
    error = libusb_kernel_driver_active( devhandle, 1 );
    if( error != LIBUSB_ERROR_NOT_SUPPORTED && error < 0 ) {
        cerr << "Error checking for kernel driver: " << libusb_error_name(error) << endl;
        return;
    }
    else if( error == 1 ) {
        cerr << "Error: Kernel driver active." << endl;
        return;
    }
    error = libusb_set_configuration( devhandle, 1 );
    if( error < 0 ) {
        cerr << "Error setting the configuration: " << libusb_error_name(error) << endl;
        return;
    }
    error =  libusb_claim_interface( devhandle, 0 );
    if( error < 0 ) {
        cerr << "Error claiming the interface: " << libusb_error_name(error) << endl;
        return;
    }
    interfaceClaimed = true;
    inPktSize = libusb_get_max_packet_size( libusb_get_device(devhandle), FX3_IN_EP );
    if( inPktSize < 0 ) {
        cerr << "Error getting IN EP packet size: " << libusb_error_name(error) << endl;
        return;
    }
    outPktSize = libusb_get_max_packet_size( libusb_get_device(devhandle), FX3_OUT_EP );
    if( outPktSize < 0 ) {
        cerr << "Error getting OUT EP packet size: " << libusb_error_name(error) << endl;
        return;
    }
    if( FX3_DEBUG ) {
        cerr << "inPktSize: " << inPktSize << ", outPktSize: " << outPktSize << endl;
    }
    allocTransfers();
}

void FX3Stream::release() {
    freeTransfers();
    if( interfaceClaimed ) {
        error = libusb_release_interface( devhandle, 0 );
        if( error < 0 ) {
            cerr << "Error releasing the interface: " << libusb_error_name(error) << endl;
            return;
        }
        interfaceClaimed = false;
    }
    libusb_close( devhandle );
    libusb_exit(0);
}

void FX3Stream::clearInternalBuffer() {
    storedBytes = consumedBytes = 0;
}

int64_t FX3Stream::receive(int64_t maxWords, uint32_t *data, unsigned timeout, bool shortOK) {
    if( error ) { cerr << "Blocked testtoevoeging 229" << endl; return 0; }
    totalBytes = maxWords*4;
    extBuf = (unsigned char*)data;
    transferredBytes = 0;
    submittedBytes = 0;
    shortPackets = 0;

    while( transferredBytes < totalBytes ) {
        //Retrieve from internal buffer
        while( consumedBytes < storedBytes && transferredBytes < totalBytes ) {
            extBuf[transferredBytes] = intBuf[consumedBytes];
            transferredBytes += 1;
            consumedBytes += 1;
        }

        if( transferredBytes && shortOK ) {
            break;
        }

        //Request remaining data
        if( transferredBytes < totalBytes ) {
            storedBytes = 0;
            consumedBytes = 0;
            for( unsigned i = 0; i < transfers.size() && transferredBytes+submittedBytes < totalBytes; ++i ) {
                int64_t remainingBytes = totalBytes-(transferredBytes+submittedBytes);
                uint32_t size = FX3_TRANSFER_SIZE;
                if( remainingBytes < FX3_TRANSFER_SIZE  ) { //request full packets
                    size = ((remainingBytes+inPktSize-1)/inPktSize)*inPktSize;
                }
                libusb_fill_bulk_transfer( transfers[i], devhandle, FX3_IN_EP, recvBufs[i],
                                           size, FX3Stream::receiveCallback, this, timeout );
                error = libusb_submit_transfer( transfers[i] );
                if( error ) {
                    cerr << "Error submitting transfer: " << libusb_error_name(error) << endl;
                    break;
                }
                submittedBytes += size;
            }
            //Wait for data
            while( submittedBytes ) {
                int r = libusb_handle_events_completed(0,0);
                if( r ) {
                    cerr << "Error handling events: " << libusb_error_name(r) << endl;
                    error = r;
                    break;
                }
            }
            if( shortPackets ) {
                if( FX3_DEBUG ) cerr << "Warning: " << shortPackets << " short packets in middle of incoming transfers." << endl;
                shortPackets = 0;
            }
            if( error < 0 && error != LIBUSB_ERROR_TIMEOUT ) {
                cerr << "Error receiving data: " << libusb_error_name(error) << endl;
                break;
            }
            else if( error == LIBUSB_ERROR_TIMEOUT ) {
                error = 0;
                break;
            }
        }
    }
    if( FX3_DEBUG ) {
        cerr << "R: " << transferredBytes << " bytes, " << shortPackets << " short packets" << endl;
        if( FX3_PRINT_DATA ) {
            for( int i = 0; i < transferredBytes-3; i += 4 ) {
                cerr << hex << setw(2) << setfill('0') << (unsigned)extBuf[i+3];
                cerr << hex << setw(2) << setfill('0') << (unsigned)extBuf[i+2];
                cerr << hex << setw(2) << setfill('0') << (unsigned)extBuf[i+1];
                cerr << hex << setw(2) << setfill('0') << (unsigned)extBuf[i+0] << dec << ' ';
            }
            cerr << endl;
        }
    }
    return transferredBytes/4;
}

int64_t FX3Stream::receive(int64_t maxBytes, unsigned char *data, unsigned timeout, bool shortOK) {
    int64_t r = receive( maxBytes/4, (uint32_t*)data, timeout, shortOK );
    if( r < 0 )
        return r;
    else
        return r*4;
}

int64_t FX3Stream::send(int64_t words, uint32_t *data, unsigned timeout) {
    if( error ) { cerr << "Blocked" << endl; return 0; }
    totalBytes = words*4;
    extBuf = (unsigned char*)data;
    transferredBytes = 0;
    submittedBytes = 0;
    shortPackets = 0;

    //Start transfer
    for( unsigned i = 0; i < transfers.size() && transferredBytes+submittedBytes < totalBytes; ++i ) {
        int64_t remainingBytes = totalBytes-(transferredBytes+submittedBytes);
        if( remainingBytes > FX3_TRANSFER_SIZE ) {
            libusb_fill_bulk_transfer( transfers[i], devhandle, FX3_OUT_EP, &extBuf[transferredBytes+submittedBytes],
                    FX3_TRANSFER_SIZE, FX3Stream::sendCallback, this, timeout );
            submittedBytes += FX3_TRANSFER_SIZE;
        }
        else if( remainingBytes > 0 ) {
            libusb_fill_bulk_transfer( transfers[i], devhandle, FX3_OUT_EP, &extBuf[transferredBytes+submittedBytes],
                    remainingBytes, FX3Stream::sendCallback, this, timeout );
            submittedBytes += remainingBytes;
        }
        error = libusb_submit_transfer( transfers[i] );
        if( error ) {
            cerr << "Error submitting transfer: " << libusb_error_name(error) << endl;
            break;
        }
    }
    //Wait for transfer
    while( submittedBytes ) {
        int r = libusb_handle_events_completed(0,0);
        if( r ) {
            cerr << "Error handling events: " << libusb_error_name(r) << endl;
            error = r;
            break;
        }
    }
    if( shortPackets ) {
        cerr << "Error: Short packet(s) in outgoing transfers." << endl;
        shortPackets = 0;
    }
    if( error < 0 ) {
        cerr << "Error sending data: " << libusb_error_name(error) << endl;
    }
    if( error == LIBUSB_ERROR_TIMEOUT ) {
        error = 0;
    }
    return transferredBytes/4;
}

int64_t FX3Stream::send(int64_t bytes, unsigned char *data, unsigned timeout) {
    int64_t r = send( bytes/4, (uint32_t*)data, timeout );
    if( r < 0 )
        return r;
    else
        return r*4;
}

void FX3Stream::sendWord(uint8_t adr, uint32_t data, unsigned timeout) {
    if( error ) { cerr << "Blocked" << endl; return; }
    uint32_t msg[2] = { FX3_FPGA_HEADER(adr,1), data };
    send( 2, msg, timeout );
}

int FX3Stream::controlTransfer(unsigned reqType, unsigned req, unsigned value, unsigned index, unsigned char *data, unsigned length, unsigned timeout)
{
    int retval = libusb_control_transfer( devhandle, reqType, req, value, index, data, length, timeout );
    if( retval < 0 ) {
        cerr << "Error in control transfer: " << libusb_error_name(retval) << endl;
    }
    return retval;
}

void FX3Stream::reset() {
    //Assert FPGA reset
    controlTransfer( 0x40, 0x04, 0x01, ~0x01, 0, 0 );
    //Clear data on FX3
    controlTransfer( 0x40, 0x05, 0x00, 0x00, 0, 0 );
    //Clear internal data
    clearInternalBuffer();
    //Release FPGA reset
    controlTransfer( 0x40, 0x04, 0x00, ~0x01, 0, 0 );
    error = 0;
}

void FX3Stream::reinit() {
    release();
    clearInternalBuffer();
    init(vid, pid);
}
