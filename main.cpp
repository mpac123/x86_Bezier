#include <SFML/Graphics.hpp>
#include "brezier.h"
#include <iostream>
#include <bitset>

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
    
    for (int i=0; i<5; ++i)
    {
		point[i].setFillColor(sf::Color::Red);
		point[i].setRadius(5.0);
	}

	int points[10];
	points[0] = width/10;
	points[5] = height/10;
	points[1] = width/4;
	points[6] = height/6;
	points[2] = width/3;
	points[7] = 3*height/5;
	points[3] = 7*width/10;
	points[8] = height/8;
	points[4] = width/2;
	points[9] = height/4;
	
	uint8_t* pixels = new uint8_t[4*width*height];
	
	sf::Texture texture;
	texture.create(width,height);
	sf::Sprite tlo(texture);
   
	
	
    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        drawBezierCurve(pixels,points,(uint64_t)(4*width),(uint64_t)(4*width*height));
		texture.update(pixels);
		
		
        window.clear();
		window.draw(tlo);
		window.draw(point[2]);
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
