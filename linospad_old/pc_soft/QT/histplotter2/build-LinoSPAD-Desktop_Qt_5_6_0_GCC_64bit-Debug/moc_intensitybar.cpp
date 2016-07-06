/****************************************************************************
** Meta object code from reading C++ file 'intensitybar.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/intensitybar.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'intensitybar.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_IntensityBar_t {
    QByteArrayData data[14];
    char stringdata0[137];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_IntensityBar_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_IntensityBar_t qt_meta_stringdata_IntensityBar = {
    {
QT_MOC_LITERAL(0, 0, 12), // "IntensityBar"
QT_MOC_LITERAL(1, 13, 11), // "elemChanged"
QT_MOC_LITERAL(2, 25, 0), // ""
QT_MOC_LITERAL(3, 26, 4), // "hist"
QT_MOC_LITERAL(4, 31, 8), // "uint32_t"
QT_MOC_LITERAL(5, 40, 9), // "intensity"
QT_MOC_LITERAL(6, 50, 7), // "maximum"
QT_MOC_LITERAL(7, 58, 11), // "elemClicked"
QT_MOC_LITERAL(8, 70, 11), // "dataChanged"
QT_MOC_LITERAL(9, 82, 21), // "std::vector<uint32_t>"
QT_MOC_LITERAL(10, 104, 6), // "counts"
QT_MOC_LITERAL(11, 111, 6), // "maxima"
QT_MOC_LITERAL(12, 118, 13), // "setActiveElem"
QT_MOC_LITERAL(13, 132, 4) // "elem"

    },
    "IntensityBar\0elemChanged\0\0hist\0uint32_t\0"
    "intensity\0maximum\0elemClicked\0dataChanged\0"
    "std::vector<uint32_t>\0counts\0maxima\0"
    "setActiveElem\0elem"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_IntensityBar[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    3,   39,    2, 0x06 /* Public */,
       7,    3,   46,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       8,    1,   53,    2, 0x0a /* Public */,
       8,    2,   56,    2, 0x0a /* Public */,
      12,    1,   61,    2, 0x0a /* Public */,

 // signals: parameters
    QMetaType::Void, QMetaType::Int, 0x80000000 | 4, 0x80000000 | 4,    3,    5,    6,
    QMetaType::Void, QMetaType::Int, 0x80000000 | 4, 0x80000000 | 4,    3,    5,    6,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 9,   10,
    QMetaType::Void, 0x80000000 | 9, 0x80000000 | 9,   10,   11,
    QMetaType::Void, 0x80000000 | 4,   13,

       0        // eod
};

void IntensityBar::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        IntensityBar *_t = static_cast<IntensityBar *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->elemChanged((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< uint32_t(*)>(_a[2])),(*reinterpret_cast< uint32_t(*)>(_a[3]))); break;
        case 1: _t->elemClicked((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< uint32_t(*)>(_a[2])),(*reinterpret_cast< uint32_t(*)>(_a[3]))); break;
        case 2: _t->dataChanged((*reinterpret_cast< const std::vector<uint32_t>(*)>(_a[1]))); break;
        case 3: _t->dataChanged((*reinterpret_cast< const std::vector<uint32_t>(*)>(_a[1])),(*reinterpret_cast< const std::vector<uint32_t>(*)>(_a[2]))); break;
        case 4: _t->setActiveElem((*reinterpret_cast< uint32_t(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (IntensityBar::*_t)(int , uint32_t , uint32_t );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&IntensityBar::elemChanged)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (IntensityBar::*_t)(int , uint32_t , uint32_t );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&IntensityBar::elemClicked)) {
                *result = 1;
                return;
            }
        }
    }
}

const QMetaObject IntensityBar::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_IntensityBar.data,
      qt_meta_data_IntensityBar,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *IntensityBar::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *IntensityBar::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_IntensityBar.stringdata0))
        return static_cast<void*>(const_cast< IntensityBar*>(this));
    return QWidget::qt_metacast(_clname);
}

int IntensityBar::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 5)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 5;
    }
    return _id;
}

// SIGNAL 0
void IntensityBar::elemChanged(int _t1, uint32_t _t2, uint32_t _t3)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)), const_cast<void*>(reinterpret_cast<const void*>(&_t3)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void IntensityBar::elemClicked(int _t1, uint32_t _t2, uint32_t _t3)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)), const_cast<void*>(reinterpret_cast<const void*>(&_t3)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}
QT_END_MOC_NAMESPACE
