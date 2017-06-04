#include <SFML/Graphics.hpp>
#include "brezier.h"
#include <iostream>
#include <bitset>
#include <cmath>
bool isPointClicked(sf::Vector2<int> coords, sf::CircleShape pt)
{
	sf::Vector2f ptcoords=pt.getPosition();
	float r=pt.getRadius();
	return pow((coords.x-ptcoords.x-r),2)+pow((coords.y-ptcoords.y-r),2)<=pow(r,2);
}
int main(int argc, char **argv)
{
	
	if(argc!=3)
	{
		printf("Usage: %s <image width > <image height >\n",
		       argv[0]);
		return 1;
	}
	int width = atoi(argv[1]);
	int height = atoi(argv[2]);
	
	
    sf::RenderWindow window(sf::VideoMode(width, height), "Bezier's Curve");
    sf::CircleShape point[5];
    
    
    uint8_t* pixels = new uint8_t[4*width*height];
    int32_t points[10];
	points[0] = 9*width/10;
	points[5] = height/10;
	points[1] = 3*width/4;
	points[6] = height/6;
	points[2] = 2*width/3;
	points[7] = 3*height/5;
	points[3] = 7*width/10;
	points[8] = height/8;
	points[4] = width/2;
	points[9] = height/2;
	
    for (int i=0; i<5; ++i)
    {
		point[i].setFillColor(sf::Color::Red);
		point[i].setRadius(5.0);
		point[i].setPosition(points[2*i],points[2*i+1]);
	}

	point[0].setFillColor(sf::Color::Blue);
	point[4].setFillColor(sf::Color::Green);
	point[1].setFillColor(sf::Color::Magenta);
	point[2].setFillColor(sf::Color::Cyan);
	
	
	
	sf::Texture texture;
	texture.create(width,height);
	sf::Sprite tlo(texture);
	
	sf::Vector2<int> coords;
	
	drawBezierCurve(pixels,points,(uint64_t)(4*width),(uint64_t)(4*width*height));
	texture.update(pixels);
	
	
	window.clear();
	window.draw(tlo);
	for (int i=0; i<5; ++i)
		window.draw(point[i]);
	window.display();
    
	while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }
		
				
		
			for (int i=0; i<5; ++i)
			{
				if (isPointClicked(sf::Mouse::getPosition(window),point[i]))
				{
					while (sf::Mouse::isButtonPressed(sf::Mouse::Left))
					{
						coords=sf::Mouse::getPosition(window);
						if(coords.x>width)
							coords.x=width;
						if(coords.y>height)
							coords.y=height;
						if(coords.x<0)
							coords.x=0;
						if (coords.y<0)
							coords.y=0;
						point[i].setPosition(coords.x,coords.y);
						points[2*i]=coords.x;
						points[2*i+1]=coords.y;
						drawBezierCurve(pixels,points,(uint64_t)(4*width),(uint64_t)(4*width*height));
						texture.update(pixels);
						window.clear();
						window.draw(tlo);
						for (int i=0; i<5; ++i)
							window.draw(point[i]);
						window.display();
						
					}
				break;	
				}
				
			}			
					drawBezierCurve(pixels,points,(uint64_t)(4*width),(uint64_t)(4*width*height));
					texture.update(pixels);
					window.clear();
					window.draw(tlo);
					for (int i=0; i<5; ++i)
						window.draw(point[i]);
					window.display();
				
			
		
        
    }
    /*for(int i=0; i<4*width*height; ++i)
    {
		
		std::cout << std::bitset<8>(pixels[i]) << " ";
		if (i%4==3)
			std::cout << std::endl;
		
	}*/
	delete[] pixels;
    return 0;
}
