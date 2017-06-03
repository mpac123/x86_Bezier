#ifndef BEZIER_H
#define BEZIER_H
#include <cstdint>
extern "C" void drawBezierCurve(void *begin, void *pointsArray, uint64_t rowBytesSize, uint64_t imageBytesSize);
#endif // BEZIER_H
