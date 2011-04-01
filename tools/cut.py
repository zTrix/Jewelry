table = [[0] * 8 for i in range(15)]
rec   = [[0] * 8 for i in range(15)]


table[1][4] = table[2][5] = table[3][6] = 1
table[1][6] = table[3][4] = 1
table[4][3] = table[5][2] = table[6][1] = 1

table[1][3] = table[2][2] = table[3][1] = 1

table[11][6] = table[12][5] = table[13][4] = 1

for i in range(1,14):
	print '%2d ' % i, table[i][1:7]
print ''

#~ for i in range(1,15):
	#~ start = end = 1
	#~ for j in range(2,8):
		#~ if table[i][j] and table[i][j] == table[i][j-1]:
			#~ end = j
		#~ else:
			#~ if end - start >= 2:
				#~ for k in range(start, end+1):
					#~ rec[i][k] = 1
			#~ end = start = j

#~ for i in range(1, 7):
	#~ start = end = 1
	#~ for j in range(2, 15):
		#~ if table[j][i] and table[j][i] == table[j-1][i]:
			#~ end = j
		#~ else:
			#~ if end - start >= 2:
				#~ for k in range(start, end+1):
					#~ rec[k][i] = 1
			#~ end = start = j

#~ for k in range(-10, 4):
	#~ if k <= 0:
		#~ start = end = 1-k
		#~ for row in range(1-k+1, 15):
			#~ if row + k > 7:
				#~ break
			#~ if table[row][row+k]>0 and table[row][row+k] == table[row-1][row+k-1]:
				#~ end = row
			#~ else:
				#~ if end - start >= 2:
					#~ for t in range(start, end+1):
						#~ rec[t][t+k] = 1
				#~ end = start = row
	#~ else:
		#~ start = end = 1
		#~ for row in range(2, 15):
			#~ if row + k > 7:break
			#~ if table[row][row+k] and table[row][row+k] == table[row-1][row+k-1]:
				#~ end = row
			#~ else:
				#~ if end - start >= 2:
					#~ for t in range(start, end+1):
						#~ rec[t][t+k] = 1
				#~ end = start = row

for k in range(4, 18):
	start = end = 1
	for row in range(1, 15):
		if k - row >= 0 and k - row <= 6:
			if table[row][k-row] and table[row][k-row] == table[row-1][k-row+1]:
				end = row
			else:
				if end - start >= 2:
					for t in range(start, end+1):
						rec[t][k-t] = 1
				end = start = row


for i in range(1,14):
	print '%2d ' % i, rec[i][1:7]
