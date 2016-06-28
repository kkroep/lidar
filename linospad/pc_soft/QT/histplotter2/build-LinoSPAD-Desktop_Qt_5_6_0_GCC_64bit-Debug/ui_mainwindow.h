/********************************************************************************
** Form generated from reading UI file 'mainwindow.ui'
**
** Created by: Qt User Interface Compiler version 5.6.0
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_MAINWINDOW_H
#define UI_MAINWINDOW_H

#include <QtCore/QVariant>
#include <QtSvg/QSvgWidget>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QCheckBox>
#include <QtWidgets/QComboBox>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QGroupBox>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QMenu>
#include <QtWidgets/QMenuBar>
#include <QtWidgets/QPlainTextEdit>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QSpinBox>
#include <QtWidgets/QTabWidget>
#include <QtWidgets/QTableWidget>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QWidget>
#include "intensitybar.h"
#include "qcustomplot.h"

QT_BEGIN_NAMESPACE

class Ui_MainWindow
{
public:
    QAction *actionQuit;
    QWidget *centralWidget;
    QHBoxLayout *horizontalLayout;
    QTabWidget *tabWidget;
    QWidget *tabPrev;
    QHBoxLayout *horizontalLayout_2;
    QVBoxLayout *verticalLayout;
    QCustomPlot *histogramPlot;
    IntensityBar *intensityBar;
    IntensityBar *verticalIntensity;
    QWidget *tabIntensity;
    QLabel *label_3;
    QLabel *label_5;
    QLabel *label_7;
    QSpinBox *intTime;
    QLabel *intDelayLabel;
    QSpinBox *intDelay;
    QSpinBox *intCycles;
    QLabel *intTimeLabel;
    QLabel *label_11;
    QCheckBox *checkIntBinary;
    QPushButton *intSaveButton;
    QPushButton *intRunButton;
    QLabel *label_12;
    QWidget *tabAcq;
    QVBoxLayout *verticalLayout_2;
    QSvgWidget *acqBg;
    QSpinBox *acqCycles;
    QLabel *label;
    QCheckBox *acqSync;
    QSpinBox *acqDelay;
    QLabel *label_2;
    QLabel *acqDelayLabel;
    QLabel *label_4;
    QSpinBox *acqTime;
    QLabel *acqTimeLabel;
    QCheckBox *acqMuxSwitch;
    QCheckBox *acqMemSwitch;
    QCheckBox *acqReadMem;
    QLabel *label_6;
    QPushButton *acqMemSwitchButton;
    QPushButton *acqReadMemButton;
    QSpinBox *acqMuxInit;
    QLabel *label_9;
    QLabel *label_10;
    QLabel *bufSizeDisp;
    QLabel *triggerWarning;
    QSpacerItem *verticalSpacer_4;
    QWidget *tabRef;
    QVBoxLayout *verticalLayout_3;
    QSvgWidget *refBg;
    QCheckBox *checkExternalClock;
    QComboBox *refClkCombo;
    QPushButton *extButton;
    QSpinBox *clkDiv;
    QLabel *outLabel;
    QLabel *tdcLabel;
    QLabel *modLabel;
    QLabel *refLabel;
    QLabel *mhz;
    QLineEdit *clockFrequencyDisplay;
    QLabel *clkDivWarning;
    QLabel *extClkWarning;
    QCheckBox *checkTrigSrc;
    QPushButton *trigSrcButton;
    QLabel *trigFreqLabel;
    QLabel *trigFreqWarning;
    QSpacerItem *verticalSpacer;
    QWidget *tabHist;
    QVBoxLayout *verticalLayout_5;
    QSvgWidget *histBg;
    QSpinBox *globalOffset;
    QLabel *configLabel_3;
    QLabel *configLabel_4;
    QLineEdit *periodLength;
    QLabel *configLabel_6;
    QComboBox *refCombo;
    QLabel *configLabel_2;
    QSpinBox *rawHistLength;
    QLabel *rawHistLengthWarning;
    QCheckBox *histCompCheck;
    QComboBox *memoryModeCombo;
    QLabel *configLabel_7;
    QLabel *configLabel_8;
    QSpacerItem *verticalSpacer_2;
    QWidget *tabProc;
    QVBoxLayout *verticalLayout_6;
    QSvgWidget *procBg;
    QSpinBox *procOutLength;
    QSpinBox *procInSegments;
    QLabel *configLabel_17;
    QLabel *configLabel_18;
    QLineEdit *procInLength;
    QLabel *configLabel_19;
    QLineEdit *procOutSegments;
    QLabel *configLabel_20;
    QLabel *procSegmentsWarning;
    QPushButton *procButton;
    QLabel *configLabel_21;
    QLineEdit *procLength;
    QLabel *procLengthWarning;
    QPushButton *procWriteButton;
    QPushButton *procResetButton;
    QSpinBox *statsDisplay;
    QSpinBox *endHistLength;
    QLabel *configLabel_5;
    QPushButton *procSaveButton;
    QPushButton *procLoadButton;
    QLabel *configLabel_22;
    QPushButton *rotAlignButton;
    QPushButton *rotSaveButton;
    QPushButton *rotResetButton;
    QPushButton *rotLoadButton;
    QLabel *configLabel_9;
    QLabel *configLabel_10;
    QLabel *histLabel_2;
    QSpinBox *rotField;
    QSpinBox *rotHistField;
    QLabel *histLabel_3;
    QCheckBox *procPerPixel;
    QSpacerItem *verticalSpacer_3;
    QWidget *tabStats;
    QGridLayout *gridLayout;
    QLabel *statsLabel_2;
    QSpinBox *statsChoose;
    QTableWidget *statsTable;
    QWidget *tabUSB;
    QVBoxLayout *verticalLayout_4;
    QGroupBox *USBactivities;
    QLabel *statusOnOff;
    QLabel *labelOnOff;
    QPushButton *usbResetButton;
    QPlainTextEdit *USBlist;
    QPushButton *resetSettings;
    QGroupBox *groupBox;
    QPushButton *startPreviewButton;
    QLabel *histLabel;
    QPushButton *savePreviewButton;
    QPushButton *resetDisplayButton;
    QSpinBox *histField;
    QLabel *waitCyclesLabel;
    QCheckBox *checkFixX;
    QCheckBox *checkFixY;
    QSpinBox *prevFrequency;
    QCheckBox *checkAutoUpdate;
    QLabel *ms_2;
    QCheckBox *checkMouseOver;
    QLabel *persistenceLabel;
    QSpinBox *persistenceField;
    QPushButton *acqRunButton;
    QPushButton *acqSaveButton;
    QLabel *dataSizeDisp;
    QLabel *label_8;
    QLabel *waitCyclesLabel_2;
    QLabel *waitCyclesDisp;
    QCheckBox *checkBinary;
    QMenuBar *menuBar;
    QMenu *menuFile;

    void setupUi(QMainWindow *MainWindow)
    {
        if (MainWindow->objectName().isEmpty())
            MainWindow->setObjectName(QStringLiteral("MainWindow"));
        MainWindow->resize(1297, 835);
        actionQuit = new QAction(MainWindow);
        actionQuit->setObjectName(QStringLiteral("actionQuit"));
        centralWidget = new QWidget(MainWindow);
        centralWidget->setObjectName(QStringLiteral("centralWidget"));
        horizontalLayout = new QHBoxLayout(centralWidget);
        horizontalLayout->setSpacing(6);
        horizontalLayout->setContentsMargins(11, 11, 11, 11);
        horizontalLayout->setObjectName(QStringLiteral("horizontalLayout"));
        tabWidget = new QTabWidget(centralWidget);
        tabWidget->setObjectName(QStringLiteral("tabWidget"));
        QSizePolicy sizePolicy(QSizePolicy::Minimum, QSizePolicy::Minimum);
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(tabWidget->sizePolicy().hasHeightForWidth());
        tabWidget->setSizePolicy(sizePolicy);
        tabWidget->setTabShape(QTabWidget::Rounded);
        tabPrev = new QWidget();
        tabPrev->setObjectName(QStringLiteral("tabPrev"));
        horizontalLayout_2 = new QHBoxLayout(tabPrev);
        horizontalLayout_2->setSpacing(6);
        horizontalLayout_2->setContentsMargins(11, 11, 11, 11);
        horizontalLayout_2->setObjectName(QStringLiteral("horizontalLayout_2"));
        verticalLayout = new QVBoxLayout();
        verticalLayout->setSpacing(6);
        verticalLayout->setObjectName(QStringLiteral("verticalLayout"));
        histogramPlot = new QCustomPlot(tabPrev);
        histogramPlot->setObjectName(QStringLiteral("histogramPlot"));

        verticalLayout->addWidget(histogramPlot);

        intensityBar = new IntensityBar(tabPrev);
        intensityBar->setObjectName(QStringLiteral("intensityBar"));
        QSizePolicy sizePolicy1(QSizePolicy::Preferred, QSizePolicy::Fixed);
        sizePolicy1.setHorizontalStretch(0);
        sizePolicy1.setVerticalStretch(0);
        sizePolicy1.setHeightForWidth(intensityBar->sizePolicy().hasHeightForWidth());
        intensityBar->setSizePolicy(sizePolicy1);
        intensityBar->setMinimumSize(QSize(512, 32));

        verticalLayout->addWidget(intensityBar);


        horizontalLayout_2->addLayout(verticalLayout);

        verticalIntensity = new IntensityBar(tabPrev);
        verticalIntensity->setObjectName(QStringLiteral("verticalIntensity"));
        QSizePolicy sizePolicy2(QSizePolicy::Fixed, QSizePolicy::Preferred);
        sizePolicy2.setHorizontalStretch(0);
        sizePolicy2.setVerticalStretch(0);
        sizePolicy2.setHeightForWidth(verticalIntensity->sizePolicy().hasHeightForWidth());
        verticalIntensity->setSizePolicy(sizePolicy2);
        verticalIntensity->setMinimumSize(QSize(32, 480));

        horizontalLayout_2->addWidget(verticalIntensity);

        QIcon icon;
        icon.addFile(QStringLiteral(":/Hist.svg"), QSize(), QIcon::Normal, QIcon::Off);
        tabWidget->addTab(tabPrev, icon, QString());
        tabIntensity = new QWidget();
        tabIntensity->setObjectName(QStringLiteral("tabIntensity"));
        label_3 = new QLabel(tabIntensity);
        label_3->setObjectName(QStringLiteral("label_3"));
        label_3->setGeometry(QRect(10, 20, 168, 13));
        label_5 = new QLabel(tabIntensity);
        label_5->setObjectName(QStringLiteral("label_5"));
        label_5->setGeometry(QRect(10, 120, 161, 13));
        label_7 = new QLabel(tabIntensity);
        label_7->setObjectName(QStringLiteral("label_7"));
        label_7->setGeometry(QRect(10, 70, 168, 13));
        intTime = new QSpinBox(tabIntensity);
        intTime->setObjectName(QStringLiteral("intTime"));
        intTime->setGeometry(QRect(190, 60, 91, 23));
        intTime->setFrame(true);
        intTime->setMinimum(2);
        intTime->setMaximum(268435456);
        intTime->setValue(2);
        intDelayLabel = new QLabel(tabIntensity);
        intDelayLabel->setObjectName(QStringLiteral("intDelayLabel"));
        intDelayLabel->setGeometry(QRect(290, 120, 91, 16));
        intDelay = new QSpinBox(tabIntensity);
        intDelay->setObjectName(QStringLiteral("intDelay"));
        intDelay->setGeometry(QRect(190, 110, 91, 23));
        intDelay->setFrame(true);
        intDelay->setMinimum(0);
        intDelay->setMaximum(268435455);
        intDelay->setValue(0);
        intCycles = new QSpinBox(tabIntensity);
        intCycles->setObjectName(QStringLiteral("intCycles"));
        intCycles->setGeometry(QRect(190, 10, 91, 23));
        intCycles->setMinimum(1);
        intCycles->setMaximum(65535);
        intCycles->setSingleStep(1);
        intCycles->setValue(1);
        intTimeLabel = new QLabel(tabIntensity);
        intTimeLabel->setObjectName(QStringLiteral("intTimeLabel"));
        intTimeLabel->setGeometry(QRect(290, 70, 91, 16));
        label_11 = new QLabel(tabIntensity);
        label_11->setObjectName(QStringLiteral("label_11"));
        label_11->setGeometry(QRect(300, 20, 119, 13));
        checkIntBinary = new QCheckBox(tabIntensity);
        checkIntBinary->setObjectName(QStringLiteral("checkIntBinary"));
        checkIntBinary->setGeometry(QRect(90, 210, 68, 22));
        intSaveButton = new QPushButton(tabIntensity);
        intSaveButton->setObjectName(QStringLiteral("intSaveButton"));
        intSaveButton->setEnabled(false);
        intSaveButton->setGeometry(QRect(90, 160, 61, 41));
        intRunButton = new QPushButton(tabIntensity);
        intRunButton->setObjectName(QStringLiteral("intRunButton"));
        intRunButton->setGeometry(QRect(10, 160, 61, 41));
        label_12 = new QLabel(tabIntensity);
        label_12->setObjectName(QStringLiteral("label_12"));
        label_12->setGeometry(QRect(170, 180, 21, 13));
        tabWidget->addTab(tabIntensity, QString());
        tabAcq = new QWidget();
        tabAcq->setObjectName(QStringLiteral("tabAcq"));
        verticalLayout_2 = new QVBoxLayout(tabAcq);
        verticalLayout_2->setSpacing(6);
        verticalLayout_2->setContentsMargins(11, 11, 11, 11);
        verticalLayout_2->setObjectName(QStringLiteral("verticalLayout_2"));
        acqBg = new QSvgWidget(tabAcq);
        acqBg->setObjectName(QStringLiteral("acqBg"));
        QSizePolicy sizePolicy3(QSizePolicy::Fixed, QSizePolicy::Fixed);
        sizePolicy3.setHorizontalStretch(0);
        sizePolicy3.setVerticalStretch(0);
        sizePolicy3.setHeightForWidth(acqBg->sizePolicy().hasHeightForWidth());
        acqBg->setSizePolicy(sizePolicy3);
        acqBg->setMinimumSize(QSize(1000, 600));
        acqBg->setMaximumSize(QSize(1000, 600));
        acqCycles = new QSpinBox(acqBg);
        acqCycles->setObjectName(QStringLiteral("acqCycles"));
        acqCycles->setGeometry(QRect(520, 30, 91, 23));
        acqCycles->setMinimum(1);
        acqCycles->setMaximum(65535);
        acqCycles->setSingleStep(4);
        acqCycles->setValue(4);
        label = new QLabel(acqBg);
        label->setObjectName(QStringLiteral("label"));
        label->setGeometry(QRect(340, 40, 168, 13));
        acqSync = new QCheckBox(acqBg);
        acqSync->setObjectName(QStringLiteral("acqSync"));
        acqSync->setGeometry(QRect(524, 90, 211, 31));
        acqDelay = new QSpinBox(acqBg);
        acqDelay->setObjectName(QStringLiteral("acqDelay"));
        acqDelay->setEnabled(false);
        acqDelay->setGeometry(QRect(670, 170, 91, 23));
        acqDelay->setFrame(true);
        acqDelay->setMinimum(0);
        acqDelay->setMaximum(268435455);
        acqDelay->setValue(0);
        label_2 = new QLabel(acqBg);
        label_2->setObjectName(QStringLiteral("label_2"));
        label_2->setGeometry(QRect(520, 180, 146, 13));
        acqDelayLabel = new QLabel(acqBg);
        acqDelayLabel->setObjectName(QStringLiteral("acqDelayLabel"));
        acqDelayLabel->setGeometry(QRect(770, 180, 91, 16));
        label_4 = new QLabel(acqBg);
        label_4->setObjectName(QStringLiteral("label_4"));
        label_4->setGeometry(QRect(340, 260, 168, 13));
        acqTime = new QSpinBox(acqBg);
        acqTime->setObjectName(QStringLiteral("acqTime"));
        acqTime->setGeometry(QRect(520, 250, 91, 23));
        acqTime->setFrame(true);
        acqTime->setMinimum(1);
        acqTime->setMaximum(268435456);
        acqTime->setValue(500000);
        acqTimeLabel = new QLabel(acqBg);
        acqTimeLabel->setObjectName(QStringLiteral("acqTimeLabel"));
        acqTimeLabel->setGeometry(QRect(620, 260, 91, 16));
        acqMuxSwitch = new QCheckBox(acqBg);
        acqMuxSwitch->setObjectName(QStringLiteral("acqMuxSwitch"));
        acqMuxSwitch->setGeometry(QRect(342, 320, 171, 20));
        acqMuxSwitch->setChecked(true);
        acqMemSwitch = new QCheckBox(acqBg);
        acqMemSwitch->setObjectName(QStringLiteral("acqMemSwitch"));
        acqMemSwitch->setGeometry(QRect(342, 470, 171, 20));
        acqMemSwitch->setChecked(true);
        acqReadMem = new QCheckBox(acqBg);
        acqReadMem->setObjectName(QStringLiteral("acqReadMem"));
        acqReadMem->setGeometry(QRect(341, 540, 171, 20));
        acqReadMem->setChecked(true);
        label_6 = new QLabel(acqBg);
        label_6->setObjectName(QStringLiteral("label_6"));
        label_6->setGeometry(QRect(340, 400, 168, 13));
        acqMemSwitchButton = new QPushButton(acqBg);
        acqMemSwitchButton->setObjectName(QStringLiteral("acqMemSwitchButton"));
        acqMemSwitchButton->setGeometry(QRect(520, 460, 131, 41));
        acqReadMemButton = new QPushButton(acqBg);
        acqReadMemButton->setObjectName(QStringLiteral("acqReadMemButton"));
        acqReadMemButton->setGeometry(QRect(520, 530, 131, 41));
        acqMuxInit = new QSpinBox(acqBg);
        acqMuxInit->setObjectName(QStringLiteral("acqMuxInit"));
        acqMuxInit->setGeometry(QRect(460, 340, 41, 23));
        acqMuxInit->setMinimum(0);
        acqMuxInit->setMaximum(3);
        acqMuxInit->setSingleStep(1);
        acqMuxInit->setValue(0);
        label_9 = new QLabel(acqBg);
        label_9->setObjectName(QStringLiteral("label_9"));
        label_9->setGeometry(QRect(380, 350, 77, 13));
        label_10 = new QLabel(acqBg);
        label_10->setObjectName(QStringLiteral("label_10"));
        label_10->setGeometry(QRect(660, 545, 101, 21));
        bufSizeDisp = new QLabel(acqBg);
        bufSizeDisp->setObjectName(QStringLiteral("bufSizeDisp"));
        bufSizeDisp->setGeometry(QRect(760, 545, 91, 21));
        triggerWarning = new QLabel(acqBg);
        triggerWarning->setObjectName(QStringLiteral("triggerWarning"));
        triggerWarning->setGeometry(QRect(740, 90, 24, 24));

        verticalLayout_2->addWidget(acqBg);

        verticalSpacer_4 = new QSpacerItem(20, 141, QSizePolicy::Minimum, QSizePolicy::Expanding);

        verticalLayout_2->addItem(verticalSpacer_4);

        tabWidget->addTab(tabAcq, QString());
        tabRef = new QWidget();
        tabRef->setObjectName(QStringLiteral("tabRef"));
        verticalLayout_3 = new QVBoxLayout(tabRef);
        verticalLayout_3->setSpacing(6);
        verticalLayout_3->setContentsMargins(11, 11, 11, 11);
        verticalLayout_3->setObjectName(QStringLiteral("verticalLayout_3"));
        refBg = new QSvgWidget(tabRef);
        refBg->setObjectName(QStringLiteral("refBg"));
        sizePolicy3.setHeightForWidth(refBg->sizePolicy().hasHeightForWidth());
        refBg->setSizePolicy(sizePolicy3);
        refBg->setMinimumSize(QSize(1000, 600));
        refBg->setMaximumSize(QSize(1000, 600));
        checkExternalClock = new QCheckBox(refBg);
        checkExternalClock->setObjectName(QStringLiteral("checkExternalClock"));
        checkExternalClock->setGeometry(QRect(470, 160, 101, 20));
        refClkCombo = new QComboBox(refBg);
        refClkCombo->setObjectName(QStringLiteral("refClkCombo"));
        refClkCombo->setGeometry(QRect(300, 150, 91, 27));
        refClkCombo->setMaxVisibleItems(8);
        refClkCombo->setFrame(true);
        extButton = new QPushButton(refBg);
        extButton->setObjectName(QStringLiteral("extButton"));
        extButton->setGeometry(QRect(468, 40, 85, 100));
        sizePolicy3.setHeightForWidth(extButton->sizePolicy().hasHeightForWidth());
        extButton->setSizePolicy(sizePolicy3);
        extButton->setMinimumSize(QSize(60, 100));
        extButton->setFlat(true);
        clkDiv = new QSpinBox(refBg);
        clkDiv->setObjectName(QStringLiteral("clkDiv"));
        clkDiv->setGeometry(QRect(660, 270, 91, 23));
        clkDiv->setMinimum(1);
        clkDiv->setMaximum(131072);
        clkDiv->setSingleStep(2);
        clkDiv->setValue(2);
        outLabel = new QLabel(refBg);
        outLabel->setObjectName(QStringLiteral("outLabel"));
        outLabel->setGeometry(QRect(880, 256, 111, 21));
        tdcLabel = new QLabel(refBg);
        tdcLabel->setObjectName(QStringLiteral("tdcLabel"));
        tdcLabel->setGeometry(QRect(740, 173, 101, 21));
        modLabel = new QLabel(refBg);
        modLabel->setObjectName(QStringLiteral("modLabel"));
        modLabel->setGeometry(QRect(740, 123, 101, 21));
        refLabel = new QLabel(refBg);
        refLabel->setObjectName(QStringLiteral("refLabel"));
        refLabel->setGeometry(QRect(740, 70, 101, 21));
        mhz = new QLabel(refBg);
        mhz->setObjectName(QStringLiteral("mhz"));
        mhz->setGeometry(QRect(390, 30, 27, 17));
        clockFrequencyDisplay = new QLineEdit(refBg);
        clockFrequencyDisplay->setObjectName(QStringLiteral("clockFrequencyDisplay"));
        clockFrequencyDisplay->setGeometry(QRect(300, 20, 91, 27));
        clockFrequencyDisplay->setReadOnly(true);
        clkDivWarning = new QLabel(refBg);
        clkDivWarning->setObjectName(QStringLiteral("clkDivWarning"));
        clkDivWarning->setGeometry(QRect(760, 270, 24, 24));
        extClkWarning = new QLabel(refBg);
        extClkWarning->setObjectName(QStringLiteral("extClkWarning"));
        extClkWarning->setGeometry(QRect(440, 20, 24, 24));
        checkTrigSrc = new QCheckBox(refBg);
        checkTrigSrc->setObjectName(QStringLiteral("checkTrigSrc"));
        checkTrigSrc->setGeometry(QRect(230, 490, 101, 20));
        trigSrcButton = new QPushButton(refBg);
        trigSrcButton->setObjectName(QStringLiteral("trigSrcButton"));
        trigSrcButton->setGeometry(QRect(235, 370, 85, 100));
        sizePolicy3.setHeightForWidth(trigSrcButton->sizePolicy().hasHeightForWidth());
        trigSrcButton->setSizePolicy(sizePolicy3);
        trigSrcButton->setMinimumSize(QSize(60, 100));
        trigSrcButton->setFlat(true);
        trigFreqLabel = new QLabel(refBg);
        trigFreqLabel->setObjectName(QStringLiteral("trigFreqLabel"));
        trigFreqLabel->setGeometry(QRect(310, 400, 111, 21));
        trigFreqWarning = new QLabel(refBg);
        trigFreqWarning->setObjectName(QStringLiteral("trigFreqWarning"));
        trigFreqWarning->setGeometry(QRect(340, 430, 24, 24));

        verticalLayout_3->addWidget(refBg);

        verticalSpacer = new QSpacerItem(20, 40, QSizePolicy::Minimum, QSizePolicy::Expanding);

        verticalLayout_3->addItem(verticalSpacer);

        QIcon icon1;
        icon1.addFile(QStringLiteral(":/RefClock.svg"), QSize(), QIcon::Normal, QIcon::Off);
        tabWidget->addTab(tabRef, icon1, QString());
        tabHist = new QWidget();
        tabHist->setObjectName(QStringLiteral("tabHist"));
        verticalLayout_5 = new QVBoxLayout(tabHist);
        verticalLayout_5->setSpacing(6);
        verticalLayout_5->setContentsMargins(11, 11, 11, 11);
        verticalLayout_5->setObjectName(QStringLiteral("verticalLayout_5"));
        histBg = new QSvgWidget(tabHist);
        histBg->setObjectName(QStringLiteral("histBg"));
        sizePolicy3.setHeightForWidth(histBg->sizePolicy().hasHeightForWidth());
        histBg->setSizePolicy(sizePolicy3);
        histBg->setMinimumSize(QSize(1000, 600));
        histBg->setMaximumSize(QSize(1000, 600));
        globalOffset = new QSpinBox(histBg);
        globalOffset->setObjectName(QStringLiteral("globalOffset"));
        globalOffset->setGeometry(QRect(470, 260, 81, 27));
        globalOffset->setMaximum(4095);
        configLabel_3 = new QLabel(histBg);
        configLabel_3->setObjectName(QStringLiteral("configLabel_3"));
        configLabel_3->setGeometry(QRect(470, 240, 108, 13));
        configLabel_4 = new QLabel(histBg);
        configLabel_4->setObjectName(QStringLiteral("configLabel_4"));
        configLabel_4->setGeometry(QRect(560, 100, 107, 26));
        periodLength = new QLineEdit(histBg);
        periodLength->setObjectName(QStringLiteral("periodLength"));
        periodLength->setGeometry(QRect(560, 130, 71, 27));
        periodLength->setReadOnly(true);
        configLabel_6 = new QLabel(histBg);
        configLabel_6->setObjectName(QStringLiteral("configLabel_6"));
        configLabel_6->setGeometry(QRect(50, 480, 108, 13));
        refCombo = new QComboBox(histBg);
        refCombo->setObjectName(QStringLiteral("refCombo"));
        refCombo->setGeometry(QRect(50, 500, 91, 22));
        configLabel_2 = new QLabel(histBg);
        configLabel_2->setObjectName(QStringLiteral("configLabel_2"));
        configLabel_2->setGeometry(QRect(650, 420, 124, 26));
        rawHistLength = new QSpinBox(histBg);
        rawHistLength->setObjectName(QStringLiteral("rawHistLength"));
        rawHistLength->setGeometry(QRect(780, 420, 81, 27));
        rawHistLength->setMinimum(8);
        rawHistLength->setMaximum(1024);
        rawHistLength->setSingleStep(2);
        rawHistLength->setValue(700);
        rawHistLengthWarning = new QLabel(histBg);
        rawHistLengthWarning->setObjectName(QStringLiteral("rawHistLengthWarning"));
        rawHistLengthWarning->setGeometry(QRect(870, 420, 24, 24));
        histCompCheck = new QCheckBox(histBg);
        histCompCheck->setObjectName(QStringLiteral("histCompCheck"));
        histCompCheck->setGeometry(QRect(650, 140, 172, 20));
        memoryModeCombo = new QComboBox(histBg);
        memoryModeCombo->setObjectName(QStringLiteral("memoryModeCombo"));
        memoryModeCombo->setGeometry(QRect(760, 380, 101, 22));
        configLabel_7 = new QLabel(histBg);
        configLabel_7->setObjectName(QStringLiteral("configLabel_7"));
        configLabel_7->setGeometry(QRect(650, 390, 85, 13));
        configLabel_8 = new QLabel(histBg);
        configLabel_8->setObjectName(QStringLiteral("configLabel_8"));
        configLabel_8->setGeometry(QRect(560, 20, 259, 39));

        verticalLayout_5->addWidget(histBg);

        verticalSpacer_2 = new QSpacerItem(20, 141, QSizePolicy::Minimum, QSizePolicy::Expanding);

        verticalLayout_5->addItem(verticalSpacer_2);

        tabWidget->addTab(tabHist, icon, QString());
        tabProc = new QWidget();
        tabProc->setObjectName(QStringLiteral("tabProc"));
        verticalLayout_6 = new QVBoxLayout(tabProc);
        verticalLayout_6->setSpacing(6);
        verticalLayout_6->setContentsMargins(11, 11, 11, 11);
        verticalLayout_6->setObjectName(QStringLiteral("verticalLayout_6"));
        procBg = new QSvgWidget(tabProc);
        procBg->setObjectName(QStringLiteral("procBg"));
        sizePolicy3.setHeightForWidth(procBg->sizePolicy().hasHeightForWidth());
        procBg->setSizePolicy(sizePolicy3);
        procBg->setMinimumSize(QSize(1000, 600));
        procBg->setMaximumSize(QSize(1000, 600));
        procOutLength = new QSpinBox(procBg);
        procOutLength->setObjectName(QStringLiteral("procOutLength"));
        procOutLength->setGeometry(QRect(760, 170, 61, 27));
        procOutLength->setMaximum(1024);
        procOutLength->setSingleStep(1);
        procOutLength->setValue(480);
        procInSegments = new QSpinBox(procBg);
        procInSegments->setObjectName(QStringLiteral("procInSegments"));
        procInSegments->setGeometry(QRect(670, 50, 61, 27));
        procInSegments->setMinimum(1);
        procInSegments->setMaximum(8);
        procInSegments->setSingleStep(1);
        procInSegments->setValue(1);
        configLabel_17 = new QLabel(procBg);
        configLabel_17->setObjectName(QStringLiteral("configLabel_17"));
        configLabel_17->setGeometry(QRect(640, 60, 24, 13));
        configLabel_18 = new QLabel(procBg);
        configLabel_18->setObjectName(QStringLiteral("configLabel_18"));
        configLabel_18->setGeometry(QRect(740, 60, 16, 16));
        procInLength = new QLineEdit(procBg);
        procInLength->setObjectName(QStringLiteral("procInLength"));
        procInLength->setGeometry(QRect(760, 50, 61, 27));
        procInLength->setReadOnly(true);
        configLabel_19 = new QLabel(procBg);
        configLabel_19->setObjectName(QStringLiteral("configLabel_19"));
        configLabel_19->setGeometry(QRect(640, 180, 24, 13));
        procOutSegments = new QLineEdit(procBg);
        procOutSegments->setObjectName(QStringLiteral("procOutSegments"));
        procOutSegments->setGeometry(QRect(670, 170, 61, 27));
        procOutSegments->setReadOnly(true);
        configLabel_20 = new QLabel(procBg);
        configLabel_20->setObjectName(QStringLiteral("configLabel_20"));
        configLabel_20->setGeometry(QRect(740, 180, 16, 16));
        procSegmentsWarning = new QLabel(procBg);
        procSegmentsWarning->setObjectName(QStringLiteral("procSegmentsWarning"));
        procSegmentsWarning->setGeometry(QRect(710, 110, 24, 24));
        procButton = new QPushButton(procBg);
        procButton->setObjectName(QStringLiteral("procButton"));
        procButton->setGeometry(QRect(830, 100, 81, 41));
        sizePolicy3.setHeightForWidth(procButton->sizePolicy().hasHeightForWidth());
        procButton->setSizePolicy(sizePolicy3);
        configLabel_21 = new QLabel(procBg);
        configLabel_21->setObjectName(QStringLiteral("configLabel_21"));
        configLabel_21->setGeometry(QRect(640, 230, 92, 13));
        procLength = new QLineEdit(procBg);
        procLength->setObjectName(QStringLiteral("procLength"));
        procLength->setGeometry(QRect(760, 220, 61, 27));
        procLength->setReadOnly(true);
        procLengthWarning = new QLabel(procBg);
        procLengthWarning->setObjectName(QStringLiteral("procLengthWarning"));
        procLengthWarning->setGeometry(QRect(710, 270, 24, 24));
        procWriteButton = new QPushButton(procBg);
        procWriteButton->setObjectName(QStringLiteral("procWriteButton"));
        procWriteButton->setGeometry(QRect(740, 260, 81, 40));
        sizePolicy3.setHeightForWidth(procWriteButton->sizePolicy().hasHeightForWidth());
        procWriteButton->setSizePolicy(sizePolicy3);
        procResetButton = new QPushButton(procBg);
        procResetButton->setObjectName(QStringLiteral("procResetButton"));
        procResetButton->setGeometry(QRect(830, 260, 81, 40));
        sizePolicy3.setHeightForWidth(procResetButton->sizePolicy().hasHeightForWidth());
        procResetButton->setSizePolicy(sizePolicy3);
        statsDisplay = new QSpinBox(procBg);
        statsDisplay->setObjectName(QStringLiteral("statsDisplay"));
        statsDisplay->setGeometry(QRect(740, 120, 81, 23));
        statsDisplay->setReadOnly(true);
        statsDisplay->setButtonSymbols(QAbstractSpinBox::NoButtons);
        statsDisplay->setMaximum(2000000000);
        endHistLength = new QSpinBox(procBg);
        endHistLength->setObjectName(QStringLiteral("endHistLength"));
        endHistLength->setGeometry(QRect(800, 360, 61, 27));
        endHistLength->setReadOnly(true);
        endHistLength->setButtonSymbols(QAbstractSpinBox::NoButtons);
        endHistLength->setMaximum(1024);
        endHistLength->setValue(700);
        configLabel_5 = new QLabel(procBg);
        configLabel_5->setObjectName(QStringLiteral("configLabel_5"));
        configLabel_5->setGeometry(QRect(640, 370, 151, 17));
        procSaveButton = new QPushButton(procBg);
        procSaveButton->setObjectName(QStringLiteral("procSaveButton"));
        procSaveButton->setGeometry(QRect(740, 310, 81, 40));
        sizePolicy3.setHeightForWidth(procSaveButton->sizePolicy().hasHeightForWidth());
        procSaveButton->setSizePolicy(sizePolicy3);
        procLoadButton = new QPushButton(procBg);
        procLoadButton->setObjectName(QStringLiteral("procLoadButton"));
        procLoadButton->setGeometry(QRect(830, 310, 81, 40));
        sizePolicy3.setHeightForWidth(procLoadButton->sizePolicy().hasHeightForWidth());
        procLoadButton->setSizePolicy(sizePolicy3);
        configLabel_22 = new QLabel(procBg);
        configLabel_22->setObjectName(QStringLiteral("configLabel_22"));
        configLabel_22->setGeometry(QRect(820, 230, 39, 13));
        rotAlignButton = new QPushButton(procBg);
        rotAlignButton->setObjectName(QStringLiteral("rotAlignButton"));
        rotAlignButton->setGeometry(QRect(10, 410, 121, 40));
        sizePolicy3.setHeightForWidth(rotAlignButton->sizePolicy().hasHeightForWidth());
        rotAlignButton->setSizePolicy(sizePolicy3);
        rotSaveButton = new QPushButton(procBg);
        rotSaveButton->setObjectName(QStringLiteral("rotSaveButton"));
        rotSaveButton->setGeometry(QRect(10, 460, 121, 40));
        sizePolicy3.setHeightForWidth(rotSaveButton->sizePolicy().hasHeightForWidth());
        rotSaveButton->setSizePolicy(sizePolicy3);
        rotResetButton = new QPushButton(procBg);
        rotResetButton->setObjectName(QStringLiteral("rotResetButton"));
        rotResetButton->setGeometry(QRect(140, 410, 121, 40));
        sizePolicy3.setHeightForWidth(rotResetButton->sizePolicy().hasHeightForWidth());
        rotResetButton->setSizePolicy(sizePolicy3);
        rotLoadButton = new QPushButton(procBg);
        rotLoadButton->setObjectName(QStringLiteral("rotLoadButton"));
        rotLoadButton->setGeometry(QRect(140, 460, 121, 40));
        sizePolicy3.setHeightForWidth(rotLoadButton->sizePolicy().hasHeightForWidth());
        rotLoadButton->setSizePolicy(sizePolicy3);
        configLabel_9 = new QLabel(procBg);
        configLabel_9->setObjectName(QStringLiteral("configLabel_9"));
        configLabel_9->setGeometry(QRect(10, 390, 151, 17));
        QFont font;
        font.setBold(true);
        font.setWeight(75);
        configLabel_9->setFont(font);
        configLabel_10 = new QLabel(procBg);
        configLabel_10->setObjectName(QStringLiteral("configLabel_10"));
        configLabel_10->setGeometry(QRect(290, 420, 116, 13));
        configLabel_10->setFont(font);
        histLabel_2 = new QLabel(procBg);
        histLabel_2->setObjectName(QStringLiteral("histLabel_2"));
        histLabel_2->setGeometry(QRect(380, 440, 50, 13));
        rotField = new QSpinBox(procBg);
        rotField->setObjectName(QStringLiteral("rotField"));
        rotField->setGeometry(QRect(380, 460, 81, 27));
        rotField->setMaximum(699);
        rotHistField = new QSpinBox(procBg);
        rotHistField->setObjectName(QStringLiteral("rotHistField"));
        rotHistField->setGeometry(QRect(290, 460, 81, 27));
        rotHistField->setMaximum(255);
        histLabel_3 = new QLabel(procBg);
        histLabel_3->setObjectName(QStringLiteral("histLabel_3"));
        histLabel_3->setGeometry(QRect(290, 440, 63, 13));
        procPerPixel = new QCheckBox(procBg);
        procPerPixel->setObjectName(QStringLiteral("procPerPixel"));
        procPerPixel->setGeometry(QRect(640, 10, 143, 20));

        verticalLayout_6->addWidget(procBg);

        verticalSpacer_3 = new QSpacerItem(20, 141, QSizePolicy::Minimum, QSizePolicy::Expanding);

        verticalLayout_6->addItem(verticalSpacer_3);

        tabWidget->addTab(tabProc, QString());
        tabStats = new QWidget();
        tabStats->setObjectName(QStringLiteral("tabStats"));
        gridLayout = new QGridLayout(tabStats);
        gridLayout->setSpacing(6);
        gridLayout->setContentsMargins(11, 11, 11, 11);
        gridLayout->setObjectName(QStringLiteral("gridLayout"));
        statsLabel_2 = new QLabel(tabStats);
        statsLabel_2->setObjectName(QStringLiteral("statsLabel_2"));

        gridLayout->addWidget(statsLabel_2, 0, 0, 1, 1);

        statsChoose = new QSpinBox(tabStats);
        statsChoose->setObjectName(QStringLiteral("statsChoose"));
        statsChoose->setMaximum(63);

        gridLayout->addWidget(statsChoose, 0, 1, 1, 1);

        statsTable = new QTableWidget(tabStats);
        statsTable->setObjectName(QStringLiteral("statsTable"));

        gridLayout->addWidget(statsTable, 2, 0, 1, 2);

        tabWidget->addTab(tabStats, QString());
        tabUSB = new QWidget();
        tabUSB->setObjectName(QStringLiteral("tabUSB"));
        verticalLayout_4 = new QVBoxLayout(tabUSB);
        verticalLayout_4->setSpacing(6);
        verticalLayout_4->setContentsMargins(11, 11, 11, 11);
        verticalLayout_4->setObjectName(QStringLiteral("verticalLayout_4"));
        USBactivities = new QGroupBox(tabUSB);
        USBactivities->setObjectName(QStringLiteral("USBactivities"));
        USBactivities->setMinimumSize(QSize(0, 100));
        statusOnOff = new QLabel(USBactivities);
        statusOnOff->setObjectName(QStringLiteral("statusOnOff"));
        statusOnOff->setGeometry(QRect(10, 30, 45, 45));
        sizePolicy3.setHeightForWidth(statusOnOff->sizePolicy().hasHeightForWidth());
        statusOnOff->setSizePolicy(sizePolicy3);
        labelOnOff = new QLabel(USBactivities);
        labelOnOff->setObjectName(QStringLiteral("labelOnOff"));
        labelOnOff->setGeometry(QRect(70, 40, 141, 24));
        usbResetButton = new QPushButton(USBactivities);
        usbResetButton->setObjectName(QStringLiteral("usbResetButton"));
        usbResetButton->setGeometry(QRect(360, 30, 151, 41));
        sizePolicy3.setHeightForWidth(usbResetButton->sizePolicy().hasHeightForWidth());
        usbResetButton->setSizePolicy(sizePolicy3);
        USBlist = new QPlainTextEdit(USBactivities);
        USBlist->setObjectName(QStringLiteral("USBlist"));
        USBlist->setGeometry(QRect(0, 99, 1071, 631));
        USBlist->setAcceptDrops(false);
        USBlist->setFrameShape(QFrame::Box);
        USBlist->setFrameShadow(QFrame::Sunken);
        USBlist->setLineWidth(1);
        USBlist->setMidLineWidth(1);
        USBlist->setUndoRedoEnabled(false);
        USBlist->setReadOnly(true);
        resetSettings = new QPushButton(USBactivities);
        resetSettings->setObjectName(QStringLiteral("resetSettings"));
        resetSettings->setGeometry(QRect(540, 30, 151, 41));

        verticalLayout_4->addWidget(USBactivities);

        QIcon icon2;
        icon2.addFile(QStringLiteral(":/USB.svg"), QSize(), QIcon::Normal, QIcon::Off);
        tabWidget->addTab(tabUSB, icon2, QString());

        horizontalLayout->addWidget(tabWidget);

        groupBox = new QGroupBox(centralWidget);
        groupBox->setObjectName(QStringLiteral("groupBox"));
        QSizePolicy sizePolicy4(QSizePolicy::Maximum, QSizePolicy::MinimumExpanding);
        sizePolicy4.setHorizontalStretch(0);
        sizePolicy4.setVerticalStretch(0);
        sizePolicy4.setHeightForWidth(groupBox->sizePolicy().hasHeightForWidth());
        groupBox->setSizePolicy(sizePolicy4);
        groupBox->setMinimumSize(QSize(160, 480));
        groupBox->setAlignment(Qt::AlignCenter);
        groupBox->setFlat(false);
        startPreviewButton = new QPushButton(groupBox);
        startPreviewButton->setObjectName(QStringLiteral("startPreviewButton"));
        startPreviewButton->setGeometry(QRect(0, 140, 45, 45));
        sizePolicy3.setHeightForWidth(startPreviewButton->sizePolicy().hasHeightForWidth());
        startPreviewButton->setSizePolicy(sizePolicy3);
        histLabel = new QLabel(groupBox);
        histLabel->setObjectName(QStringLiteral("histLabel"));
        histLabel->setGeometry(QRect(0, 190, 105, 17));
        savePreviewButton = new QPushButton(groupBox);
        savePreviewButton->setObjectName(QStringLiteral("savePreviewButton"));
        savePreviewButton->setGeometry(QRect(50, 140, 45, 45));
        sizePolicy3.setHeightForWidth(savePreviewButton->sizePolicy().hasHeightForWidth());
        savePreviewButton->setSizePolicy(sizePolicy3);
        resetDisplayButton = new QPushButton(groupBox);
        resetDisplayButton->setObjectName(QStringLiteral("resetDisplayButton"));
        resetDisplayButton->setGeometry(QRect(100, 140, 45, 45));
        sizePolicy3.setHeightForWidth(resetDisplayButton->sizePolicy().hasHeightForWidth());
        resetDisplayButton->setSizePolicy(sizePolicy3);
        histField = new QSpinBox(groupBox);
        histField->setObjectName(QStringLiteral("histField"));
        histField->setGeometry(QRect(0, 210, 111, 27));
        histField->setMaximum(255);
        waitCyclesLabel = new QLabel(groupBox);
        waitCyclesLabel->setObjectName(QStringLiteral("waitCyclesLabel"));
        waitCyclesLabel->setGeometry(QRect(0, 294, 143, 13));
        checkFixX = new QCheckBox(groupBox);
        checkFixX->setObjectName(QStringLiteral("checkFixX"));
        checkFixX->setGeometry(QRect(0, 260, 57, 22));
        checkFixX->setChecked(true);
        checkFixY = new QCheckBox(groupBox);
        checkFixY->setObjectName(QStringLiteral("checkFixY"));
        checkFixY->setGeometry(QRect(70, 260, 57, 22));
        prevFrequency = new QSpinBox(groupBox);
        prevFrequency->setObjectName(QStringLiteral("prevFrequency"));
        prevFrequency->setGeometry(QRect(0, 100, 131, 27));
        prevFrequency->setMinimum(1);
        prevFrequency->setMaximum(60);
        prevFrequency->setValue(5);
        checkAutoUpdate = new QCheckBox(groupBox);
        checkAutoUpdate->setObjectName(QStringLiteral("checkAutoUpdate"));
        checkAutoUpdate->setGeometry(QRect(0, 80, 101, 22));
        checkAutoUpdate->setChecked(true);
        ms_2 = new QLabel(groupBox);
        ms_2->setObjectName(QStringLiteral("ms_2"));
        ms_2->setGeometry(QRect(130, 110, 15, 17));
        checkMouseOver = new QCheckBox(groupBox);
        checkMouseOver->setObjectName(QStringLiteral("checkMouseOver"));
        checkMouseOver->setGeometry(QRect(0, 240, 161, 22));
        persistenceLabel = new QLabel(groupBox);
        persistenceLabel->setObjectName(QStringLiteral("persistenceLabel"));
        persistenceLabel->setGeometry(QRect(0, 30, 67, 13));
        persistenceField = new QSpinBox(groupBox);
        persistenceField->setObjectName(QStringLiteral("persistenceField"));
        persistenceField->setGeometry(QRect(0, 50, 131, 27));
        persistenceField->setMinimum(1);
        persistenceField->setMaximum(10000);
        persistenceField->setValue(1);
        acqRunButton = new QPushButton(groupBox);
        acqRunButton->setObjectName(QStringLiteral("acqRunButton"));
        acqRunButton->setGeometry(QRect(0, 380, 61, 41));
        acqSaveButton = new QPushButton(groupBox);
        acqSaveButton->setObjectName(QStringLiteral("acqSaveButton"));
        acqSaveButton->setEnabled(false);
        acqSaveButton->setGeometry(QRect(80, 380, 61, 41));
        dataSizeDisp = new QLabel(groupBox);
        dataSizeDisp->setObjectName(QStringLiteral("dataSizeDisp"));
        dataSizeDisp->setGeometry(QRect(60, 354, 101, 20));
        label_8 = new QLabel(groupBox);
        label_8->setObjectName(QStringLiteral("label_8"));
        label_8->setGeometry(QRect(0, 354, 56, 20));
        waitCyclesLabel_2 = new QLabel(groupBox);
        waitCyclesLabel_2->setObjectName(QStringLiteral("waitCyclesLabel_2"));
        waitCyclesLabel_2->setGeometry(QRect(0, 340, 71, 13));
        waitCyclesLabel_2->setFont(font);
        waitCyclesDisp = new QLabel(groupBox);
        waitCyclesDisp->setObjectName(QStringLiteral("waitCyclesDisp"));
        waitCyclesDisp->setGeometry(QRect(42, 310, 101, 21));
        checkBinary = new QCheckBox(groupBox);
        checkBinary->setObjectName(QStringLiteral("checkBinary"));
        checkBinary->setGeometry(QRect(80, 430, 68, 22));

        horizontalLayout->addWidget(groupBox);

        MainWindow->setCentralWidget(centralWidget);
        menuBar = new QMenuBar(MainWindow);
        menuBar->setObjectName(QStringLiteral("menuBar"));
        menuBar->setGeometry(QRect(0, 0, 1297, 19));
        QSizePolicy sizePolicy5(QSizePolicy::Preferred, QSizePolicy::Preferred);
        sizePolicy5.setHorizontalStretch(0);
        sizePolicy5.setVerticalStretch(0);
        sizePolicy5.setHeightForWidth(menuBar->sizePolicy().hasHeightForWidth());
        menuBar->setSizePolicy(sizePolicy5);
        menuFile = new QMenu(menuBar);
        menuFile->setObjectName(QStringLiteral("menuFile"));
        MainWindow->setMenuBar(menuBar);
        QWidget::setTabOrder(startPreviewButton, savePreviewButton);

        menuBar->addAction(menuFile->menuAction());
        menuFile->addAction(actionQuit);

        retranslateUi(MainWindow);

        tabWidget->setCurrentIndex(0);
        refClkCombo->setCurrentIndex(6);


        QMetaObject::connectSlotsByName(MainWindow);
    } // setupUi

    void retranslateUi(QMainWindow *MainWindow)
    {
        MainWindow->setWindowTitle(QApplication::translate("MainWindow", "LinoSPAD", 0));
        actionQuit->setText(QApplication::translate("MainWindow", "Quit", 0));
#ifndef QT_NO_ACCESSIBILITY
        tabPrev->setAccessibleName(QApplication::translate("MainWindow", "tab1", 0));
#endif // QT_NO_ACCESSIBILITY
        tabWidget->setTabText(tabWidget->indexOf(tabPrev), QApplication::translate("MainWindow", "Preview", 0));
        label_3->setText(QApplication::translate("MainWindow", "Number of acquisition cycles:", 0));
        label_5->setText(QApplication::translate("MainWindow", "Delay of acquisition window:", 0));
        label_7->setText(QApplication::translate("MainWindow", "Length of acquisition window:", 0));
        intDelayLabel->setText(QApplication::translate("MainWindow", "ns", 0));
        intTimeLabel->setText(QApplication::translate("MainWindow", "ns", 0));
        label_11->setText(QApplication::translate("MainWindow", "Executed in software", 0));
        checkIntBinary->setText(QApplication::translate("MainWindow", "Binary", 0));
        intSaveButton->setText(QApplication::translate("MainWindow", "Save", 0));
        intRunButton->setText(QApplication::translate("MainWindow", "Run", 0));
        label_12->setText(QApplication::translate("MainWindow", "2kB", 0));
        tabWidget->setTabText(tabWidget->indexOf(tabIntensity), QApplication::translate("MainWindow", "Intensity counters", 0));
        label->setText(QApplication::translate("MainWindow", "Number of acquisition cycles:", 0));
        acqSync->setText(QApplication::translate("MainWindow", "Wait for trigger / Synchronize\n"
"acquisition window with trigger", 0));
        label_2->setText(QApplication::translate("MainWindow", "Delay acquisition window:", 0));
        acqDelayLabel->setText(QApplication::translate("MainWindow", "ns", 0));
        label_4->setText(QApplication::translate("MainWindow", "Length of acquisition window:", 0));
        acqTimeLabel->setText(QApplication::translate("MainWindow", "ns", 0));
        acqMuxSwitch->setText(QApplication::translate("MainWindow", "Switch pixel multiplexer", 0));
        acqMemSwitch->setText(QApplication::translate("MainWindow", "Switch memory buffers", 0));
        acqReadMem->setText(QApplication::translate("MainWindow", "Read inactive buffer", 0));
        label_6->setText(QApplication::translate("MainWindow", "Wait for memory buffer", 0));
        acqMemSwitchButton->setText(QApplication::translate("MainWindow", "Switch buffers", 0));
        acqReadMemButton->setText(QApplication::translate("MainWindow", "Read back buffer", 0));
        label_9->setText(QApplication::translate("MainWindow", "Initial setting:", 0));
        label_10->setText(QApplication::translate("MainWindow", "64 sets of data:", 0));
        bufSizeDisp->setText(QApplication::translate("MainWindow", "ns", 0));
        triggerWarning->setText(QString());
        tabWidget->setTabText(tabWidget->indexOf(tabAcq), QApplication::translate("MainWindow", "TDC data acquisition", 0));
        checkExternalClock->setText(QApplication::translate("MainWindow", "Use external", 0));
        refClkCombo->clear();
        refClkCombo->insertItems(0, QStringList()
         << QApplication::translate("MainWindow", "20 MHz", 0)
         << QApplication::translate("MainWindow", "25 MHz", 0)
         << QApplication::translate("MainWindow", "33 MHz", 0)
         << QApplication::translate("MainWindow", "40 MHz", 0)
         << QApplication::translate("MainWindow", "50 MHz", 0)
         << QApplication::translate("MainWindow", "66 MHz", 0)
         << QApplication::translate("MainWindow", "80 MHz", 0)
         << QApplication::translate("MainWindow", "100 MHz", 0)
        );
        extButton->setText(QString());
        outLabel->setText(QApplication::translate("MainWindow", "out", 0));
        tdcLabel->setText(QApplication::translate("MainWindow", "tdc", 0));
        modLabel->setText(QApplication::translate("MainWindow", "mod", 0));
        refLabel->setText(QApplication::translate("MainWindow", "ref", 0));
        mhz->setText(QApplication::translate("MainWindow", "MHz", 0));
        clkDivWarning->setText(QString());
        extClkWarning->setText(QString());
        checkTrigSrc->setText(QApplication::translate("MainWindow", "Use internal", 0));
        trigSrcButton->setText(QString());
        trigFreqLabel->setText(QApplication::translate("MainWindow", "out", 0));
        trigFreqWarning->setText(QString());
        tabWidget->setTabText(tabWidget->indexOf(tabRef), QApplication::translate("MainWindow", "Reference clock", 0));
        configLabel_3->setText(QApplication::translate("MainWindow", "Global code offset", 0));
        configLabel_4->setText(QApplication::translate("MainWindow", "Histogram bins for\n"
"reference period", 0));
        periodLength->setText(QApplication::translate("MainWindow", "700", 0));
        configLabel_6->setText(QApplication::translate("MainWindow", "Reference signal", 0));
        refCombo->clear();
        refCombo->insertItems(0, QStringList()
         << QApplication::translate("MainWindow", "REF", 0)
         << QApplication::translate("MainWindow", "TDC trigger", 0)
        );
        configLabel_2->setText(QApplication::translate("MainWindow", "Number of items\n"
"to read from memory", 0));
        rawHistLengthWarning->setText(QString());
        histCompCheck->setText(QApplication::translate("MainWindow", "Compress histogram 4:1", 0));
        memoryModeCombo->clear();
        memoryModeCombo->insertItems(0, QStringList()
         << QApplication::translate("MainWindow", "Histogram", 0)
         << QApplication::translate("MainWindow", "Timestamps", 0)
        );
        configLabel_7->setText(QApplication::translate("MainWindow", "Memory mode:", 0));
        configLabel_8->setText(QApplication::translate("MainWindow", "The delay line is sampled with 400 MHz (TDC)\n"
"for 140 bins per 2.5ns period.\n"
"(35 bins per period compressed.)", 0));
        tabWidget->setTabText(tabWidget->indexOf(tabHist), QApplication::translate("MainWindow", "Histogram settings", 0));
        configLabel_17->setText(QApplication::translate("MainWindow", "64 x", 0));
        configLabel_18->setText(QApplication::translate("MainWindow", "x", 0));
        procInLength->setText(QApplication::translate("MainWindow", "700", 0));
        configLabel_19->setText(QApplication::translate("MainWindow", "64 x", 0));
        procOutSegments->setText(QApplication::translate("MainWindow", "1", 0));
        configLabel_20->setText(QApplication::translate("MainWindow", "x", 0));
        procSegmentsWarning->setText(QString());
#ifndef QT_NO_TOOLTIP
        procButton->setToolTip(QApplication::translate("MainWindow", "Start / Stop button (Interval depends on Integration Time; 0 is one run)", 0));
#endif // QT_NO_TOOLTIP
        procButton->setText(QApplication::translate("MainWindow", "Process", 0));
        configLabel_21->setText(QApplication::translate("MainWindow", "Program length:", 0));
        procLength->setText(QApplication::translate("MainWindow", "N/A", 0));
        procLengthWarning->setText(QString());
#ifndef QT_NO_TOOLTIP
        procWriteButton->setToolTip(QApplication::translate("MainWindow", "Start / Stop button (Interval depends on Integration Time; 0 is one run)", 0));
#endif // QT_NO_TOOLTIP
        procWriteButton->setText(QApplication::translate("MainWindow", "Write", 0));
#ifndef QT_NO_TOOLTIP
        procResetButton->setToolTip(QApplication::translate("MainWindow", "Start / Stop button (Interval depends on Integration Time; 0 is one run)", 0));
#endif // QT_NO_TOOLTIP
        procResetButton->setText(QApplication::translate("MainWindow", "Reset", 0));
        configLabel_5->setText(QApplication::translate("MainWindow", "Current histogram length:", 0));
#ifndef QT_NO_TOOLTIP
        procSaveButton->setToolTip(QApplication::translate("MainWindow", "Start / Stop button (Interval depends on Integration Time; 0 is one run)", 0));
#endif // QT_NO_TOOLTIP
        procSaveButton->setText(QApplication::translate("MainWindow", "Save", 0));
#ifndef QT_NO_TOOLTIP
        procLoadButton->setToolTip(QApplication::translate("MainWindow", "Start / Stop button (Interval depends on Integration Time; 0 is one run)", 0));
#endif // QT_NO_TOOLTIP
        procLoadButton->setText(QApplication::translate("MainWindow", "Load", 0));
        configLabel_22->setText(QApplication::translate("MainWindow", "/12288", 0));
#ifndef QT_NO_TOOLTIP
        rotAlignButton->setToolTip(QApplication::translate("MainWindow", "Start / Stop button (Interval depends on Integration Time; 0 is one run)", 0));
#endif // QT_NO_TOOLTIP
        rotAlignButton->setText(QApplication::translate("MainWindow", "Align histogram\n"
"peaks", 0));
#ifndef QT_NO_TOOLTIP
        rotSaveButton->setToolTip(QApplication::translate("MainWindow", "Start / Stop button (Interval depends on Integration Time; 0 is one run)", 0));
#endif // QT_NO_TOOLTIP
        rotSaveButton->setText(QApplication::translate("MainWindow", "Save", 0));
#ifndef QT_NO_TOOLTIP
        rotResetButton->setToolTip(QApplication::translate("MainWindow", "Start / Stop button (Interval depends on Integration Time; 0 is one run)", 0));
#endif // QT_NO_TOOLTIP
        rotResetButton->setText(QApplication::translate("MainWindow", "Reset", 0));
#ifndef QT_NO_TOOLTIP
        rotLoadButton->setToolTip(QApplication::translate("MainWindow", "Start / Stop button (Interval depends on Integration Time; 0 is one run)", 0));
#endif // QT_NO_TOOLTIP
        rotLoadButton->setText(QApplication::translate("MainWindow", "Load", 0));
        configLabel_9->setText(QApplication::translate("MainWindow", "Histogram rotation:", 0));
        configLabel_10->setText(QApplication::translate("MainWindow", "Individual setting:", 0));
        histLabel_2->setText(QApplication::translate("MainWindow", "Rotation:", 0));
        histLabel_3->setText(QApplication::translate("MainWindow", "Histogram:", 0));
        procPerPixel->setText(QApplication::translate("MainWindow", "Per  pixel correction", 0));
        tabWidget->setTabText(tabWidget->indexOf(tabProc), QApplication::translate("MainWindow", "Postprocessing", 0));
        statsLabel_2->setText(QApplication::translate("MainWindow", "TDC statistics:", 0));
        tabWidget->setTabText(tabWidget->indexOf(tabStats), QApplication::translate("MainWindow", "Statistics", 0));
        USBactivities->setTitle(QApplication::translate("MainWindow", "USB", 0));
        statusOnOff->setText(QString());
        labelOnOff->setText(QApplication::translate("MainWindow", "Not connected", 0));
#ifndef QT_NO_TOOLTIP
        usbResetButton->setToolTip(QApplication::translate("MainWindow", "Start / Stop button (Interval depends on Integration Time; 0 is one run)", 0));
#endif // QT_NO_TOOLTIP
        usbResetButton->setText(QApplication::translate("MainWindow", "Reset connection", 0));
        resetSettings->setText(QApplication::translate("MainWindow", "Reset settings", 0));
        tabWidget->setTabText(tabWidget->indexOf(tabUSB), QApplication::translate("MainWindow", "Debug", 0));
        groupBox->setTitle(QApplication::translate("MainWindow", "Preview", 0));
#ifndef QT_NO_TOOLTIP
        startPreviewButton->setToolTip(QApplication::translate("MainWindow", "Start/Stop preview", 0));
#endif // QT_NO_TOOLTIP
        startPreviewButton->setText(QString());
        histLabel->setText(QApplication::translate("MainWindow", "Histogram (0-255)", 0));
#ifndef QT_NO_TOOLTIP
        savePreviewButton->setToolTip(QApplication::translate("MainWindow", "Save current display values", 0));
#endif // QT_NO_TOOLTIP
        savePreviewButton->setText(QString());
#ifndef QT_NO_TOOLTIP
        resetDisplayButton->setToolTip(QApplication::translate("MainWindow", "Reset display axes", 0));
#endif // QT_NO_TOOLTIP
        resetDisplayButton->setText(QString());
        waitCyclesLabel->setText(QApplication::translate("MainWindow", "Lost waiting for memory:", 0));
        checkFixX->setText(QApplication::translate("MainWindow", "Fix X", 0));
        checkFixY->setText(QApplication::translate("MainWindow", "Fix Y", 0));
        checkAutoUpdate->setText(QApplication::translate("MainWindow", "Auto update", 0));
        ms_2->setText(QApplication::translate("MainWindow", "Hz", 0));
        checkMouseOver->setText(QApplication::translate("MainWindow", "Change on mouseover", 0));
        persistenceLabel->setText(QApplication::translate("MainWindow", "Persistence", 0));
        acqRunButton->setText(QApplication::translate("MainWindow", "Run", 0));
        acqSaveButton->setText(QApplication::translate("MainWindow", "Save", 0));
        dataSizeDisp->setText(QApplication::translate("MainWindow", "ns", 0));
        label_8->setText(QApplication::translate("MainWindow", "Data size:", 0));
        waitCyclesLabel_2->setText(QApplication::translate("MainWindow", "Acquisition", 0));
        waitCyclesDisp->setText(QApplication::translate("MainWindow", "ns", 0));
        checkBinary->setText(QApplication::translate("MainWindow", "Binary", 0));
        menuFile->setTitle(QApplication::translate("MainWindow", "File", 0));
    } // retranslateUi

};

namespace Ui {
    class MainWindow: public Ui_MainWindow {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MAINWINDOW_H
