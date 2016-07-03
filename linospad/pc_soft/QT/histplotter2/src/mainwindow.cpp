#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "qcustomplot.h"
#include "mytimer.h" // kees added this
#include <QDebug>
#include <QDesktopWidget>
#include <QScreen>
#include <QMessageBox>
#include <QMetaEnum>
#include <QStatusBar>
#include <QFileDialog>
#include <QSettings>
#include <QChar>
#include <QShortcut>
#include <QTimer>
#include <iostream>
#include <fstream>
#include <ctime>
#include <complex>
#include <algorithm>

using namespace std;

extern uint32_t file_number = 1;
extern uint32_t folder_number = 1;


// ///////////////////////////////////////
// Initialisation
// ///////////////////////////////////////
MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    connect(ui->actionQuit,SIGNAL(triggered(bool)),this,SLOT(on_escape()));

    ui->acqBg->load(QString(":/MuxStateMachine.svg"));

    ui->refBg->load(QString(":/MuxClock.svg"));
    ui->extButton->setIcon(QIcon(QPixmap(":/IntClock.svg")));
    ui->extButton->setIconSize(QSize(40,100));
    ui->trigSrcButton->setIcon(QIcon(QPixmap(":/IntClock.svg")));
    ui->trigSrcButton->setIconSize(QSize(40,100));

    ui->histBg->load(QString(":/MuxTriggerRef.svg"));

    ui->procBg->load(QString(":/MuxProcessing.svg"));

    ui->startPreviewButton->setIcon(QIcon(QPixmap(":/Start.svg")));
    ui->startPreviewButton->setIconSize(QSize(45, 45));
    ui->savePreviewButton->setIcon(QIcon(QPixmap(":/Save.svg")));
    ui->savePreviewButton->setIconSize(QSize(45, 45));
    ui->resetDisplayButton->setIcon(QIcon(QPixmap(":/Reset.svg")));
    ui->resetDisplayButton->setIconSize(QSize(45, 45));

    //Setup status bar
    statusLabel = new QLabel("Histogram: 0, Intensity: 0");
    statusBar()->addWidget(statusLabel);
    processingLabel = new QLabel("Processing off");
    statusBar()->addPermanentWidget(processingLabel);
    usbIcon = new QLabel();
    usbIcon->setPixmap(QPixmap(":/USBoff.svg").scaledToHeight(statusLabel->height()-12));
    statusBar()->addPermanentWidget(usbIcon);

    fx3Disconnected();

    ui->histogramPlot->addGraph();
    ui->histogramPlot->graph(0)->setLineStyle(QCPGraph::lsStepLeft);
    ui->histogramPlot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom);
    ui->histogramPlot->axisRect()->setRangeZoom(Qt::Vertical);
    ui->histogramPlot->axisRect()->setRangeDrag(Qt::Vertical);
    ui->histogramPlot->xAxis->setLabel("TDC output code");
    ui->histogramPlot->yAxis->setLabel("Counts");
    ui->histogramPlot->xAxis->setRange(0, 1024);
    ui->histogramPlot->yAxis->setRange(0, 0xffff);
    textLabel = new QCPItemText(ui->histogramPlot);
    ui->histogramPlot->addItem(textLabel);
    ui->histogramPlot->addGraph();
    textLabel->setPositionAlignment(Qt::AlignTop|Qt::AlignHorizontal_Mask);
    textLabel->position->setType(QCPItemPosition::ptAxisRectRatio);
    textLabel->position->setCoords(0.5, 0); // place position at center/top of axis rect
    textLabel->setText("Histogram");
    textLabel->setFont(QFont(font().family(), 17)); // make font a bit larger

    QPen Pen = QPen(QColor(155, 100, 0));
    Pen.setWidthF(2);
    Pen.setStyle(Qt::DotLine);

    connect(ui->intensityBar, SIGNAL(elemClicked(int,uint32_t,uint32_t)), ui->histField, SLOT(setValue(int)));

    new QShortcut(QKeySequence(Qt::Key_Up), ui->histField, SLOT(stepUp()));
    new QShortcut(QKeySequence(Qt::Key_Down), ui->histField, SLOT(stepDown()));
    new QShortcut(QKeySequence(Qt::Key_Return), this, SLOT(on_startPreviewButton_clicked()));
    new QShortcut(QKeySequence(Qt::CTRL + Qt::Key_S), this, SLOT(on_savePreviewButton_clicked()));
    new QShortcut(QKeySequence(Qt::Key_Escape), this, SLOT(on_escape()));
    new QShortcut(QKeySequence(Qt::Key_Tab), this, SLOT(on_tab()));
    new QShortcut(QKeySequence(Qt::SHIFT + Qt::Key_Tab), this, SLOT(on_shiftTab()));

    timer = new QTimer(this);
    connect(timer, SIGNAL(timeout()), this, SLOT(updatePreview()));

    fx3Open();
    if(!fx3 && QMessageBox::question(this,
                                     "Device not found",
                                     "FX3 device not found. Continue anyway?",
                                     QMessageBox::StandardButtons(QMessageBox::Yes|QMessageBox::No),
                                     QMessageBox::StandardButton(QMessageBox::No) ) == QMessageBox::No ) {
        exit(0);
    }

    clockStatus = 0;
    statusTimer = new QTimer(this);
    connect(statusTimer, SIGNAL(timeout()), this, SLOT(statusTimeout()));
    statusTimer->start(500);

    statistics.resize(256*1024);
    histogramLength = 256*512; //32 bit words
    histReceiveBuffer.resize(256*1024,0);
    histDisplayBuffer.resize(256*1024,0);
    histogramShifts.resize(256,0);
    fx3SetShift();
    waitCycles = 0;
    autoRunning = false;

    loadSettings();

    //connect settings
    connect(ui->histogramPlot->xAxis, SIGNAL(rangeChanged(QCPRange)), this, SLOT(onXRangeChanged()));
    connect(ui->histogramPlot->yAxis, SIGNAL(rangeChanged(QCPRange)), this, SLOT(onYRangeChanged()));
    connect(ui->refClkCombo, SIGNAL(currentIndexChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->clkDiv, SIGNAL(valueChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->histCompCheck, SIGNAL(toggled(bool)), this, SLOT(settingsChanged()));
    connect(ui->globalOffset, SIGNAL(valueChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->refCombo, SIGNAL(currentIndexChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->memoryModeCombo, SIGNAL(currentIndexChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->rawHistLength, SIGNAL(valueChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->procPerPixel, SIGNAL(toggled(bool)), this, SLOT(settingsChanged()));
    connect(ui->procInSegments, SIGNAL(valueChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->procOutLength, SIGNAL(valueChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->acqTime, SIGNAL(valueChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->acqCycles, SIGNAL(valueChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->acqSync, SIGNAL(toggled(bool)), this, SLOT(settingsChanged()));
    connect(ui->acqDelay, SIGNAL(valueChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->acqReadMem, SIGNAL(toggled(bool)), this, SLOT(settingsChanged()));
    connect(ui->extButton, SIGNAL(clicked(bool)), ui->checkExternalClock, SLOT(click()));
    connect(ui->trigSrcButton, SIGNAL(clicked(bool)), ui->checkTrigSrc, SLOT(click()));
    connect(ui->checkTrigSrc, SIGNAL(toggled(bool)), this, SLOT(settingsChanged()));
    connect(ui->intTime, SIGNAL(valueChanged(int)), this, SLOT(settingsChanged()));
    connect(ui->intDelay, SIGNAL(valueChanged(int)), this, SLOT(settingsChanged()));

    settingsChanged();
    applySettings();
    if(ui->checkExternalClock->isChecked()) {
        on_checkExternalClock_clicked(true);
    }
}

MainWindow::~MainWindow()
{
    saveSettings();
    delete ui;
}

void MainWindow::on_escape()
{
    qApp->quit();
}

void MainWindow::on_tab()
{
    ui->tabWidget->setCurrentIndex((ui->tabWidget->currentIndex()+1)%ui->tabWidget->count());
}

void MainWindow::on_shiftTab()
{
    ui->tabWidget->setCurrentIndex((ui->tabWidget->currentIndex()+ui->tabWidget->count()-1)%ui->tabWidget->count());
}

void MainWindow::saveSettings()
{
    QSettings settings("settings.txt", QSettings::IniFormat);

    settings.beginGroup("MainWindow");
    settings.setValue("Size", size());
    settings.setValue("Pos", pos());
    settings.setValue("Tab", ui->tabWidget->currentIndex());
    settings.endGroup();

    settings.beginGroup("Preview");
    settings.setValue("Persistence", ui->persistenceField->value());
    settings.setValue("Frequency", ui->prevFrequency->value());
    settings.setValue("AutoRepeat", ui->checkAutoUpdate->isChecked());
    settings.setValue("Histogram", ui->histField->value());
    settings.setValue("FollowMouse", ui->checkMouseOver->isChecked());
    settings.setValue("FixX", ui->checkFixX->isChecked());
    settings.setValue("FixY", ui->checkFixY->isChecked());
    settings.setValue("Xmin", ui->histogramPlot->xAxis->range().lower);
    settings.setValue("Xmax", ui->histogramPlot->xAxis->range().upper);
    settings.setValue("Ymin", ui->histogramPlot->yAxis->range().lower);
    settings.setValue("Ymax", ui->histogramPlot->yAxis->range().upper);
    settings.setValue("Binary", ui->checkBinary->isChecked());
    settings.endGroup();

    settings.beginGroup("Intensity");
    settings.setValue("Cycles", ui->intCycles->value());
    settings.setValue("Delay", ui->intDelay->value());
    settings.setValue("Length", ui->intTime->value());
    settings.setValue("Binary", ui->checkIntBinary->isChecked());
    settings.endGroup();

    settings.beginGroup("Acquisition");
    settings.setValue("Cycles", ui->acqCycles->value());
    settings.setValue("Sync", ui->acqSync->isChecked());
    settings.setValue("Delay", ui->acqDelay->value());
    settings.setValue("Length", ui->acqTime->value());
    settings.setValue("SwitchMux", ui->acqMuxSwitch->isChecked());
    settings.setValue("Mux", ui->acqMuxInit->value());
    settings.setValue("SwitchMem", ui->acqMemSwitch->isChecked());
    settings.setValue("Read", ui->acqReadMem->isChecked());
    settings.endGroup();

    settings.beginGroup("Clocking");
    settings.setValue("IntRef", ui->refClkCombo->currentIndex());
    settings.setValue("UseExt", ui->checkExternalClock->isChecked());
    settings.setValue("Divider", ui->clkDiv->value());
    settings.setValue("TrigSrc", ui->checkTrigSrc->isChecked());
    settings.endGroup();

    settings.beginGroup("Histogram");
    settings.setValue("RefSignal", ui->refCombo->currentIndex());
    settings.setValue("CodeOffset", ui->globalOffset->value());
    settings.setValue("Compress", ui->histCompCheck->isChecked());
    settings.setValue("MemMode", ui->memoryModeCombo->currentIndex());
    settings.setValue("MemCount", ui->rawHistLength->value());
    settings.endGroup();

    settings.beginGroup("Processing");
    settings.setValue("PerPixel", ui->procPerPixel->isChecked());
    settings.setValue("Segments", ui->procInSegments->value());
    settings.setValue("Bins", ui->procOutLength->value());
    settings.setValue("Reset", procReset);
    settings.setValue("RotReset", rotReset);
    settings.endGroup();

    ofstream rotfile("rotation.txt");
    rotSave(rotfile);
}

void MainWindow::loadSettings()
{
    QSettings settings("settings.txt", QSettings::IniFormat);

    settings.beginGroup("MainWindow");
    if( !settings.contains("Tab") ) {
        on_resetSettings_clicked();
        return;
    }
    resize(settings.value("Size", QSize(400, 400)).toSize());
    move(settings.value("Pos", QPoint(200, 200)).toPoint());
    ui->tabWidget->setCurrentIndex(settings.value("Tab").toInt());
    settings.endGroup();

    settings.beginGroup("Preview");
    ui->persistenceField->setValue(settings.value("Persistence").toInt());
    ui->prevFrequency->setValue(settings.value("Frequency").toInt());
    ui->checkAutoUpdate->setChecked(settings.value("AutoRepeat").toBool());
    ui->histField->setValue(settings.value("Histogram").toInt());
    ui->checkMouseOver->setChecked(settings.value("FollowMouse").toBool());
    ui->checkFixX->setChecked(settings.value("FixX").toBool());
    ui->checkFixY->setChecked(settings.value("FixY").toBool());
    ui->histogramPlot->xAxis->setRange(settings.value("Xmin").toDouble(),settings.value("Xmax").toDouble());
    ui->histogramPlot->yAxis->setRange(settings.value("Ymin").toDouble(),settings.value("Ymax").toDouble());
    ui->checkBinary->setChecked(settings.value("Binary").toBool());
    settings.endGroup();
    fixHistAxes();

    settings.beginGroup("Intensity");
    ui->intCycles->setValue(settings.value("Cycles").toInt());
    ui->intDelay->setValue(settings.value("Delay").toInt());
    ui->intTime->setValue(settings.value("Length").toInt());
    ui->checkIntBinary->setChecked(settings.value("Binary").toBool());
    settings.endGroup();

    settings.beginGroup("Acquisition");
    ui->acqCycles->setValue(settings.value("Cycles").toInt());
    ui->acqSync->setChecked(settings.value("Sync").toBool());
    ui->acqDelay->setValue(settings.value("Delay").toInt());
    ui->acqTime->setValue(settings.value("Length").toInt());
    ui->acqMuxSwitch->setChecked(settings.value("SwitchMux").toBool());
    ui->acqMuxInit->setValue(settings.value("Mux").toInt());
    ui->acqMemSwitch->setChecked(settings.value("SwitchMem").toBool());
    ui->acqReadMem->setChecked(settings.value("Read").toBool());
    settings.endGroup();

    settings.beginGroup("Clocking");
    ui->refClkCombo->setCurrentIndex(settings.value("IntRef").toInt());
    ui->checkExternalClock->setChecked(settings.value("UseExt").toBool());
    ui->clkDiv->setValue(settings.value("Divider").toInt());
    ui->checkTrigSrc->setChecked(settings.value("TrigSrc").toBool());
    settings.endGroup();

    settings.beginGroup("Histogram");
    ui->refCombo->setCurrentIndex(settings.value("RefSignal").toInt());
    ui->globalOffset->setValue(settings.value("CodeOffset").toInt());
    ui->histCompCheck->setChecked(settings.value("Compress").toBool());
    ui->memoryModeCombo->setCurrentIndex(settings.value("MemMode").toInt());
    ui->rawHistLength->setValue(settings.value("MemCount").toInt());
    settings.endGroup();

    settings.beginGroup("Processing");
    ui->procPerPixel->setChecked(settings.value("PerPixel").toBool());
    ui->procInSegments->setValue(settings.value("Segments").toInt());
    ui->procOutLength->setValue(settings.value("Bins").toInt());
    if(!settings.value("Reset").toBool()) {
        ifstream stats("processing.txt");
        if( stats.is_open() ) {
            procLoad(stats);
            on_procWriteButton_clicked();
        }
    }
    else {
        on_procResetButton_clicked();
    }
    settings.endGroup();

    if(!settings.value("RotReset").toBool()) {
        ifstream rotfile("rotation.txt");
        if( rotfile.is_open() ) {
            rotLoad(rotfile);
        }
    }
    else {
        on_rotResetButton_clicked();
    }
}

void MainWindow::on_resetSettings_clicked()
{
    if( QMessageBox::question(this,
        "Reset settings",
        "Are you sure?",
        QMessageBox::StandardButtons(QMessageBox::Yes|QMessageBox::No),
        QMessageBox::StandardButton(QMessageBox::No) ) == QMessageBox::No )
    {
        return;
    }
    ui->persistenceField->setValue(1);
    ui->prevFrequency->setValue(5);
    ui->checkAutoUpdate->setChecked(false);
    ui->histField->setValue(0);
    ui->checkMouseOver->setChecked(false);
    ui->checkFixX->setChecked(true);
    ui->checkFixY->setChecked(false);
    ui->histogramPlot->xAxis->setRange(0.0,560.0);
    ui->histogramPlot->yAxis->setRange(0.0,65536.0);
    ui->checkBinary->setChecked(false);
    fixHistAxes();

    ui->intCycles->setValue(1);
    ui->intDelay->setValue(0);
    ui->intTime->setValue(5000000);
    ui->checkIntBinary->setChecked(false);

    ui->acqCycles->setValue(4);
    ui->acqSync->setChecked(false);
    ui->acqDelay->setValue(0);
    ui->acqTime->setValue(5000000);
    ui->acqMuxSwitch->setChecked(true);
    ui->acqMuxInit->setValue(0);
    ui->acqMemSwitch->setChecked(true);
    ui->acqReadMem->setChecked(true);

    ui->refClkCombo->setCurrentIndex(7);
    ui->checkExternalClock->setChecked(false);
    ui->clkDiv->setValue(50);
    ui->checkTrigSrc->setChecked(true);

    ui->refCombo->setCurrentIndex(0);
    ui->globalOffset->setValue(0);
    ui->histCompCheck->setChecked(false);
    ui->memoryModeCombo->setCurrentIndex(0);
    ui->rawHistLength->setValue(560);

    ui->procPerPixel->setChecked(false);
    ui->procInSegments->setValue(1);
    ui->procOutLength->setValue(400);
    on_procResetButton_clicked();
    on_rotResetButton_clicked();
}

void MainWindow::settingsChanged()
{
    int32_t refClkIndex = ui->refClkCombo->currentIndex();
    if( refClkIndex < 0 || refClkIndex > 7 ) return;

    QString pllLabels[8][3] = {
        {"x1, 20MHz", "x5, 100MHz", "x20, 400MHz"},
        {"x1, 25MHz", "x4, 100MHz", "x16, 400MHz"},
        {"x1, 33MHz", "x3, 100MHz", "x12, 400MHz"},
        {"x1, 40MHz", "x2, 80MHz", "x10, 400MHz"},
        {"x1, 50MHz", "x2, 100MHz", "x8, 400MHz"},
        {"x1, 66MHz", "x2, 133MHz", "x6, 400MHz"},
        {"x1, 80MHz", "x1, 80MHz", "x5, 400MHz"},
        {"x1, 100MHz", "x1, 100MHz", "x4, 400MHz"}
    };
    ui->refLabel->setText(pllLabels[refClkIndex][0]);
    ui->modLabel->setText(pllLabels[refClkIndex][1]);
    ui->tdcLabel->setText(pllLabels[refClkIndex][2]);

    uint32_t fullPeriod[8] = {
        20*(TDC_MAX_CODE+1),
        16*(TDC_MAX_CODE+1),
        12*(TDC_MAX_CODE+1),
        10*(TDC_MAX_CODE+1),
        8*(TDC_MAX_CODE+1),
        6*(TDC_MAX_CODE+1),
        5*(TDC_MAX_CODE+1),
        4*(TDC_MAX_CODE+1)
    };
    uint32_t currentPeriod = fullPeriod[refClkIndex];
    if( ui->histCompCheck->isChecked() )
        currentPeriod /= 4;
    if( ui->refCombo->currentIndex() != 0 ) {
        ui->periodLength->setText("N/A");
    }
    else {
        ui->periodLength->setText(QString::number(currentPeriod));
    }

    uint32_t clkDiv = ui->clkDiv->value();
    if( (clkDiv&1) && clkDiv != 1 ) {
        clkDiv -= 1;
        ui->clkDivWarning->setPixmap(QIcon(":/warning.svg").pixmap(QSize(24, 24)));
    }
    else {
        ui->clkDivWarning->setPixmap(QIcon().pixmap(QSize(24, 24)));
    }

    uint32_t refPerSec[8] = {
        20000000, //20 MHz
        25000000, //25 MHz
        33333333, //33 MHz
        40000000, //40 MHz
        50000000, //50 MHz
        66666666, //66 MHz
        80000000, //80 MHz
        100000000  //100 MHz
    };
    double outFreq = refPerSec[refClkIndex]/(double)clkDiv;
    if(outFreq<1000.0) {
        ui->outLabel->setText(QString("%1 Hz").arg(outFreq,0,'f',3));
    }
    else if(outFreq<1000000.0) {
        ui->outLabel->setText(QString("%1 kHz").arg(outFreq/1000.0,0,'f',3));
    }
    else {
        ui->outLabel->setText(QString("%1 MHz").arg(outFreq/1000000.0,0,'f',3));
    }

    if( ui->checkTrigSrc->isChecked() ) {
        ui->trigSrcButton->setIcon(QIcon(QPixmap((":/ExtClock.svg"))));
    }
    else {
        ui->trigSrcButton->setIcon(QIcon(QPixmap((":/IntClock.svg"))));
    }

    uint32_t memMode = ui->memoryModeCombo->currentIndex();
    if( TIMESTAMP_MODE == memMode ) { //timestamps
        ui->rawHistLength->setMinimum(8);
        ui->rawHistLength->setMaximum(512);
        ui->rawHistLength->setSingleStep(1);
        ui->tabProc->setDisabled(true);
    }
    else {
        ui->rawHistLength->setMinimum(16);
        ui->rawHistLength->setMaximum(1024);
        ui->rawHistLength->setSingleStep(2);
        ui->tabProc->setDisabled(false);
    }

    uint32_t rawElements = ui->rawHistLength->value();
    if( (HISTOGRAM_MODE == memMode &&  ((rawElements&1) || rawElements < 16)) || (TIMESTAMP_MODE == memMode && rawElements < 8) ) {
        ui->rawHistLengthWarning->setPixmap(QIcon(":/warning.svg").pixmap(QSize(24, 24)));
        ui->startPreviewButton->setDisabled(true);
        ui->acqReadMemButton->setDisabled(true);
        ui->acqRunButton->setDisabled(true);
    }
    else {
        ui->rawHistLengthWarning->setPixmap(QIcon().pixmap(QSize(24, 24)));
        ui->startPreviewButton->setDisabled(false);
        ui->acqReadMemButton->setDisabled(false);
        ui->acqRunButton->setDisabled(false);
    }

    ui->procInLength->setText(QString::number(rawElements/ui->procInSegments->value()));
    ui->procOutSegments->setText(QString::number(ui->procInSegments->value()));

    if(rawElements%ui->procInSegments->value()) {
        ui->procSegmentsWarning->setPixmap(QIcon(":/warning.svg").pixmap(QSize(24, 24)));
        ui->procButton->setDisabled(true);
    }
    else {
        ui->procSegmentsWarning->setPixmap(QIcon().pixmap(QSize(24, 24)));
        ui->procButton->setEnabled(true);
    }

    uint32_t modPerSec[8] = {
        100000000, //20 MHz
        100000000, //25 MHz
        100000000, //33 MHz
        80000000, //40 MHz
        100000000, //50 MHz
        133333333, //66 MHz
        80000000, //80 MHz
        100000000  //100 MHz
    };
    uint32_t acqTimeCycles = ui->acqTime->value();
    double acqTimeNs = acqTimeCycles*1000000000.0/modPerSec[refClkIndex];
    ui->prevFrequency->setMaximum(max(1,min(60,(int)(1000000000.0/(acqTimeNs*4.0)))));
    if(acqTimeNs<1000.0) {
        ui->acqTimeLabel->setText(QString("%1 ns").arg(acqTimeNs,0,'f',3));
    }
    else if(acqTimeNs<1000000.0) {
        ui->acqTimeLabel->setText(QString("%1 us").arg(acqTimeNs/1000.0,0,'f',3));
    }
    else {
        ui->acqTimeLabel->setText(QString("%1 ms").arg(acqTimeNs/1000000.0,0,'f',3));
    }

    if(ui->acqSync->isChecked()) {
        ui->acqDelay->setEnabled(true);
    }
    else {
        ui->acqDelay->setDisabled(true);
    }
    uint32_t acqDelayCycles = ui->acqDelay->value();
    double acqDelayNs = acqDelayCycles*1000000000.0/modPerSec[refClkIndex];
    if(acqDelayNs<1000.0) {
        ui->acqDelayLabel->setText(QString("%1 ns").arg(acqDelayNs,0,'f',3));
    }
    else if(acqDelayNs<1000000.0) {
        ui->acqDelayLabel->setText(QString("%1 us").arg(acqDelayNs/1000.0,0,'f',3));
    }
    else {
        ui->acqDelayLabel->setText(QString("%1 ms").arg(acqDelayNs/1000000.0,0,'f',3));
    }

    //Datasize
    uint32_t bufSize = 64*2;
    if( procReset )
        bufSize *= ui->rawHistLength->value();
    else
        bufSize *= ui->procOutLength->value()*ui->procInSegments->value(); //bytes
    if( TIMESTAMP_MODE == ui->memoryModeCombo->currentIndex() )
        bufSize *= 2;
    if(bufSize < 1024) {
        ui->bufSizeDisp->setText(QString("%1 B").arg(bufSize));
    }
    else if(bufSize < 1024*1024) {
        ui->bufSizeDisp->setText(QString("%1 kB").arg(bufSize/1024.0,0,'f',3));
    }
    else {
        ui->bufSizeDisp->setText(QString("%1 MB").arg(bufSize/(1024.0*1024.0),0,'f',3));
    }

    uint32_t dataSize = ui->acqReadMem->isChecked()?ui->acqCycles->value()*bufSize:0;
    if(dataSize < 1024) {
        ui->dataSizeDisp->setText(QString("%1 B").arg(dataSize));
    }
    else if(dataSize < 1024*1024) {
        ui->dataSizeDisp->setText(QString("%1 kB").arg(dataSize/1024.0,0,'f',3));
    }
    else {
        ui->dataSizeDisp->setText(QString("%1 MB").arg(dataSize/(1024.0*1024.0),0,'f',3));
    }
    if(0 == dataSize) {
        ui->startPreviewButton->setDisabled(true);
    }
    else {
        ui->startPreviewButton->setEnabled(true);
    }

    uint32_t intTimeCycles = ui->intTime->value();
    double intTimeNs = intTimeCycles*10.0;
    if(intTimeNs<1000.0) {
        ui->intTimeLabel->setText(QString("%1 ns").arg(intTimeNs,0,'f',3));
    }
    else if(intTimeNs<1000000.0) {
        ui->intTimeLabel->setText(QString("%1 us").arg(intTimeNs/1000.0,0,'f',3));
    }
    else {
        ui->intTimeLabel->setText(QString("%1 ms").arg(intTimeNs/1000000.0,0,'f',3));
    }

    uint32_t intDelayCycles = ui->intDelay->value();
    double intDelayNs = intDelayCycles*10.0;
    if(intDelayNs<1000.0) {
        ui->intDelayLabel->setText(QString("%1 ns").arg(intDelayNs,0,'f',3));
    }
    else if(intDelayNs<1000000.0) {
        ui->intDelayLabel->setText(QString("%1 us").arg(intDelayNs/1000.0,0,'f',3));
    }
    else {
        ui->intDelayLabel->setText(QString("%1 ms").arg(intDelayNs/1000000.0,0,'f',3));
    }
}

void MainWindow::applyClocks()
{
    //Clock output divider and trigger source settings
    uint32_t clkDiv = ui->clkDiv->value();
    if( (clkDiv&1) && clkDiv != 1 ) {
        clkDiv -= 1;
    }
    uint32_t prg = ((clkDiv == 1) ? 0x40000000 : (0x40010000|((clkDiv/2)-1)));
    if( ui->checkTrigSrc->isChecked() ) {
        prg |= 0x01100000;
    }
    fx3.sendWord(3,prg);

    int32_t refClkIndex = ui->refClkCombo->currentIndex();
    if( refClkIndex < 0 || refClkIndex > 7 ) return;

    //Program clock manager
    uint32_t configWords[8] = {
        0x30020109, //20 MHz
        0x30050107, //25 MHz
        0x30060105, //33 MHz
        0x30030104, //40 MHz
        0x30000103, //50 MHz
        0x30070102, //66 MHz
        0x30040304, //80 MHz
        0x30010101  //100 MHz
    };
    prg = configWords[refClkIndex];
    //cout << "Program words: 0x" << setw(8) << setfill('0') << hex << prg;
    if( ((clockStatus&0xfffff00)>>8) != (prg&0xfffff) ) {
        fx3.sendWord(3,prg);
    }
}

void MainWindow::applySettings()
{
    applyClocks();

    int32_t refClkIndex = ui->refClkCombo->currentIndex();
    if( refClkIndex < 0 || refClkIndex > 7 ) return;

    //Intensity counters are not cycle accurate
    //Granularity is 256 (8) cycles at 100 MHz
    uint32_t us2cycles[8] = {
        100,100,100,80,100,133,80,100
    };
    uint32_t acqTimeCycles = ui->acqTime->value();

    fx3SetIntensityDelay(acqTimeCycles/us2cycles[refClkIndex]); //us
    //Intensity counter operation settings
    fx3.sendWord(5,0x30000006); //update intensity when ready, read last value
    fx3.sendWord(6,0x30000006); //update intensity when ready, read last value
    fx3.sendWord(5,0x50000000|ui->intDelay->value());
    fx3.sendWord(6,0x50000000|ui->intDelay->value());
    fx3.sendWord(5,0x60000000|(ui->intTime->value()-2));
    fx3.sendWord(6,0x60000000|(ui->intTime->value()-2));

    //Program TDC modules
    uint32_t memMode = ui->memoryModeCombo->currentIndex();
    uint32_t clkMul[8] = {
        1,1,1,3,1,0,3,1
    };
    uint32_t rawLength = ui->rawHistLength->value();
    if( TIMESTAMP_MODE == memMode )
        rawLength *= 2;

    //Check for valid post-processing settings
    if( !procReset && (memMode == TIMESTAMP_MODE || rawLength != proc.getInputLength()) ) {
        on_procResetButton_clicked();
    }
    if( memMode == TIMESTAMP_MODE && count_if( histogramShifts.begin(), histogramShifts.end(), bind2nd( not_equal_to<uint16_t>(), 0 ) ) ) {
        on_rotResetButton_clicked();
    }

    uint32_t eqSegments = proc.getNumSegments()-1;
    uint32_t prg = 0x50000000|clkMul[refClkIndex]|(((rawLength/2)-1)<<7)|(eqSegments<<19);
    uint32_t useSlowRef = ui->refCombo->currentIndex();
    uint32_t useSlowTrigger = ui->acqSync->isChecked()?1:0;
    uint32_t blockMux = ui->acqMuxSwitch->isChecked()?0:1;
    uint32_t blockMem = ui->acqMemSwitch->isChecked()?0:1;
    uint32_t blockRead = ui->acqReadMem->isChecked()?0:1;
    prg |= (useSlowRef<<22)|(useSlowTrigger<<23)|(blockMux<<24)|(blockMem<<25)|(blockRead<<26);
    //Global config
    //cout << ", 0x" << setw(8) << setfill('0') << hex << prg;
    fx3.sendWord(4,prg);
    fx3.sendWord(4,0xC0000000|ui->acqDelay->value());

    uint32_t globalOffset = ui->globalOffset->value();
    uint32_t histComp = ui->histCompCheck->isChecked()?1:0;
    //Chain config
    fx3WriteTDCchain( globalOffset, memMode, histComp );

    if(procReset) {
        histogramLength = 256*ui->rawHistLength->value()/2;
        if(TIMESTAMP_MODE == memMode)
            histogramLength *= 2;
    }
    else {
        histogramLength = 256*proc.getOutputLength()/2;
    }
    prg = 0xB0000000|((histogramLength/256)-1);
    //cout << ", 0x" << setw(8) << setfill('0') << hex << prg;
    fx3.sendWord(4,prg);

    fx3.sendWord(4, 0x20000000|ui->acqMuxInit->value()); //mux init
    fx3.sendWord(4, 0x60000000|(ui->acqTime->value()-1)); //acq window

    //ui->USBlist->appendPlainText(cout.str().c_str());
}

void MainWindow::processingChanged( bool reset )
{
    statistics.clear();
    statistics.resize(256*1024);
    ui->statsDisplay->setValue(0);
    if( reset ) {
        procReset = true;
        ui->procLengthWarning->setPixmap(QIcon().pixmap(QSize(24, 24)));
        ui->procLength->setText("N/A");
        ui->procWriteButton->setDisabled(true);
        histogramLength = 256*ui->rawHistLength->value()/2;
        if(TIMESTAMP_MODE == ui->memoryModeCombo->currentIndex())
            histogramLength *= 2;
    }
    else {
        procReset = false;
        ofstream procfile("processing.txt");
        proc.save(procfile);
        histogramLength = 256*proc.getOutputLength()/2;
    }

    uint32_t endLength = histogramLength/128;
    ui->endHistLength->setValue(endLength);
    ui->rotField->setMaximum(endLength-1);
    ui->histogramPlot->xAxis->setRange(0, endLength);
    settingsChanged();
    applySettings();
}

void MainWindow::on_tabWidget_currentChanged(int index)
{
    Q_UNUSED(index);
    applySettings();
}

void MainWindow::on_checkExternalClock_clicked(bool checked)
{
    applySettings();
    fx3SyncClock(checked);
}

void MainWindow::statusTimeout()
{
    if( procReset && rotReset ) {
        processingLabel->setText("Processing off");
    }
    else {
        processingLabel->setText("Processing on");
    }
    if( !FX3_DEBUG && fx3 ) {
        applyClocks();
        fx3ReadClockStatus();
        fx3GetIntensity();
    }
    //statusTimer->start(500);
}

// ///////////////////////////////////////
// Main start button pressed routine
// ///////////////////////////////////////
void MainWindow::on_startPreviewButton_clicked()
{
    if(ui->checkAutoUpdate->isChecked() && !autoRunning)
    {
        autoRunning = true;
        ui->startPreviewButton->setIcon(QIcon(QPixmap(":/Stop.svg")));
        ui->startPreviewButton->setIconSize(QSize(45, 45));
    }
    else if(autoRunning)
    {
        autoRunning = false;
        timer->stop();
        ui->startPreviewButton->setIcon(QIcon(QPixmap(":/Start.svg")));
        ui->startPreviewButton->setIconSize(QSize(45, 45));
    }
    applySettings();
    ui->histField->setMaximum(255);
    updatePreview();
}

void MainWindow::updatePreview()
{
    statusTimer->stop();

    int32_t refClkIndex = ui->refClkCombo->currentIndex();
    if( refClkIndex < 0 || refClkIndex > 7 ) return;
    uint32_t us2cycles[8] = {
        100,100,100,80,100,133,80,100
    };

    fx3GetPreview();
    if( procReset )
    {
        addToStats();
    }
    doPersistence();
    ui->waitCyclesDisp->setText(QString("%1 ms").arg(waitCycles/1000.0/us2cycles[refClkIndex],0,'f',3));
    makeDisp(ui->histField->text().toInt());
    if(HISTOGRAM_MODE == ui->memoryModeCombo->currentIndex()) {
        makeIntensity();
    }
    if(autoRunning)
    {
        timer->start(1000/ui->prevFrequency->value()-4*ui->acqTime->value()/us2cycles[refClkIndex]/1000);
    }
    else
    {
        statusTimer->start(500);
    }
}

void MainWindow::on_checkAutoUpdate_clicked(bool checked)
{
    if(autoRunning && !checked)
    {
        on_startPreviewButton_clicked();
    }
}

void MainWindow::on_intensityBar_elemChanged(int hist, uint32_t intensity, uint32_t maximum)
{
    statusLabel->setText(QString("Histogram: %1, Intensity %2, Maximum %3").arg(hist).arg(intensity).arg(maximum));
    if(ui->checkMouseOver->isChecked())
    {
        ui->histField->setValue(hist);
    }
}

void MainWindow::checkProc()
{
    proc.compile();
    ui->procLength->setText(QString::number(proc.length()));
    if( proc.length() == 0 || proc.length() > 3*4096 ) {
        ui->procLengthWarning->setPixmap(QIcon(":/warning.svg").pixmap(QSize(24, 24)));
        ui->procWriteButton->setDisabled(true);
    }
    else {
        ui->procLengthWarning->setPixmap(QIcon().pixmap(QSize(24, 24)));
        ui->procWriteButton->setEnabled(true);
    }
}

void MainWindow::on_procButton_clicked()
{
    ostringstream cout;
    proc.analyze(statistics, ui->rawHistLength->value(), ui->procInSegments->value(), ui->procOutLength->value(), ui->procPerPixel->isChecked());
    cout << "Largest bin size: " << proc.getLargestBin() << " ps";
    checkProc();
    if(ui->procPerPixel->isChecked()) {
        ui->statsChoose->setMaximum(255);
    }
    else {
        ui->statsChoose->setMaximum(63);
    }
    displayStats(ui->statsChoose->value());
    ui->USBlist->appendPlainText(cout.str().c_str());
}

void MainWindow::on_procWriteButton_clicked()
{
    if(proc.getProgramData().size() != fx3.send(proc.getProgramData().size(),proc.getProgramData().data())) {
        cerr << "Error on program write" << endl;
    }
    processingChanged();
}

void MainWindow::on_procResetButton_clicked()
{
    proc.reset();
    proc.compile();
    if(proc.getProgramData().size() != fx3.send(proc.getProgramData().size(),proc.getProgramData().data())) {
        cerr << "Error on program write" << endl;
    }
    processingChanged(true);
    displayStats(ui->statsChoose->value());
}

void MainWindow::on_procSaveButton_clicked()
{
    QString statsfilename = QFileDialog::getSaveFileName(this,"Choose save file name line 893","results/");
    if(statsfilename.isNull()) return;
    ofstream stats(statsfilename.toStdString().c_str());
    proc.save( stats );
}

void MainWindow::procLoad( istream& stats )
{
    proc.load( stats );
    if( proc.getInputLength() != ui->rawHistLength->value() ) {
        proc.reset();
        QMessageBox::warning(this,"Wrong raw setting.","The length of the raw histogram does not match the correction.");
    }
    else {
        checkProc();
        ui->procPerPixel->setChecked(proc.isPerPixel());
        ui->procInSegments->setValue(proc.getNumSegments());
        ui->procOutLength->setValue(proc.getOutputLength()/proc.getNumSegments());
    }
    displayStats(ui->statsChoose->value());
}

void MainWindow::on_procLoadButton_clicked()
{
    QString statsfilename = QFileDialog::getOpenFileName(this,"Choose load file name","results/");
    if(statsfilename.isNull()) return;
    ifstream stats(statsfilename.toStdString().c_str());
    if(!stats) {
        cerr << "File not found." << endl;
        return;
    }
    procLoad(stats);
}

void MainWindow::on_acqMemSwitchButton_clicked()
{
    fx3.sendWord(4,0x20000004);
}

void MainWindow::on_acqReadMemButton_clicked()
{
    applySettings();
    uint32_t cmd[4] = {
        FX3_FPGA_HEADER(4,3),
        0xA0000000|(histogramLength/4), //number of words
        0x20000008|ui->acqMuxInit->value(),  //read cmd
        0x30000000 //get wait cycles
    };
    fx3.send(4,cmd);
    uint32_t count = fx3.receive( histogramLength/4, (uint32_t*)histReceiveBuffer.data(), 20000, false );
    if(count != histogramLength/4) {
        cerr << "Error: Only " << count << " words received, instead of " << histogramLength/4 << endl;
    }
    count = fx3.receive( 1, &waitCycles, 500, false );
    if( count != 1 ) {
        cerr << "Error: Could not read wait cycles." << endl;
    }

    int32_t refClkIndex = ui->refClkCombo->currentIndex();
    if( refClkIndex < 0 || refClkIndex > 7 ) return;
    uint32_t us2cycles[8] = {
        100,100,100,80,100,133,80,100
    };
    ui->waitCyclesDisp->setText(QString::number(waitCycles/1000.0/us2cycles[refClkIndex],'f',3));

    doPersistence();
    ui->histField->setMaximum(63);
    makeDisp(ui->histField->text().toInt());
}

void MainWindow::on_acqRunButton_clicked()
{
    applySettings();
    uint32_t dataSize = ui->acqReadMem->isChecked()?ui->acqCycles->value()*histogramLength/4:0;

    acqReceiveBuffer.clear();
    acqReceiveBuffer.resize(dataSize);

    uint32_t cmd[6] = {
        FX3_FPGA_HEADER(4,5),
        0xA0000000|dataSize, //number of words
        0x10000000, //waitCycles reset
        0x20000000|ui->acqMuxInit->value(),  //mux init
        ui->acqCycles->value(),
        0x30000000 //get wait cycles
    };
    fx3.send(6,cmd);
    if(dataSize) {
        uint32_t count = fx3.receive( dataSize, acqReceiveBuffer.data(), 20000, false );
        if(count != dataSize) {
            cerr << "Error: Only " << count << " words received, instead of " << dataSize << endl;
        }
    }
    uint32_t count = fx3.receive( 1, &waitCycles, 500, false );
    if( count != 1 ) {
        cerr << "Error: Could not read wait cycles." << endl;
    }

    int32_t refClkIndex = ui->refClkCombo->currentIndex();
    if( refClkIndex < 0 || refClkIndex > 7 ) return;
    uint32_t us2cycles[8] = {
        100,100,100,80,100,133,80,100
    };
    ui->waitCyclesDisp->setText(QString("%1 ms").arg(waitCycles/1000.0/us2cycles[refClkIndex],0,'f',3));

    if(dataSize)
        ui->acqSaveButton->setEnabled(true);
}

void MainWindow::on_acqSaveButton_clicked()
{
    QString statsfilename = QFileDialog::getSaveFileName(this,"Choose save file name line 1004","results/");
    if(statsfilename.isNull()) return;
    if(ui->checkBinary->isChecked()) {
        ofstream stats(statsfilename.toStdString().c_str(), ios::binary);
        stats.write((char*)acqReceiveBuffer.data(), acqReceiveBuffer.size()*4);
    }
    else {
        ofstream stats(statsfilename.toStdString().c_str());
        if(TIMESTAMP_MODE == ui->memoryModeCombo->currentIndex()) {
            for( uint32_t i = 0; i < acqReceiveBuffer.size(); ++i )
            {
                stats << acqReceiveBuffer[i] << endl;
            }
        }
        else {
            for( uint32_t i = 0; i < acqReceiveBuffer.size(); ++i )
            {
                stats << (acqReceiveBuffer[i]&0xffff) << endl;
                stats << ((acqReceiveBuffer[i]>>16)&0xffff) << endl;
            }
        }
    }
}

void MainWindow::on_intRunButton_clicked()
{
    applySettings();

    intReceiveBuffer.clear();
    intReceiveBuffer.resize(512);

    vector<uint32_t> cmd;
    cmd.push_back(0); //header
    cmd.push_back(0x30000008); //disable counting
    cmd.push_back(0x00000000); //read to clear counters
    for( uint32_t i = 0; i < ui->intCycles->value(); ++i )
        cmd.push_back(0x40000000); //counting windows
    cmd.push_back(0x00000000); //read counts
    cmd[0] = FX3_FPGA_HEADER(5,cmd.size()-1);
    fx3.send(cmd.size(),cmd.data());

    //read clearing data followed by counts
    for( uint32_t i = 0; i < 2; ++i ) {
        uint32_t count = fx3.receive( 512, intReceiveBuffer.data(), 20000, false );
        if(count != 512) {
            cerr << "Error: Only " << count << " words received, instead of " << 512 << endl;
        }
        uint32_t cycles;
        count = fx3.receive( 1, &cycles, 500, false );
        if( count != 1 ) {
            cerr << "Error: Could not read wait cycles." << endl;
        }
    }

    ui->intSaveButton->setEnabled(true);
    applySettings(); //Restore operation
}

void MainWindow::on_intSaveButton_clicked()
{
    QString statsfilename = QFileDialog::getSaveFileName(this,"Choose save file name 1064","results/");
    if(statsfilename.isNull()) return;
    if(ui->checkIntBinary->isChecked()) {
        ofstream stats(statsfilename.toStdString().c_str(), ios::binary);
        stats.write((char*)intReceiveBuffer.data(), intReceiveBuffer.size()*4);
    }
    else {
        ofstream stats(statsfilename.toStdString().c_str());
        for( uint32_t i = 0; i < intReceiveBuffer.size(); ++i )
        {
            stats << intReceiveBuffer[i] << endl;
        }
    }
}

void MainWindow::on_statsChoose_valueChanged(int tdc)
{
    displayStats(tdc);
}

void MainWindow::displayStats(int tdc)
{
    const Processing::TDC_characteristic &c = proc.getCharacteristic(tdc);
    ui->statsTable->clear();
    ui->statsTable->setRowCount(c.binPosition.size());
    ui->statsTable->setColumnCount(6);
    ui->statsTable->setHorizontalHeaderLabels(QStringList()<<"Position [ps]"<<"Size [ps]"<<"First bin"<<"Commit count"<<"Factors"<<"Code");
    for( uint32_t i = 0; i < c.binPosition.size(); ++i ) {
        ui->statsTable->setItem(i,0,new QTableWidgetItem(QString::number(c.binPosition[i],'f',3)));
        ui->statsTable->setItem(i,1,new QTableWidgetItem(QString::number(c.binSize[i],'f',3)));
        ui->statsTable->setItem(i,2,new QTableWidgetItem(QString::number(c.firstOutputBin[i])));
        ui->statsTable->setItem(i,3,new QTableWidgetItem(QString::number(c.commitCount[i])));
        ui->statsTable->setItem(i,4,new QTableWidgetItem(QString("%1,%2,%3").arg(c.factors[i][0],0,'f',3).arg(c.factors[i][1],0,'f',3).arg(c.factors[i][2],0,'f',3)));
        ui->statsTable->setItem(i,5,new QTableWidgetItem(c.code[i]));
    }
}

// ///////////////////////////////////////
// Data display handling -- Making the graphs
// ///////////////////////////////////////

void MainWindow::addToStats()
{
    for( uint32_t i = 0; i < histReceiveBuffer.size(); ++i )
    {
        statistics[i] += histReceiveBuffer[i];
    }
    ui->statsDisplay->stepUp();
}

void MainWindow::makeDisp(int channel)
{
    double persistenceDiv = 1.0;
    if(ui->persistenceField->value()>1 && histPersistenceBuffer.size())
        persistenceDiv = histPersistenceBuffer.size();

    ui->histogramPlot->graph(0)->clearData();
    uint32_t binCount = histogramLength/128;
    QVector<double> x(binCount), y(binCount);

    //Timestamp mode
    if( TIMESTAMP_MODE == ui->memoryModeCombo->currentIndex() ) {
        for (uint32_t i=0; i<binCount; i+=2)
        {
            x[i/2] = i/2;
            double h = (histDisplayBuffer[channel*binCount+i+1]&0x7fff);
            double l = histDisplayBuffer[channel*binCount+i];
            y[i/2] = (h*65536.0+l)/persistenceDiv;
        }
    }
    //Histogram mode
    else {
        for (uint32_t i=0; i<binCount; i+=1)
        {
            x[i] = i;
            y[i] = histDisplayBuffer[channel*binCount+i]/persistenceDiv;
        }
    }

    ui->histogramPlot->graph(0)->setData(x,y);
    QString title = "Histogram Channel " + QString::number(channel) + " (Original)";
    textLabel->setText(title);
    textLabel->setFont(QFont(font().family(), 12));
    ui->histogramPlot->replot();
}

void MainWindow::on_persistenceField_valueChanged(int value)
{
    Q_UNUSED(value);
    for( uint32_t i = 0; i < 256*1024; ++i )
    {
        histDisplayBuffer[i] = 0;
    }
    histPersistenceBuffer.clear();
}

void MainWindow::doPersistence()
{
    uint32_t persistenceCount = ui->persistenceField->value();
    if(persistenceCount < 2)
    {
        histDisplayBuffer.assign( histReceiveBuffer.begin(), histReceiveBuffer.end() );
    }
    else
    {
        if(histPersistenceBuffer.size()<persistenceCount)
        {
            for( uint32_t i = 0; i < 256*1024; ++i )
            {
                histDisplayBuffer[i] += histReceiveBuffer[i];
            }
            histPersistenceBuffer.push_front(histReceiveBuffer);
        }
        else
        {
            for( uint32_t i = 0; i < 256*1024; ++i )
            {
                histDisplayBuffer[i] -= histPersistenceBuffer.back()[i];
                histDisplayBuffer[i] += histReceiveBuffer[i];
            }
            histPersistenceBuffer.pop_back();
            histPersistenceBuffer.push_front(histReceiveBuffer);
        }
    }
}

void MainWindow::makeIntensity()
{
    uint32_t binCount = histogramLength/128;
    vector<uint32_t> totalCounts(256);
    vector<uint32_t> maxima(256);
    for( int i = 0; i < 256; ++i )
    {
        uint64_t maxVal = 0;
        for( uint32_t j = 0; j < binCount; ++j )
        {
            if( histDisplayBuffer[i*binCount+j] > maxVal ) {
                maxVal = histDisplayBuffer[i*binCount+j];
                maxima[i] = j;
            }
            totalCounts[i] += histDisplayBuffer[i*binCount+j];
        }
    }
    ui->intensityBar->dataChanged(totalCounts,maxima);
}

void MainWindow::fx3SetIntensityDelay(uint32_t us)
{
    //Cycles in intensity counters are in higher granularity
    uint32_t prgval = 0x20000000|(((us*100)/256)&0xfffffff);
    fx3.sendWord(5,prgval);
    prgval = 0x20000000|(((us*100)/8)&0xfffffff);
    fx3.sendWord(6,prgval);
}

void MainWindow::fx3GetIntensity()
{
    vector<uint32_t> totalCounts(256);
    uint32_t cycles = 0;
    fx3.sendWord(5,0x10000000);
    //high count
    if( 256 != fx3.receive(256, totalCounts.data()) ) {
        cerr << "Error reading intensities 1. mainwindow.cpp line 1226" << endl;
        return;
    }
    //edge count
    if( 256 != fx3.receive(256, totalCounts.data()) ) {
        cerr << "Error reading intensities 2." << endl;
        return;
    }
    //cycles
    if( 1 != fx3.receive(1, &cycles) ) {
        cerr << "Error reading intensity cycle count." << endl;
        return;
    }
    ui->intensityBar->dataChanged(totalCounts);

    vector<uint32_t> auxCounts(8);
    fx3.sendWord(6,0x10000000);
    //high count
    if( 8 != fx3.receive(8, auxCounts.data()) ) {
        cerr << "Error reading intensities 1." << endl;
        return;
    }
    //edge count
    if( 8 != fx3.receive(8, auxCounts.data()) ) {
        cerr << "Error reading intensities 2." << endl;
        return;
    }
    //cycles
    if( 1 != fx3.receive(1, &cycles) ) {
        cerr << "Error reading intensity cycle count." << endl;
        return;
    }
    ui->verticalIntensity->dataChanged(auxCounts);
}

// ///////////////////////////////////////
// Handles of button pressers
// ///////////////////////////////////////

void MainWindow::on_usbResetButton_clicked()
{
    fx3Reset();
    if(fx3) {
        applySettings();
    }
}

void MainWindow::on_savePreviewButton_clicked()
{
    // cerr << "debug 1282 tester. folder: " << folder_number << "   file: " << file_number << endl;
    //QString histfilename = QFileDialog::getSaveFileName(this,"Choose save file name line 1277","results/");

    MyTimers mTimer;


    QString new_file_location = "../../../results/h_";
    new_file_location.append(QString::number(folder_number));
    if(QDir(new_file_location).exists())
        cerr << "debug 1288    folder_number: " << folder_number << endl;
    else{
        QDir().mkdir(new_file_location);
        cerr << "debug 1290" << endl;
    }
    new_file_location.append("/m_");
    new_file_location.append(QString::number(file_number));
    new_file_location.append(".txt");
    file_number++;
    if(file_number>60){
        file_number = 1;
        folder_number++;
    }

    cerr << "debug 1289   exporting to " << new_file_location.toStdString() << endl;
    
    //if(histfilename.isNull()) return;
    //ofstream hist(histfilename.toStdString().c_str());
    ofstream hist(new_file_location.toStdString().c_str());

    
    uint32_t len = histogramLength*2;
    if(ui->histField->maximum()==63)
        len /= 4;

    double persistenceDiv = 1.0;
    if(ui->persistenceField->value()>1 && histPersistenceBuffer.size())
        persistenceDiv = histPersistenceBuffer.size();

    if( HISTOGRAM_MODE == ui->memoryModeCombo->currentIndex() ) {
        for( uint32_t i = 0; i < len; i+=1 )
        {
            hist << setprecision(15) << histDisplayBuffer[i]/persistenceDiv << endl;
        }
    }
    else {
        for( uint32_t i = 0; i < len; i+=2 )
        {
            uint64_t h = (histDisplayBuffer[i+1]&0x7fff);
            uint64_t l = histDisplayBuffer[i];
            hist << setprecision(15) << (h*65536.0+l)/persistenceDiv << endl;
        }
    }
}

void MainWindow::on_resetDisplayButton_clicked()
{
    if( TIMESTAMP_MODE == ui->memoryModeCombo->currentIndex() ) {
        ui->histogramPlot->xAxis->setRange(0, histogramLength/256);
        ui->histogramPlot->yAxis->setRange(0, 0xfffffff);
        ui->histogramPlot->replot();
    }
    else {
        ui->histogramPlot->xAxis->setRange(0, histogramLength/128);
        ui->histogramPlot->yAxis->setRange(0, 0xffff);
        ui->histogramPlot->replot();
    }
}

void MainWindow::fixHistAxes()
{
    Qt::Orientations flags = 0;
    if(!ui->checkFixX->isChecked())
    {
        flags |= Qt::Horizontal;
    }
    if(!ui->checkFixY->isChecked())
    {
        flags |= Qt::Vertical;
    }
    ui->histogramPlot->axisRect()->setRangeZoom(flags);
    ui->histogramPlot->axisRect()->setRangeDrag(flags);
}

void MainWindow::on_checkFixX_clicked()
{
    fixHistAxes();
}

void MainWindow::on_checkFixY_clicked()
{
    fixHistAxes();
}

void MainWindow::onXRangeChanged()
{
    double maxValue = ui->memoryModeCombo->currentIndex()==HISTOGRAM_MODE?1024.0:512.0;
    double newMin = ui->histogramPlot->xAxis->range().lower;
    if(newMin < 0.0)
    {
        newMin = 0.0;
    }
    double newMax = ui->histogramPlot->xAxis->range().upper;
    if(newMax > maxValue)
    {
        newMax = maxValue;
    }
    if(newMax-newMin < 1.0)
    {
        newMax = newMin+1.0;
    }
    ui->histogramPlot->xAxis->setRange(newMin,newMax);
}

void MainWindow::onYRangeChanged()
{
    double maxValue = ui->memoryModeCombo->currentIndex()==HISTOGRAM_MODE?65535.0:268435455.0;
    double newMin = ui->histogramPlot->yAxis->range().lower;
    if(newMin < 0.0)
    {
        newMin = 0.0;
    }
    double newMax = ui->histogramPlot->yAxis->range().upper;
    if(newMax > maxValue)
    {
        newMax = maxValue;
    }
    if(newMax-newMin < 1.0)
    {
        newMax = newMin+1.0;
    }
    ui->histogramPlot->yAxis->setRange(newMin,newMax);
}

void MainWindow::on_histField_valueChanged(int channel)
{
    ui->intensityBar->setActiveElem(channel);
    makeDisp(channel);
}

void MainWindow::fx3SetShift()
{
    rotReset = false;
    for( uint32_t p = 0; p < 256; ++p )
    {
        fx3WriteShift(p,histogramShifts[p]);
    }
    ui->rotField->setValue(histogramShifts[ui->rotHistField->value()]);
}

void MainWindow::fx3WriteShift(int pixel, int shift)
{
    uint32_t prgval = shift&0x3ff;
    if( 0 == (prgval&0x3fe) ) {
        prgval |= 0x400;
    }
    //Program post rotate module
    fx3.sendWord(4,0x80000000|(pixel&0xff)); //Address to channel
    fx3.sendWord(4,0x90040000); //Number of words to write
    fx3.sendWord(4,prgval);
    fx3.sendWord(4,0x70000000); //Equalizer init
}

void MainWindow::on_rotAlignButton_clicked()
{
    uint32_t binCount = histogramLength/128;
    for( int i = 0; i < 256; ++i )
    {
        uint32_t maxPos = 0;
        uint64_t maxVal = 0;
        for( uint32_t j = 0; j < binCount; ++j )
        {
            if( histDisplayBuffer[i*binCount+j] > maxVal ) {
                maxVal = histDisplayBuffer[i*binCount+j];
                maxPos = j;
            }
        }
        histogramShifts[i] = (maxPos+binCount/2)%binCount;
    }
    fx3SetShift();
}

void MainWindow::on_rotResetButton_clicked()
{
    for( int i = 0; i < 256; ++i )
    {
        histogramShifts[i] = 0;
    }
    fx3SetShift();
    rotReset = true;
}

void MainWindow::on_rotHistField_valueChanged(int channel)
{
    ui->rotField->setValue(histogramShifts[channel]);
}

void MainWindow::on_rotField_valueChanged(int shift)
{
    uint32_t rotChannel = ui->rotHistField->value();
    if(shift == histogramShifts[rotChannel]) {
        //nothing to do
        return;
    }

    histogramShifts[rotChannel] = shift;
    fx3WriteShift(rotChannel,shift);
    ostringstream cout;
    cout << "Rotate histogram " << rotChannel << " by " << shift << " bins.";
    ui->USBlist->appendPlainText(cout.str().c_str());
}

void MainWindow::rotSave( ostream& shift )
{
    for( uint32_t p = 0; p < 256; ++p )
    {
        shift << histogramShifts[p] << endl;
    }
}

void MainWindow::on_rotSaveButton_clicked()
{
    QString shiftfilename = QFileDialog::getSaveFileName(this,"Choose save file name line 1472","results/");
    if(shiftfilename.isNull()) return;
    ofstream shift(shiftfilename.toStdString().c_str());
    rotSave(shift);
}

void MainWindow::rotLoad( istream& shift )
{
    for( uint32_t p = 0; p < 256; ++p )
    {
        shift >> histogramShifts[p];
    }
    fx3SetShift();
}

void MainWindow::on_rotLoadButton_clicked()
{
    QString shiftfilename = QFileDialog::getOpenFileName(this,"Choose load file name","results/");
    if(shiftfilename.isNull()) return;
    ifstream shift(shiftfilename.toStdString().c_str());
    if(!shift) {
        cerr << "Shift file not found." << endl;
        return;
    }
    rotLoad(shift);
}

// ///////////////////////////////////////
// USB 3 Data handling
// ///////////////////////////////////////

void MainWindow::fx3Connected()
{
    ui->startPreviewButton->setEnabled(true);
    usbIcon->setPixmap(QPixmap(":/USBon.svg").scaledToHeight(statusBar()->height()-12));
    ui->statusOnOff->setPixmap(QIcon(":/USBon.svg").pixmap(QSize(45, 45)));
    ui->labelOnOff->setText("Connected");
}

void MainWindow::fx3Disconnected()
{
    ui->startPreviewButton->setDisabled(true);
    usbIcon->setPixmap(QPixmap(":/USBoff.svg").scaledToHeight(statusBar()->height()-12));
    ui->statusOnOff->setPixmap(QIcon(":/USBoff.svg").pixmap(QSize(45, 45)));
    ui->labelOnOff->setText("Not connected");
}

bool MainWindow::fx3ReadTimestamp()
{
    ostringstream cout;
    fx3.sendWord( 15, 0x00000000 );
    unsigned id;
    if( 4 != fx3.receive(4, (unsigned char*)&id) ) {
        cerr << "Error receiving data" << endl;
        ui->USBlist->appendPlainText(cout.str().c_str());
        return false;
    }
    cout << "FPGA timestamp: " << hex << id;
    ui->USBlist->appendPlainText(cout.str().c_str());
    return true;
}

void MainWindow::fx3ReadClockStatus(bool print)
{
    uint32_t cmd[4] = {
        FX3_FPGA_HEADER(3,3),
        0x10000000,
        0x00000000,
        0x50000000
    };
    fx3.send(4,cmd);
    uint32_t recvdata[3];
    uint32_t count = fx3.receive( 3, recvdata, 500, false );
    if( count != 3 ) {
        cerr << "Read clock status error: " << count << " words instead of 3 received." << endl;
        return;
    }
    clockStatus = recvdata[1];
    if(print)
    {
        ostringstream cout;
        cout << "External frequency: " << recvdata[0]*1000.0 << " Hz" << endl;
        cout << "Status: 0x" << setw(8) << setfill('0') << hex << recvdata[1] << dec << endl;
        if( !(recvdata[1]&0x20) )
            cout << "WARNING: NOT PROGRAMMED" << endl;
        cout << "External: " << (recvdata[1]&0x1 ? "yes" : "no") << endl;
        cout << "Locked: " << (recvdata[1]&0x4 ? "yes" : "no");
        ui->USBlist->appendPlainText(cout.str().c_str());
    }
    ui->clockFrequencyDisplay->setText(QString::number(recvdata[0]/1000.0,'f',3));
    int32_t refClkIndex = ui->refClkCombo->currentIndex();
    if( refClkIndex < 0 || refClkIndex > 7 ) return;
    uint32_t base[8] = {
        20000, //20 MHz
        25000, //25 MHz
        33333, //33 MHz
        40000, //40 MHz
        50000, //50 MHz
        66666, //66 MHz
        80000, //80 MHz
        100000  //100 MHz
    };
    if( fabs( ((double)recvdata[0])/base[refClkIndex] -1.0 ) > 0.01 ) {
        ui->extClkWarning->setPixmap(QIcon(":/warning.svg").pixmap(QSize(24, 24)));
    }
    else {
        ui->extClkWarning->setPixmap(QIcon().pixmap(QSize(24, 24)));
    }
    if( (recvdata[1]&0x5) == 0x5 ) {
        ui->checkExternalClock->setChecked(true);
        ui->extButton->setIcon(QIcon(QPixmap(":/ExtClock.svg")));
    }
    else {
        ui->checkExternalClock->setChecked(false);
        ui->extButton->setIcon(QIcon(QPixmap(":/IntClock.svg")));
    }
    if( recvdata[2]>=1000 ) {
        ui->trigFreqLabel->setText(QString("%1 MHz").arg(recvdata[2]/1000.0,0,'f',1));
    }
    else {
        ui->trigFreqLabel->setText(QString("%1 kHz").arg(recvdata[2]));
    }
    if( recvdata[2] < 1 ) {
        ui->trigFreqWarning->setPixmap(QIcon(":/warning.svg").pixmap(QSize(24, 24)));
        if( ui->acqSync->isChecked() ) {
            ui->triggerWarning->setPixmap(QIcon(":/warning.svg").pixmap(QSize(24, 24)));
        }
        else {
            ui->triggerWarning->setPixmap(QIcon().pixmap(QSize(24, 24)));
        }
    }
    else {
        ui->trigFreqWarning->setPixmap(QIcon().pixmap(QSize(24, 24)));
        ui->triggerWarning->setPixmap(QIcon().pixmap(QSize(24, 24)));
    }
}

void MainWindow::fx3SyncClock(bool external)
{
    fx3.sendWord(3, 0x20000000|(external?1:0));
    fx3ReadClockStatus(true);
}

void MainWindow::fx3Open()
{
    fx3.init(0x4b4,0xf1);
    if(fx3)
    {
        if(fx3ReadTimestamp()) {
            fx3ReadClockStatus();
            fx3Connected();
        }
    }
}

void MainWindow::fx3Reset()
{
    fx3.reinit();
    fx3.reset();
    while(0<fx3.receive(histogramLength,(uint32_t*)histReceiveBuffer.data(),250,true));
    if(fx3)
    {
        if(fx3ReadTimestamp()) {
            fx3ReadClockStatus();
            fx3Connected();
        }
    }
}

void MainWindow::fx3WriteTDCchain(uint32_t globalOffset, uint32_t memMode, uint32_t histComp)
{
    uint32_t words[5] = {
        FX3_FPGA_HEADER(4,4),
        0x40000000|globalOffset,
        0x40000000|globalOffset,
        0x40000000|(histComp<<16)|globalOffset,
        0x40000000|(memMode<<16)|globalOffset
    };
    //Program modules 63-0
    for(uint32_t i = 0; i < 64; ++i) {
        if( 5 != fx3.send(5,words) ) {
            cerr << "Failed to program TDC modules" << endl;
            return;
        }
    }
}

void MainWindow::fx3GetPreview()
{
    uint32_t cmd[5] = {
        FX3_FPGA_HEADER(4,4),
        0xA0000000|histogramLength, //number of words
        0x10000000, //waitCycles reset
        4, //switch mux n times
        0x30000000 //get wait cycles
    };
    fx3.send(5,cmd);
    uint32_t count = fx3.receive( histogramLength, (uint32_t*)histReceiveBuffer.data(), 20000, false ); //timeout for 80MHz module clock
    if(count != histogramLength) {
        cerr << "Error: Only " << count << " words received, instead of " << histogramLength << endl;
    }
    count = fx3.receive( 1, &waitCycles, 500, false );
    if( count != 1 ) {
        cerr << "Error: Could not read wait cycles." << endl;
    }
}
