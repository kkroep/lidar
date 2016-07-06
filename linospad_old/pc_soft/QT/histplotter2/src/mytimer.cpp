// #include "mytimer.h"
// #include <QtCore>
// #include <QDebug>

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

MyTimer::MyTimer()
{
	timer = new QTimer(this);
	connect(timer, SIGNAL(timeout()), this, SLOT(MySlot()));

	timer->start(1000);
}

void MyTimer::MySlot()
{
    cerr << "Timer loop 1 sec" << endl;
}