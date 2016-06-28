/****************************************************************************
** Meta object code from reading C++ file 'mainwindow.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.5.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "mainwindow.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'mainwindow.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.5.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_MainWindow_t {
    QByteArrayData data[51];
    char stringdata0[1009];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_MainWindow_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_MainWindow_t qt_meta_stringdata_MainWindow = {
    {
QT_MOC_LITERAL(0, 0, 10), // "MainWindow"
QT_MOC_LITERAL(1, 11, 15), // "settingsChanged"
QT_MOC_LITERAL(2, 27, 0), // ""
QT_MOC_LITERAL(3, 28, 9), // "on_escape"
QT_MOC_LITERAL(4, 38, 6), // "on_tab"
QT_MOC_LITERAL(5, 45, 11), // "on_shiftTab"
QT_MOC_LITERAL(6, 57, 13), // "updatePreview"
QT_MOC_LITERAL(7, 71, 29), // "on_startPreviewButton_clicked"
QT_MOC_LITERAL(8, 101, 25), // "on_histField_valueChanged"
QT_MOC_LITERAL(9, 127, 7), // "channel"
QT_MOC_LITERAL(10, 135, 29), // "on_resetDisplayButton_clicked"
QT_MOC_LITERAL(11, 165, 27), // "on_tabWidget_currentChanged"
QT_MOC_LITERAL(12, 193, 5), // "index"
QT_MOC_LITERAL(13, 199, 29), // "on_checkExternalClock_clicked"
QT_MOC_LITERAL(14, 229, 7), // "checked"
QT_MOC_LITERAL(15, 237, 13), // "statusTimeout"
QT_MOC_LITERAL(16, 251, 15), // "onXRangeChanged"
QT_MOC_LITERAL(17, 267, 15), // "onYRangeChanged"
QT_MOC_LITERAL(18, 283, 20), // "on_checkFixX_clicked"
QT_MOC_LITERAL(19, 304, 20), // "on_checkFixY_clicked"
QT_MOC_LITERAL(20, 325, 26), // "on_checkAutoUpdate_clicked"
QT_MOC_LITERAL(21, 352, 27), // "on_intensityBar_elemChanged"
QT_MOC_LITERAL(22, 380, 4), // "hist"
QT_MOC_LITERAL(23, 385, 8), // "uint32_t"
QT_MOC_LITERAL(24, 394, 9), // "intensity"
QT_MOC_LITERAL(25, 404, 7), // "maximum"
QT_MOC_LITERAL(26, 412, 27), // "on_statsChoose_valueChanged"
QT_MOC_LITERAL(27, 440, 3), // "tdc"
QT_MOC_LITERAL(28, 444, 25), // "on_usbResetButton_clicked"
QT_MOC_LITERAL(29, 470, 21), // "on_procButton_clicked"
QT_MOC_LITERAL(30, 492, 26), // "on_procResetButton_clicked"
QT_MOC_LITERAL(31, 519, 26), // "on_procWriteButton_clicked"
QT_MOC_LITERAL(32, 546, 25), // "on_procSaveButton_clicked"
QT_MOC_LITERAL(33, 572, 25), // "on_procLoadButton_clicked"
QT_MOC_LITERAL(34, 598, 28), // "on_savePreviewButton_clicked"
QT_MOC_LITERAL(35, 627, 29), // "on_acqMemSwitchButton_clicked"
QT_MOC_LITERAL(36, 657, 27), // "on_acqReadMemButton_clicked"
QT_MOC_LITERAL(37, 685, 23), // "on_acqRunButton_clicked"
QT_MOC_LITERAL(38, 709, 24), // "on_acqSaveButton_clicked"
QT_MOC_LITERAL(39, 734, 23), // "on_intRunButton_clicked"
QT_MOC_LITERAL(40, 758, 24), // "on_intSaveButton_clicked"
QT_MOC_LITERAL(41, 783, 28), // "on_rotHistField_valueChanged"
QT_MOC_LITERAL(42, 812, 24), // "on_rotField_valueChanged"
QT_MOC_LITERAL(43, 837, 5), // "shift"
QT_MOC_LITERAL(44, 843, 24), // "on_rotSaveButton_clicked"
QT_MOC_LITERAL(45, 868, 24), // "on_rotLoadButton_clicked"
QT_MOC_LITERAL(46, 893, 25), // "on_rotAlignButton_clicked"
QT_MOC_LITERAL(47, 919, 25), // "on_rotResetButton_clicked"
QT_MOC_LITERAL(48, 945, 32), // "on_persistenceField_valueChanged"
QT_MOC_LITERAL(49, 978, 5), // "value"
QT_MOC_LITERAL(50, 984, 24) // "on_resetSettings_clicked"

    },
    "MainWindow\0settingsChanged\0\0on_escape\0"
    "on_tab\0on_shiftTab\0updatePreview\0"
    "on_startPreviewButton_clicked\0"
    "on_histField_valueChanged\0channel\0"
    "on_resetDisplayButton_clicked\0"
    "on_tabWidget_currentChanged\0index\0"
    "on_checkExternalClock_clicked\0checked\0"
    "statusTimeout\0onXRangeChanged\0"
    "onYRangeChanged\0on_checkFixX_clicked\0"
    "on_checkFixY_clicked\0on_checkAutoUpdate_clicked\0"
    "on_intensityBar_elemChanged\0hist\0"
    "uint32_t\0intensity\0maximum\0"
    "on_statsChoose_valueChanged\0tdc\0"
    "on_usbResetButton_clicked\0"
    "on_procButton_clicked\0on_procResetButton_clicked\0"
    "on_procWriteButton_clicked\0"
    "on_procSaveButton_clicked\0"
    "on_procLoadButton_clicked\0"
    "on_savePreviewButton_clicked\0"
    "on_acqMemSwitchButton_clicked\0"
    "on_acqReadMemButton_clicked\0"
    "on_acqRunButton_clicked\0"
    "on_acqSaveButton_clicked\0"
    "on_intRunButton_clicked\0"
    "on_intSaveButton_clicked\0"
    "on_rotHistField_valueChanged\0"
    "on_rotField_valueChanged\0shift\0"
    "on_rotSaveButton_clicked\0"
    "on_rotLoadButton_clicked\0"
    "on_rotAlignButton_clicked\0"
    "on_rotResetButton_clicked\0"
    "on_persistenceField_valueChanged\0value\0"
    "on_resetSettings_clicked"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_MainWindow[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
      39,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    0,  209,    2, 0x08 /* Private */,
       3,    0,  210,    2, 0x08 /* Private */,
       4,    0,  211,    2, 0x08 /* Private */,
       5,    0,  212,    2, 0x08 /* Private */,
       6,    0,  213,    2, 0x08 /* Private */,
       7,    0,  214,    2, 0x08 /* Private */,
       8,    1,  215,    2, 0x08 /* Private */,
      10,    0,  218,    2, 0x08 /* Private */,
      11,    1,  219,    2, 0x08 /* Private */,
      13,    1,  222,    2, 0x08 /* Private */,
      15,    0,  225,    2, 0x08 /* Private */,
      16,    0,  226,    2, 0x08 /* Private */,
      17,    0,  227,    2, 0x08 /* Private */,
      18,    0,  228,    2, 0x08 /* Private */,
      19,    0,  229,    2, 0x08 /* Private */,
      20,    1,  230,    2, 0x08 /* Private */,
      21,    3,  233,    2, 0x08 /* Private */,
      26,    1,  240,    2, 0x08 /* Private */,
      28,    0,  243,    2, 0x08 /* Private */,
      29,    0,  244,    2, 0x08 /* Private */,
      30,    0,  245,    2, 0x08 /* Private */,
      31,    0,  246,    2, 0x08 /* Private */,
      32,    0,  247,    2, 0x08 /* Private */,
      33,    0,  248,    2, 0x08 /* Private */,
      34,    0,  249,    2, 0x08 /* Private */,
      35,    0,  250,    2, 0x08 /* Private */,
      36,    0,  251,    2, 0x08 /* Private */,
      37,    0,  252,    2, 0x08 /* Private */,
      38,    0,  253,    2, 0x08 /* Private */,
      39,    0,  254,    2, 0x08 /* Private */,
      40,    0,  255,    2, 0x08 /* Private */,
      41,    1,  256,    2, 0x08 /* Private */,
      42,    1,  259,    2, 0x08 /* Private */,
      44,    0,  262,    2, 0x08 /* Private */,
      45,    0,  263,    2, 0x08 /* Private */,
      46,    0,  264,    2, 0x08 /* Private */,
      47,    0,  265,    2, 0x08 /* Private */,
      48,    1,  266,    2, 0x08 /* Private */,
      50,    0,  269,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    9,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,   12,
    QMetaType::Void, QMetaType::Bool,   14,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Bool,   14,
    QMetaType::Void, QMetaType::Int, 0x80000000 | 23, 0x80000000 | 23,   22,   24,   25,
    QMetaType::Void, QMetaType::Int,   27,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    9,
    QMetaType::Void, QMetaType::Int,   43,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,   49,
    QMetaType::Void,

       0        // eod
};

void MainWindow::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        MainWindow *_t = static_cast<MainWindow *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->settingsChanged(); break;
        case 1: _t->on_escape(); break;
        case 2: _t->on_tab(); break;
        case 3: _t->on_shiftTab(); break;
        case 4: _t->updatePreview(); break;
        case 5: _t->on_startPreviewButton_clicked(); break;
        case 6: _t->on_histField_valueChanged((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 7: _t->on_resetDisplayButton_clicked(); break;
        case 8: _t->on_tabWidget_currentChanged((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 9: _t->on_checkExternalClock_clicked((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 10: _t->statusTimeout(); break;
        case 11: _t->onXRangeChanged(); break;
        case 12: _t->onYRangeChanged(); break;
        case 13: _t->on_checkFixX_clicked(); break;
        case 14: _t->on_checkFixY_clicked(); break;
        case 15: _t->on_checkAutoUpdate_clicked((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 16: _t->on_intensityBar_elemChanged((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< uint32_t(*)>(_a[2])),(*reinterpret_cast< uint32_t(*)>(_a[3]))); break;
        case 17: _t->on_statsChoose_valueChanged((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 18: _t->on_usbResetButton_clicked(); break;
        case 19: _t->on_procButton_clicked(); break;
        case 20: _t->on_procResetButton_clicked(); break;
        case 21: _t->on_procWriteButton_clicked(); break;
        case 22: _t->on_procSaveButton_clicked(); break;
        case 23: _t->on_procLoadButton_clicked(); break;
        case 24: _t->on_savePreviewButton_clicked(); break;
        case 25: _t->on_acqMemSwitchButton_clicked(); break;
        case 26: _t->on_acqReadMemButton_clicked(); break;
        case 27: _t->on_acqRunButton_clicked(); break;
        case 28: _t->on_acqSaveButton_clicked(); break;
        case 29: _t->on_intRunButton_clicked(); break;
        case 30: _t->on_intSaveButton_clicked(); break;
        case 31: _t->on_rotHistField_valueChanged((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 32: _t->on_rotField_valueChanged((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 33: _t->on_rotSaveButton_clicked(); break;
        case 34: _t->on_rotLoadButton_clicked(); break;
        case 35: _t->on_rotAlignButton_clicked(); break;
        case 36: _t->on_rotResetButton_clicked(); break;
        case 37: _t->on_persistenceField_valueChanged((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 38: _t->on_resetSettings_clicked(); break;
        default: ;
        }
    }
}

const QMetaObject MainWindow::staticMetaObject = {
    { &QMainWindow::staticMetaObject, qt_meta_stringdata_MainWindow.data,
      qt_meta_data_MainWindow,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *MainWindow::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *MainWindow::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_MainWindow.stringdata0))
        return static_cast<void*>(const_cast< MainWindow*>(this));
    return QMainWindow::qt_metacast(_clname);
}

int MainWindow::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QMainWindow::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 39)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 39;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 39)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 39;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
