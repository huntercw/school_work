#include <iostream>

#include "Polygon.h"
#include "Quadrilateral.h"
#include "Rectangle.h"
#include "Square.h"
#include "Triangle.h"
#include "IsoTri.h"


using namespace std;

int main()
{
    // Rectangle Dimensions input
    double rectLength;
    cout << endl << endl << endl << "Please enter the length of the Rectangle." << endl;
    cin >> rectLength;
    double rectWidth;
    cout << endl << endl << endl << "Please enter the width of the Rectangle." << endl; 
    cin >> rectWidth;
    
    // Square dimentions input
    double squSide;
    cout << endl << endl << "Please enter the side length of the square." << endl;
    cin >> squSide;
    
    double isoA;
    cout << "Please enter the length of the congruent sides of the isoceles triangle." << endl;
    cin >> isoA;
    double isoB;
    cout << "Please enter the lenth of the third side of the isoceles triangle." << endl;
    cin >> isoB;

    Rectangle recTest(rectLength, rectWidth);
    double rectPerim = recTest.Perimeter();
    double rectArea = recTest.Area();

    Square squTest(squSide);
    double squArea = squTest.Area();
    double squPerim= squTest.Perimeter();

    IsoTri isoTest(isoA, isoB);
    double isoArea = isoTest.Area();
    double isoPerim = isoTest.Perimeter();

    cout<< "Perimter of the Rectangle: " <<   rectPerim <<endl;
    cout<< "Area of the Rectanle: " << rectArea << endl << endl;

    cout << "Perimeter of the Square: " << squPerim << endl;
    cout << "Area of the Square: " << squArea << endl << endl;

    cout << "Perimeter of the Isoceles Triangle: " << isoPerim << endl;
    cout << "Area of the Isoceles Triangle: " << isoArea << endl << endl;
    return 0;
}
main.cpp
Displaying main.cpp.