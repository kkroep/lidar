#include "processing.h"

#include "fx3stream.h"
#include <iostream>
#include <QMap>
#include <QStringList>

Processing::Processing()
{
    reset();
    numSegments = 0; //mark invalid
}

void Processing::reset()
{
    largestBin = 0.0;
    progValid = false;

    perPixel = false;
    numSegments = PROC_DEFAULT_SEGMENT_COUNT;
    numInputBins = PROC_DEFAULT_BIN_COUNT;
    numOutputBins = PROC_DEFAULT_BIN_COUNT;

    tdcCharacteristics.clear();
    tdcCharacteristics.resize(PROC_NUM_TDCS);

    for( uint32_t tdc = 0; tdc < tdcCharacteristics.size(); ++tdc )
    {
        TDC_characteristic &c = tdcCharacteristics[tdc];

        c.totalCommits = numInputBins;
        c.binSize.resize(numInputBins);
        c.binPosition.resize(numInputBins);
        c.firstOutputBin.resize(numInputBins);
        c.commitCount.resize(numInputBins);
        c.factors.resize(numInputBins,vector<double>(3));
        c.code.resize(numInputBins);

        for( uint32_t i = 0; i < numInputBins; ++i ) {
            c.binPosition[i] = 2500.0/numInputBins*i;
            c.binSize[i] = 2500.0/numInputBins;
            c.firstOutputBin[i] = i;
            c.commitCount[i] = 1;
            c.factors[i][0] = 1.0;
            c.factors[i][1] = 0.0;
            c.factors[i][2] = 0.0;
            commitCode(tdc,i);
        }
    }

    compile();
}

void Processing::analyze(const vector<uint64_t>& statistics, uint32_t inputBinsPerPixel, uint32_t segmentsPerTDC, uint32_t outputBinsPerSegment, bool perPixelCorrection = false )
{
    if( statistics.size() < PROC_NUM_PIXELS*inputBinsPerPixel ) return;

    numSegments = segmentsPerTDC;
    numInputBins = inputBinsPerPixel/numSegments;
    numOutputBins = outputBinsPerSegment;
    perPixel = perPixelCorrection;

    uint32_t correctionCount = PROC_NUM_TDCS;
    if( perPixel ) {
        correctionCount *= 4;
    }
    double segmentSize = 2500.0 * inputBinsPerPixel/140.0 / segmentsPerTDC;

    uint32_t histlen = inputBinsPerPixel;
    tdcCharacteristics.clear();
    tdcCharacteristics.resize(correctionCount);
    largestBin = 0.0;
    for( uint32_t tdc = 0; tdc < correctionCount; ++tdc )
    {
        TDC_characteristic &c = tdcCharacteristics[tdc];

        c.totalEvents = 0;
        c.counts.resize(numInputBins);
        for( uint32_t code = 0; code < numInputBins; ++code )
        {
            uint64_t events = 0;
            if( perPixel ) {
                for( uint32_t bin = code; bin < histlen; bin += numInputBins ) {
                    events += statistics[tdc*histlen+bin];
                }
            }
            else {
                for( uint32_t bin = code; bin < histlen; bin += numInputBins ) {
                    //sum multiplexed pixels
                    events += statistics[(tdc+0*PROC_NUM_TDCS)*histlen+bin]
                            + statistics[(tdc+1*PROC_NUM_TDCS)*histlen+bin]
                            + statistics[(tdc+2*PROC_NUM_TDCS)*histlen+bin]
                            + statistics[(tdc+3*PROC_NUM_TDCS)*histlen+bin];
                }
            }
            c.totalEvents += events;
            c.counts[code] += events;
        }
        if(0 == c.totalEvents) {
            reset();
            return;
        }

        c.totalCommits = 0;
        c.binSize.resize(numInputBins);
        c.binPosition.resize(numInputBins);
        c.firstOutputBin.resize(numInputBins);
        c.commitCount.resize(numInputBins);
        c.factors.resize(numInputBins,vector<double>(3));
        c.code.resize(numInputBins);

        const double outputBinSize = segmentSize/numOutputBins; // [ps]
        double outputPosition = 0.0; // [ps]
        int nextBin = 0;
        double nextBinLimit = outputBinSize;
        for( uint32_t i = 0; i < numInputBins; ++i ) {
            double size = ((double)c.counts[i])/c.totalEvents*segmentSize; // [ps]
            largestBin = max(largestBin,size);

            c.binPosition[i] = outputPosition;
            c.binSize[i] = size;
            c.firstOutputBin[i] = nextBin;

            //Calculate outputs
            double lastFactor = 1.0;
            double nextOutputPosition = outputPosition;
            while(outputPosition+size > nextBinLimit){
                c.commitCount[i] += 1;
                double factor = (nextBinLimit-nextOutputPosition)/size;
                nextOutputPosition = nextBinLimit;
                nextBinLimit = (nextBin+c.commitCount[i]+1.0)*outputBinSize;
                lastFactor -= factor;
                if(c.commitCount[i]==1){
                    c.factors[i][0] = factor;
                }else{
                    c.factors[i][1] = factor;
                }
            }
            outputPosition += size;
            nextBin += c.commitCount[i];
            c.totalCommits += c.commitCount[i];
            c.factors[i][2] = lastFactor;

            commitCode(tdc, i);
        }
        //Check commit count, fix last commit
        if(c.totalCommits > numOutputBins) {
            cerr << "Error: too many commits" << endl;
            progValid = false;
        }
        else if(c.totalCommits < numOutputBins-1) {
            cerr << "Error: too few commits" << endl;
            progValid = false;
        }
        else if(c.totalCommits == numOutputBins) {
            for(uint32_t i = numInputBins-1; i > 0; --i) {
                if(c.commitCount[i]) {
                    c.commitCount[i] -= 1;
                    c.factors[i][2] += c.factors[i][1];
                    c.factors[i][1] = 0.0;
                    commitCode(tdc,i);
                    break;
                }
            }
        }
        if(c.commitCount[numInputBins-1]) {
            c.factors[numInputBins-1][1] += c.factors[numInputBins-1][2];
            c.factors[numInputBins-1][2] = 0.0;
        }
        else {
            c.factors[numInputBins-1][0] = 1.0;
            c.factors[numInputBins-1][2] = 0.0;
        }
        c.commitCount[numInputBins-1] += 1;
        commitCode(tdc,numInputBins-1);
        c.totalCommits = numOutputBins;
    }
}

void Processing::compile()
{
    progValid = true;
    uint32_t commits = makeProgram();

    if( !progValid ) {
        metaWords.clear();
        commandWords.clear();
        return;
    }

    if( commits&0x3f ) {
        cerr << "Error: Total commit count not a multiple of TDC count: " << commits << endl;
        reset();
        return;
    }

    if(commandWords.size()>3*4096) {
        cerr << "Error: Maximum program size exceeded." << endl;
        reset();
        return;
    }

    writedata.clear();
    writedata.push_back(0); //Prepare header
    writedata.push_back(0x80000000);
    writedata.push_back(0x90010000|(metaWords.size()-1));
    for( uint32_t i = 0; i < metaWords.size(); ++i ) {
        writedata.push_back(metaWords[i]);
        writedata.push_back(commandWords[i]>>32);
        writedata.push_back(commandWords[i]&0xffffffff);
    }
    writedata.push_back(0x70000000);
    writedata[0] = FX3_FPGA_HEADER(4,writedata.size()-1);
}

uint32_t Processing::length()
{
    return metaWords.size();
}

vector<uint32_t>& Processing::getProgramData()
{
    return writedata;
}

uint32_t Processing::getInputLength()
{
    return numInputBins*numSegments;
}

uint32_t Processing::getOutputLength()
{
    return numOutputBins*numSegments;
}

uint32_t Processing::getNumSegments()
{
    return numSegments;
}

const Processing::TDC_characteristic &Processing::getCharacteristic(uint32_t tdc)
{
    return tdcCharacteristics[tdc%tdcCharacteristics.size()];
}

uint64_t Processing::shl(uint64_t v, uint32_t c)
{
    if(c > 63) return 0;
    return v<<c;
}

uint64_t Processing::shr(uint64_t v, uint32_t c)
{
    if(c > 63) return 0;
    return v>>c;
}

void Processing::appendProgram(QString &program)
{
    vector<uint8_t> tdcMetaWords;
    vector<uint64_t> tdcCommandWords;
    QString  last64;
    while(program.length()) {
        last64 = program.right(64);
        program.chop(64);
        bool ok = false;
        uint64_t cmdword = last64.toULongLong(&ok,2);
        if(!ok) {
            cerr << "Error 1" << endl;
            progValid = false;
        }
        tdcCommandWords.push_back(cmdword);
    }
    uint32_t lastLength = last64.length();
    if(tdcCommandWords.size()<4) {
        cerr << "Error 2" << endl;
        progValid = false;
        while(tdcCommandWords.size()<4)
            tdcCommandWords.push_back(0);
    }
//    cout << lastLength << endl;

    uint32_t bitsUsed = 0;
    uint64_t back, front = 0;
    uint32_t totalActions = 0;
    for( uint32_t i = 0; i < tdcCommandWords.size(); ++i ) {
        front |= shl(tdcCommandWords[i],bitsUsed);
        back = shr(tdcCommandWords[i],64-bitsUsed);
        bitsUsed += 64;
//        cout << bitsUsed << "; " << hex << back << ":" << front << dec << endl;

        uint32_t actionCount = 0;
        uint32_t actionLength = 0;
        while( ((i!=tdcCommandWords.size()-1 && bitsUsed >= 40) || (i==tdcCommandWords.size()-1 && bitsUsed > 64-lastLength)) && actionCount < 64 ) {
            actionCount += 2;
            actionLength = (front&7)<<3;
            bitsUsed -= actionLength;
//            cout << bitsUsed << "; " << actionLength << "; " << hex << (front&((1<<actionLength)-1)) << "; ";
            front >>= actionLength;
            front |= shl(back,64-actionLength);
            back >>= actionLength;
//            cout << hex << back << ":" << front << dec << endl;
        }
        totalActions += actionCount;
        if(actionCount > 31) {
                cerr << "Error 4: " << actionCount << endl;
                progValid = false;
        }
        tdcMetaWords.push_back((actionCount>>1)-1);
    }
    if( totalActions != numInputBins || tdcMetaWords.size() != tdcCommandWords.size() ) {
        cerr << "Error 3: " << totalActions << "; " << tdcMetaWords.size()-tdcCommandWords.size() << endl;
        progValid = false;
        while(tdcMetaWords.size() < tdcCommandWords.size()) {
            tdcMetaWords.push_back(0);
        }
    }
    tdcMetaWords[tdcMetaWords.size()-4] |= 0x20; //End marker
    tdcMetaWords[tdcMetaWords.size()-1] |= 0x10; //Reload marker

    commandWords.insert(commandWords.end(),tdcCommandWords.begin(), tdcCommandWords.end());
    metaWords.insert(metaWords.end(), tdcMetaWords.begin(), tdcMetaWords.end());
//    for( uint32_t i = 0; i < tdcCommandWords.size(); ++i ) {
//        cout << setw(2) << setfill('0') << hex << (uint32_t)tdcMetaWords[i] << dec << ' ';
//        cout << setw(16) << setfill('0') << hex << tdcCommandWords[i] << dec << endl;
//    }
}

void Processing::commitCode(uint32_t tdc, uint32_t i)
{
    TDC_characteristic &c = tdcCharacteristics[tdc];
    switch(c.commitCount[i]){
        case 0: c.code[i] = "001"; break;
        case 1: c.code[i] = QString("%1").arg(QString::number((int)(255.999*c.factors[i][2]),2),8,'0')+"000"; break;
        case 2: c.code[i] = QString("%1%2").arg(QString::number((int)(255.999*c.factors[i][0]),2),8,'0').arg(QString::number((int)(255.999*c.factors[i][2]),2),8,'0')+"010"; break;
        case 3: c.code[i] = QString("%1%2").arg(QString::number((int)(255.999*c.factors[i][0]),2),8,'0').arg(QString::number((int)(255.999*c.factors[i][2]),2),8,'0')+"100"; break;
        case 4: c.code[i] = QString("%1%2").arg(QString::number((int)(255.999*c.factors[i][0]),2),8,'0').arg(QString::number((int)(255.999*c.factors[i][2]),2),8,'0')+"110"; break;
        default: progValid = false; cerr << "Error: bin too large (" << tdc << ", " << i << ")" << endl; break;
    }
}

uint32_t Processing::makeProgram()
{
    //see eq_microcode.txt with VHDL
    QMap<QString,QString> cmd2eqcode;
    cmd2eqcode["001001"] = "00010001";
    cmd2eqcode["001011"] = "01001001";
    cmd2eqcode["011001"] = "01101001";
    cmd2eqcode["011011"] = "10001001";

    cmd2eqcode["000001"] = "00011010";
    cmd2eqcode["001000"] = "00100010";
    cmd2eqcode["000011"] = "10101010";
    cmd2eqcode["011000"] = "00000010";

    cmd2eqcode["000000"] = "00001011";
    cmd2eqcode["001010"] = "01000011";
    cmd2eqcode["001100"] = "01100011";
    cmd2eqcode["001110"] = "10000011";
    cmd2eqcode["010001"] = "00101011";
    cmd2eqcode["100001"] = "00110011";
    cmd2eqcode["110001"] = "00111011";
    cmd2eqcode["011010"] = "10100011";
    cmd2eqcode["011100"] = "11000011";
    cmd2eqcode["011110"] = "11100011";
    cmd2eqcode["010011"] = "11001011";
    cmd2eqcode["100011"] = "11101011";
    cmd2eqcode["110011"] = "01010011";

    cmd2eqcode["000010"] = "00001100";
    cmd2eqcode["000100"] = "00101100";
    cmd2eqcode["000110"] = "01001100";
    cmd2eqcode["010000"] = "00010100";
    cmd2eqcode["100000"] = "00110100";
    cmd2eqcode["110000"] = "01010100";

    cmd2eqcode["010010"] = "01110101";
    cmd2eqcode["010100"] = "10010101";
    cmd2eqcode["010110"] = "10110101";
    cmd2eqcode["100010"] = "11010101";
    cmd2eqcode["100100"] = "11110101";
    cmd2eqcode["100110"] = "00011101";
    cmd2eqcode["110010"] = "00111101";
    cmd2eqcode["110100"] = "01011101";
    cmd2eqcode["110110"] = "01111101";

    metaWords.clear();
    commandWords.clear();
    uint32_t commits = 0;
    for( uint32_t tdc = 0; tdc < tdcCharacteristics.size(); ++tdc )
    {
        QString progstr;
        TDC_characteristic &c = tdcCharacteristics[tdc];
        commits += c.totalCommits;
        for( uint32_t i = 0; i < c.code.size(); i+=2 ) { //treat two word entities
            QString cmd_p_n = c.code[i].right(3)+c.code[i+1].right(3);
            if( !cmd2eqcode.contains(cmd_p_n) ) {
                cerr << "Error 1 in code translation: " << cmd_p_n.toStdString() << endl;
                progValid = false;
            }
            progstr.prepend(c.code[i+1].left(c.code[i+1].length()-3)+c.code[i].left(c.code[i].length()-3)+cmd2eqcode[cmd_p_n]);
        }
        appendProgram(progstr);
    }

    //End of program marker
    metaWords[metaWords.size()-4] |= 0x80;

    return commits;
}

void Processing::save( ostream& stats )
{
    stats << "Segments:;" << numSegments << ";Input:;" << numInputBins << ";Output:;" << numOutputBins << ";" << (uint32_t)perPixel << endl;
    for( uint32_t tdc = 0; tdc < tdcCharacteristics.size(); ++tdc )
    {
        TDC_characteristic &c = tdcCharacteristics[tdc];
        stats << "TDC:;" << tdc << ";Input bin count;" << c.binPosition.size() << ";Output bin count;" << c.totalCommits << ";" << endl;
        stats << "Position [ps];" << "Size [ps];" << "First bin;" << "Commit count;" << "Factors;" << "Code;" << endl;
        for( uint32_t i = 0; i < c.binPosition.size(); ++i ) {
            stats << QString::number(c.binPosition[i],'f',3).toStdString() << ';';
            stats << QString::number(c.binSize[i],'f',3).toStdString() << ';';
            stats << (uint32_t)c.firstOutputBin[i] << ';';
            stats << (uint32_t)c.commitCount[i] << ';';
            stats << QString("%1,%2,%3").arg(c.factors[i][0],0,'f',3).arg(c.factors[i][1],0,'f',3).arg(c.factors[i][2],0,'f',3).toStdString() << ';';
            stats << c.code[i].toStdString() << ';';
            stats << endl;
        }
        stats << "0-0-0-0-0-0-0-0-0-0-0-0-0;;;;;;" << endl;
    }
}

void Processing::load( istream& stats )
{
    string buf;
    getline(stats,buf);
    QString line(buf.c_str());
    QStringList tokens = line.split(';');
    if(tokens.length() < 6) {
        cerr << "Error reading stats 1." << endl;
        reset();
        return;
    }
    numSegments = tokens[1].toInt();
    numInputBins = tokens[3].toInt();
    numOutputBins = tokens[5].toInt();
    perPixel = false;
    if(tokens.length()>6) {
        perPixel = (tokens[6].toInt() != 0);
    }

    uint32_t correctionCount = PROC_NUM_TDCS;
    if( perPixel ) {
        correctionCount *= 4;
    }

    tdcCharacteristics.clear();
    tdcCharacteristics.resize(correctionCount);
    for( uint32_t tdc = 0; tdc < tdcCharacteristics.size(); ++tdc )
    {
        TDC_characteristic &c = tdcCharacteristics[tdc];

        string buf;
        getline(stats,buf);
        QString line(buf.c_str());
        QStringList tokens = line.split(';');
        if(tokens.length() < 6 || tokens[1].toInt() != tdc) {
            cerr << "Error reading stats 1." << endl;
            reset();
            return;
        }

        uint32_t numInputBins = tokens[3].toInt();
        c.totalCommits = tokens[5].toInt();

        c.counts.resize(numInputBins);
        c.binSize.resize(numInputBins);
        c.binPosition.resize(numInputBins);
        c.firstOutputBin.resize(numInputBins);
        c.commitCount.resize(numInputBins);
        c.factors.resize(numInputBins,vector<double>(3));
        c.code.resize(numInputBins);

        getline(stats,buf); //Column headings

        uint32_t commitCountCheck = 0;
        for( uint32_t i = 0; i < numInputBins; ++i ) {
            getline(stats,buf);
            line = QString(buf.c_str());
            tokens = line.split(';');
            if(tokens.size()<6) {
                cerr << "Error reading stats 2." << endl;
                reset();
                return;
            }
            c.binPosition[i] = tokens[0].toDouble();
            c.binSize[i] = tokens[1].toDouble();
            c.firstOutputBin[i] = tokens[2].toInt();
            c.commitCount[i] = tokens[3].toInt();
            QStringList factors = tokens[4].split(',');
            if(factors.size()<3) {
                cerr << "Error reading stats 3." << endl;
                reset();
                return;
            }
            c.factors[i][0] = factors[0].toDouble();
            c.factors[i][1] = factors[1].toDouble();
            c.factors[i][2] = factors[2].toDouble();
            c.code[i] = tokens[5];

            commitCountCheck += c.commitCount[i];
        }
        if( commitCountCheck != c.totalCommits ) {
            cerr << "Error reading stats 4." << endl;
            reset();
            return;
        }
        getline(stats,buf); //End separator
    }
}
