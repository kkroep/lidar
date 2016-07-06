#ifndef INTENSITYBAR_H
#define INTENSITYBAR_H

#include <QWidget>
#include <vector>
#include <cstdint>
using namespace std;

class IntensityBar : public QWidget
{
    Q_OBJECT
public:
    IntensityBar(QWidget*);

protected:
    void mouseMoveEvent(QMouseEvent *ev) Q_DECL_OVERRIDE;
    void mouseReleaseEvent(QMouseEvent *) Q_DECL_OVERRIDE;
    void paintEvent(QPaintEvent *event) Q_DECL_OVERRIDE;

public slots:
    void dataChanged(const std::vector<uint32_t> &counts);
    void dataChanged(const std::vector<uint32_t> &counts, const std::vector<uint32_t> &maxima);
    void setActiveElem(uint32_t elem);

signals:
    void elemChanged(int hist, uint32_t intensity, uint32_t maximum);
    void elemClicked(int hist, uint32_t intensity, uint32_t maximum);

private:
    uint32_t dataSize;
    uint32_t activeElem;
    bool isVertical;
    std::vector<uint32_t> intensityData;
    std::vector<uint32_t> maximaData;
};

#endif // INTENSITYBAR_H
