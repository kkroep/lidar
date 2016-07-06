#include "intensitybar.h"

#include <QMouseEvent>
#include <QPainter>
#include <QPen>
#include <QColor>
#include <QDebug>

#include <algorithm>
#include <cstdint>
using namespace std;

IntensityBar::IntensityBar(QWidget *)
{
    dataSize = 0;
    activeElem = 0;
    isVertical = false;
    setMouseTracking(true);
}

void IntensityBar::mouseMoveEvent(QMouseEvent *ev)
{
    if( 0 == dataSize ) return;
    if( !isVertical ) {
        double valueWidth = ((double)width())/dataSize;
        int elem = ev->x()/valueWidth;
        if( elem != activeElem ) {
            activeElem = elem;
            elemChanged(elem, intensityData[elem], maximaData[elem]);
        }
    }
    else {
        double valueHeight = ((double)height())/dataSize;
        int elem = ev->y()/valueHeight;
        if( elem != activeElem ) {
            activeElem = elem;
            elemChanged(elem, intensityData[elem], maximaData[elem]);
        }
    }
}

void IntensityBar::mouseReleaseEvent(QMouseEvent *)
{
    if( activeElem >= dataSize ) return;
    elemClicked(activeElem, intensityData[activeElem], maximaData[activeElem]);
}

void IntensityBar::dataChanged(const std::vector<uint32_t> &counts)
{
    dataChanged(counts,vector<uint32_t>(counts.size()));
}

void IntensityBar::dataChanged(const std::vector<uint32_t> &counts, const std::vector<uint32_t> &maxima)
{
    intensityData = counts;
    dataSize = intensityData.size();

    maximaData = maxima;
    if( maximaData.size() != dataSize ) {
        maximaData.resize(dataSize);
    }

    if( activeElem >= dataSize ) {
        activeElem = dataSize-1;
    }
    elemChanged(activeElem,intensityData[activeElem], maximaData[activeElem]);
    update();
}

void IntensityBar::setActiveElem(uint32_t elem)
{
    if( elem >= dataSize ) return;
    activeElem = elem;
    elemChanged(activeElem,intensityData[activeElem], maximaData[activeElem]);
}

void IntensityBar::paintEvent(QPaintEvent *event)
{
    Q_UNUSED(event);
    if( 0 == dataSize ) return;
    QPainter painter(this);
    if( width() > height() ) {
        isVertical = false;
        double valueWidth = ((double)width())/dataSize;
        double maxIntensity = max(1u, *max_element(intensityData.begin(),intensityData.end()));
        QPen myPen(Qt::black, 0.5, Qt::SolidLine);
        painter.setPen(myPen);

        for( unsigned int i = 0; i < dataSize; ++i ) {
            QRectF rect(i*valueWidth,0.0,valueWidth,height());
            painter.setBrush(QBrush(QColor(intensityData[i]/maxIntensity*255.0+0.5,0,0), Qt::SolidPattern));
            painter.drawRect(rect);
        }
    }
    else {
        isVertical = true;
        double valueHeight = ((double)height())/dataSize;
        double maxIntensity = max(1u, *max_element(intensityData.begin(),intensityData.end()));
        QPen myPen(Qt::black, 0.5, Qt::SolidLine);
        painter.setPen(myPen);

        for( unsigned int i = 0; i < dataSize; ++i ) {
            QRectF rect(0.0,i*valueHeight,width(),valueHeight);
            painter.setBrush(QBrush(QColor(intensityData[i]/maxIntensity*255.0+0.5,0,0), Qt::SolidPattern));
            painter.drawRect(rect);
        }
    }
}
