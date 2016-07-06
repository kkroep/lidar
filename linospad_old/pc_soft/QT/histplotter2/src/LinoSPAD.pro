#-------------------------------------------------
#
# Project created by QtCreator 2013-11-13T11:54:44
#
#-------------------------------------------------

QT       += core gui svg

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets printsupport

TARGET =    LinoSPAD
TEMPLATE =  app
CONFIG +=   c++11
DESTDIR = $$PWD/..

#RC_FILE +=  Icon.rc

#DEFINES += EIGEN_FFTW_DEFAULT

SOURCES +=  main.cpp\
			mytimer.cpp\ # Kees added this
            mainwindow.cpp \
            qcustomplot.cpp \
            intensitybar.cpp \
    fx3stream.C \
    processing.cpp

HEADERS  += mainwindow.h \
			mytimer.h \ # Kees added this
            qcustomplot.h \
            intensitybar.h \
    fx3stream.h \
    processing.h

FORMS    += mainwindow.ui

RESOURCES += resource.qrc

LIBS += -lusb-1.0
win32: INCLUDEPATH += "..\libusb\include"
win32: LIBS += -L"..\libusb\MinGW32\static"
win32: QMAKE_CFLAGS += -std=c++11
