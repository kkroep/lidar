#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#define NUM_TDCS (64)
#define TDC_MAX_CODE (139)

#include <QMainWindow>
#include <vector>
#include <deque>
using namespace std;

#include "fx3stream.h"
class QLabel;
class QTimer;
#include "qcustomplot.h"
#include "processing.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT
    QTimer *timer; // Added by Kees


public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:
    void settingsChanged();

    void on_escape();
    void on_tab();
    void on_shiftTab();
    void updatePreview();
    void on_startPreviewButton_clicked();
    void on_histField_valueChanged(int channel);
    void on_resetDisplayButton_clicked();
    void on_tabWidget_currentChanged(int index);
    void on_checkExternalClock_clicked(bool checked);
    void statusTimeout();

    void onXRangeChanged();
    void onYRangeChanged();
    void on_checkFixX_clicked();
    void on_checkFixY_clicked();
    void on_checkAutoUpdate_clicked(bool checked);
    void on_intensityBar_elemChanged(int hist, uint32_t intensity, uint32_t maximum);
    void on_statsChoose_valueChanged(int tdc);
    void on_usbResetButton_clicked();
    void on_procButton_clicked();
    void on_procResetButton_clicked();
    void on_procWriteButton_clicked();
    void on_procSaveButton_clicked();
    void on_procLoadButton_clicked();
    void on_savePreviewButton_clicked();
    void on_acqMemSwitchButton_clicked();
    void on_acqReadMemButton_clicked();
    void on_acqRunButton_clicked();
    void on_acqSaveButton_clicked();
    void on_intRunButton_clicked();
    void on_intSaveButton_clicked();
    void on_rotHistField_valueChanged(int channel);
    void on_rotField_valueChanged(int shift);
    void on_rotSaveButton_clicked();
    void on_rotLoadButton_clicked();
    void on_rotAlignButton_clicked();
    void on_rotResetButton_clicked();
    void on_persistenceField_valueChanged(int value);
    void on_resetSettings_clicked();
protected:
    void fx3Connected();
    void fx3Disconnected();
    bool fx3ReadTimestamp();
    void fx3ReadClockStatus(bool print=false);
    void fx3SyncClock(bool external);
    void fx3Open();
    void fx3Reset();
    void fx3SetShift();
    void fx3WriteShift(int pixel, int shift);
    void fx3WriteTDCchain( uint32_t globalOffset, uint32_t memMode, uint32_t histComp );
    void fx3GetPreview();
    void fx3GetTimestamps();
    void fx3SetIntensityDelay(uint32_t ms);
    void fx3GetIntensity();

private:
    uint32_t clockStatus;
    void applyClocks();
    void applySettings();
    void saveSettings();
    void loadSettings();
    void processingChanged(bool reset = false);
    void checkProc();

    Ui::MainWindow *ui;
    FX3Stream fx3;
    QLabel* usbIcon;
    QCPItemText *textLabel;

    QLabel *statusLabel, *processingLabel;
    QTimer *timer;
    QTimer *statusTimer;

    vector<uint16_t> histogramShifts;

    vector<uint32_t> acqReceiveBuffer;
    vector<uint32_t> intReceiveBuffer;

    vector<uint64_t> statistics; //Summed histograms to calculate correction on
    Processing proc;
    bool procReset, rotReset;

    enum MEMMODE { HISTOGRAM_MODE = 0, TIMESTAMP_MODE = 1 };
    uint32_t histogramLength; //word count
    vector<uint16_t> histReceiveBuffer; //usb receive buffer
    uint32_t waitCycles;

    vector<uint32_t> histDisplayBuffer;
    deque< vector<uint16_t> > histPersistenceBuffer;
    void doPersistence();

    bool autoRunning;

    void makeDisp(int channel);

    void fixHistAxes();
    void makeIntensity();
    void addToStats();

    void displayStats(int tdc);

    void rotSave(ostream&);
    void rotLoad(istream&);

    void procLoad(istream&);

private slots:
        void onTimeout();
};

#endif // MAINWINDOW_H
