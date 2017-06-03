section .text
global drawBezierCurve

drawBezierCurve:
	
	;rdi - wskaźnik na tablicę pikseli
	;rsi - wskaźnik na tablicę punktów (10 wspolrzednych po 64 bit: int x, int y)
	;rdx - szerokosc obrazka [B]
	;rcx - rozmiar obrazka [B]
	
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15
	mov	r15, rdx ;szerokosc obrazka skopiowana do r15

clearImage:
	;wszystkie piksele są zamalowane na biało
	;r10 pokazuje na poczatek ukladu wspolrzednych
		
	mov	r10, rdi
	mov	al, 0xff	;bajt ktorym bedzie zapelniony caly obrazek
	rep	stosb 		;powtarza zapelniane obszaru wskazanego przed rdi (wskaznik na tablice pikseli)
					;az do wyzerowania licznika rcx (na poczatku rozmiar obrazka)
	;jmp end
loadFirstPoint:
	;ładuję współrzędne pierwszego punktu
	;będe używała rejestrów xmm, bo łatwo będzie mi wykonywać powtarzalne obliczenia
	;bez konieczności uzywania skoków
	mov rax,[rsi]		;rax=(p0.x,p0.y)
	movq	xmm0, rax 	;xmm0=(0,0,p1.x,p1.y)
	;movlps xmm0,[rsi]
	;movlhps	xmm2, xmm2 	;xmm0=(p0.x,p0.y,p0.x,p0.y) - przyda się do wyznaczenia współrzędnych p1..p4
						;								w układzie współrzędnych względem p0
changeCoordinateSystem:	
	;ustawiam r10 na p0 czyli nowy początek układu współrzędnych
	mov	r11d, eax 		;p0.x (bo wyższe bity automatycznie się wyzerowały)
	shr	rax, 32 		;p0.y
	mul	r15 			;rax = rax*r15 = p0.y * (szerokosc obrazka) -> offset po wysokosci
	add r10, rax
	lea	r11, [4*r11]	;p0.x * 4 - offset po szerokosci
	add	r10, r11		
	
	
loadNextPoints:
	movlps xmm1,[rsi+8] 	;xmm1=(0,0,p1.x,p1.y)
	movlps xmm2,[rsi+16]	;xmm2=(0,0,p2.x,p2.y)
	movlps xmm3,[rsi+24]	;xmm3=(0,0,03.x,p3.y)
	movlps xmm4,[rsi+32]	;xmm4=(0,0,p4.x,p4.y)
	psubd xmm1, xmm0
	psubd xmm2, xmm0
	psubd xmm3, xmm0
	psubd xmm4,xmm0
	;lddqu	xmm1, [rsi+8] 	;xmm1=(p1.x,p1.y,p2.x,p2.y)
	;lddqu	xmm2, [rsi+24]	;xmm2=(p3.x,p3.y,p4.x,p4.y)
	;psubd 	xmm1, xmm0 		;odejmowanie od kazdej wspolrzednej odpowiadajacej wspolrzednej p0
	;psubd	xmm2, xmm0
	
initializeConstants:
	;inicjalizacja roznych stałych występujących w algorytmie
	
	;wymnazam punkty przez odpowiednie dwumiany Newtona (p0 i p4 bez zmian bo (4 nad 0)=(4 nad 4)=1
	mov rax, 0x400000004
	movq xmm5, rax
	pmulld xmm1,xmm5		;xmm1=(0,0,4*p1.x,4*p1.y)
	cvtpi2ps xmm1, mm1
	pmulld xmm3,xmm5		;xmm3=(0,0,4*p3.x,4*p3.y)
	cvtpi2ps xmm3,mm3
	mov rax, 0x60000006
	movq xmm5, rax
	pmulld xmm2, xmm5		;xmm2=(0,0,6*p2.x,6*p2.y)
	cvtpi2ps xmm2, mm2
	
	mov rax, 0x3b8000003b800000
	movq xmm5, rax ; dt: xmm5=(0,0,1/256,1/256)
	mov rax, 0x3f8000003f800000
	movq xmm6, rax ; xmm6=(0,0,1.0,1.0)
	mov rax, 0x0
	movq xmm0, rax ; t = (0,0,0,0)
	mov r8, 256 ; licznik

	%define t xmm0
	%define dt xmm5
loop:
	
	
	paddd t,dt		;zwiekszenie t o 1 krok
	
	;kopie do obliczeń:
	;xmm9 - p3
	;xmm10 - p2
	;xmm11 - p1
	;xmm13 - p4
	
	;mnozenie przez potęgi t
	movaps xmm8, t ;t^1
	movaps xmm9, xmm3
	mulps xmm9, xmm8 ;p3*t
	
	mulps xmm8, t ;t^2
	movaps xmm10, xmm2
	mulps xmm10, xmm8 ;p2*t^2
	
	mulps xmm8, t ;t^3
	movaps xmm11, xmm1
	mulps xmm11, xmm8 ;p1*t^3
	
	;mnożenie przez potęgi (1-t)
	movaps xmm8, xmm6 ;1
	subps xmm8, t ;1-t
	movaps xmm14, xmm8 ; kopia 1-t do wymnazania dalej
	
	mulps xmm11,xmm8 ;p1*(1-t)
	
	mulps xmm8, xmm14 ;(1-t)^2
	mulps xmm10,xmm8 ;p2*(1-t)^2
	
	mulps xmm8,xmm14 ;(1-t)^3
	mulps xmm9,xmm8 ;p3*(1-t)^3
	
	mulps xmm8,xmm14 ;(1-t)^4
	mulps xmm13,xmm8 ;p4*(1-t)^4
	
	;sumowanie
	mov rax, 0x0
	movq xmm7, rax
	paddd xmm7,xmm9
	paddd xmm7,xmm10
	paddd xmm7,xmm11
	paddd xmm7,xmm13
	
	;zapisanie obliczonych wspolrzednych do oddzielnych rejestrow
	movq r11,xmm7
	mov r12d,r11d
	sar r11,32
	;r11 px; r12 py

setPixelOnFire:
	;zamalowywanie obliczonego pixela
	mov	rax, r15 	;szerokosc obrazka [B]
	imul	r12 	;rax = py*rax : offset py wysokości
	
	lea	rdi, [4*r11] ;offset po szerokości
	add	rdi, r10 
	add	rdi, rax
	xor	ax, ax
	stosb
	stosw
	
	dec	r8 ; zmniejszenie licznika
	jnz	loop
	
	%undef t
	%undef dt

end:
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	ret
	
