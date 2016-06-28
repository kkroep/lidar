#ifndef PROCESSING_H
#define PROCESSING_H

#include <cstdint>
#include <vector>
#include <QString>
using namespace std;

#define PROC_NUM_PIXELS 256
#define PROC_NUM_TDCS 64
#define PROC_DEFAULT_BIN_COUNT 140
#define PROC_DEFAULT_SEGMENT_COUNT 1

class Processing {
public:
    Processing();

    void reset();

    void analyze(const vector<uint64_t>& statistics, uint32_t inputBinsPerPixel, uint32_t segmentsPerTDC, uint32_t outputBinsPerSegment, bool perPixelCorrection);
    double getLargestBin() { return largestBin; }
    void compile();
    uint32_t length();
    vector<uint32_t>& getProgramData();
    uint32_t getInputLength();
    uint32_t getOutputLength();
    uint32_t getNumSegments();
    bool isPerPixel() { return perPixel; }

    struct TDC_characteristic
    {
        uint64_t totalEvents;
        uint32_t totalCommits;
        vector<uint64_t> counts;
        vector<double> binPosition;
        vector<double> binSize;
        vector<uint32_t> firstOutputBin;
        vector<uint32_t> commitCount;
        vector< vector<double> > factors;
        vector<QString> code;
    };
    const TDC_characteristic& getCharacteristic( uint32_t tdc );

    void save(ostream &stats);
    void load(istream &stats);

private:
    //Correction statistics
    bool perPixel;
    uint32_t numSegments, numInputBins, numOutputBins;
    double largestBin;
    bool progValid;
    vector<TDC_characteristic> tdcCharacteristics;

    vector<uint8_t> metaWords;
    vector<uint64_t> commandWords;
    void commitCode(uint32_t tdc, uint32_t i);
    uint32_t makeProgram();
    void appendProgram(QString &program);
    uint64_t shr(uint64_t v, uint32_t c);
    uint64_t shl(uint64_t v, uint32_t c);

    vector<uint32_t> writedata;
};

#endif // PROCESSING_H
