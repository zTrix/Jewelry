import sys, os
import random

f = open('fallrom.mif', 'w')

f.write('Depth = 256;\n')
f.write('Width = 9;\n')
f.write('Address_radix = hex;\n')
f.write('Data_radix = bin;\n')
f.write('Content\n')
f.write('Begin\n')


def genblock(r):
	t = random.randint(1, r)
	s = str(bin(t)[2:])
	while len(s) < 3:
		s = '0' + s
	return s

def gen():
	r = 5
	return genblock(r) + genblock(r) + genblock(r)

for i in range(0, 256):
	si = "%x" % i;
	if i < 16:si = '0' + si
	if i % 16 == 0: f.write('\n')
	f.write(si + '  : ' + gen() + ' ;' +  '\n')

f.write('\nEnd;\n')
